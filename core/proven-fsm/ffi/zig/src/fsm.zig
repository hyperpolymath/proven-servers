// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// fsm.zig — Zig FFI implementation of proven-fsm.
//
// Implements the generic finite state machine primitive with:
//   - Slot-based machine management (up to 64 concurrent machines)
//   - State transition enforcement matching Idris2 Transitions.idr proofs
//   - Event submission with disposition tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/FSMABI/Layout.idr)
//   - C header   (generated/abi/fsm.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// TransitionResult — matches transitionResultToTag
pub const TransitionResult = enum(u8) {
    accepted = 0,
    rejected = 1,
    deferred = 2,
};

/// ValidationError — matches validationErrorToTag
pub const ValidationError = enum(u8) {
    invalid_transition = 0,
    precondition_failed = 1,
    postcondition_failed = 2,
    guard_failed = 3,
};

/// MachineState — matches machineStateToTag
pub const MachineState = enum(u8) {
    initial = 0,
    running = 1,
    terminal = 2,
    faulted = 3,
};

/// EventDisposition — matches eventDispositionToTag
pub const EventDisposition = enum(u8) {
    consumed = 0,
    ignored = 1,
    queued = 2,
    dropped = 3,
};

// ── Machine instance ────────────────────────────────────────────────────

const Machine = struct {
    state: MachineState,
    max_states: u16,
    max_transitions: u32,
    event_count: u32,
    last_error: u8, // 255 = no error
    active: bool,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_MACHINES: usize = 64;

var machines: [MAX_MACHINES]Machine = [_]Machine{.{
    .state = .initial,
    .max_states = 0,
    .max_transitions = 0,
    .event_count = 0,
    .last_error = 255,
    .active = false,
}} ** MAX_MACHINES;

var mutex: std.Thread.Mutex = .{};

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match FSMABI.Foreign.abiVersion (currently 1).
pub export fn fsm_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new FSM in Initial state.
/// Returns slot index (0-63) or -1 if no slots available.
pub export fn fsm_create(max_states: u16, max_transitions: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (max_states == 0 or max_transitions == 0) return -1;

    for (&machines, 0..) |*m, i| {
        if (!m.active) {
            m.* = .{
                .state = .initial,
                .max_states = max_states,
                .max_transitions = max_transitions,
                .event_count = 0,
                .last_error = 255,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy a machine, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn fsm_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return;
    const idx: usize = @intCast(slot);
    machines[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current MachineState tag for a slot.
/// Returns Initial (0) for invalid/inactive slots.
pub export fn fsm_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return 0;
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return 0;
    return @intFromEnum(machines[idx].state);
}

/// Get the last ValidationError tag, or 255 if no error.
pub export fn fsm_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return 255;
    const idx: usize = @intCast(slot);
    return machines[idx].last_error;
}

// ── Transitions (matching Transitions.idr ValidMachineTransition) ───────

/// Start the machine: Initial -> Running.
/// Returns TransitionResult tag.
pub export fn fsm_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return @intFromEnum(TransitionResult.rejected);
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return @intFromEnum(TransitionResult.rejected);

    if (machines[idx].state == .initial) {
        machines[idx].state = .running;
        machines[idx].last_error = 255;
        return @intFromEnum(TransitionResult.accepted);
    }
    machines[idx].last_error = @intFromEnum(ValidationError.invalid_transition);
    return @intFromEnum(TransitionResult.rejected);
}

/// Complete the machine: Running -> Terminal.
/// Returns TransitionResult tag.
pub export fn fsm_complete(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return @intFromEnum(TransitionResult.rejected);
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return @intFromEnum(TransitionResult.rejected);

    if (machines[idx].state == .running) {
        machines[idx].state = .terminal;
        machines[idx].last_error = 255;
        return @intFromEnum(TransitionResult.accepted);
    }
    machines[idx].last_error = @intFromEnum(ValidationError.invalid_transition);
    return @intFromEnum(TransitionResult.rejected);
}

/// Fault the machine: Initial|Running -> Faulted.
/// Returns TransitionResult tag.
pub export fn fsm_fault(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return @intFromEnum(TransitionResult.rejected);
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return @intFromEnum(TransitionResult.rejected);

    if (machines[idx].state == .initial or machines[idx].state == .running) {
        machines[idx].state = .faulted;
        machines[idx].last_error = 255;
        return @intFromEnum(TransitionResult.accepted);
    }
    machines[idx].last_error = @intFromEnum(ValidationError.invalid_transition);
    return @intFromEnum(TransitionResult.rejected);
}

/// Reset the machine: Faulted -> Initial.
/// Returns TransitionResult tag.
pub export fn fsm_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_MACHINES) return @intFromEnum(TransitionResult.rejected);
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return @intFromEnum(TransitionResult.rejected);

    if (machines[idx].state == .faulted) {
        machines[idx].state = .initial;
        machines[idx].event_count = 0;
        machines[idx].last_error = 255;
        return @intFromEnum(TransitionResult.accepted);
    }
    machines[idx].last_error = @intFromEnum(ValidationError.invalid_transition);
    return @intFromEnum(TransitionResult.rejected);
}

// ── Event processing ────────────────────────────────────────────────────

/// Submit an event to the machine.
/// Returns EventDisposition tag.
/// Only Running machines can accept events; others return Ignored.
pub export fn fsm_submit_event(slot: c_int, event_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = event_id; // Event ID would be used by user-defined transition tables

    if (slot < 0 or slot >= MAX_MACHINES) return @intFromEnum(EventDisposition.dropped);
    const idx: usize = @intCast(slot);
    if (!machines[idx].active) return @intFromEnum(EventDisposition.dropped);

    if (machines[idx].state == .running) {
        machines[idx].event_count += 1;
        return @intFromEnum(EventDisposition.consumed);
    }
    return @intFromEnum(EventDisposition.ignored);
}

// ── Stateless validation ────────────────────────────────────────────────

/// Check whether a transition from one MachineState to another is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateTransition exactly.
pub export fn fsm_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Initial -> Running
    if (from == 0 and to == 1) return 1;
    // Running -> Terminal
    if (from == 1 and to == 2) return 1;
    // Running -> Faulted
    if (from == 1 and to == 3) return 1;
    // Initial -> Faulted
    if (from == 0 and to == 3) return 1;
    // Faulted -> Initial
    if (from == 3 and to == 0) return 1;
    return 0;
}
