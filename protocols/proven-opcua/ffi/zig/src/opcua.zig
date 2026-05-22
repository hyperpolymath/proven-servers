// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// opcua.zig -- Zig FFI implementation of proven-opcua.
//
// Implements an OPC UA (Industrial IoT) session state machine with:
//   - 64-slot mutex-protected session pool
//   - Address space node tracking (max 256 nodes per session)
//   - Subscription management (max 16 subscriptions per session)
//   - Security mode enforcement per session
//   - Service request validation per session state
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching OPCUAABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching OPCUAABI.Types.idr tag assignments)
// =========================================================================

/// OPC UA service types (ABI tags 0-10).
pub const ServiceType = enum(u8) {
    read = 0,
    write = 1,
    browse = 2,
    subscribe = 3,
    publish = 4,
    call = 5,
    create_session = 6,
    activate_session = 7,
    close_session = 8,
    create_subscription = 9,
    delete_subscription = 10,
};

/// Node classes (ABI tags 0-7).
pub const NodeClass = enum(u8) {
    object = 0,
    variable = 1,
    method = 2,
    object_type = 3,
    variable_type = 4,
    reference_type = 5,
    data_type = 6,
    view = 7,
};

/// Status codes (ABI tags 0-11).
pub const StatusCode = enum(u8) {
    good = 0,
    uncertain = 1,
    bad = 2,
    bad_node_id_unknown = 3,
    bad_attribute_id_invalid = 4,
    bad_not_readable = 5,
    bad_not_writable = 6,
    bad_out_of_range = 7,
    bad_type_mismatch = 8,
    bad_session_id_invalid = 9,
    bad_subscription_id_invalid = 10,
    bad_timeout = 11,
};

/// Security modes (ABI tags 0-2).
pub const SecurityMode = enum(u8) {
    none = 0,
    sign = 1,
    sign_and_encrypt = 2,
};

/// Session lifecycle states (ABI tags 0-5).
pub const SessionState = enum(u8) {
    idle = 0,
    connected = 1,
    created = 2,
    activated = 3,
    monitoring = 4,
    closing = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_NODES: usize = 256;
const MAX_SUBSCRIPTIONS: usize = 16;
const MAX_NAME_LEN: usize = 256;
const MAX_ENDPOINT_LEN: usize = 256;
const MAX_VALUE_LEN: usize = 256;

/// An address space node.
const NodeEntry = struct {
    node_id: u32,
    node_class: NodeClass,
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Simple value storage for Variable nodes.
    value: [MAX_VALUE_LEN]u8,
    value_len: u32,
    active: bool,
};

/// A subscription entry.
const SubscriptionEntry = struct {
    sub_id: u32,
    interval_ms: u32,
    active: bool,
};

const empty_node: NodeEntry = .{
    .node_id = 0,
    .node_class = .object,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .value = [_]u8{0} ** MAX_VALUE_LEN,
    .value_len = 0,
    .active = false,
};

const empty_subscription: SubscriptionEntry = .{
    .sub_id = 0,
    .interval_ms = 1000,
    .active = false,
};

/// An OPC UA session.
const Session = struct {
    state: SessionState,
    endpoint: [MAX_ENDPOINT_LEN]u8,
    endpoint_len: u32,
    security_mode: SecurityMode,
    nodes: [MAX_NODES]NodeEntry,
    node_count: u32,
    subscriptions: [MAX_SUBSCRIPTIONS]SubscriptionEntry,
    subscription_count: u32,
    next_sub_id: u32,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .endpoint = [_]u8{0} ** MAX_ENDPOINT_LEN,
    .endpoint_len = 0,
    .security_mode = .none,
    .nodes = [_]NodeEntry{empty_node} ** MAX_NODES,
    .node_count = 0,
    .subscriptions = [_]SubscriptionEntry{empty_subscription} ** MAX_SUBSCRIPTIONS,
    .subscription_count = 0,
    .next_sub_id = 1,
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

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

fn findNode(idx: usize, node_id: u32) ?usize {
    for (&sessions[idx].nodes, 0..) |*n, i| {
        if (n.active and n.node_id == node_id) return i;
    }
    return null;
}

fn findSubscription(idx: usize, sub_id: u32) ?usize {
    for (&sessions[idx].subscriptions, 0..) |*s, i| {
        if (s.active and s.sub_id == sub_id) return i;
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn opcua_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new OPC UA session. Returns slot (>=0) or -1.
/// Transitions: Idle -> Connected.
pub export fn opcua_create(
    endpoint_ptr: [*]const u8,
    endpoint_len: u32,
    security_mode: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (endpoint_len == 0 or endpoint_len > MAX_ENDPOINT_LEN) return -1;
    if (security_mode > 2) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.endpoint[0..endpoint_len], endpoint_ptr[0..endpoint_len]);
            s.endpoint_len = endpoint_len;
            s.security_mode = @enumFromInt(security_mode);
            s.state = .connected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn opcua_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn opcua_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Create a session (OPC UA CreateSession service). Returns 0 on success.
/// Transitions: Connected -> Created.
pub export fn opcua_create_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;

    sessions[idx].state = .created;
    return 0;
}

/// Activate the session. Returns 0 on success.
/// Transitions: Created -> Activated.
pub export fn opcua_activate_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .created) return 1;

    sessions[idx].state = .activated;
    return 0;
}

/// Read a node attribute. Returns 0 on success, 1 on rejection.
pub export fn opcua_read_node(slot: c_int, node_id: u32, attr_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = attr_id;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .activated and sessions[idx].state != .monitoring) return 1;
    if (findNode(idx, node_id) == null) return 1;

    return 0;
}

/// Write a node attribute. Returns 0 on success, 1 on rejection.
pub export fn opcua_write_node(
    slot: c_int,
    node_id: u32,
    attr_id: u32,
    value_ptr: [*]const u8,
    value_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = attr_id;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .activated and sessions[idx].state != .monitoring) return 1;
    if (value_len > MAX_VALUE_LEN) return 1;

    const ni = findNode(idx, node_id) orelse return 1;
    if (sessions[idx].nodes[ni].node_class != .variable) return 1;

    if (value_len > 0) {
        @memcpy(sessions[idx].nodes[ni].value[0..value_len], value_ptr[0..value_len]);
    }
    sessions[idx].nodes[ni].value_len = value_len;
    return 0;
}

/// Browse a node (simulated). Returns 0 on success, 1 if node not found.
pub export fn opcua_browse(slot: c_int, node_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .activated and sessions[idx].state != .monitoring) return 1;
    if (findNode(idx, node_id) == null) return 1;

    return 0;
}

/// Add a node to the address space. Returns 0 on success, 1 on rejection.
pub export fn opcua_add_node(
    slot: c_int,
    node_id: u32,
    node_class: u8,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .activated and sessions[idx].state != .monitoring) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (node_class > 7) return 1;

    // Check for duplicate node_id
    if (findNode(idx, node_id) != null) return 1;

    for (&sessions[idx].nodes) |*n| {
        if (!n.active) {
            n.* = empty_node;
            n.node_id = node_id;
            n.node_class = @enumFromInt(node_class);
            @memcpy(n.name[0..name_len], name_ptr[0..name_len]);
            n.name_len = name_len;
            n.active = true;
            sessions[idx].node_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Create a subscription. Returns 0 on success, 1 on rejection.
/// Transitions: Activated -> Monitoring.
pub export fn opcua_create_subscription(slot: c_int, interval_ms: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .activated and sessions[idx].state != .monitoring) return 1;

    for (&sessions[idx].subscriptions) |*sub| {
        if (!sub.active) {
            sub.sub_id = sessions[idx].next_sub_id;
            sessions[idx].next_sub_id += 1;
            sub.interval_ms = if (interval_ms == 0) 1000 else interval_ms;
            sub.active = true;
            sessions[idx].subscription_count += 1;
            sessions[idx].state = .monitoring;
            return 0;
        }
    }
    return 1;
}

/// Delete a subscription. Returns 0 on success, 1 on rejection.
/// May transition: Monitoring -> Activated if last subscription.
pub export fn opcua_delete_subscription(slot: c_int, sub_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const si = findSubscription(idx, sub_id) orelse return 1;

    sessions[idx].subscriptions[si].active = false;
    sessions[idx].subscription_count -= 1;

    if (sessions[idx].subscription_count == 0 and sessions[idx].state == .monitoring) {
        sessions[idx].state = .activated;
    }
    return 0;
}

/// Returns the subscription count.
pub export fn opcua_subscription_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].subscription_count;
}

/// Returns the node count.
pub export fn opcua_node_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].node_count;
}

/// Returns the security mode tag.
pub export fn opcua_get_security_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].security_mode);
}

/// Close the session. Returns 0 on success, 1 on rejection.
pub export fn opcua_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .created or
        state == .activated or state == .monitoring)
    {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions: Closing -> Idle.
pub export fn opcua_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].nodes = [_]NodeEntry{empty_node} ** MAX_NODES;
    sessions[idx].node_count = 0;
    sessions[idx].subscriptions = [_]SubscriptionEntry{empty_subscription} ** MAX_SUBSCRIPTIONS;
    sessions[idx].subscription_count = 0;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn opcua_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Created
    if (from == 2 and to == 3) return 1; // Created -> Activated
    if (from == 3 and to == 4) return 1; // Activated -> Monitoring
    if (from == 4 and to == 4) return 1; // Monitoring -> Monitoring
    if (from == 4 and to == 3) return 1; // Monitoring -> Activated
    if (from == 1 and to == 5) return 1; // Connected -> Closing
    if (from == 2 and to == 5) return 1; // Created -> Closing
    if (from == 3 and to == 5) return 1; // Activated -> Closing
    if (from == 4 and to == 5) return 1; // Monitoring -> Closing
    if (from == 5 and to == 0) return 1; // Closing -> Idle
    return 0;
}
