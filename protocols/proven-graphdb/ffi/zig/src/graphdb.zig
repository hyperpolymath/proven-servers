// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// graphdb.zig -- Zig FFI implementation of proven-graphdb.

const std = @import("std");

pub const ElementType = enum(u8) { node = 0, edge = 1, property = 2, label = 3, index = 4 };
pub const QueryLanguage = enum(u8) { cypher = 0, gremlin = 1, sparql = 2, graphql = 3 };
pub const TraversalStrategy = enum(u8) { bfs = 0, dfs = 1, dijkstra = 2, a_star = 3, random = 4 };
pub const Consistency = enum(u8) { strong = 0, eventual = 1, session = 2, causal = 3 };
pub const ErrorCode = enum(u8) { syntax_error = 0, node_not_found = 1, edge_not_found = 2, constraint_violation = 3, index_exists = 4, transaction_conflict = 5, out_of_memory = 6 };
pub const SessionState = enum(u8) { idle = 0, connected = 1, querying = 2, traversing = 3, disconnecting = 4 };

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;

const Session = struct {
    state: SessionState, name: [MAX_NAME_LEN]u8, name_len: u32,
    consistency: Consistency, node_count: u32, edge_count: u32, query_count: u32, active: bool,
};
const empty_session: Session = .{ .state = .idle, .name = [_]u8{0} ** MAX_NAME_LEN, .name_len = 0, .consistency = .strong, .node_count = 0, .edge_count = 0, .query_count = 0, .active = false };

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

pub export fn gdb_abi_version() callconv(.c) u32 { return 1; }

pub export fn gdb_create(name_ptr: [*]const u8, name_len: u32, consistency: u8) callconv(.c) c_int {
    mutex.lock(); defer mutex.unlock();
    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (consistency > 3) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len; s.consistency = @enumFromInt(consistency);
            s.state = .connected; s.active = true; return @intCast(i);
        }
    }
    return -1;
}

pub export fn gdb_destroy(slot: c_int) callconv(.c) void {
    mutex.lock(); defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn gdb_state(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn gdb_add_node(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    sessions[idx].node_count += 1; return 0;
}

pub export fn gdb_add_edge(slot: c_int, from: u32, to: u32) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    if (from >= sessions[idx].node_count or to >= sessions[idx].node_count) return 1;
    sessions[idx].edge_count += 1; return 0;
}

pub export fn gdb_node_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].node_count;
}

pub export fn gdb_edge_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].edge_count;
}

pub export fn gdb_execute_query(slot: c_int, lang: u8, query_ptr: [*]const u8, query_len: u32) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = query_ptr; _ = query_len;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    if (lang > 3) return 1;
    sessions[idx].query_count += 1; return 0;
}

pub export fn gdb_begin_traversal(slot: c_int, strategy: u8) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = strategy;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    sessions[idx].state = .traversing; return 0;
}

pub export fn gdb_finish_traversal(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .traversing) return 1;
    sessions[idx].state = .connected; return 0;
}

pub export fn gdb_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .traversing) { sessions[idx].state = .disconnecting; return 0; }
    return 1;
}

pub export fn gdb_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;
    sessions[idx].state = .idle; sessions[idx].node_count = 0; sessions[idx].edge_count = 0; sessions[idx].query_count = 0; return 0;
}

pub export fn gdb_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1;
    if (from == 1 and to == 2) return 1;
    if (from == 2 and to == 1) return 1;
    if (from == 1 and to == 3) return 1;
    if (from == 3 and to == 1) return 1;
    if (from == 1 and to == 4) return 1;
    if (from == 3 and to == 4) return 1;
    if (from == 4 and to == 0) return 1;
    return 0;
}
