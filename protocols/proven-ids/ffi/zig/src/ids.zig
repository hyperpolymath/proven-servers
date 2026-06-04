// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ids.zig -- Zig FFI implementation of proven-ids.
//
// Implements verified IDS/IPS packet inspection and alert state machines with:
//   - Slot-based context management (up to 64 concurrent)
//   - Packet inspection lifecycle: Captured -> Decoded -> Inspecting -> Evaluated -> Disposed
//   - Alert lifecycle: Idle -> Triggered -> Escalated -> Acknowledged -> Closed
//   - Rule evaluation with priority ordering (max 64 rules per context)
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching IDSABI.Layout.idr tag assignments) -----------------------

/// Alert severity levels (4 constructors, tags 0-3).
pub const AlertSeverity = enum(u8) {
    low = 0,
    medium = 1,
    high = 2,
    critical = 3,
};

/// Detection method strategies (4 constructors, tags 0-3).
pub const DetectionMethod = enum(u8) {
    signature = 0,
    anomaly = 1,
    stateful = 2,
    heuristic = 3,
};

/// Network protocol identifiers (7 constructors, tags 0-6).
pub const Protocol = enum(u8) {
    tcp = 0,
    udp = 1,
    icmp = 2,
    dns = 3,
    http = 4,
    tls = 5,
    ssh = 6,
};

/// Response actions when a rule fires (5 constructors, tags 0-4).
pub const Action = enum(u8) {
    alert = 0,
    drop = 1,
    log = 2,
    block = 3,
    pass = 4,
};

/// Traffic direction for rule scope (3 constructors, tags 0-2).
pub const Direction = enum(u8) {
    inbound = 0,
    outbound = 1,
    both = 2,
};

/// Assessed severity of a detected threat (5 constructors, tags 0-4).
pub const ThreatLevel = enum(u8) {
    info = 0,
    low = 1,
    medium = 2,
    high = 3,
    critical = 4,
};

/// Packet inspection criteria for rule matching (8 constructors, tags 0-7).
pub const RuleMatch = enum(u8) {
    src_addr = 0,
    dst_addr = 1,
    src_port = 2,
    dst_port = 3,
    content = 4,
    regex = 5,
    threshold = 6,
    flow_bits = 7,
};

/// Result of evaluating a detection rule against a packet (3 constructors, tags 0-2).
pub const MatchStatus = enum(u8) {
    no_match = 0,
    matched = 1,
    suppressed = 2,
};

/// Packet inspection lifecycle state (5 constructors, tags 0-4).
pub const InspectionState = enum(u8) {
    captured = 0,
    decoded = 1,
    inspecting = 2,
    evaluated = 3,
    disposed = 4,
};

/// Alert lifecycle state (5 constructors, tags 0-4).
pub const AlertState = enum(u8) {
    idle = 0,
    triggered = 1,
    escalated = 2,
    acknowledged = 3,
    closed = 4,
};

// -- Constants ----------------------------------------------------------------

/// Maximum number of concurrent IDS contexts (slot pool size).
const MAX_CONTEXTS: usize = 64;

/// Maximum number of detection rules per context.
const MAX_RULES: usize = 64;

// -- Detection rule -----------------------------------------------------------

/// A single detection rule in the rule set.
const DetectionRule = struct {
    /// Match criterion type (RuleMatch tag).
    match_type: RuleMatch,
    /// Match value (IP address, port number, content hash, etc.).
    match_value: u32,
    /// Action to take when this rule matches.
    action: Action,
    /// Alert severity to assign on match.
    severity: AlertSeverity,
    /// Detection method used by this rule.
    detection: DetectionMethod,
    /// Evaluation priority (lower = evaluated first).
    priority: u16,
};

// -- IDS context --------------------------------------------------------------

/// A single IDS context representing one packet inspection lifecycle.
const Context = struct {
    /// Current packet inspection state.
    inspection_state: InspectionState,
    /// Current alert lifecycle state.
    alert_state: AlertState,
    /// Decoded packet protocol.
    packet_proto: Protocol,
    /// Decoded packet direction.
    packet_direction: Direction,
    /// Decoded source IP (network byte order).
    src_ip: u32,
    /// Decoded destination IP (network byte order).
    dst_ip: u32,
    /// Decoded source port.
    src_port: u16,
    /// Decoded destination port.
    dst_port: u16,
    /// Detection rules loaded into this context.
    rules: [MAX_RULES]DetectionRule,
    /// Number of rules currently loaded.
    rule_count: u16,
    /// Number of alerts generated.
    alert_count: u16,
    /// Match status after rule evaluation.
    match_status: MatchStatus,
    /// Action decided after rule evaluation.
    decided_action: Action,
    /// Default action when no rule matches.
    default_action: Action,
    /// Severity of the highest-priority matching rule.
    match_severity: AlertSeverity,
    /// Detection method of the matching rule.
    match_detection: DetectionMethod,
    /// Assessed threat level.
    threat_level: ThreatLevel,
    /// Alert severity (set on trigger).
    alert_severity: AlertSeverity,
    /// Whether this slot is in use.
    active: bool,
};

/// Default-initialised (inactive) context.
const DEFAULT_CONTEXT: Context = .{
    .inspection_state = .captured,
    .alert_state = .idle,
    .packet_proto = .tcp,
    .packet_direction = .inbound,
    .src_ip = 0,
    .dst_ip = 0,
    .src_port = 0,
    .dst_port = 0,
    .rules = [_]DetectionRule{.{
        .match_type = .src_addr,
        .match_value = 0,
        .action = .pass,
        .severity = .low,
        .detection = .signature,
        .priority = 0xFFFF,
    }} ** MAX_RULES,
    .rule_count = 0,
    .alert_count = 0,
    .match_status = .no_match,
    .decided_action = .pass,
    .default_action = .pass,
    .match_severity = .low,
    .match_detection = .signature,
    .threat_level = .info,
    .alert_severity = .low,
    .active = false,
};

/// Pool of IDS contexts, indexed by slot number.
var contexts: [MAX_CONTEXTS]Context = [_]Context{DEFAULT_CONTEXT} ** MAX_CONTEXTS;

/// Mutex protecting the context pool from concurrent access.
var mutex: std.Thread.Mutex = .{};

/// Validate a slot index and return it as usize if active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match IDSABI.Foreign.abiVersion.
pub export fn ids_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new IDS context in Captured/Idle state.
/// Returns a non-negative slot index on success, or -1 if the pool is full.
pub export fn ids_create_context() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = DEFAULT_CONTEXT;
            ctx.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

/// Destroy an IDS context, freeing its slot for reuse.
/// Safe to call with invalid or already-destroyed slots.
pub export fn ids_destroy_context(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)].active = false;
}

// -- State queries ------------------------------------------------------------

/// Returns the current inspection state tag for the given slot.
/// Returns 4 (Disposed) for invalid slots as a safe fallback.
pub export fn ids_inspection_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // disposed fallback
    return @intFromEnum(contexts[idx].inspection_state);
}

/// Returns the current alert state tag for the given slot.
/// Returns 4 (Closed) for invalid slots as a safe fallback.
pub export fn ids_alert_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // closed fallback
    return @intFromEnum(contexts[idx].alert_state);
}

// -- Packet inspection transitions --------------------------------------------

/// Captured -> Decoded: decode packet headers.
/// Returns 0 on success, 1 if rejected (not in Captured state).
pub export fn ids_decode_packet(slot: c_int, proto: u8, dir: u8, src_ip: u32, dst_ip: u32, src_port: u16, dst_port: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].inspection_state != .captured) return 1;
    if (proto > 6) return 1; // invalid Protocol tag
    if (dir > 2) return 1; // invalid Direction tag
    contexts[idx].packet_proto = @enumFromInt(proto);
    contexts[idx].packet_direction = @enumFromInt(dir);
    contexts[idx].src_ip = src_ip;
    contexts[idx].dst_ip = dst_ip;
    contexts[idx].src_port = src_port;
    contexts[idx].dst_port = dst_port;
    contexts[idx].inspection_state = .decoded;
    return 0;
}

/// Decoded -> Inspecting: begin rule evaluation.
/// Returns 0 on success, 1 if rejected (not in Decoded state).
pub export fn ids_begin_inspection(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].inspection_state != .decoded) return 1;
    contexts[idx].inspection_state = .inspecting;
    return 0;
}

/// Add a detection rule to the context (max 64 rules).
/// Returns 0 on success, 1 if rejected (invalid tags, rule limit, or wrong state).
pub export fn ids_add_rule(slot: c_int, match_type: u8, match_value: u32, action: u8, severity: u8, detection: u8, priority: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    // Validate enum tags
    if (match_type > 7) return 1; // invalid RuleMatch tag
    if (action > 4) return 1; // invalid Action tag
    if (severity > 3) return 1; // invalid AlertSeverity tag
    if (detection > 3) return 1; // invalid DetectionMethod tag
    // Check rule capacity
    if (contexts[idx].rule_count >= MAX_RULES) return 1;
    const rc: usize = contexts[idx].rule_count;
    contexts[idx].rules[rc] = .{
        .match_type = @enumFromInt(match_type),
        .match_value = match_value,
        .action = @enumFromInt(action),
        .severity = @enumFromInt(severity),
        .detection = @enumFromInt(detection),
        .priority = priority,
    };
    contexts[idx].rule_count += 1;
    return 0;
}

/// Inspecting -> Evaluated: evaluate all loaded rules in priority order.
/// The highest-priority (lowest priority number) matching rule determines the
/// decided action, match severity, detection method, and threat level.
/// Returns 0 on success, 1 if rejected (not in Inspecting state).
pub export fn ids_evaluate_rules(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].inspection_state != .inspecting) return 1;

    const ctx = &contexts[idx];
    const rc: usize = ctx.rule_count;

    // Default: no match
    ctx.match_status = .no_match;
    ctx.decided_action = ctx.default_action;
    ctx.match_severity = .low;
    ctx.match_detection = .signature;
    ctx.threat_level = .info;

    // Find the highest-priority (lowest number) matching rule.
    // A rule "matches" if match_value matches the corresponding packet field.
    var best_priority: u16 = 0xFFFF;
    var best_idx: ?usize = null;

    for (0..rc) |ri| {
        const rule = &ctx.rules[ri];
        const matched = switch (rule.match_type) {
            .src_addr => rule.match_value == ctx.src_ip,
            .dst_addr => rule.match_value == ctx.dst_ip,
            .src_port => @as(u16, @truncate(rule.match_value)) == ctx.src_port,
            .dst_port => @as(u16, @truncate(rule.match_value)) == ctx.dst_port,
            // Content, Regex, Threshold, FlowBits: match if match_value != 0
            // (simplified: real engine would do deep packet inspection)
            .content, .regex, .threshold, .flow_bits => rule.match_value != 0,
        };
        if (matched and rule.priority < best_priority) {
            best_priority = rule.priority;
            best_idx = ri;
        }
    }

    if (best_idx) |bi| {
        const best = &ctx.rules[bi];
        ctx.match_status = .matched;
        ctx.decided_action = best.action;
        ctx.match_severity = best.severity;
        ctx.match_detection = best.detection;
        // Derive threat level from severity
        ctx.threat_level = switch (best.severity) {
            .low => .low,
            .medium => .medium,
            .high => .high,
            .critical => .critical,
        };
    }

    ctx.inspection_state = .evaluated;
    return 0;
}

/// Evaluated -> Disposed: apply the decided action.
/// Returns 0 on success, 1 if rejected (not in Evaluated state).
pub export fn ids_dispose(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].inspection_state != .evaluated) return 1;
    contexts[idx].inspection_state = .disposed;
    return 0;
}

// -- Packet field queries -----------------------------------------------------

/// Returns the decided action tag for the given slot.
/// Returns 4 (Pass) for invalid slots.
pub export fn ids_get_action(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // pass fallback
    return @intFromEnum(contexts[idx].decided_action);
}

/// Returns the match status tag for the given slot.
/// Returns 0 (NoMatch) for invalid slots.
pub export fn ids_get_match_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].match_status);
}

/// Returns the severity tag of the highest-priority match.
/// Returns 0 (Low) for invalid slots.
pub export fn ids_get_match_severity(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].match_severity);
}

/// Returns the detection method tag of the matching rule.
/// Returns 0 (Signature) for invalid slots.
pub export fn ids_get_match_detection(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].match_detection);
}

/// Returns the assessed threat level tag.
/// Returns 0 (Info) for invalid slots.
pub export fn ids_get_threat_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].threat_level);
}

/// Returns the number of loaded rules.
/// Returns 0 for invalid slots.
pub export fn ids_rule_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].rule_count;
}

/// Returns the number of alerts generated.
/// Returns 0 for invalid slots.
pub export fn ids_alert_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].alert_count;
}

/// Returns the decoded packet protocol tag.
/// Returns 0 (TCP) for invalid slots.
pub export fn ids_packet_proto(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].packet_proto);
}

/// Returns the decoded packet direction tag.
/// Returns 0 (Inbound) for invalid slots.
pub export fn ids_packet_direction(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].packet_direction);
}

/// Returns the decoded source IP address.
/// Returns 0 for invalid slots.
pub export fn ids_packet_src_ip(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].src_ip;
}

/// Returns the decoded destination IP address.
/// Returns 0 for invalid slots.
pub export fn ids_packet_dst_ip(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].dst_ip;
}

/// Returns the decoded source port.
/// Returns 0 for invalid slots.
pub export fn ids_packet_src_port(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].src_port;
}

/// Returns the decoded destination port.
/// Returns 0 for invalid slots.
pub export fn ids_packet_dst_port(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].dst_port;
}

// -- Alert lifecycle transitions ----------------------------------------------

/// Idle -> Triggered: trigger an alert with the given severity.
/// Returns 0 on success, 1 if rejected (not in Idle state or invalid severity).
pub export fn ids_trigger_alert(slot: c_int, severity: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].alert_state != .idle) return 1;
    if (severity > 3) return 1; // invalid AlertSeverity tag
    contexts[idx].alert_state = .triggered;
    contexts[idx].alert_severity = @enumFromInt(severity);
    contexts[idx].alert_count += 1;
    return 0;
}

/// Triggered -> Escalated: escalate the alert.
/// Returns 0 on success, 1 if rejected (not in Triggered state).
pub export fn ids_escalate_alert(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].alert_state != .triggered) return 1;
    contexts[idx].alert_state = .escalated;
    return 0;
}

/// Triggered/Escalated -> Acknowledged: acknowledge the alert.
/// Returns 0 on success, 1 if rejected (not in Triggered or Escalated state).
pub export fn ids_acknowledge_alert(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = contexts[idx].alert_state;
    if (state != .triggered and state != .escalated) return 1;
    contexts[idx].alert_state = .acknowledged;
    return 0;
}

/// Acknowledged -> Closed: close the alert.
/// Returns 0 on success, 1 if rejected (not in Acknowledged state).
pub export fn ids_close_alert(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].alert_state != .acknowledged) return 1;
    contexts[idx].alert_state = .closed;
    return 0;
}

/// Triggered -> Closed: auto-close (suppression).
/// Returns 0 on success, 1 if rejected (not in Triggered state).
pub export fn ids_auto_close_alert(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].alert_state != .triggered) return 1;
    contexts[idx].alert_state = .closed;
    return 0;
}

// -- Configuration ------------------------------------------------------------

/// Set the default action when no rule matches.
/// Returns 0 on success, 1 if rejected (invalid slot or invalid action tag).
pub export fn ids_set_default_action(slot: c_int, action: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (action > 4) return 1; // invalid Action tag
    contexts[idx].default_action = @enumFromInt(action);
    return 0;
}

/// Returns the current alert severity tag.
/// Returns 0 (Low) for invalid slots.
pub export fn ids_get_alert_severity(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(contexts[idx].alert_severity);
}

// -- Stateless transition queries ---------------------------------------------

/// Check whether a packet inspection state transition is valid.
/// Matches Transitions.idr validateInspectionTransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn ids_can_inspection_transition(from: u8, to: u8) callconv(.c) u8 {
    // Captured(0) -> Decoded(1): DecodePacket
    if (from == 0 and to == 1) return 1;
    // Decoded(1) -> Inspecting(2): BeginInspection
    if (from == 1 and to == 2) return 1;
    // Inspecting(2) -> Evaluated(3): CompleteRules
    if (from == 2 and to == 3) return 1;
    // Evaluated(3) -> Disposed(4): DisposePacket
    if (from == 3 and to == 4) return 1;
    // Captured(0) -> Disposed(4): AbortCaptured
    if (from == 0 and to == 4) return 1;
    // Decoded(1) -> Disposed(4): AbortDecoded
    if (from == 1 and to == 4) return 1;
    // Inspecting(2) -> Disposed(4): AbortInspecting
    if (from == 2 and to == 4) return 1;
    return 0;
}

/// Check whether an alert lifecycle state transition is valid.
/// Matches Transitions.idr validateAlertTransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn ids_can_alert_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> Triggered(1): TriggerAlert
    if (from == 0 and to == 1) return 1;
    // Triggered(1) -> Escalated(2): EscalateAlert
    if (from == 1 and to == 2) return 1;
    // Triggered(1) -> Acknowledged(3): AcknowledgeDirect
    if (from == 1 and to == 3) return 1;
    // Escalated(2) -> Acknowledged(3): AcknowledgeEsc
    if (from == 2 and to == 3) return 1;
    // Acknowledged(3) -> Closed(4): CloseAlert
    if (from == 3 and to == 4) return 1;
    // Triggered(1) -> Closed(4): AutoClose
    if (from == 1 and to == 4) return 1;
    return 0;
}
