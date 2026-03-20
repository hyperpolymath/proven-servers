// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// authserver.zig -- Zig FFI implementation of proven-authserver.
//
// Implements the authentication server state machine with:
//   - 64-slot mutex-protected session pool
//   - Authentication attempts with 8 configurable methods
//   - MFA challenge/response workflow (5 MFA methods)
//   - Token issuance tracking (max 32 tokens per session)
//   - Session lifecycle: Active -> Expired/Revoked/Locked
//   - Failed attempt tracking with automatic lockout (max 5)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching AuthserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching AuthserverABI.Types.idr tag assignments)
// =========================================================================

/// Authentication methods (ABI tags 0-7).
pub const AuthMethod = enum(u8) {
    password = 0,
    certificate = 1,
    oauth2 = 2,
    saml = 3,
    fido2 = 4,
    kerberos = 5,
    ldap = 6,
    radius = 7,
};

/// Token types (ABI tags 0-3).
pub const TokenType = enum(u8) {
    access = 0,
    refresh = 1,
    id = 2,
    api = 3,
};

/// Authentication results (ABI tags 0-5).
pub const AuthResult = enum(u8) {
    success = 0,
    invalid_credentials = 1,
    account_locked = 2,
    account_expired = 3,
    mfa_required = 4,
    ip_blocked = 5,
};

/// MFA methods (ABI tags 0-4).
pub const MFAMethod = enum(u8) {
    totp = 0,
    sms = 1,
    push = 2,
    fido2_mfa = 3,
    email = 4,
};

/// Session states (ABI tags 0-3).
pub const SessionState = enum(u8) {
    active = 0,
    expired = 1,
    revoked = 2,
    locked = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum tokens per session.
const MAX_TOKENS: usize = 32;

/// Maximum failed attempts before lockout.
const MAX_FAILED_ATTEMPTS: u32 = 5;

/// A token record.
const Token = struct {
    /// Token type.
    token_type: TokenType,
    /// Whether this token is active.
    active: bool,
};

/// Default (empty) token.
const empty_token: Token = .{
    .token_type = .access,
    .active = false,
};

/// An authentication session.
const Session = struct {
    /// Current session state.
    state: SessionState,
    /// Primary authentication method used to create this session.
    auth_method: AuthMethod,
    /// Whether MFA is required for this session.
    mfa_required: bool,
    /// MFA method required (valid if mfa_required is true).
    mfa_method: MFAMethod,
    /// Whether MFA has been verified.
    mfa_verified: bool,
    /// Issued tokens.
    tokens: [MAX_TOKENS]Token,
    /// Number of active tokens.
    token_count: u32,
    /// Number of failed authentication attempts.
    failed_attempts: u32,
    /// Total successful authentications.
    auth_count: u64,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .active,
    .auth_method = .password,
    .mfa_required = false,
    .mfa_method = .totp,
    .mfa_verified = false,
    .tokens = [_]Token{empty_token} ** MAX_TOKENS,
    .token_count = 0,
    .failed_attempts = 0,
    .auth_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn authserver_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new authentication session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Active state.
pub export fn authserver_create(method: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (method > 7) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.auth_method = @enumFromInt(method);
            s.state = .active;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn authserver_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries ------------------------------------------------------------

/// Returns the current SessionState tag.
pub export fn authserver_session_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // active fallback
    return @intFromEnum(sessions[idx].state);
}

// -- Authentication -----------------------------------------------------------

/// Attempt authentication. Returns AuthResult tag.
/// Tracks failed attempts and auto-locks after MAX_FAILED_ATTEMPTS.
pub export fn authserver_authenticate(slot: c_int, method: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(AuthResult.invalid_credentials);
    if (sessions[idx].state != .active) {
        if (sessions[idx].state == .locked) return @intFromEnum(AuthResult.account_locked);
        if (sessions[idx].state == .expired) return @intFromEnum(AuthResult.account_expired);
        return @intFromEnum(AuthResult.invalid_credentials);
    }
    if (method > 7) return @intFromEnum(AuthResult.invalid_credentials);

    // Check if already locked out from too many failures
    if (sessions[idx].failed_attempts >= MAX_FAILED_ATTEMPTS) {
        sessions[idx].state = .locked;
        return @intFromEnum(AuthResult.account_locked);
    }

    const req_method: AuthMethod = @enumFromInt(method);

    // Simulate auth: method must match session's configured method
    if (req_method != sessions[idx].auth_method) {
        sessions[idx].failed_attempts += 1;
        if (sessions[idx].failed_attempts >= MAX_FAILED_ATTEMPTS) {
            sessions[idx].state = .locked;
            return @intFromEnum(AuthResult.account_locked);
        }
        return @intFromEnum(AuthResult.invalid_credentials);
    }

    // Check if MFA is required and not yet verified
    if (sessions[idx].mfa_required and !sessions[idx].mfa_verified) {
        return @intFromEnum(AuthResult.mfa_required);
    }

    sessions[idx].auth_count += 1;
    return @intFromEnum(AuthResult.success);
}

// -- MFA ----------------------------------------------------------------------

/// Set MFA requirement on a session. Returns 0 on success, 1 on rejection.
pub export fn authserver_require_mfa(slot: c_int, mfa_method: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (mfa_method > 4) return 1;

    sessions[idx].mfa_required = true;
    sessions[idx].mfa_method = @enumFromInt(mfa_method);
    sessions[idx].mfa_verified = false;
    return 0;
}

/// Verify MFA challenge. Returns 0 on success, 1 on rejection.
pub export fn authserver_verify_mfa(slot: c_int, mfa_method: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (!sessions[idx].mfa_required) return 1;
    if (mfa_method > 4) return 1;

    const req_mfa: MFAMethod = @enumFromInt(mfa_method);
    if (req_mfa != sessions[idx].mfa_method) return 1;

    sessions[idx].mfa_verified = true;
    return 0;
}

// -- Token management ---------------------------------------------------------

/// Issue a token. Returns 0 on success, 1 on rejection.
/// Only allowed for Active sessions.
pub export fn authserver_issue_token(slot: c_int, token_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (token_type > 3) return 1;

    // Find free token slot
    for (&sessions[idx].tokens) |*t| {
        if (!t.active) {
            t.token_type = @enumFromInt(token_type);
            t.active = true;
            sessions[idx].token_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active tokens.
pub export fn authserver_token_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].token_count;
}

// -- Session state transitions ------------------------------------------------

/// Revoke a session. Returns 0 on success, 1 on rejection.
/// Transitions: Active -> Revoked.
pub export fn authserver_revoke_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;

    sessions[idx].state = .revoked;
    return 0;
}

/// Expire a session. Returns 0 on success, 1 on rejection.
/// Transitions: Active -> Expired.
pub export fn authserver_expire_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;

    sessions[idx].state = .expired;
    return 0;
}

/// Lock a session. Returns 0 on success, 1 on rejection.
/// Transitions: Active -> Locked.
pub export fn authserver_lock_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;

    sessions[idx].state = .locked;
    return 0;
}

/// Returns the number of failed authentication attempts.
pub export fn authserver_failed_attempts(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].failed_attempts;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a session state transition is valid.
pub export fn authserver_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Active -> Expired
    if (from == 0 and to == 2) return 1; // Active -> Revoked
    if (from == 0 and to == 3) return 1; // Active -> Locked
    return 0;
}
