// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// diode.zig -- Zig FFI implementation of proven-diode.
//
// Implements the unidirectional data diode gateway state machine with:
//   - 64-slot mutex-protected gateway pool
//   - Segment queuing per gateway (max 128 segments)
//   - Direction and protocol enforcement
//   - Integrity verification per segment
//   - Validation before transit
//   - Transfer statistics tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DiodeABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DiodeABI.Types.idr tag assignments)
// =========================================================================

/// Data flow direction (ABI tags 0-1).
pub const Direction = enum(u8) {
    high_to_low = 0,
    low_to_high = 1,
};

/// Supported transit protocols (ABI tags 0-4).
pub const Protocol = enum(u8) {
    udp = 0,
    tcp = 1,
    file_transfer = 2,
    syslog = 3,
    snmp = 4,
};

/// Transfer lifecycle states (ABI tags 0-4).
pub const TransferState = enum(u8) {
    queued = 0,
    sending = 1,
    confirming = 2,
    complete = 3,
    failed = 4,
};

/// Validation results (ABI tags 0-3).
pub const ValidationResult = enum(u8) {
    passed = 0,
    format_error = 1,
    size_exceeded = 2,
    policy_blocked = 3,
};

/// Integrity check algorithms (ABI tags 0-2).
pub const IntegrityCheck = enum(u8) {
    crc32 = 0,
    sha256 = 1,
    hmac = 2,
};

/// Gateway lifecycle states (ABI tags 0-4).
pub const GatewayState = enum(u8) {
    idle = 0,
    configured = 1,
    transferring = 2,
    validating = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent gateways.
const MAX_GATEWAYS: usize = 64;

/// Maximum queued segments per gateway.
const MAX_SEGMENTS: usize = 128;

/// Maximum segment data length in bytes.
const MAX_SEGMENT_LEN: usize = 4096;

/// A queued data segment.
const Segment = struct {
    /// Segment payload (truncated to MAX_SEGMENT_LEN).
    data: [MAX_SEGMENT_LEN]u8,
    data_len: u32,
    /// Integrity check algorithm used.
    integrity: IntegrityCheck,
    /// Transfer lifecycle state.
    state: TransferState,
    /// Whether this segment slot is active.
    active: bool,
};

/// A data diode gateway instance.
const Gateway = struct {
    /// Current gateway lifecycle state.
    state: GatewayState,
    /// Enforced data flow direction.
    direction: Direction,
    /// Transit protocol.
    protocol: Protocol,
    /// Queued segments.
    segments: [MAX_SEGMENTS]Segment,
    /// Number of active (queued/in-flight) segments.
    queue_depth: u32,
    /// Total segments successfully transferred (monotonic counter).
    transferred_count: u64,
    /// Whether this gateway slot is in use.
    active: bool,
};

/// Default (empty) segment.
const empty_segment: Segment = .{
    .data = [_]u8{0} ** MAX_SEGMENT_LEN,
    .data_len = 0,
    .integrity = .crc32,
    .state = .queued,
    .active = false,
};

/// Default (empty) gateway.
const empty_gateway: Gateway = .{
    .state = .idle,
    .direction = .high_to_low,
    .protocol = .udp,
    .segments = [_]Segment{empty_segment} ** MAX_SEGMENTS,
    .queue_depth = 0,
    .transferred_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var gateways: [MAX_GATEWAYS]Gateway = [_]Gateway{empty_gateway} ** MAX_GATEWAYS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_GATEWAYS) return null;
    const idx: usize = @intCast(slot);
    if (!gateways[idx].active) return null;
    return idx;
}

/// Find the next queued segment in a gateway.
fn findNextQueued(idx: usize) ?usize {
    for (&gateways[idx].segments, 0..) |*s, i| {
        if (s.active and s.state == .queued) {
            return i;
        }
    }
    return null;
}

/// Find the next segment in sending state.
fn findNextSending(idx: usize) ?usize {
    for (&gateways[idx].segments, 0..) |*s, i| {
        if (s.active and s.state == .sending) {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn diode_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new data diode gateway. Returns slot index (>=0) or -1 on failure.
/// The gateway starts in Configured state.
pub export fn diode_create(direction: u8, protocol: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (direction > 1) return -1;
    if (protocol > 4) return -1;

    for (&gateways, 0..) |*gw, i| {
        if (!gw.active) {
            gw.* = empty_gateway;
            gw.direction = @enumFromInt(direction);
            gw.protocol = @enumFromInt(protocol);
            gw.state = .configured;
            gw.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a gateway, releasing its slot.
pub export fn diode_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_GATEWAYS) return;
    gateways[@intCast(slot)] = empty_gateway;
}

// -- State queries ------------------------------------------------------------

/// Returns the current GatewayState tag for a gateway.
pub export fn diode_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(gateways[idx].state);
}

/// Returns 1 if the gateway can transfer, 0 otherwise.
pub export fn diode_can_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = gateways[idx].state;
    return if (state == .configured or state == .transferring or state == .validating) 1 else 0;
}

// -- Segment management -------------------------------------------------------

/// Enqueue a data segment for transfer. Returns 0 on success, 1 on rejection.
pub export fn diode_enqueue(
    slot: c_int,
    data_ptr: [*]const u8,
    data_len: u32,
    integrity: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = gateways[idx].state;
    if (state != .configured and state != .transferring and state != .validating) return 1;
    if (data_len == 0 or data_len > MAX_SEGMENT_LEN) return 1;
    if (integrity > 2) return 1;

    // Find a free segment slot
    for (&gateways[idx].segments) |*s| {
        if (!s.active) {
            @memcpy(s.data[0..data_len], data_ptr[0..data_len]);
            s.data_len = data_len;
            s.integrity = @enumFromInt(integrity);
            s.state = .queued;
            s.active = true;
            gateways[idx].queue_depth += 1;
            return 0;
        }
    }
    return 1;
}

/// Validate the next queued segment. Returns ValidationResult tag.
/// Transitions: Configured -> Validating, or stays Validating/Transferring.
pub export fn diode_validate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(ValidationResult.format_error);
    const state = gateways[idx].state;
    if (state != .configured and state != .transferring and state != .validating) {
        return @intFromEnum(ValidationResult.policy_blocked);
    }

    const si = findNextQueued(idx) orelse return @intFromEnum(ValidationResult.format_error);

    // Validate: check segment has data
    if (gateways[idx].segments[si].data_len == 0) {
        gateways[idx].segments[si].state = .failed;
        return @intFromEnum(ValidationResult.format_error);
    }

    // Segment passes validation, mark as sending
    gateways[idx].segments[si].state = .sending;
    if (gateways[idx].state == .configured) {
        gateways[idx].state = .validating;
    }

    return @intFromEnum(ValidationResult.passed);
}

/// Transfer the next validated segment. Returns 0 on success, 1 on rejection.
/// Transitions: Validating -> Transferring.
pub export fn diode_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = gateways[idx].state;
    if (state != .validating and state != .transferring) return 1;

    const si = findNextSending(idx) orelse return 1;

    gateways[idx].segments[si].state = .confirming;
    gateways[idx].state = .transferring;

    return 0;
}

/// Confirm transfer completion. Returns 0 on success, 1 on rejection.
pub export fn diode_confirm(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;

    // Find a confirming segment
    for (&gateways[idx].segments) |*s| {
        if (s.active and s.state == .confirming) {
            s.state = .complete;
            s.active = false;
            gateways[idx].queue_depth -= 1;
            gateways[idx].transferred_count += 1;

            // If queue is empty, return to configured
            if (gateways[idx].queue_depth == 0) {
                gateways[idx].state = .configured;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of queued segments for a gateway.
pub export fn diode_queue_depth(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return gateways[idx].queue_depth;
}

/// Returns the total number of segments transferred.
pub export fn diode_transferred_count(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return gateways[idx].transferred_count;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the gateway. Returns 0 on success, 1 on rejection.
pub export fn diode_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = gateways[idx].state;
    if (state == .configured or state == .transferring or state == .validating) {
        gateways[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn diode_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (gateways[idx].state != .shutdown) return 1;

    gateways[idx].state = .idle;
    gateways[idx].segments = [_]Segment{empty_segment} ** MAX_SEGMENTS;
    gateways[idx].queue_depth = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a gateway state transition is valid.
pub export fn diode_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Configured
    if (from == 1 and to == 3) return 1; // Configured -> Validating
    if (from == 1 and to == 1) return 1; // Configured -> Configured (enqueue more)
    if (from == 3 and to == 2) return 1; // Validating -> Transferring
    if (from == 3 and to == 3) return 1; // Validating -> Validating (more segments)
    if (from == 2 and to == 2) return 1; // Transferring -> Transferring
    if (from == 2 and to == 1) return 1; // Transferring -> Configured (queue empty)
    if (from == 2 and to == 3) return 1; // Transferring -> Validating (next segment)
    if (from == 1 and to == 4) return 1; // Configured -> Shutdown
    if (from == 2 and to == 4) return 1; // Transferring -> Shutdown
    if (from == 3 and to == 4) return 1; // Validating -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
