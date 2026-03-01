// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// authconn.zig — Zig FFI implementation for proven-authconn.
//
// Skeleton implementation that enforces the authentication state machine at
// runtime.  Real authentication backends (LDAP, OAuth2, SAML) would replace
// the stub behaviour with actual protocol I/O.
//
// Tag values MUST match:
//   - Idris2:  src/AuthConnABI/Layout.idr
//   - C:       generated/abi/authconn.h

const std = @import("std");

// ---------------------------------------------------------------------------
// Constants (must match Idris2 AuthConn module and C header)
// ---------------------------------------------------------------------------

pub const ABI_VERSION: u32 = 1;
pub const MAX_TOKEN_LIFETIME: u32 = 3600;
pub const MAX_REFRESH_LIFETIME: u32 = 86400;
pub const MAX_LOGIN_ATTEMPTS: u16 = 5;
pub const LOCKOUT_DURATION: u32 = 900;

// ---------------------------------------------------------------------------
// Enum types (tags match C header and Idris2 Layout.idr exactly)
// ---------------------------------------------------------------------------

pub const AuthMethod = enum(u8) {
    password_hash = 0,
    certificate = 1,
    token = 2,
    mfa = 3,
    kerberos = 4,
    saml = 5,
    oidc = 6,
};

pub const AuthState = enum(u8) {
    unauthenticated = 0,
    challenging = 1,
    authenticated = 2,
    expired = 3,
    revoked = 4,
    locked = 5,
};

pub const TokenState = enum(u8) {
    valid = 0,
    expired = 1,
    revoked = 2,
    refreshing = 3,
};

pub const CredentialType = enum(u8) {
    opaque_ = 0,
    hashed = 1,
    encrypted = 2,
    delegated = 3,
};

pub const AuthError = enum(u8) {
    none = 0,
    invalid_credentials = 1,
    account_locked = 2,
    token_expired = 3,
    mfa_required = 4,
    provider_unavailable = 5,
    insufficient_scope = 6,
    session_expired = 7,
};

// ---------------------------------------------------------------------------
// Opaque handle structs
// ---------------------------------------------------------------------------

pub const SessionHandle = struct {
    state: AuthState,
    method: AuthMethod,
    failed_attempts: u16,
};

pub const TokenHandle = struct {
    session: *SessionHandle,
    state: TokenState,
};

// ---------------------------------------------------------------------------
// Allocator
// ---------------------------------------------------------------------------

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ---------------------------------------------------------------------------
// Exported C-ABI functions
// ---------------------------------------------------------------------------

/// Returns the ABI version.  Callers must verify this matches their expected
/// version before calling any other function.
pub export fn authconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new authentication session with the given method.
/// Returns NULL on allocation failure, sets *err.
pub export fn authconn_create_session(
    method: AuthMethod,
    err: *AuthError,
) callconv(.c) ?*SessionHandle {
    const handle = allocator.create(SessionHandle) catch {
        err.* = AuthError.provider_unavailable;
        return null;
    };
    handle.* = SessionHandle{
        .state = AuthState.unauthenticated,
        .method = method,
        .failed_attempts = 0,
    };
    err.* = AuthError.none;
    return handle;
}

/// Destroy a session handle, freeing its memory.
pub export fn authconn_destroy_session(h: ?*SessionHandle) callconv(.c) void {
    const handle = h orelse return;
    allocator.destroy(handle);
}

/// Query the current AuthState of a session.
/// Returns unauthenticated if h is NULL.
pub export fn authconn_session_state(h: ?*const SessionHandle) callconv(.c) AuthState {
    const handle = h orelse return AuthState.unauthenticated;
    return handle.state;
}

/// Attempt authentication with credentials.
/// Requires: CanAuthenticate (Unauthenticated state).
/// Transitions to Authenticated (direct auth) or Challenging (MFA) or Locked.
pub export fn authconn_authenticate(
    h: ?*SessionHandle,
    cred: ?*const anyopaque,
    cred_len: u32,
    cred_type: CredentialType,
) callconv(.c) AuthError {
    const handle = h orelse return AuthError.invalid_credentials;
    _ = cred;
    _ = cred_len;
    _ = cred_type;

    switch (handle.state) {
        .unauthenticated => {
            // Skeleton: MFA methods go to Challenging, others go direct
            switch (handle.method) {
                .mfa, .saml, .oidc => {
                    handle.state = AuthState.challenging;
                },
                else => {
                    handle.state = AuthState.authenticated;
                },
            }
            handle.failed_attempts = 0;
            return AuthError.none;
        },
        .challenging => return AuthError.invalid_credentials,
        .authenticated => return AuthError.invalid_credentials,
        .expired => return AuthError.session_expired,
        .revoked => return AuthError.session_expired,
        .locked => return AuthError.account_locked,
    }
}

/// Respond to an authentication challenge (e.g. MFA code, SAML assertion).
/// Requires: Challenging state.
/// Transitions to Authenticated on success, Unauthenticated on failure,
/// or Locked if too many failures.
pub export fn authconn_challenge_respond(
    h: ?*SessionHandle,
    response: ?*const anyopaque,
    resp_len: u32,
) callconv(.c) AuthError {
    const handle = h orelse return AuthError.invalid_credentials;
    _ = response;
    _ = resp_len;

    switch (handle.state) {
        .challenging => {
            // Skeleton: always succeed
            handle.state = AuthState.authenticated;
            handle.failed_attempts = 0;
            return AuthError.none;
        },
        .unauthenticated => return AuthError.invalid_credentials,
        .authenticated => return AuthError.invalid_credentials,
        .expired => return AuthError.session_expired,
        .revoked => return AuthError.session_expired,
        .locked => return AuthError.account_locked,
    }
}

/// Revoke an active session (logout / admin revocation).
/// Requires: Authenticated state.
/// Transitions to Revoked.
pub export fn authconn_revoke(h: ?*SessionHandle) callconv(.c) AuthError {
    const handle = h orelse return AuthError.invalid_credentials;

    switch (handle.state) {
        .authenticated => {
            handle.state = AuthState.revoked;
            return AuthError.none;
        },
        .unauthenticated, .challenging => return AuthError.invalid_credentials,
        .expired => return AuthError.session_expired,
        .revoked => return AuthError.session_expired,
        .locked => return AuthError.account_locked,
    }
}

/// Reset a session from Expired, Revoked, or Locked back to Unauthenticated.
pub export fn authconn_reset(h: ?*SessionHandle) callconv(.c) AuthError {
    const handle = h orelse return AuthError.invalid_credentials;

    switch (handle.state) {
        .expired, .revoked => {
            handle.state = AuthState.unauthenticated;
            handle.failed_attempts = 0;
            return AuthError.none;
        },
        .locked => {
            handle.state = AuthState.unauthenticated;
            handle.failed_attempts = 0;
            return AuthError.none;
        },
        .unauthenticated => return AuthError.none, // already there
        .challenging, .authenticated => return AuthError.invalid_credentials,
    }
}

/// Issue a token for an authenticated session.
/// Requires: CanAccessResource (Authenticated state).
/// Returns NULL on failure, sets *err.
pub export fn authconn_issue_token(
    h: ?*SessionHandle,
    err: *AuthError,
) callconv(.c) ?*TokenHandle {
    const handle = h orelse {
        err.* = AuthError.invalid_credentials;
        return null;
    };

    switch (handle.state) {
        .authenticated => {},
        .unauthenticated, .challenging => {
            err.* = AuthError.invalid_credentials;
            return null;
        },
        .expired => {
            err.* = AuthError.session_expired;
            return null;
        },
        .revoked => {
            err.* = AuthError.session_expired;
            return null;
        },
        .locked => {
            err.* = AuthError.account_locked;
            return null;
        },
    }

    const token = allocator.create(TokenHandle) catch {
        err.* = AuthError.provider_unavailable;
        return null;
    };
    token.* = TokenHandle{
        .session = handle,
        .state = TokenState.valid,
    };
    err.* = AuthError.none;
    return token;
}

/// Query the current TokenState.
/// Returns expired if t is NULL.
pub export fn authconn_token_state(t: ?*const TokenHandle) callconv(.c) TokenState {
    const token = t orelse return TokenState.expired;
    return token.state;
}

/// Refresh a token, returning a new token handle.
/// The old token handle becomes invalid (revoked).
/// Returns NULL on failure, sets *err.
pub export fn authconn_refresh_token(
    t: ?*TokenHandle,
    err: *AuthError,
) callconv(.c) ?*TokenHandle {
    const old = t orelse {
        err.* = AuthError.token_expired;
        return null;
    };

    switch (old.state) {
        .valid => {},
        .expired => {
            err.* = AuthError.token_expired;
            return null;
        },
        .revoked => {
            err.* = AuthError.token_expired;
            return null;
        },
        .refreshing => {
            err.* = AuthError.token_expired;
            return null;
        },
    }

    // Mark old token as refreshing, then create new one
    old.state = TokenState.refreshing;

    const new_token = allocator.create(TokenHandle) catch {
        old.state = TokenState.valid; // rollback
        err.* = AuthError.provider_unavailable;
        return null;
    };
    new_token.* = TokenHandle{
        .session = old.session,
        .state = TokenState.valid,
    };

    // Revoke old token
    old.state = TokenState.revoked;
    allocator.destroy(old);

    err.* = AuthError.none;
    return new_token;
}

/// Revoke and free a token handle.
pub export fn authconn_revoke_token(t: ?*TokenHandle) callconv(.c) void {
    const token = t orelse return;
    token.state = TokenState.revoked;
    allocator.destroy(token);
}
