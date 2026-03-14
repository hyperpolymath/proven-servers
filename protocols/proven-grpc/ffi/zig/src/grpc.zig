// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// grpc.zig -- Zig FFI implementation of proven-grpc.
//
// Implements verified HTTP/2 stream state machine for gRPC with:
//   - Slot-based context management (up to 64 concurrent)
//   - Stream state machine enforcement matching Idris2 Transitions.idr
//   - Flow control window tracking (RFC 7540 section 6.9)
//   - Thread-safe via mutex
//   - gRPC status code recording

const std = @import("std");

// -- Enums (matching GRPCABI.Layout.idr tag assignments) ----------------------

/// HTTP/2 frame types used by gRPC (9 constructors, tags 0-8).
pub const FrameType = enum(u8) {
    data = 0,
    headers = 1,
    rst_stream = 2,
    settings = 3,
    push_promise = 4,
    ping = 5,
    goaway = 6,
    window_update = 7,
    continuation = 8,
};

/// HTTP/2 stream states per RFC 7540 (6 constructors, tags 0-5).
pub const StreamState = enum(u8) {
    idle = 0,
    open = 1,
    half_closed_local = 2,
    half_closed_remote = 3,
    closed = 4,
    reserved = 5,
};

/// gRPC status codes (17 constructors, tags 0-16).
pub const StatusCode = enum(u8) {
    ok = 0,
    cancelled = 1,
    unknown = 2,
    invalid_argument = 3,
    deadline_exceeded = 4,
    not_found = 5,
    already_exists = 6,
    permission_denied = 7,
    resource_exhausted = 8,
    failed_precondition = 9,
    aborted = 10,
    out_of_range = 11,
    unimplemented = 12,
    internal = 13,
    unavailable = 14,
    data_loss = 15,
    unauthenticated = 16,
};

/// gRPC compression algorithms (5 constructors, tags 0-4).
pub const Compression = enum(u8) {
    identity = 0,
    gzip = 1,
    deflate = 2,
    snappy = 3,
    zstd = 4,
};

/// gRPC stream cardinality types (4 constructors, tags 0-3).
pub const StreamType = enum(u8) {
    unary = 0,
    server_streaming = 1,
    client_streaming = 2,
    bidi_streaming = 3,
};

/// gRPC content type encodings (2 constructors, tags 0-1).
pub const ContentType = enum(u8) {
    protobuf = 0,
    json = 1,
};

// -- Constants ----------------------------------------------------------------

/// Default HTTP/2 initial window size (RFC 7540 section 6.9.2): 65,535 bytes.
const DEFAULT_WINDOW_SIZE: i32 = 65535;

/// Maximum number of concurrent gRPC contexts (slot pool size).
const MAX_CONTEXTS: usize = 64;

// -- gRPC context -------------------------------------------------------------

/// A single gRPC context representing one HTTP/2 stream.
const Context = struct {
    /// Current HTTP/2 stream state.
    stream_state: StreamState,
    /// Compression algorithm for this context.
    compression: Compression,
    /// gRPC status code (255 = not yet set).
    status_code: u8,
    /// Send-direction flow control window (bytes remaining).
    send_window: i32,
    /// Receive-direction flow control window (bytes remaining).
    recv_window: i32,
    /// HTTP/2 stream identifier (odd for client-initiated).
    stream_id: u32,
    /// Whether this slot is in use.
    active: bool,
};

/// Pool of gRPC contexts, indexed by slot number.
var contexts: [MAX_CONTEXTS]Context = [_]Context{.{
    .stream_state = .idle,
    .compression = .identity,
    .status_code = 255,
    .send_window = DEFAULT_WINDOW_SIZE,
    .recv_window = DEFAULT_WINDOW_SIZE,
    .stream_id = 0,
    .active = false,
}} ** MAX_CONTEXTS;

/// Mutex protecting the context pool from concurrent access.
var mutex: std.Thread.Mutex = .{};

/// Next stream ID to assign (odd numbers for client-initiated streams).
var next_stream_id: u32 = 1;

/// Validate a slot index and return it as usize if active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number.  Must match GRPCABI.Foreign.abiVersion.
pub export fn grpc_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new gRPC context with the given compression algorithm.
/// Returns a non-negative slot index on success, or -1 if the pool is full
/// or the compression tag is invalid.
pub export fn grpc_create(compression: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (compression > 4) return -1; // invalid Compression tag
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            const sid = next_stream_id;
            next_stream_id +%= 2; // odd stream IDs, wrapping
            ctx.* = .{
                .stream_state = .idle,
                .compression = @enumFromInt(compression),
                .status_code = 255,
                .send_window = DEFAULT_WINDOW_SIZE,
                .recv_window = DEFAULT_WINDOW_SIZE,
                .stream_id = sid,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

/// Destroy a gRPC context, freeing its slot for reuse.
/// Safe to call with invalid or already-destroyed slots.
pub export fn grpc_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)].active = false;
}

// -- State queries ------------------------------------------------------------

/// Returns the current stream state tag for the given slot.
/// Returns 4 (Closed) for invalid slots as a safe fallback.
pub export fn grpc_stream_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // closed fallback
    return @intFromEnum(contexts[idx].stream_state);
}

/// Returns the compression algorithm tag for the given slot.
/// Returns 255 for invalid slots.
pub export fn grpc_compression(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return @intFromEnum(contexts[idx].compression);
}

/// Returns the gRPC status code tag for the given slot.
/// Returns 255 (not set) for invalid slots.
pub export fn grpc_status_code(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].status_code;
}

/// Records a gRPC status code on the given slot.
/// Returns 0 on success, 1 if the slot is invalid or the status tag is out of range.
pub export fn grpc_set_status(slot: c_int, status: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (status > 16) return 1; // invalid StatusCode tag
    contexts[idx].status_code = status;
    return 0;
}

/// Returns the HTTP/2 stream identifier for the given slot.
/// Returns 0 for invalid slots.
pub export fn grpc_stream_id(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].stream_id;
}

// -- Stream state transitions -------------------------------------------------

/// Idle -> Open: send or receive initial HEADERS.
/// Returns 0 on success, 1 if rejected (not in Idle state).
pub export fn grpc_send_headers(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .idle) return 1;
    contexts[idx].stream_state = .open;
    return 0;
}

/// Open -> HalfClosedLocal: local side sends END_STREAM.
/// Returns 0 on success, 1 if rejected (not in Open state).
pub export fn grpc_local_end_stream(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .open) return 1;
    contexts[idx].stream_state = .half_closed_local;
    return 0;
}

/// Open -> HalfClosedRemote: remote side sends END_STREAM.
/// Returns 0 on success, 1 if rejected (not in Open state).
pub export fn grpc_remote_end_stream(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .open) return 1;
    contexts[idx].stream_state = .half_closed_remote;
    return 0;
}

/// RST_STREAM: move to Closed from Open, HalfClosedLocal, HalfClosedRemote,
/// or Reserved.  Records the given status code.
/// Returns 0 on success, 1 if rejected (Idle or already Closed).
pub export fn grpc_reset_stream(slot: c_int, status: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = contexts[idx].stream_state;
    // Can reset from Open, HalfClosedLocal, HalfClosedRemote, Reserved
    if (state == .idle or state == .closed) return 1;
    if (status <= 16) contexts[idx].status_code = status;
    contexts[idx].stream_state = .closed;
    return 0;
}

/// HalfClosedLocal -> Closed: remote sends END_STREAM or RST_STREAM.
/// Returns 0 on success, 1 if rejected (not in HalfClosedLocal state).
pub export fn grpc_close_half_local(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .half_closed_local) return 1;
    contexts[idx].stream_state = .closed;
    return 0;
}

/// HalfClosedRemote -> Closed: local sends END_STREAM or RST_STREAM.
/// Returns 0 on success, 1 if rejected (not in HalfClosedRemote state).
pub export fn grpc_close_half_remote(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .half_closed_remote) return 1;
    contexts[idx].stream_state = .closed;
    return 0;
}

/// Idle -> Reserved: received PUSH_PROMISE frame.
/// Returns 0 on success, 1 if rejected (not in Idle state).
pub export fn grpc_push_promise(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .idle) return 1;
    contexts[idx].stream_state = .reserved;
    return 0;
}

/// Reserved -> HalfClosedRemote: server sends HEADERS to open push stream.
/// Returns 0 on success, 1 if rejected (not in Reserved state).
pub export fn grpc_reserved_to_half(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].stream_state != .reserved) return 1;
    contexts[idx].stream_state = .half_closed_remote;
    return 0;
}

// -- Capability queries -------------------------------------------------------

/// Whether local side can send DATA frames.
/// True for Open (1) and HalfClosedRemote (3).
/// Returns 1 if yes, 0 if no.
pub export fn grpc_can_send(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = contexts[idx].stream_state;
    return if (state == .open or state == .half_closed_remote) 1 else 0;
}

/// Whether remote side can send DATA frames (i.e., local can receive).
/// True for Open (1) and HalfClosedLocal (2).
/// Returns 1 if yes, 0 if no.
pub export fn grpc_can_receive(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = contexts[idx].stream_state;
    return if (state == .open or state == .half_closed_local) 1 else 0;
}

// -- Flow control -------------------------------------------------------------

/// Returns the current send flow control window (bytes remaining).
/// Returns -1 for invalid slots.
pub export fn grpc_send_window(slot: c_int) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    return contexts[idx].send_window;
}

/// Returns the current receive flow control window (bytes remaining).
/// Returns -1 for invalid slots.
pub export fn grpc_recv_window(slot: c_int) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    return contexts[idx].recv_window;
}

/// Adjusts the send flow control window by delta bytes.
/// Positive delta = WINDOW_UPDATE received; negative = DATA sent.
/// Returns 0 on success, 1 if invalid slot or resulting window overflows i32.
pub export fn grpc_update_send_window(slot: c_int, delta: i32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const result = @as(i64, contexts[idx].send_window) + @as(i64, delta);
    // RFC 7540 section 6.9.1: window size must not exceed 2^31-1
    if (result > 2147483647 or result < -2147483648) return 1;
    contexts[idx].send_window = @intCast(result);
    return 0;
}

/// Adjusts the receive flow control window by delta bytes.
/// Positive delta = WINDOW_UPDATE sent; negative = DATA received.
/// Returns 0 on success, 1 if invalid slot or resulting window overflows i32.
pub export fn grpc_update_recv_window(slot: c_int, delta: i32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const result = @as(i64, contexts[idx].recv_window) + @as(i64, delta);
    if (result > 2147483647 or result < -2147483648) return 1;
    contexts[idx].recv_window = @intCast(result);
    return 0;
}

// -- Stateless queries --------------------------------------------------------

/// Check whether a stream state transition is valid.
/// Matches Transitions.idr validateStreamTransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn grpc_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> Open(1): SendHeaders
    if (from == 0 and to == 1) return 1;
    // Open(1) -> HalfClosedLocal(2): LocalEndStream
    if (from == 1 and to == 2) return 1;
    // Open(1) -> HalfClosedRemote(3): RemoteEndStream
    if (from == 1 and to == 3) return 1;
    // Open(1) -> Closed(4): ResetFromOpen
    if (from == 1 and to == 4) return 1;
    // HalfClosedLocal(2) -> Closed(4): CloseHalfLocal
    if (from == 2 and to == 4) return 1;
    // HalfClosedRemote(3) -> Closed(4): CloseHalfRemote
    if (from == 3 and to == 4) return 1;
    // Idle(0) -> Reserved(5): PushPromiseRecv
    if (from == 0 and to == 5) return 1;
    // Reserved(5) -> HalfClosedRemote(3): ReservedToHalf
    if (from == 5 and to == 3) return 1;
    // Reserved(5) -> Closed(4): ReservedReset
    if (from == 5 and to == 4) return 1;
    return 0;
}
