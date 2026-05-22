// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// container.zig -- Zig FFI implementation of proven-container.
//
// Implements a container lifecycle manager with:
//   - 64-slot container instance pool
//   - State machine with valid transition enforcement
//   - Per-container network mode, restart policy, health status
//   - Operation dispatch with state-dependent validation
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ContainerABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching ContainerABI.Types.idr tag assignments)
// =========================================================================

/// Container lifecycle states (tags 0-6).
pub const ContainerState = enum(u8) {
    creating = 0,
    running = 1,
    paused = 2,
    restarting = 3,
    stopped = 4,
    removing = 5,
    dead = 6,
};

/// Container operations (tags 0-10).
pub const Operation = enum(u8) {
    create = 0,
    start = 1,
    stop = 2,
    restart = 3,
    pause = 4,
    unpause = 5,
    kill = 6,
    remove = 7,
    exec = 8,
    logs = 9,
    inspect = 10,
};

/// Network modes (tags 0-4).
pub const NetworkMode = enum(u8) {
    bridge = 0,
    host = 1,
    none = 2,
    overlay = 3,
    macvlan = 4,
};

/// Volume types (tags 0-2).
pub const VolumeType = enum(u8) {
    bind = 0,
    named = 1,
    tmpfs = 2,
};

/// Restart policies (tags 0-3).
pub const RestartPolicy = enum(u8) {
    no = 0,
    always = 1,
    on_failure = 2,
    unless_stopped = 3,
};

/// Health statuses (tags 0-3).
pub const HealthStatus = enum(u8) {
    starting = 0,
    healthy = 1,
    unhealthy = 2,
    no_check = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent container instances.
const MAX_SESSIONS: usize = 64;

/// A container instance.
const Session = struct {
    /// Current lifecycle state.
    state: ContainerState,
    /// Network mode.
    network: NetworkMode,
    /// Restart policy.
    restart_policy: RestartPolicy,
    /// Current health status.
    health: HealthStatus,
    /// Number of restarts.
    restart_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .creating,
    .network = .bridge,
    .restart_policy = .no,
    .health = .no_check,
    .restart_count = 0,
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

/// Apply an operation to the container state machine.
/// Returns the new state, or null if the operation is invalid for the
/// current state.
fn applyOperation(state: ContainerState, op: Operation) ?ContainerState {
    return switch (op) {
        .create => if (state == .creating) .stopped else null,
        .start => switch (state) {
            .stopped, .dead => .running,
            else => null,
        },
        .stop => switch (state) {
            .running, .paused, .restarting => .stopped,
            else => null,
        },
        .restart => switch (state) {
            .running, .stopped, .paused => .restarting,
            else => null,
        },
        .pause => if (state == .running) .paused else null,
        .unpause => if (state == .paused) .running else null,
        .kill => switch (state) {
            .running, .paused, .restarting => .stopped,
            else => null,
        },
        .remove => switch (state) {
            .stopped, .dead => .removing,
            else => null,
        },
        .exec => if (state == .running) .running else null,
        .logs => .running, // Logs can be read in any state (returns current)
        .inspect => state, // Inspect is always valid, no state change
    };
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn container_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new container in Creating state. Returns slot index (>=0) or -1.
pub export fn container_create(network: u8, restart: u8) callconv(.c) c_int {
    if (network > 4 or restart > 3) return -1;

    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.network = @enumFromInt(network);
            s.restart_policy = @enumFromInt(restart);
            s.state = .creating;
            s.health = .no_check;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a container, releasing its slot.
pub export fn container_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current ContainerState tag.
pub export fn container_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Apply an operation. Returns 0 on success, 1 on invalid state transition.
pub export fn container_apply_op(slot: c_int, op: u8) callconv(.c) u8 {
    if (op > 10) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const operation: Operation = @enumFromInt(op);
    const new_state = applyOperation(sessions[idx].state, operation) orelse return 1;

    // Track restart count
    if (operation == .restart) {
        sessions[idx].restart_count += 1;
    }

    // Auto-transition from Restarting to Running
    if (new_state == .restarting) {
        sessions[idx].state = .running;
        sessions[idx].health = .starting;
    } else {
        sessions[idx].state = new_state;
    }

    // Reset health when stopping
    if (new_state == .stopped or new_state == .dead) {
        sessions[idx].health = .no_check;
    }

    return 0;
}

/// Returns the network mode tag.
pub export fn container_network_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].network);
}

/// Returns the restart policy tag.
pub export fn container_restart_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].restart_policy);
}

/// Returns the current health status tag.
pub export fn container_health_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3; // NoCheck fallback
    return @intFromEnum(sessions[idx].health);
}

/// Set health status. Returns 0 on success, 1 on invalid tag/slot.
pub export fn container_set_health(slot: c_int, status: u8) callconv(.c) u8 {
    if (status > 3) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    sessions[idx].health = @enumFromInt(status);
    return 0;
}

/// Returns the number of restarts.
pub export fn container_restart_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].restart_count;
}

/// Returns 1 if the container is in Running state, 0 otherwise.
pub export fn container_is_running(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .running) 1 else 0;
}

/// Stateless: check if a container state transition is valid.
pub export fn container_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Creating -> Stopped (after create op)
    if (from == 0 and to == 4) return 1;
    // Stopped -> Running (start)
    if (from == 4 and to == 1) return 1;
    // Stopped -> Removing (remove)
    if (from == 4 and to == 5) return 1;
    // Running -> Stopped (stop/kill)
    if (from == 1 and to == 4) return 1;
    // Running -> Paused (pause)
    if (from == 1 and to == 2) return 1;
    // Running -> Restarting (restart)
    if (from == 1 and to == 3) return 1;
    // Running -> Running (exec, self-loop)
    if (from == 1 and to == 1) return 1;
    // Paused -> Running (unpause)
    if (from == 2 and to == 1) return 1;
    // Paused -> Stopped (stop/kill)
    if (from == 2 and to == 4) return 1;
    // Paused -> Restarting (restart)
    if (from == 2 and to == 3) return 1;
    // Restarting -> Running (after restart)
    if (from == 3 and to == 1) return 1;
    // Restarting -> Stopped (stop/kill)
    if (from == 3 and to == 4) return 1;
    // Dead -> Running (start)
    if (from == 6 and to == 1) return 1;
    // Dead -> Removing (remove)
    if (from == 6 and to == 5) return 1;
    // Stopped -> Restarting (restart)
    if (from == 4 and to == 3) return 1;
    return 0;
}
