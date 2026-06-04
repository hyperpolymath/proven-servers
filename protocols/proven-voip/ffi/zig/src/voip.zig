// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// voip.zig -- Zig FFI implementation of proven-voip.
//
// Implements the SIP/VoIP session state machine with:
//   - 64-slot mutex-protected session pool
//   - Dialog state tracking (Early/Confirmed/Terminated)
//   - SIP method request counting
//   - SIP response code tracking
//   - CSeq management (monotonically increasing)
//   - Registration binding tracking (max 16 per session)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching VoIPABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching VoIPABI.Types.idr tag assignments)
// =========================================================================

/// SIP methods (ABI tags 0-12).
pub const Method = enum(u8) {
    invite = 0,
    ack = 1,
    bye = 2,
    cancel = 3,
    register = 4,
    options = 5,
    info = 6,
    update = 7,
    subscribe = 8,
    notify = 9,
    refer = 10,
    message = 11,
    prack = 12,
};

/// SIP response codes (ABI tags 0-16).
pub const ResponseCode = enum(u8) {
    trying = 0,
    ringing = 1,
    session_progress = 2,
    ok = 3,
    multiple_choices = 4,
    moved_permanently = 5,
    moved_temporarily = 6,
    bad_request = 7,
    unauthorized = 8,
    forbidden = 9,
    not_found = 10,
    method_not_allowed = 11,
    request_timeout = 12,
    busy_here = 13,
    decline = 14,
    server_internal_error = 15,
    service_unavailable = 16,
};

/// Dialog states (ABI tags 0-2).
pub const DialogState = enum(u8) {
    early = 0,
    confirmed = 1,
    terminated = 2,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum registrations per session.
const MAX_REGISTRATIONS: usize = 16;

/// Maximum Call-ID / contact length.
const MAX_ID_LEN: usize = 256;

/// A registration binding.
const Registration = struct {
    contact: [MAX_ID_LEN]u8,
    contact_len: u32,
    expires: u32,
    active: bool,
};

/// Default (empty) registration.
const empty_registration: Registration = .{
    .contact = [_]u8{0} ** MAX_ID_LEN,
    .contact_len = 0,
    .expires = 0,
    .active = false,
};

/// A VoIP session.
const Session = struct {
    /// Current dialog state.
    state: DialogState,
    /// Call-ID for this session.
    call_id: [MAX_ID_LEN]u8,
    call_id_len: u32,
    /// Current CSeq number (monotonically increasing).
    cseq: u32,
    /// Total requests sent.
    request_count: u32,
    /// Total responses received.
    response_count: u32,
    /// Registration bindings.
    registrations: [MAX_REGISTRATIONS]Registration,
    /// Number of active registrations.
    registration_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .early,
    .call_id = [_]u8{0} ** MAX_ID_LEN,
    .call_id_len = 0,
    .cseq = 1,
    .request_count = 0,
    .response_count = 0,
    .registrations = [_]Registration{empty_registration} ** MAX_REGISTRATIONS,
    .registration_count = 0,
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

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn voip_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new VoIP session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Early state.
pub export fn voip_create(
    call_id_ptr: [*]const u8,
    call_id_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (call_id_len == 0 or call_id_len > MAX_ID_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.call_id[0..call_id_len], call_id_ptr[0..call_id_len]);
            s.call_id_len = call_id_len;
            s.state = .early;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn voip_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current DialogState tag for a session.
pub export fn voip_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Send a SIP request. Returns 0 on success, 1 on rejection.
pub export fn voip_send_request(slot: c_int, method: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (method > 12) return 1;

    // BYE only allowed from Confirmed state
    if (method == 2 and sessions[idx].state != .confirmed) return 1;
    // Cannot send requests from Terminated state
    if (sessions[idx].state == .terminated) return 1;

    sessions[idx].cseq += 1;
    sessions[idx].request_count += 1;
    return 0;
}

/// Receive a SIP response. Returns 0 on success, 1 on rejection.
pub export fn voip_recv_response(slot: c_int, code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (code > 16) return 1;
    if (sessions[idx].state == .terminated) return 1;

    sessions[idx].response_count += 1;
    return 0;
}

/// Confirm a dialog. Transitions Early -> Confirmed. Returns 0 on success.
pub export fn voip_confirm(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .early) return 1;

    sessions[idx].state = .confirmed;
    return 0;
}

/// Terminate a dialog. Returns 0 on success, 1 on rejection.
pub export fn voip_terminate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .terminated) return 1;

    sessions[idx].state = .terminated;
    return 0;
}

/// Returns current CSeq number.
pub export fn voip_cseq(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].cseq;
}

/// Register a contact binding. Returns 0 on success, 1 on rejection.
pub export fn voip_register(
    slot: c_int,
    contact_ptr: [*]const u8,
    contact_len: u32,
    expires: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (contact_len == 0 or contact_len > MAX_ID_LEN) return 1;

    for (&sessions[idx].registrations) |*reg| {
        if (!reg.active) {
            @memcpy(reg.contact[0..contact_len], contact_ptr[0..contact_len]);
            reg.contact_len = contact_len;
            reg.expires = expires;
            reg.active = true;
            sessions[idx].registration_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns number of active registrations.
pub export fn voip_registration_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].registration_count;
}

/// Returns number of requests sent.
pub export fn voip_request_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].request_count;
}

/// Returns number of responses received.
pub export fn voip_response_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].response_count;
}

/// Check if a dialog state transition is valid.
pub export fn voip_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Early -> Confirmed
    if (from == 0 and to == 2) return 1; // Early -> Terminated
    if (from == 1 and to == 2) return 1; // Confirmed -> Terminated
    return 0;
}
