// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// metrics.zig -- Zig FFI implementation of proven-metrics.
//
// Implements the metrics telemetry collector state machine with:
//   - 64-slot mutex-protected collector session pool
//   - Per-session scrape target tracking (max 32 targets)
//   - Per-session metric family registry (max 64 families)
//   - Per-session alert rule tracking (max 16 rules)
//   - Collector lifecycle (configure/scrape/alert)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching abi.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching abi.Types.idr tag assignments)
// =========================================================================

/// Metric types (ABI tags 0-5).
pub const MetricType = enum(u8) {
    counter = 0,
    gauge = 1,
    histogram = 2,
    summary = 3,
    info = 4,
    state_set = 5,
};

/// Scrape results (ABI tags 0-3).
pub const ScrapeResult = enum(u8) {
    success = 0,
    scrape_timeout = 1,
    connection_refused = 2,
    invalid_response = 3,
};

/// Alert states (ABI tags 0-3).
pub const AlertState = enum(u8) {
    inactive = 0,
    pending = 1,
    firing = 2,
    resolved = 3,
};

/// Aggregation operations (ABI tags 0-10).
pub const AggregationOp = enum(u8) {
    sum = 0,
    avg = 1,
    min = 2,
    max = 3,
    count = 4,
    rate = 5,
    increase = 6,
    p50 = 7,
    p90 = 8,
    p95 = 9,
    p99 = 10,
};

/// Query errors (ABI tags 0-3).
pub const QueryError = enum(u8) {
    parse_error = 0,
    execution_error = 1,
    query_timeout = 2,
    too_many_series = 3,
};

/// Collector lifecycle states (ABI tags 0-4).
pub const CollectorState = enum(u8) {
    idle = 0,
    configured = 1,
    scraping = 2,
    alerting = 3,
    stopping = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum scrape targets per session.
const MAX_TARGETS: usize = 32;

/// Maximum metric families per session.
const MAX_METRICS: usize = 64;

/// Maximum alert rules per session.
const MAX_ALERTS: usize = 16;

/// Maximum name/URL length.
const MAX_NAME_LEN: usize = 256;

/// A scrape target entry.
const TargetEntry = struct {
    url: [MAX_NAME_LEN]u8,
    url_len: u32,
    last_result: ScrapeResult,
    active: bool,
};

/// Default (empty) target entry.
const empty_target: TargetEntry = .{
    .url = [_]u8{0} ** MAX_NAME_LEN,
    .url_len = 0,
    .last_result = .success,
    .active = false,
};

/// A metric family entry.
const MetricEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    mtype: MetricType,
    active: bool,
};

/// Default (empty) metric entry.
const empty_metric: MetricEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .mtype = .counter,
    .active = false,
};

/// An alert rule entry.
const AlertEntry = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    state: AlertState,
    active: bool,
};

/// Default (empty) alert entry.
const empty_alert: AlertEntry = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .state = .inactive,
    .active = false,
};

/// A metrics collector session.
const Session = struct {
    /// Current collector lifecycle state.
    state: CollectorState,
    /// Scrape interval in milliseconds.
    interval_ms: u32,
    /// Scrape targets.
    targets: [MAX_TARGETS]TargetEntry,
    /// Number of active targets.
    target_count: u32,
    /// Metric families.
    metrics: [MAX_METRICS]MetricEntry,
    /// Number of active metric families.
    metric_count: u32,
    /// Alert rules.
    alerts: [MAX_ALERTS]AlertEntry,
    /// Number of active alert rules.
    alert_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .interval_ms = 15000,
    .targets = [_]TargetEntry{empty_target} ** MAX_TARGETS,
    .target_count = 0,
    .metrics = [_]MetricEntry{empty_metric} ** MAX_METRICS,
    .metric_count = 0,
    .alerts = [_]AlertEntry{empty_alert} ** MAX_ALERTS,
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

/// Returns the ABI version number.
pub export fn metrics_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new metrics collector session. Returns slot (>=0) or -1 on failure.
pub export fn metrics_create(interval_ms: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.interval_ms = if (interval_ms == 0) 15000 else interval_ms;
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn metrics_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current CollectorState tag.
pub export fn metrics_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Add a scrape target. Transitions Idle -> Configured.
pub export fn metrics_add_target(
    slot: c_int,
    url_ptr: [*]const u8,
    url_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .idle and state != .configured) return 1;
    if (url_len == 0 or url_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].target_count >= MAX_TARGETS) return 1;

    // Check for duplicate URL
    const url = url_ptr[0..url_len];
    for (&sessions[idx].targets) |*t| {
        if (t.active and t.url_len == url_len and
            std.mem.eql(u8, t.url[0..t.url_len], url))
        {
            return 1;
        }
    }

    // Find a free target slot
    for (&sessions[idx].targets) |*t| {
        if (!t.active) {
            @memcpy(t.url[0..url_len], url);
            t.url_len = url_len;
            t.last_result = .success;
            t.active = true;
            sessions[idx].target_count += 1;
            if (sessions[idx].state == .idle) {
                sessions[idx].state = .configured;
            }
            return 0;
        }
    }
    return 1;
}

/// Remove a scrape target. Returns 0 on success, 1 on rejection.
pub export fn metrics_remove_target(
    slot: c_int,
    url_ptr: [*]const u8,
    url_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (url_len == 0 or url_len > MAX_NAME_LEN) return 1;

    const url = url_ptr[0..url_len];
    for (&sessions[idx].targets) |*t| {
        if (t.active and t.url_len == url_len and
            std.mem.eql(u8, t.url[0..t.url_len], url))
        {
            t.active = false;
            t.url_len = 0;
            sessions[idx].target_count -= 1;

            if (sessions[idx].target_count == 0 and
                sessions[idx].state == .configured)
            {
                sessions[idx].state = .idle;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active scrape targets.
pub export fn metrics_target_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].target_count;
}

/// Start scraping. Transitions Configured -> Scraping.
pub export fn metrics_start_scraping(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .configured) return 1;
    if (sessions[idx].target_count == 0) return 1;

    sessions[idx].state = .scraping;
    return 0;
}

/// Record the result of a scrape. Returns 0 on success, 1 on rejection.
pub export fn metrics_record_scrape(
    slot: c_int,
    target_idx: u32,
    result: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .scraping and sessions[idx].state != .alerting) return 1;
    if (result > 3) return 1;
    if (target_idx >= MAX_TARGETS) return 1;
    if (!sessions[idx].targets[target_idx].active) return 1;

    sessions[idx].targets[target_idx].last_result = @enumFromInt(result);
    return 0;
}

/// Register a metric family. Returns 0 on success, 1 on rejection.
pub export fn metrics_register_metric(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    mtype: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (mtype > 5) return 1;
    if (sessions[idx].metric_count >= MAX_METRICS) return 1;

    // Find a free metric slot
    for (&sessions[idx].metrics) |*m| {
        if (!m.active) {
            @memcpy(m.name[0..name_len], name_ptr[0..name_len]);
            m.name_len = name_len;
            m.mtype = @enumFromInt(mtype);
            m.active = true;
            sessions[idx].metric_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of registered metric families.
pub export fn metrics_metric_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].metric_count;
}

/// Add an alert rule. Returns 0 on success, 1 on rejection.
pub export fn metrics_add_alert(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].alert_count >= MAX_ALERTS) return 1;

    for (&sessions[idx].alerts) |*a| {
        if (!a.active) {
            @memcpy(a.name[0..name_len], name_ptr[0..name_len]);
            a.name_len = name_len;
            a.state = .inactive;
            a.active = true;
            sessions[idx].alert_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Set the state of an alert rule. Returns 0 on success, 1 on rejection.
pub export fn metrics_set_alert_state(
    slot: c_int,
    alert_idx: u32,
    state: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (state > 3) return 1;
    if (alert_idx >= MAX_ALERTS) return 1;
    if (!sessions[idx].alerts[alert_idx].active) return 1;

    sessions[idx].alerts[alert_idx].state = @enumFromInt(state);
    return 0;
}

/// Returns the number of active alert rules.
pub export fn metrics_alert_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].alert_count;
}

/// Start alerting. Transitions Scraping -> Alerting.
pub export fn metrics_start_alerting(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .scraping) return 1;
    if (sessions[idx].alert_count == 0) return 1;

    sessions[idx].state = .alerting;
    return 0;
}

/// Stop the collector. Transitions to Stopping.
pub export fn metrics_stop(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .configured or state == .scraping or state == .alerting) {
        sessions[idx].state = .stopping;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions Stopping -> Idle.
pub export fn metrics_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .stopping) return 1;

    sessions[idx].state = .idle;
    sessions[idx].targets = [_]TargetEntry{empty_target} ** MAX_TARGETS;
    sessions[idx].target_count = 0;
    sessions[idx].metrics = [_]MetricEntry{empty_metric} ** MAX_METRICS;
    sessions[idx].metric_count = 0;
    sessions[idx].alerts = [_]AlertEntry{empty_alert} ** MAX_ALERTS;
    sessions[idx].alert_count = 0;

    return 0;
}

/// Check if a collector state transition is valid.
pub export fn metrics_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Configured
    if (from == 1 and to == 0) return 1; // Configured -> Idle (all targets removed)
    if (from == 1 and to == 2) return 1; // Configured -> Scraping
    if (from == 2 and to == 3) return 1; // Scraping -> Alerting
    if (from == 1 and to == 4) return 1; // Configured -> Stopping
    if (from == 2 and to == 4) return 1; // Scraping -> Stopping
    if (from == 3 and to == 4) return 1; // Alerting -> Stopping
    if (from == 4 and to == 0) return 1; // Stopping -> Idle
    return 0;
}
