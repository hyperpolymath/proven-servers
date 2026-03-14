// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// firewall.zig -- Zig FFI implementation of proven-firewall.
//
// Implements the verified firewall packet lifecycle state machine with:
//   - 64-slot mutex-protected context pool
//   - State machine enforcement matching Idris2 FirewallABI.Transitions.idr
//   - Rule chain (fixed array of 64 rules per context, priority-ordered)
//   - Connection tracking table with stateful inspection
//   - Thread-safe via per-slot mutex pool

const std = @import("std");

// -- Enums (matching FirewallABI.Layout.idr tag assignments) -------------------

/// Firewall rule actions (ABI tags 0-7, matching Layout.idr).
pub const Action = enum(u8) {
    accept = 0,
    drop = 1,
    reject = 2,
    log = 3,
    redirect = 4,
    dnat = 5,
    snat = 6,
    masquerade = 7,
};

/// IP protocols (ABI tags 0-7, matching Layout.idr).
pub const Protocol = enum(u8) {
    tcp = 0,
    udp = 1,
    icmp = 2,
    icmpv6 = 3,
    gre = 4,
    esp = 5,
    ah = 6,
    any = 7,
};

/// Netfilter chain types (ABI tags 0-4, matching Layout.idr).
pub const ChainType = enum(u8) {
    input = 0,
    output = 1,
    forward = 2,
    pre_routing = 3,
    post_routing = 4,
};

/// Rule match criteria types (ABI tags 0-7, matching Layout.idr).
pub const RuleMatchType = enum(u8) {
    source_ip = 0,
    dest_ip = 1,
    source_port = 2,
    dest_port = 3,
    match_proto = 4,
    interface = 5,
    state = 6,
    mark = 7,
};

/// Connection tracking states (ABI tags 0-3, matching Layout.idr).
pub const ConnState = enum(u8) {
    new = 0,
    established = 1,
    related = 2,
    invalid = 3,
};

/// Packet lifecycle states (matching FirewallABI.Transitions.idr).
pub const PacketState = enum(u8) {
    arrived = 0,
    classified = 1,
    chain_traversal = 2,
    decided = 3,
    committed = 4,
};

/// Connection tracking states (matching FirewallABI.Transitions.idr).
pub const ConnTrackState = enum(u8) {
    untracked = 0,
    tracking = 1,
    tracked = 2,
    expired = 3,
};

// -- Rule storage -------------------------------------------------------------

/// A single firewall rule in a chain.
const Rule = struct {
    /// Type of match criterion (RuleMatchType tag).
    match_type: u8,
    /// Value to match against (interpretation depends on match_type).
    /// For IP: packed IPv4 address. For port: port number in low 16 bits.
    /// For protocol: Protocol tag. For state: ConnState tag. For mark: mark value.
    match_value: u32,
    /// Action to take on match (Action tag).
    action: u8,
    /// Priority (lower = evaluated first).
    priority: u16,
    /// Whether this rule slot is active.
    active: bool,
};

/// Maximum number of rules per chain.
const MAX_RULES: u16 = 64;

/// The default (empty) rule used for array initialisation.
const empty_rule: Rule = .{
    .match_type = 255,
    .match_value = 0,
    .action = 0,
    .priority = 0xFFFF,
    .active = false,
};

// -- Firewall context ---------------------------------------------------------

/// A firewall packet processing context.
const Context = struct {
    /// Current packet lifecycle state.
    packet_state: PacketState,
    /// Current connection tracking state.
    conntrack_state: ConnTrackState,
    /// Tracked connection state (valid when conntrack_state == tracked).
    conn_state: u8,
    /// Decided action (valid when packet_state == decided or committed).
    decision: u8,
    /// Default action when no rule matches.
    default_action: u8,
    /// Packet protocol (Protocol tag).
    proto: u8,
    /// Chain type being traversed (ChainType tag).
    chain: u8,
    /// Source IPv4 address (packed, network byte order).
    src_ip: u32,
    /// Destination IPv4 address (packed, network byte order).
    dst_ip: u32,
    /// Source port (host byte order).
    src_port: u16,
    /// Destination port (host byte order).
    dst_port: u16,
    /// Whether this slot is in use.
    active: bool,
    /// Rule chain (fixed array of MAX_RULES entries).
    rules: [64]Rule,
    /// Number of active rules in the chain.
    rule_count: u16,
};

const MAX_CONTEXTS: usize = 64;

/// The default (empty) context used for array initialisation.
const empty_context: Context = .{
    .packet_state = .arrived,
    .conntrack_state = .untracked,
    .conn_state = 255,
    .decision = 255,
    .default_action = 1, // drop by default
    .proto = 255,
    .chain = 255,
    .src_ip = 0,
    .dst_ip = 0,
    .src_port = 0,
    .dst_port = 0,
    .active = false,
    .rules = [_]Rule{empty_rule} ** 64,
    .rule_count = 0,
};

var contexts: [MAX_CONTEXTS]Context = [_]Context{empty_context} ** MAX_CONTEXTS;

/// Per-slot mutex pool for thread safety.
var mutexes: [MAX_CONTEXTS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_CONTEXTS;

/// Global mutex for slot allocation/deallocation.
var global_mutex: std.Thread.Mutex = .{};

/// Validate and return the slot index, or null if invalid/inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- ABI version --------------------------------------------------------------

pub export fn fw_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

pub export fn fw_create_context() callconv(.c) c_int {
    global_mutex.lock();
    defer global_mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_context;
            ctx.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn fw_destroy_context(slot: c_int) callconv(.c) void {
    global_mutex.lock();
    defer global_mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// -- State queries ------------------------------------------------------------

pub export fn fw_packet_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 4; // committed as fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(contexts[idx].packet_state);
}

pub export fn fw_conntrack_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 0; // untracked fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(contexts[idx].conntrack_state);
}

pub export fn fw_get_decision(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1; // drop fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].decision;
}

pub export fn fw_rule_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].rule_count;
}

pub export fn fw_packet_proto(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].proto;
}

pub export fn fw_packet_chain(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].chain;
}

pub export fn fw_packet_src_ip(slot: c_int) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].src_ip;
}

pub export fn fw_packet_dst_ip(slot: c_int) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].dst_ip;
}

pub export fn fw_packet_src_port(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].src_port;
}

pub export fn fw_packet_dst_port(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].dst_port;
}

pub export fn fw_conn_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 255;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].conn_state;
}

// -- Packet lifecycle transitions ---------------------------------------------

/// Classify a packet: parse protocol, chain, addresses, and ports.
/// Transitions: Arrived -> Classified.
pub export fn fw_classify_packet(slot: c_int, proto: u8, chain: u8, src_ip: u32, dst_ip: u32, src_port: u16, dst_port: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].packet_state != .arrived) return 1;
    if (proto > 7) return 1; // invalid Protocol tag
    if (chain > 4) return 1; // invalid ChainType tag

    contexts[idx].proto = proto;
    contexts[idx].chain = chain;
    contexts[idx].src_ip = src_ip;
    contexts[idx].dst_ip = dst_ip;
    contexts[idx].src_port = src_port;
    contexts[idx].dst_port = dst_port;
    contexts[idx].packet_state = .classified;
    return 0;
}

/// Begin walking the rule chain.
/// Transitions: Classified -> ChainTraversal.
pub export fn fw_begin_chain(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].packet_state != .classified) return 1;
    contexts[idx].packet_state = .chain_traversal;
    return 0;
}

/// Add a rule to the chain.
/// Only valid in ChainTraversal state (rules can be dynamically loaded).
/// Maximum 64 rules per context.
pub export fn fw_add_rule(slot: c_int, match_type: u8, match_value: u32, action: u8, priority: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].packet_state != .chain_traversal) return 1;
    if (match_type > 7) return 1; // invalid RuleMatchType tag
    if (action > 7) return 1; // invalid Action tag
    if (contexts[idx].rule_count >= MAX_RULES) return 1; // chain full

    const count = contexts[idx].rule_count;
    contexts[idx].rules[count] = .{
        .match_type = match_type,
        .match_value = match_value,
        .action = action,
        .priority = priority,
        .active = true,
    };
    contexts[idx].rule_count += 1;
    return 0;
}

/// Set the default action when no rule matches.
pub export fn fw_set_default_action(slot: c_int, action: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (action > 7) return 1; // invalid Action tag
    contexts[idx].default_action = action;
    return 0;
}

/// Evaluate rules in priority order and decide on an action.
/// Transitions: ChainTraversal -> Decided.
/// Rules are evaluated in priority order (lowest first).
/// The first matching rule determines the action.
/// If no rule matches, the default action is used.
pub export fn fw_evaluate_rules(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].packet_state != .chain_traversal) return 1;

    // Sort rules by priority (simple insertion sort -- max 64 rules).
    const count = contexts[idx].rule_count;
    var sorted_indices: [64]u16 = undefined;
    var i: u16 = 0;
    while (i < count) : (i += 1) {
        sorted_indices[i] = i;
    }
    // Insertion sort by priority.
    var j: u16 = 1;
    while (j < count) : (j += 1) {
        const key = sorted_indices[j];
        var k: i32 = @as(i32, @intCast(j)) - 1;
        while (k >= 0 and contexts[idx].rules[sorted_indices[@intCast(k)]].priority >
            contexts[idx].rules[key].priority) : (k -= 1)
        {
            sorted_indices[@intCast(k + 1)] = sorted_indices[@intCast(k)];
        }
        sorted_indices[@intCast(k + 1)] = key;
    }

    // Evaluate sorted rules against packet fields.
    var r: u16 = 0;
    while (r < count) : (r += 1) {
        const rule = contexts[idx].rules[sorted_indices[r]];
        if (!rule.active) continue;
        if (ruleMatches(rule, &contexts[idx])) {
            contexts[idx].decision = rule.action;
            contexts[idx].packet_state = .decided;
            return 0;
        }
    }

    // No rule matched -- apply default action.
    contexts[idx].decision = contexts[idx].default_action;
    contexts[idx].packet_state = .decided;
    return 0;
}

/// Check whether a rule matches the current packet in a context.
fn ruleMatches(rule: Rule, ctx: *const Context) bool {
    return switch (rule.match_type) {
        0 => ctx.src_ip == rule.match_value, // SourceIP
        1 => ctx.dst_ip == rule.match_value, // DestIP
        2 => ctx.src_port == @as(u16, @truncate(rule.match_value)), // SourcePort
        3 => ctx.dst_port == @as(u16, @truncate(rule.match_value)), // DestPort
        4 => ctx.proto == @as(u8, @truncate(rule.match_value)), // Protocol
        5 => true, // Interface match (simplified: always match for FFI layer)
        6 => ctx.conn_state == @as(u8, @truncate(rule.match_value)), // State
        7 => true, // Mark match (simplified: always match for FFI layer)
        else => false,
    };
}

/// Commit the decided action.
/// Transitions: Decided -> Committed.
pub export fn fw_commit(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].packet_state != .decided) return 1;
    contexts[idx].packet_state = .committed;
    return 0;
}

// -- Connection tracking operations -------------------------------------------

/// Begin connection tracking lookup.
/// Transitions: Untracked -> Tracking.
pub export fn fw_begin_tracking(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].conntrack_state != .untracked) return 1;
    contexts[idx].conntrack_state = .tracking;
    return 0;
}

/// Complete connection tracking with a determined connection state.
/// Transitions: Tracking -> Tracked.
pub export fn fw_complete_tracking(slot: c_int, conn_state_tag: u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].conntrack_state != .tracking) return 1;
    if (conn_state_tag > 3) return 1; // invalid ConnState tag
    contexts[idx].conn_state = conn_state_tag;
    contexts[idx].conntrack_state = .tracked;
    return 0;
}

/// Expire a tracked connection.
/// Transitions: Tracked -> Expired.
pub export fn fw_expire_conn(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].conntrack_state != .tracked) return 1;
    contexts[idx].conntrack_state = .expired;
    return 0;
}

// -- Stateless transition checks ----------------------------------------------

/// Check whether a packet lifecycle state transition is valid.
/// Matches FirewallABI.Transitions.validatePacketTransition exactly.
pub export fn fw_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Arrived -> Classified
    if (from == 1 and to == 2) return 1; // Classified -> ChainTraversal
    if (from == 2 and to == 3) return 1; // ChainTraversal -> Decided
    if (from == 3 and to == 4) return 1; // Decided -> Committed
    // Abort edges
    if (from == 0 and to == 4) return 1; // Arrived -> Committed
    if (from == 1 and to == 4) return 1; // Classified -> Committed
    if (from == 2 and to == 4) return 1; // ChainTraversal -> Committed
    return 0;
}

/// Check whether a connection tracking state transition is valid.
/// Matches FirewallABI.Transitions.validateConnTrackTransition exactly.
pub export fn fw_can_conntrack_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Untracked -> Tracking
    if (from == 1 and to == 2) return 1; // Tracking -> Tracked
    if (from == 2 and to == 3) return 1; // Tracked -> Expired
    return 0;
}
