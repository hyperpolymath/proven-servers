// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// sandbox.zig -- Zig FFI implementation of proven-sandbox.
//
// Implements the sandbox execution server state machine with:
//   - 64-slot mutex-protected sandbox pool
//   - Execution policy and syscall policy per sandbox
//   - Resource limit tracking (6 limit types)
//   - Sandbox lifecycle: Creating -> Ready -> Running -> Suspended/Terminated -> Destroyed
//   - Exit reason tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching SandboxABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching SandboxABI.Types.idr tag assignments)
// =========================================================================

/// Execution security policies (ABI tags 0-4).
pub const ExecutionPolicy = enum(u8) {
    unrestricted = 0,
    read_only = 1,
    network_denied = 2,
    isolated = 3,
    ephemeral = 4,
};

/// Resource limit categories (ABI tags 0-5).
pub const ResourceLimit = enum(u8) {
    cpu_time = 0,
    memory = 1,
    disk_io = 2,
    network_io = 3,
    file_descriptors = 4,
    processes = 5,
};

/// Sandbox lifecycle states (ABI tags 0-5).
pub const SandboxState = enum(u8) {
    creating = 0,
    ready = 1,
    running = 2,
    suspended = 3,
    terminated = 4,
    destroyed = 5,
};

/// Exit reasons for terminated sandboxes (ABI tags 0-5).
pub const ExitReason = enum(u8) {
    normal = 0,
    timeout = 1,
    memory_exceeded = 2,
    policy_violation = 3,
    killed = 4,
    err = 5,
};

/// Syscall policies (ABI tags 0-3).
pub const SyscallPolicy = enum(u8) {
    allow = 0,
    deny = 1,
    log = 2,
    trap = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sandboxes.
const MAX_SESSIONS: usize = 64;

/// Number of resource limit types.
const NUM_LIMITS: usize = 6;

/// A sandbox session.
const Session = struct {
    /// Current sandbox lifecycle state.
    state: SandboxState,
    /// Execution policy.
    policy: ExecutionPolicy,
    /// Syscall policy.
    syscall_policy: SyscallPolicy,
    /// Resource limits (indexed by ResourceLimit tag).
    limits: [NUM_LIMITS]u64,
    /// Exit reason (valid only in Terminated state).
    exit_reason: ExitReason,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .creating,
    .policy = .isolated,
    .syscall_policy = .deny,
    .limits = [_]u64{0} ** NUM_LIMITS,
    .exit_reason = .normal,
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
pub export fn sandbox_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new sandbox. Returns slot index (>=0) or -1 on failure.
/// The sandbox starts in Ready state (Creating -> Ready transition applied).
pub export fn sandbox_create(policy: u8, syscall_policy: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (policy > 4) return -1;
    if (syscall_policy > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.policy = @enumFromInt(policy);
            s.syscall_policy = @enumFromInt(syscall_policy);
            s.state = .ready; // Creating -> Ready
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a sandbox, releasing its slot.
pub export fn sandbox_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SandboxState tag for a sandbox.
pub export fn sandbox_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // creating fallback
    return @intFromEnum(sessions[idx].state);
}

/// Start a sandbox. Returns 0 on success, 1 on rejection.
/// Transitions: Ready -> Running.
pub export fn sandbox_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    sessions[idx].state = .running;
    return 0;
}

/// Suspend a sandbox. Returns 0 on success, 1 on rejection.
/// Transitions: Running -> Suspended.
pub export fn sandbox_suspend(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    sessions[idx].state = .suspended;
    return 0;
}

/// Resume a sandbox. Returns 0 on success, 1 on rejection.
/// Transitions: Suspended -> Running.
pub export fn sandbox_resume(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .suspended) return 1;
    sessions[idx].state = .running;
    return 0;
}

/// Terminate a sandbox. Returns 0 on success, 1 on rejection.
/// Transitions: Running/Suspended -> Terminated.
pub export fn sandbox_terminate(slot: c_int, reason: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running and sessions[idx].state != .suspended) return 1;
    if (reason > 5) return 1;
    sessions[idx].exit_reason = @enumFromInt(reason);
    sessions[idx].state = .terminated;
    return 0;
}

/// Clean up a terminated sandbox. Returns 0 on success, 1 on rejection.
/// Transitions: Terminated -> Destroyed.
pub export fn sandbox_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .terminated) return 1;
    sessions[idx].state = .destroyed;
    sessions[idx].limits = [_]u64{0} ** NUM_LIMITS;
    return 0;
}

/// Set a resource limit on a sandbox. Returns 0 on success, 1 on rejection.
pub export fn sandbox_set_limit(slot: c_int, limit_type: u8, value: u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (limit_type >= NUM_LIMITS) return 1;
    // Can only set limits in Ready or Running state
    if (sessions[idx].state != .ready and sessions[idx].state != .running) return 1;
    sessions[idx].limits[limit_type] = value;
    return 0;
}

/// Get a resource limit value. Returns 0 if unset or invalid.
pub export fn sandbox_get_limit(slot: c_int, limit_type: u8) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (limit_type >= NUM_LIMITS) return 0;
    return sessions[idx].limits[limit_type];
}

/// Returns the ExecutionPolicy tag for a sandbox.
pub export fn sandbox_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3; // isolated fallback
    return @intFromEnum(sessions[idx].policy);
}

/// Returns the SyscallPolicy tag for a sandbox.
pub export fn sandbox_syscall_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // deny fallback
    return @intFromEnum(sessions[idx].syscall_policy);
}

/// Returns the ExitReason tag (valid only in Terminated state).
pub export fn sandbox_exit_reason(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].exit_reason);
}

/// Check if a sandbox state transition is valid.
pub export fn sandbox_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Creating -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Running
    if (from == 2 and to == 3) return 1; // Running -> Suspended
    if (from == 3 and to == 2) return 1; // Suspended -> Running
    if (from == 2 and to == 4) return 1; // Running -> Terminated
    if (from == 3 and to == 4) return 1; // Suspended -> Terminated
    if (from == 4 and to == 5) return 1; // Terminated -> Destroyed
    return 0;
}

/// Returns number of active sandbox slots.
pub export fn sandbox_active_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
