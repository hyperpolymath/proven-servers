// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// stun.zig — Zig FFI implementation of proven-stun.
//
// Implements the STUN/TURN session primitive (RFC 8489) with:
//   - Slot-based session management (up to 64 concurrent sessions)
//   - Message type tracking (12 message types across binding, allocation,
//     refresh, and data relay operations)
//   - Transport protocol management (UDP/TCP/TLS/DTLS)
//   - Error code tracking (RFC 8489 Section 14.8)
//   - Send and receive counters
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)
//   - C header   (generated/abi/stun.h)

const std = @import("std");

// ── Enums (matching Idris2 STUNABI.Types tag assignments exactly) ────────

/// MessageType — matches messageTypeToTag
pub const MessageType = enum(u8) {
    binding_request = 0,
    binding_response = 1,
    binding_error = 2,
    allocate_request = 3,
    allocate_response = 4,
    allocate_error = 5,
    refresh_request = 6,
    refresh_response = 7,
    send_indication = 8,
    data_indication = 9,
    create_permission = 10,
    channel_bind = 11,
};

/// TransportProtocol — matches transportProtocolToTag
pub const TransportProtocol = enum(u8) {
    udp = 0,
    tcp = 1,
    tls = 2,
    dtls = 3,
};

/// ErrorCode — matches errorCodeToTag
pub const ErrorCode = enum(u8) {
    try_alternate = 0,
    bad_request = 1,
    unauthorized = 2,
    forbidden = 3,
    mobility_forbidden = 4,
    stale_nonce = 5,
    server_error = 6,
    insufficient_capacity = 7,
};

/// STUNError — error codes for FFI operations
pub const STUNError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_message_type = 3,
    invalid_transport = 4,
    invalid_error_code = 5,
};

// ── Session Context ─────────────────────────────────────────────────────

const SessionCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Transport protocol.
    transport: TransportProtocol,
    /// Last error code (255 = none).
    last_error: u8,
    /// Number of messages sent.
    send_count: u32,
    /// Number of messages received.
    recv_count: u32,
    /// Last sent message type (255 = none).
    last_sent: u8,
    /// Last received message type (255 = none).
    last_recv: u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: SessionCtx = .{
    .active = false,
    .transport = .udp,
    .last_error = 255,
    .send_count = 0,
    .recv_count = 0,
    .last_sent = 255,
    .last_recv = 255,
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

/// ABI version — must match STUNABI.Foreign.abiVersion (currently 1).
pub export fn stun_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new STUN/TURN session.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn stun_create(transport: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate transport (0-3)
    if (transport > 3) return -1;

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

/// Destroy a session, freeing its slot.
pub export fn stun_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the TransportProtocol tag for a slot.
/// Returns UDP (0) for invalid/inactive slots.
pub export fn stun_get_transport(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.transport);
}

/// Get the last error code tag (255 = none).
pub export fn stun_get_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

/// Get the number of messages sent.
pub export fn stun_get_send_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.send_count;
}

/// Get the number of messages received.
pub export fn stun_get_recv_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.recv_count;
}

/// Get the last sent message type tag (255 = none).
pub export fn stun_get_last_sent(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_sent;
}

/// Get the last received message type tag (255 = none).
pub export fn stun_get_last_recv(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_recv;
}

// ── Operations ──────────────────────────────────────────────────────────

/// Set the error code for a session.
/// Returns STUNError tag.
pub export fn stun_set_error(slot: c_int, err: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(STUNError.invalid_slot);

    if (err > 7) {
        return @intFromEnum(STUNError.invalid_error_code);
    }

    ctx.last_error = err;
    return @intFromEnum(STUNError.ok);
}

/// Clear the error state.
pub export fn stun_clear_error(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return;
    ctx.last_error = 255;
}

/// Send a STUN/TURN message of the given type.
/// Returns STUNError tag.
pub export fn stun_send_message(slot: c_int, msg: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(STUNError.invalid_slot);

    // Validate message type (0-11)
    if (msg > 11) {
        return @intFromEnum(STUNError.invalid_message_type);
    }

    ctx.last_sent = msg;
    ctx.send_count += 1;
    return @intFromEnum(STUNError.ok);
}

/// Record a received STUN/TURN message of the given type.
/// Returns STUNError tag.
pub export fn stun_receive_message(slot: c_int, msg: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(STUNError.invalid_slot);

    // Validate message type (0-11)
    if (msg > 11) {
        return @intFromEnum(STUNError.invalid_message_type);
    }

    ctx.last_recv = msg;
    ctx.recv_count += 1;
    return @intFromEnum(STUNError.ok);
}

/// Set the transport protocol for a session.
/// Returns STUNError tag.
pub export fn stun_set_transport(slot: c_int, t: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(STUNError.invalid_slot);

    if (t > 3) {
        return @intFromEnum(STUNError.invalid_transport);
    }

    ctx.transport = @enumFromInt(t);
    return @intFromEnum(STUNError.ok);
}
