// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// siem.zig -- Zig FFI implementation of proven-siem.
//
// Implements a SIEM engine state machine with:
//   - 64-slot mutex-protected SIEM engine pool
//   - Event ingestion with severity and category classification
//   - Correlation rule registration and threshold-based matching
//   - Alert lifecycle management (New -> Acknowledged -> ... -> Resolved)
//   - Engine lifecycle: Idle -> Running -> Paused -> Disconnecting
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching SIEMABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching SIEMABI.Types.idr tag assignments)
// =========================================================================

/// Event severity levels (ABI tags 0-4).
pub const EventSeverity = enum(u8) {
    info = 0,
    low = 1,
    medium = 2,
    high = 3,
    critical = 4,
};

/// Event categories (ABI tags 0-6).
pub const EventCategory = enum(u8) {
    authentication = 0,
    network_traffic = 1,
    file_activity = 2,
    process_execution = 3,
    policy_violation = 4,
    malware = 5,
    data_exfiltration = 6,
};

/// Correlation rule types (ABI tags 0-4).
pub const CorrelationRule = enum(u8) {
    threshold = 0,
    sequence = 1,
    aggregation = 2,
    absence = 3,
    statistical = 4,
};

/// Alert lifecycle states (ABI tags 0-4).
pub const AlertState = enum(u8) {
    new = 0,
    acknowledged = 1,
    in_progress = 2,
    resolved = 3,
    false_positive = 4,
};

/// Engine lifecycle states (ABI tags 0-4).
pub const EngineState = enum(u8) {
    idle = 0,
    running = 1,
    paused = 2,
    disconnecting = 3,
    destroyed = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum events per engine.
const MAX_EVENTS: usize = 512;

/// Maximum correlation rules per engine.
const MAX_RULES: usize = 32;

/// Maximum alerts per engine.
const MAX_ALERTS: usize = 128;

/// Maximum name length.
const MAX_NAME_LEN: usize = 256;

/// An ingested event.
const Event = struct {
    severity: EventSeverity,
    category: EventCategory,
    source: [MAX_NAME_LEN]u8,
    source_len: u32,
    active: bool,
};

/// A correlation rule.
const Rule = struct {
    rule_type: CorrelationRule,
    threshold: u32,
    category: EventCategory,
    active: bool,
};

/// An alert.
const Alert = struct {
    state: AlertState,
    rule_idx: u32,
    active: bool,
};

/// Default (empty) event.
const empty_event: Event = .{
    .severity = .info,
    .category = .authentication,
    .source = [_]u8{0} ** MAX_NAME_LEN,
    .source_len = 0,
    .active = false,
};

/// Default (empty) rule.
const empty_rule: Rule = .{
    .rule_type = .threshold,
    .threshold = 0,
    .category = .authentication,
    .active = false,
};

/// Default (empty) alert.
const empty_alert: Alert = .{
    .state = .new,
    .rule_idx = 0,
    .active = false,
};

/// A SIEM engine session.
const Session = struct {
    /// Current engine lifecycle state.
    state: EngineState,
    /// Engine name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Events.
    events: [MAX_EVENTS]Event,
    event_count: u32,
    /// Correlation rules.
    rules: [MAX_RULES]Rule,
    rule_count: u32,
    /// Alerts.
    alerts: [MAX_ALERTS]Alert,
    alert_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .events = [_]Event{empty_event} ** MAX_EVENTS,
    .event_count = 0,
    .rules = [_]Rule{empty_rule} ** MAX_RULES,
    .rule_count = 0,
    .alerts = [_]Alert{empty_alert} ** MAX_ALERTS,
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
pub export fn siem_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new SIEM engine. Returns slot index or -1 on failure.
pub export fn siem_create(name_ptr: [*]const u8, name_len: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session.
pub export fn siem_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current EngineState tag.
pub export fn siem_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Ingest a security event. Returns 0 on success, 1 on rejection.
pub export fn siem_ingest_event(
    slot: c_int,
    severity: u8,
    category: u8,
    source_ptr: [*]const u8,
    source_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    if (severity > 4) return 1;
    if (category > 6) return 1;
    if (source_len == 0 or source_len > MAX_NAME_LEN) return 1;

    for (&sessions[idx].events) |*e| {
        if (!e.active) {
            e.severity = @enumFromInt(severity);
            e.category = @enumFromInt(category);
            @memcpy(e.source[0..source_len], source_ptr[0..source_len]);
            e.source_len = source_len;
            e.active = true;
            sessions[idx].event_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of ingested events.
pub export fn siem_event_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].event_count;
}

/// Add a correlation rule. Returns 0 on success, 1 on rejection.
pub export fn siem_add_rule(slot: c_int, rule_type: u8, threshold: u32, category: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (rule_type > 4) return 1;
    if (category > 6) return 1;

    for (&sessions[idx].rules) |*r| {
        if (!r.active) {
            r.rule_type = @enumFromInt(rule_type);
            r.threshold = threshold;
            r.category = @enumFromInt(category);
            r.active = true;
            sessions[idx].rule_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active rules.
pub export fn siem_rule_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].rule_count;
}

/// Run correlation engine. Returns number of new alerts generated.
pub export fn siem_correlate(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (sessions[idx].state != .running) return 0;

    var new_alerts: u32 = 0;

    for (&sessions[idx].rules, 0..) |*rule, ri| {
        if (!rule.active) continue;

        // Count events matching this rule's category
        var matching: u32 = 0;
        for (&sessions[idx].events) |*e| {
            if (e.active and e.category == rule.category) {
                matching += 1;
            }
        }

        // For threshold rules, fire if count >= threshold
        if (rule.rule_type == .threshold and matching >= rule.threshold) {
            // Create alert if we have space
            for (&sessions[idx].alerts) |*a| {
                if (!a.active) {
                    a.state = .new;
                    a.rule_idx = @intCast(ri);
                    a.active = true;
                    sessions[idx].alert_count += 1;
                    new_alerts += 1;
                    break;
                }
            }
        }
    }

    return new_alerts;
}

/// Returns the number of active alerts.
pub export fn siem_alert_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].alert_count;
}

/// Returns the AlertState tag for an alert.
pub export fn siem_alert_state(slot: c_int, alert_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (alert_id >= MAX_ALERTS) return 0;
    if (!sessions[idx].alerts[alert_id].active) return 0;
    return @intFromEnum(sessions[idx].alerts[alert_id].state);
}

/// Transition an alert to a new state. Returns 0 on success, 1 on rejection.
pub export fn siem_alert_transition(slot: c_int, alert_id: u32, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (alert_id >= MAX_ALERTS) return 1;
    if (!sessions[idx].alerts[alert_id].active) return 1;
    if (new_state > 4) return 1;

    const current = @intFromEnum(sessions[idx].alerts[alert_id].state);
    // Valid transitions: New->Ack, Ack->InProgress, InProgress->Resolved,
    // any->FalsePositive
    if (new_state == 4) {
        // FalsePositive from any state
        sessions[idx].alerts[alert_id].state = .false_positive;
        return 0;
    }
    if (new_state == current + 1) {
        sessions[idx].alerts[alert_id].state = @enumFromInt(new_state);
        return 0;
    }
    return 1;
}

/// Start the engine. Transitions Idle -> Running.
pub export fn siem_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .idle) return 1;
    sessions[idx].state = .running;
    return 0;
}

/// Pause the engine. Transitions Running -> Paused.
pub export fn siem_pause(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    sessions[idx].state = .paused;
    return 0;
}

/// Resume the engine. Transitions Paused -> Running.
pub export fn siem_resume(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .paused) return 1;
    sessions[idx].state = .running;
    return 0;
}

/// Disconnect. Returns 0 on success, 1 on rejection.
pub export fn siem_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .running or state == .paused) {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

/// Cleanup. Transitions Disconnecting -> Destroyed.
pub export fn siem_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;
    sessions[idx].state = .destroyed;
    sessions[idx].events = [_]Event{empty_event} ** MAX_EVENTS;
    sessions[idx].event_count = 0;
    sessions[idx].alerts = [_]Alert{empty_alert} ** MAX_ALERTS;
    sessions[idx].alert_count = 0;
    return 0;
}

/// Check if an engine state transition is valid.
pub export fn siem_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Running
    if (from == 1 and to == 2) return 1; // Running -> Paused
    if (from == 2 and to == 1) return 1; // Paused -> Running
    if (from == 0 and to == 3) return 1; // Idle -> Disconnecting
    if (from == 1 and to == 3) return 1; // Running -> Disconnecting
    if (from == 2 and to == 3) return 1; // Paused -> Disconnecting
    if (from == 3 and to == 4) return 1; // Disconnecting -> Destroyed
    return 0;
}
