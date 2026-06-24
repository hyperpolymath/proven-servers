// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// sdn.zig -- Zig FFI implementation of proven-sdn.
//
// Implements an OpenFlow-style SDN controller state machine with:
//   - 64-slot mutex-protected controller session pool
//   - Switch registration by datapath ID (DPID)
//   - Flow table management (install/remove rules)
//   - Port state tracking per switch (max 32 ports)
//   - OpenFlow message type validation
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching SDNABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching SDNABI.Types.idr tag assignments)
// =========================================================================

/// OpenFlow message types (ABI tags 0-11).
pub const MessageType = enum(u8) {
    hello = 0,
    err = 1,
    echo_request = 2,
    echo_reply = 3,
    features_request = 4,
    features_reply = 5,
    flow_mod = 6,
    packet_in = 7,
    packet_out = 8,
    port_status = 9,
    barrier_request = 10,
    barrier_reply = 11,
};

/// Flow actions (ABI tags 0-6).
pub const FlowAction = enum(u8) {
    output = 0,
    set_field = 1,
    drop = 2,
    push_vlan = 3,
    pop_vlan = 4,
    set_queue = 5,
    group = 6,
};

/// Match fields (ABI tags 0-10).
pub const MatchField = enum(u8) {
    in_port = 0,
    eth_dst = 1,
    eth_src = 2,
    eth_type = 3,
    vlan_id = 4,
    ip_src = 5,
    ip_dst = 6,
    tcp_src = 7,
    tcp_dst = 8,
    udp_src = 9,
    udp_dst = 10,
};

/// Port states (ABI tags 0-2).
pub const PortState = enum(u8) {
    up = 0,
    down = 1,
    blocked = 2,
};

/// Controller lifecycle states (ABI tags 0-5).
pub const ControllerState = enum(u8) {
    idle = 0,
    connected = 1,
    features_wait = 2,
    ready = 3,
    operating = 4,
    disconnecting = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum flow rules per session.
const MAX_FLOWS: usize = 128;

/// Maximum ports per switch.
const MAX_PORTS: usize = 32;

/// A flow rule entry.
const FlowEntry = struct {
    table_id: u8,
    priority: u16,
    match_field: MatchField,
    action: FlowAction,
    active: bool,
};

/// A port entry.
const PortEntry = struct {
    port_no: u16,
    state: PortState,
    active: bool,
};

/// Default (empty) flow entry.
const empty_flow: FlowEntry = .{
    .table_id = 0,
    .priority = 0,
    .match_field = .in_port,
    .action = .drop,
    .active = false,
};

/// Default (empty) port entry.
const empty_port: PortEntry = .{
    .port_no = 0,
    .state = .down,
    .active = false,
};

/// A controller session.
const Session = struct {
    /// Current controller lifecycle state.
    state: ControllerState,
    /// Switch datapath ID.
    dpid: u64,
    /// Flow table.
    flows: [MAX_FLOWS]FlowEntry,
    /// Flow count.
    flow_count: u32,
    /// Port table.
    ports: [MAX_PORTS]PortEntry,
    /// Port count.
    port_count: u16,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .dpid = 0,
    .flows = [_]FlowEntry{empty_flow} ** MAX_FLOWS,
    .flow_count = 0,
    .ports = [_]PortEntry{empty_port} ** MAX_PORTS,
    .port_count = 0,
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
pub export fn sdn_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new SDN controller session. Returns slot index or -1 on failure.
/// State: Idle -> Connected.
pub export fn sdn_create(dpid: u64) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (dpid == 0) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.dpid = dpid;
            s.state = .connected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session.
pub export fn sdn_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current ControllerState tag.
pub export fn sdn_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Send an OpenFlow message. Returns 0 on success, 1 on rejection.
pub export fn sdn_send_message(slot: c_int, msg_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (msg_type > 11) return 1;
    const state = sessions[idx].state;
    // Must be at least connected to send messages
    if (state == .idle or state == .disconnecting) return 1;
    return 0;
}

/// Add a flow rule. Returns 0 on success, 1 on rejection.
pub export fn sdn_flow_add(slot: c_int, table_id: u8, priority: u16, match_field: u8, action: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .operating) return 1;
    if (match_field > 10) return 1;
    if (action > 6) return 1;

    for (&sessions[idx].flows) |*f| {
        if (!f.active) {
            f.table_id = table_id;
            f.priority = priority;
            f.match_field = @enumFromInt(match_field);
            f.action = @enumFromInt(action);
            f.active = true;
            sessions[idx].flow_count += 1;
            sessions[idx].state = .operating;
            return 0;
        }
    }
    return 1;
}

/// Remove a flow rule. Returns 0 on success, 1 on rejection.
pub export fn sdn_flow_remove(slot: c_int, table_id: u8, priority: u16, match_field: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .operating) return 1;
    if (match_field > 10) return 1;

    const mf: MatchField = @enumFromInt(match_field);
    for (&sessions[idx].flows) |*f| {
        if (f.active and f.table_id == table_id and f.priority == priority and f.match_field == mf) {
            f.active = false;
            sessions[idx].flow_count -= 1;
            if (sessions[idx].flow_count == 0) {
                sessions[idx].state = .ready;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active flow rules.
pub export fn sdn_flow_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].flow_count;
}

/// Set port state. Returns 0 on success, 1 on rejection.
pub export fn sdn_port_set_state(slot: c_int, port_no: u16, state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (state > 2) return 1;

    // Find existing port
    for (&sessions[idx].ports) |*p| {
        if (p.active and p.port_no == port_no) {
            p.state = @enumFromInt(state);
            return 0;
        }
    }
    // Port not found -- add it if we have space
    for (&sessions[idx].ports) |*p| {
        if (!p.active) {
            p.port_no = port_no;
            p.state = @enumFromInt(state);
            p.active = true;
            sessions[idx].port_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Get port state. Returns PortState tag (Down=1 as fallback).
pub export fn sdn_port_get_state(slot: c_int, port_no: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;

    for (&sessions[idx].ports) |*p| {
        if (p.active and p.port_no == port_no) {
            return @intFromEnum(p.state);
        }
    }
    return 1; // Down fallback
}

/// Returns the number of active ports.
pub export fn sdn_port_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].port_count;
}

/// Send features request. Transitions Connected -> FeaturesWait.
pub export fn sdn_features_request(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    sessions[idx].state = .features_wait;
    return 0;
}

/// Receive features reply. Transitions FeaturesWait -> Ready.
pub export fn sdn_features_reply(slot: c_int, n_ports: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .features_wait) return 1;

    // Initialize ports
    var i: u16 = 0;
    while (i < n_ports and i < MAX_PORTS) : (i += 1) {
        sessions[idx].ports[i] = .{
            .port_no = i + 1,
            .state = .up,
            .active = true,
        };
    }
    sessions[idx].port_count = i;
    sessions[idx].state = .ready;
    return 0;
}

/// Disconnect. Transitions any active -> Disconnecting.
pub export fn sdn_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .disconnecting) return 1;
    sessions[idx].state = .disconnecting;
    return 0;
}

/// Cleanup. Transitions Disconnecting -> Idle.
pub export fn sdn_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;
    sessions[idx].state = .idle;
    sessions[idx].flows = [_]FlowEntry{empty_flow} ** MAX_FLOWS;
    sessions[idx].flow_count = 0;
    sessions[idx].ports = [_]PortEntry{empty_port} ** MAX_PORTS;
    sessions[idx].port_count = 0;
    return 0;
}

/// Check if a controller state transition is valid.
pub export fn sdn_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> FeaturesWait
    if (from == 2 and to == 3) return 1; // FeaturesWait -> Ready
    if (from == 3 and to == 4) return 1; // Ready -> Operating
    if (from == 4 and to == 3) return 1; // Operating -> Ready (all flows removed)
    if (from == 1 and to == 5) return 1; // Connected -> Disconnecting
    if (from == 2 and to == 5) return 1; // FeaturesWait -> Disconnecting
    if (from == 3 and to == 5) return 1; // Ready -> Disconnecting
    if (from == 4 and to == 5) return 1; // Operating -> Disconnecting
    if (from == 5 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}

/// Send a barrier request. Returns 0 on success, 1 on rejection.
pub export fn sdn_barrier(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .operating) return 1;
    return 0;
}

/// Returns number of active sessions.
pub export fn sdn_active_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
