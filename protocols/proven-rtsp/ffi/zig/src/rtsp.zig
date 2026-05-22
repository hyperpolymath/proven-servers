// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// rtsp.zig — Zig FFI implementation of proven-rtsp.
//
// Implements the RTSP (RFC 7826) session state machine with:
//   - Slot-based context management (up to 64 concurrent sessions)
//   - 4-state session machine (Init -> Ready -> Playing/Recording)
//   - Method validation per session state
//   - Transport protocol configuration
//   - Method counting and status code tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)

const std = @import("std");

// ── Enums (matching Idris2 Types.idr tag assignments exactly) ──────────

/// Method — matches methodToTag
pub const Method = enum(u8) {
    describe = 0,
    setup = 1,
    play = 2,
    pause = 3,
    teardown = 4,
    get_parameter = 5,
    set_parameter = 6,
    options = 7,
    announce = 8,
    record = 9,
    redirect = 10,
};

/// TransportProtocol — matches transportProtocolToTag
pub const TransportProtocol = enum(u8) {
    rtp_avp_udp = 0,
    rtp_avp_tcp = 1,
    rtp_avp_udp_multicast = 2,
};

/// SessionState — matches sessionStateToTag
pub const SessionState = enum(u8) {
    init = 0,
    ready = 1,
    playing = 2,
    recording = 3,
};

/// StatusCode — matches statusCodeToTag
pub const StatusCode = enum(u8) {
    ok = 0,
    moved_permanently = 1,
    moved_temporarily = 2,
    bad_request = 3,
    unauthorized = 4,
    not_found = 5,
    method_not_allowed = 6,
    not_acceptable = 7,
    session_not_found = 8,
    internal_server_error = 9,
    not_implemented = 10,
    service_unavailable = 11,
};

/// RTSPError — matches rtspErrorToTag
pub const RTSPError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    method_not_allowed = 4,
    transport_error = 5,
    session_expired = 6,
};

// ── Session Context instance ────────────────────────────────────────────

const SessionCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current session state.
    state: SessionState,
    /// Transport protocol for media delivery.
    transport: TransportProtocol,
    /// Last status code.
    last_status: StatusCode,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of methods executed.
    method_count: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: SessionCtx = .{
    .active = false,
    .state = .init,
    .transport = .rtp_avp_udp,
    .last_status = .ok,
    .last_error = 255,
    .method_count = 0,
};

var contexts: [MAX_CONTEXTS]SessionCtx = [_]SessionCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*SessionCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match RTSPABI.Foreign.abiVersion (currently 1).
pub export fn rtsp_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new RTSP session.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn rtsp_create(transport: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (transport > 2) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.transport = @enumFromInt(transport);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session context, freeing its slot.
pub export fn rtsp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current SessionState tag.
pub export fn rtsp_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the TransportProtocol tag.
pub export fn rtsp_get_transport(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.transport);
}

/// Get the method execution count.
pub export fn rtsp_get_method_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.method_count;
}

/// Get the last StatusCode tag.
pub export fn rtsp_get_last_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.last_status);
}

/// Get the last error tag, or 255 if no error.
pub export fn rtsp_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── State transitions ───────────────────────────────────────────────────

/// Check whether a session state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches RFC 7826 session state machine.
pub export fn rtsp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Init (0) -> Ready (1) (SETUP)
    if (from == 0 and to == 1) return 1;
    // Ready (1) -> Playing (2) (PLAY)
    if (from == 1 and to == 2) return 1;
    // Ready (1) -> Recording (3) (RECORD)
    if (from == 1 and to == 3) return 1;
    // Playing (2) -> Ready (1) (PAUSE)
    if (from == 2 and to == 1) return 1;
    // Recording (3) -> Ready (1) (PAUSE)
    if (from == 3 and to == 1) return 1;
    // Ready (1) -> Init (0) (TEARDOWN)
    if (from == 1 and to == 0) return 1;
    // Playing (2) -> Init (0) (TEARDOWN)
    if (from == 2 and to == 0) return 1;
    // Recording (3) -> Init (0) (TEARDOWN)
    if (from == 3 and to == 0) return 1;
    return 0;
}

/// Advance a session to a new state, validating the transition.
pub export fn rtsp_transition(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(RTSPError.invalid_slot);

    if (new_state > 3) {
        ctx.last_error = @intFromEnum(RTSPError.invalid_transition);
        return @intFromEnum(RTSPError.invalid_transition);
    }

    const from = @intFromEnum(ctx.state);
    if (rtsp_can_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(RTSPError.invalid_transition);
        return @intFromEnum(RTSPError.invalid_transition);
    }

    // Reset method count on teardown (back to Init)
    if (new_state == @intFromEnum(SessionState.init)) {
        ctx.method_count = 0;
    }

    ctx.state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(RTSPError.ok);
}

// ── Method execution ────────────────────────────────────────────────────

/// Execute an RTSP method.
pub export fn rtsp_execute_method(slot: c_int, method: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(RTSPError.invalid_slot);

    if (method > 10) {
        ctx.last_error = @intFromEnum(RTSPError.method_not_allowed);
        ctx.last_status = .method_not_allowed;
        return @intFromEnum(RTSPError.method_not_allowed);
    }

    const m: Method = @enumFromInt(method);

    // Validate method is allowed in current state
    const allowed = switch (ctx.state) {
        .init => switch (m) {
            .describe, .options, .setup, .announce => true,
            else => false,
        },
        .ready => switch (m) {
            .play, .record, .teardown, .setup, .options,
            .get_parameter, .set_parameter, .announce,
            => true,
            else => false,
        },
        .playing => switch (m) {
            .pause, .teardown, .options, .get_parameter,
            .set_parameter, .play,
            => true,
            else => false,
        },
        .recording => switch (m) {
            .pause, .teardown, .options, .get_parameter,
            .set_parameter, .record,
            => true,
            else => false,
        },
    };

    if (!allowed) {
        ctx.last_error = @intFromEnum(RTSPError.method_not_allowed);
        ctx.last_status = .method_not_allowed;
        return @intFromEnum(RTSPError.method_not_allowed);
    }

    ctx.method_count += 1;
    ctx.last_status = .ok;
    ctx.last_error = 255;
    return @intFromEnum(RTSPError.ok);
}
