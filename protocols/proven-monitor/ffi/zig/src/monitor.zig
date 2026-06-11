// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// monitor.zig -- Zig FFI implementation of proven-monitor.
//
// Implements the monitoring server state machine with:
//   - 64-slot mutex-protected session pool
//   - Check registration per session (max 32 checks)
//   - Alert channel tracking
//   - Check execution state tracking
//   - Severity escalation
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching MonitorABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching MonitorABI.Types.idr tag assignments)
// =========================================================================

/// Monitoring check types (ABI tags 0-10).
pub const CheckType = enum(u8) {
    http = 0,
    tcp = 1,
    udp = 2,
    icmp = 3,
    dns = 4,
    certificate = 5,
    disk = 6,
    cpu = 7,
    memory = 8,
    process = 9,
    custom = 10,
};

/// Monitoring status (ABI tags 0-4).
pub const Status = enum(u8) {
    up = 0,
    down = 1,
    degraded = 2,
    unknown = 3,
    maintenance = 4,
};

/// Alert channel types (ABI tags 0-4).
pub const AlertChannel = enum(u8) {
    email = 0,
    sms = 1,
    webhook = 2,
    slack = 3,
    pagerduty = 4,
};

/// Alert severity levels (ABI tags 0-3).
pub const Severity = enum(u8) {
    info = 0,
    warning = 1,
    err = 2,
    critical = 3,
};

/// Check execution state (ABI tags 0-5).
pub const CheckState = enum(u8) {
    pending = 0,
    running = 1,
    passed = 2,
    failed = 3,
    timeout = 4,
    cs_error = 5,
};

/// Monitor server lifecycle states (ABI tags 0-5).
pub const MonitorState = enum(u8) {
    idle = 0,
    configured = 1,
    running_state = 2,
    paused = 3,
    alerting = 4,
    shutdown = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum checks per session.
const MAX_CHECKS: usize = 32;

/// Maximum name/target length in bytes.
const MAX_NAME_LEN: usize = 256;

/// A registered health check.
const Check = struct {
    /// The type of check (HTTP, TCP, etc.).
    check_type: CheckType,
    /// Target hostname/IP/path.
    target: [MAX_NAME_LEN]u8,
    target_len: u32,
    /// Severity level assigned to this check's alerts.
    severity: Severity,
    /// Last execution state.
    last_state: CheckState,
    /// Last observed status from the check.
    last_status: Status,
    /// Whether this check slot is active.
    active: bool,
};

/// A monitoring session.
const Session = struct {
    /// Current lifecycle state.
    state: MonitorState,
    /// Session name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Check interval in milliseconds.
    interval_ms: u32,
    /// Registered checks.
    checks: [MAX_CHECKS]Check,
    /// Number of active checks.
    check_count: u32,
    /// Total alerts fired in this session.
    alert_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) check.
const empty_check: Check = .{
    .check_type = .http,
    .target = [_]u8{0} ** MAX_NAME_LEN,
    .target_len = 0,
    .severity = .info,
    .last_state = .pending,
    .last_status = .unknown,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .interval_ms = 60000,
    .checks = [_]Check{empty_check} ** MAX_CHECKS,
    .check_count = 0,
    .alert_count = 0,
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
pub export fn monitor_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new monitoring session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Configured state.
pub export fn monitor_create(
    name_ptr: [*]const u8,
    name_len: u32,
    interval_ms: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (interval_ms == 0) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.interval_ms = interval_ms;
            s.state = .configured;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn monitor_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current MonitorState tag for a session.
pub export fn monitor_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Add a check to a session. Returns 0 on success, 1 on rejection.
pub export fn monitor_add_check(
    slot: c_int,
    check_type: u8,
    target_ptr: [*]const u8,
    target_len: u32,
    severity: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .configured and sessions[idx].state != .running_state and
        sessions[idx].state != .paused) return 1;
    if (check_type > 10) return 1;
    if (severity > 3) return 1;
    if (target_len == 0 or target_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].check_count >= MAX_CHECKS) return 1;

    for (&sessions[idx].checks) |*chk| {
        if (!chk.active) {
            chk.* = empty_check;
            chk.check_type = @enumFromInt(check_type);
            @memcpy(chk.target[0..target_len], target_ptr[0..target_len]);
            chk.target_len = target_len;
            chk.severity = @enumFromInt(severity);
            chk.active = true;
            sessions[idx].check_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Remove a check by index. Returns 0 on success, 1 on rejection.
pub export fn monitor_remove_check(slot: c_int, index: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (index >= MAX_CHECKS) return 1;
    if (!sessions[idx].checks[index].active) return 1;

    sessions[idx].checks[index] = empty_check;
    sessions[idx].check_count -= 1;
    return 0;
}

/// Returns the number of active checks for a session.
pub export fn monitor_check_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].check_count;
}

/// Start monitoring. Configured -> Running.
pub export fn monitor_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .configured) return 1;
    sessions[idx].state = .running_state;
    return 0;
}

/// Pause monitoring. Running -> Paused.
pub export fn monitor_pause(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running_state and sessions[idx].state != .alerting) return 1;
    sessions[idx].state = .paused;
    return 0;
}

/// Resume monitoring. Paused -> Running.
pub export fn monitor_resume(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .paused) return 1;
    sessions[idx].state = .running_state;
    return 0;
}

/// Run a check by index. Returns CheckState tag after execution.
/// Simulates check execution: transitions Pending -> Running -> Passed.
pub export fn monitor_run_check(slot: c_int, index: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(CheckState.cs_error);
    if (sessions[idx].state != .running_state and sessions[idx].state != .alerting) {
        return @intFromEnum(CheckState.cs_error);
    }
    if (index >= MAX_CHECKS) return @intFromEnum(CheckState.cs_error);
    if (!sessions[idx].checks[index].active) return @intFromEnum(CheckState.cs_error);

    // Simulate check execution: mark as passed and status as up.
    sessions[idx].checks[index].last_state = .passed;
    sessions[idx].checks[index].last_status = .up;
    return @intFromEnum(CheckState.passed);
}

/// Get the last status of a check by index.
pub export fn monitor_check_status(slot: c_int, index: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(Status.unknown);
    if (index >= MAX_CHECKS) return @intFromEnum(Status.unknown);
    if (!sessions[idx].checks[index].active) return @intFromEnum(Status.unknown);
    return @intFromEnum(sessions[idx].checks[index].last_status);
}

/// Fire an alert. Returns 0 on success, 1 on rejection.
/// Transitions Running -> Alerting, stays Alerting if already alerting.
pub export fn monitor_fire_alert(
    slot: c_int,
    channel: u8,
    severity: u8,
    msg_ptr: [*]const u8,
    msg_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = msg_ptr;
    _ = msg_len;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running_state and sessions[idx].state != .alerting) return 1;
    if (channel > 4) return 1;
    if (severity > 3) return 1;

    sessions[idx].state = .alerting;
    sessions[idx].alert_count += 1;
    return 0;
}

/// Shutdown the monitor. Any non-Idle/Shutdown -> Shutdown.
pub export fn monitor_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .shutdown) return 1;
    sessions[idx].state = .shutdown;
    return 0;
}

/// Complete cleanup after shutdown. Shutdown -> Idle.
pub export fn monitor_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].checks = [_]Check{empty_check} ** MAX_CHECKS;
    sessions[idx].check_count = 0;
    sessions[idx].alert_count = 0;
    return 0;
}

/// Check if a monitor state transition is valid (stateless).
pub export fn monitor_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Configured
    if (from == 1 and to == 2) return 1; // Configured -> Running
    if (from == 2 and to == 3) return 1; // Running -> Paused
    if (from == 3 and to == 2) return 1; // Paused -> Running
    if (from == 2 and to == 4) return 1; // Running -> Alerting
    if (from == 4 and to == 4) return 1; // Alerting -> Alerting
    if (from == 4 and to == 2) return 1; // Alerting -> Running (alert resolved)
    if (from == 4 and to == 3) return 1; // Alerting -> Paused
    if (from == 1 and to == 5) return 1; // Configured -> Shutdown
    if (from == 2 and to == 5) return 1; // Running -> Shutdown
    if (from == 3 and to == 5) return 1; // Paused -> Shutdown
    if (from == 4 and to == 5) return 1; // Alerting -> Shutdown
    if (from == 5 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
