// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ssh_bastion.zig -- Zig FFI implementation of proven-ssh-bastion.
//
// Implements the verified SSH bastion session state machine with:
//   - 64-slot session pool with per-slot mutex protection
//   - Key exchange state tracking
//   - Channel management (up to 10 channels per session)
//   - Audit log buffer (up to 256 entries per session)
//   - Session recording state
//   - Authentication failure tracking
//
// All enums match SSHABI.Layout.idr tag assignments exactly.

const std = @import("std");

// -- Enums (matching SSHABI.Layout.idr tag assignments) -----------------------

/// SSH message types relevant to bastion operation (8 tags, 0-7).
pub const SshMessageType = enum(u8) {
    kexinit = 0,
    newkeys = 1,
    service_request = 2,
    userauth_request = 3,
    channel_open = 4,
    channel_data = 5,
    channel_close = 6,
    disconnect = 7,
};

/// Authentication methods (4 tags, 0-3).
pub const AuthMethod = enum(u8) {
    publickey = 0,
    password = 1,
    keyboard_interactive = 2,
    auth_none = 3,
};

/// Key exchange algorithms (6 tags, 0-5).
pub const KexMethod = enum(u8) {
    diffie_hellman_group14_sha256 = 0,
    curve25519_sha256 = 1,
    diffie_hellman_group16_sha512 = 2,
    diffie_hellman_group18_sha512 = 3,
    ecdh_sha2_nistp256 = 4,
    ecdh_sha2_nistp384 = 5,
};

/// Channel types (4 tags, 0-3).
pub const ChannelType = enum(u8) {
    session = 0,
    direct_tcpip = 1,
    forwarded_tcpip = 2,
    x11 = 3,
};

/// Bastion session states (6 tags, 0-5).
/// Matches SSHABI.Transitions.BastionState.
pub const BastionState = enum(u8) {
    connected = 0,
    key_exchanged = 1,
    authenticated = 2,
    channel_open = 3,
    active = 4,
    closed = 5,
};

/// Channel states (4 tags, 0-3).
pub const ChannelState = enum(u8) {
    opening = 0,
    open = 1,
    closing = 2,
    closed = 3,
};

/// Disconnect reason codes (12 tags, 0-11).
pub const DisconnectReason = enum(u8) {
    host_not_allowed = 0,
    protocol_error = 1,
    key_exchange_failed = 2,
    host_auth_failed = 3,
    mac_error = 4,
    service_not_available = 5,
    version_not_supported = 6,
    host_key_not_verifiable = 7,
    connection_lost = 8,
    by_application = 9,
    too_many_connections = 10,
    auth_cancelled = 11,
};

/// Host key algorithms (4 tags, 0-3).
pub const HostKeyAlgorithm = enum(u8) {
    ssh_ed25519 = 0,
    rsa_sha2_256 = 1,
    rsa_sha2_512 = 2,
    ecdsa_nistp256 = 3,
};

/// Cipher algorithms (6 tags, 0-5).
pub const CipherAlgorithm = enum(u8) {
    chacha20_poly1305 = 0,
    aes256_gcm = 1,
    aes128_gcm = 2,
    aes256_ctr = 3,
    aes192_ctr = 4,
    aes128_ctr = 5,
};

/// Channel open failure codes (4 tags, 0-3).
pub const ChannelOpenFailure = enum(u8) {
    admin_prohibited = 0,
    connect_failed = 1,
    unknown_channel_type = 2,
    resource_shortage = 3,
};

// -- Audit log entry ----------------------------------------------------------

/// A single audit log entry recording a state transition.
const AuditEntry = struct {
    /// State before the transition
    from_state: BastionState,
    /// State after the transition
    to_state: BastionState,
    /// Monotonic sequence number (acts as logical timestamp)
    sequence: u32,
};

// -- Channel record -----------------------------------------------------------

const MAX_CHANNELS: usize = 10;

/// A single SSH channel within a session.
const ChannelRecord = struct {
    channel_type: ChannelType,
    state: ChannelState,
    active: bool,
};

const default_channel: ChannelRecord = .{
    .channel_type = .session,
    .state = .closed,
    .active = false,
};

// -- Session ------------------------------------------------------------------

const MAX_AUDIT_ENTRIES: usize = 256;

/// An SSH bastion session with full state tracking.
const Session = struct {
    /// Current bastion state
    state: BastionState,
    /// Configured key exchange method
    kex_method: KexMethod,
    /// Configured authentication method
    auth_method: AuthMethod,
    /// Whether the session slot is in use
    active: bool,
    /// Whether session recording is enabled
    recording: bool,
    /// Number of failed authentication attempts
    auth_failures: u8,
    /// Disconnect reason (255 = not disconnected)
    disconnect_reason: u8,
    /// Channels for this session
    channels: [MAX_CHANNELS]ChannelRecord,
    /// Audit log buffer
    audit_log: [MAX_AUDIT_ENTRIES]AuditEntry,
    /// Number of audit entries recorded
    audit_count: u32,
    /// Monotonic sequence counter for audit entries
    audit_sequence: u32,
};

const default_session: Session = .{
    .state = .connected,
    .kex_method = .curve25519_sha256,
    .auth_method = .publickey,
    .active = false,
    .recording = false,
    .auth_failures = 0,
    .disconnect_reason = 255,
    .channels = [_]ChannelRecord{default_channel} ** MAX_CHANNELS,
    .audit_log = [_]AuditEntry{.{
        .from_state = .closed,
        .to_state = .closed,
        .sequence = 0,
    }} ** MAX_AUDIT_ENTRIES,
    .audit_count = 0,
    .audit_sequence = 0,
};

// -- Session pool (64 slots, per-slot mutex) ----------------------------------

const MAX_SESSIONS: usize = 64;

var sessions: [MAX_SESSIONS]Session = [_]Session{default_session} ** MAX_SESSIONS;
var mutexes: [MAX_SESSIONS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_SESSIONS;

/// Validate a slot index and return it as usize if the session is active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

/// Record an audit log entry for a state transition.
fn recordAudit(idx: usize, from: BastionState, to: BastionState) void {
    const s = &sessions[idx];
    if (s.audit_count < MAX_AUDIT_ENTRIES) {
        s.audit_log[s.audit_count] = .{
            .from_state = from,
            .to_state = to,
            .sequence = s.audit_sequence,
        };
        s.audit_count += 1;
    }
    s.audit_sequence += 1;
}

/// Count active (non-closed) channels in a session.
fn countActiveChannels(idx: usize) u8 {
    var count: u8 = 0;
    for (&sessions[idx].channels) |*ch| {
        if (ch.active and ch.state != .closed) {
            count += 1;
        }
    }
    return count;
}

// -- ABI version --------------------------------------------------------------

pub export fn ssh_bastion_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new SSH bastion session.
/// Returns the slot index (0-63) or -1 if no slots available or invalid args.
pub export fn ssh_bastion_create(kex_method: u8, auth_method: u8) callconv(.c) c_int {
    if (kex_method > 5) return -1;
    if (auth_method > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        mutexes[i].lock();
        const was_active = s.active;
        if (!was_active) {
            s.* = default_session;
            s.state = .connected;
            s.kex_method = @enumFromInt(kex_method);
            s.auth_method = @enumFromInt(auth_method);
            s.active = true;
            recordAudit(i, .closed, .connected);
        }
        mutexes[i].unlock();
        if (!was_active) return @intCast(i);
    }
    return -1; // no free slots
}

/// Destroy (release) a session slot.
pub export fn ssh_bastion_destroy(slot: c_int) callconv(.c) void {
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    sessions[idx].active = false;
}

// -- State queries ------------------------------------------------------------

/// Get the current bastion state of a session.
pub export fn ssh_bastion_state(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 5; // closed fallback
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 5;
    return @intFromEnum(sessions[i].state);
}

/// Get the configured key exchange method.
pub export fn ssh_bastion_kex_method(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    return @intFromEnum(sessions[i].kex_method);
}

/// Get the configured authentication method.
pub export fn ssh_bastion_auth_method(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    return @intFromEnum(sessions[i].auth_method);
}

/// Check whether data transfer is allowed (session must be Active).
pub export fn ssh_bastion_can_transfer(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 0;
    return if (sessions[i].state == .active) 1 else 0;
}

/// Get the disconnect reason (255 = not disconnected).
pub export fn ssh_bastion_disconnect_reason(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    return sessions[i].disconnect_reason;
}

/// Get the number of failed authentication attempts.
pub export fn ssh_bastion_auth_failures(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    return sessions[i].auth_failures;
}

// -- Transitions --------------------------------------------------------------

/// Complete key exchange: Connected -> KeyExchanged.
pub export fn ssh_bastion_complete_kex(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    if (sessions[i].state != .connected) return 1;
    const old_state = sessions[i].state;
    sessions[i].state = .key_exchanged;
    recordAudit(i, old_state, .key_exchanged);
    return 0;
}

/// Complete authentication: KeyExchanged -> Authenticated.
/// user_len is the length of the username (for logging purposes; the actual
/// username is managed by the caller).
pub export fn ssh_bastion_authenticate(slot: c_int, user_len: u16) callconv(.c) u8 {
    _ = user_len;
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    if (sessions[i].state != .key_exchanged) return 1;
    const old_state = sessions[i].state;
    sessions[i].state = .authenticated;
    recordAudit(i, old_state, .authenticated);
    return 0;
}

/// Record a failed authentication attempt.
/// Returns 1 if locked out (3+ failures), 0 otherwise.
pub export fn ssh_bastion_record_auth_failure(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    if (sessions[i].auth_failures < 255) {
        sessions[i].auth_failures += 1;
    }
    return if (sessions[i].auth_failures >= 3) 1 else 0;
}

/// Open a channel: Authenticated -> ChannelOpen, or Active -> Active.
/// Returns the channel ID (0-9) or -1 on failure.
pub export fn ssh_bastion_open_channel(slot: c_int, ch_type: u8) callconv(.c) c_int {
    if (slot < 0 or slot >= MAX_SESSIONS) return -1;
    if (ch_type > 3) return -1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return -1;
    const s = &sessions[i];

    // Can only open channels from Authenticated or Active states
    if (s.state != .authenticated and s.state != .active) return -1;

    // Find a free channel slot
    for (&s.channels, 0..) |*ch, ci| {
        if (!ch.active) {
            ch.* = .{
                .channel_type = @enumFromInt(ch_type),
                .state = .opening,
                .active = true,
            };
            const old_state = s.state;
            if (s.state == .authenticated) {
                s.state = .channel_open;
            }
            // Active stays Active (additional channel)
            recordAudit(i, old_state, s.state);
            return @intCast(ci);
        }
    }
    return -1; // no free channel slots
}

/// Confirm a channel: ChannelOpen -> Active.
pub export fn ssh_bastion_confirm_channel(slot: c_int, ch_id: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    if (ch_id >= MAX_CHANNELS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    const s = &sessions[i];
    const ch = &s.channels[ch_id];

    if (!ch.active or ch.state != .opening) return 1;

    ch.state = .open;
    const old_state = s.state;
    if (s.state == .channel_open) {
        s.state = .active;
    }
    recordAudit(i, old_state, s.state);
    return 0;
}

/// Close a specific channel.
pub export fn ssh_bastion_close_channel(slot: c_int, ch_id: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    if (ch_id >= MAX_CHANNELS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    const ch = &sessions[i].channels[ch_id];

    if (!ch.active or ch.state == .closed) return 1;

    ch.state = .closed;
    ch.active = false;
    return 0;
}

/// Get the state of a specific channel.
pub export fn ssh_bastion_channel_state(slot: c_int, ch_id: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 3; // closed fallback
    if (ch_id >= MAX_CHANNELS) return 3;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 3;
    const ch = &sessions[i].channels[ch_id];
    if (!ch.active) return 3;
    return @intFromEnum(ch.state);
}

/// Get the type of a specific channel.
pub export fn ssh_bastion_channel_type(slot: c_int, ch_id: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    if (ch_id >= MAX_CHANNELS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    const ch = &sessions[i].channels[ch_id];
    if (!ch.active) return 255;
    return @intFromEnum(ch.channel_type);
}

/// Get the count of active (non-closed) channels.
pub export fn ssh_bastion_channel_count(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 0;
    return countActiveChannels(i);
}

/// Re-key: Active -> Active.
pub export fn ssh_bastion_rekey(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    if (sessions[i].state != .active) return 1;
    recordAudit(i, .active, .active);
    return 0;
}

/// Disconnect: any non-Closed state -> Closed.
pub export fn ssh_bastion_disconnect(slot: c_int, reason: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    if (reason > 11) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    if (sessions[i].state == .closed) return 1;
    const old_state = sessions[i].state;
    sessions[i].state = .closed;
    sessions[i].disconnect_reason = reason;
    // Close all active channels
    for (&sessions[i].channels) |*ch| {
        if (ch.active) {
            ch.state = .closed;
            ch.active = false;
        }
    }
    recordAudit(i, old_state, .closed);
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check whether a state transition is valid (stateless query).
/// Matches SSHABI.Transitions.validateBastionTransition exactly.
pub export fn ssh_bastion_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Connected(0) -> KeyExchanged(1)
    if (from == 0 and to == 1) return 1;
    // KeyExchanged(1) -> Authenticated(2)
    if (from == 1 and to == 2) return 1;
    // Authenticated(2) -> ChannelOpen(3)
    if (from == 2 and to == 3) return 1;
    // ChannelOpen(3) -> Active(4)
    if (from == 3 and to == 4) return 1;
    // Active(4) -> Active(4) (rekey/data/additional channel)
    if (from == 4 and to == 4) return 1;
    // Active(4) -> Closed(5)
    if (from == 4 and to == 5) return 1;
    // Abort edges: any non-Closed -> Closed
    if (from == 0 and to == 5) return 1;
    if (from == 1 and to == 5) return 1;
    if (from == 2 and to == 5) return 1;
    if (from == 3 and to == 5) return 1;
    return 0;
}

// -- Audit log ----------------------------------------------------------------

/// Get the number of audit log entries for a session.
pub export fn ssh_bastion_audit_count(slot: c_int) callconv(.c) u32 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 0;
    return sessions[i].audit_count;
}

/// Read a specific audit log entry (returns the from_state tag).
pub export fn ssh_bastion_audit_entry(slot: c_int, entry_idx: u32) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    if (entry_idx >= sessions[i].audit_count) return 255;
    return @intFromEnum(sessions[i].audit_log[entry_idx].from_state);
}

/// Read the to_state of a specific audit log entry.
pub export fn ssh_bastion_audit_entry_to(slot: c_int, entry_idx: u32) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 255;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 255;
    if (entry_idx >= sessions[i].audit_count) return 255;
    return @intFromEnum(sessions[i].audit_log[entry_idx].to_state);
}

// -- Session recording --------------------------------------------------------

/// Enable or disable session recording.
pub export fn ssh_bastion_set_recording(slot: c_int, enabled: u8) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 1;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 1;
    sessions[i].recording = (enabled != 0);
    return 0;
}

/// Check whether session recording is active.
pub export fn ssh_bastion_is_recording(slot: c_int) callconv(.c) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const i = validSlot(slot) orelse return 0;
    return if (sessions[i].recording) 1 else 0;
}
