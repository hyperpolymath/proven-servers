// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
const std = @import("std");
const gdb = @import("graphdb");

test "abi version" { try std.testing.expectEqual(@as(u32, 1), gdb.gdb_abi_version()); }
test "ElementType encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.ElementType.node)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gdb.ElementType.index)); }
test "QueryLanguage encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.QueryLanguage.cypher)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gdb.QueryLanguage.graphql)); }
test "TraversalStrategy encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.TraversalStrategy.bfs)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gdb.TraversalStrategy.random)); }
test "Consistency encoding (4)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.Consistency.strong)); try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gdb.Consistency.causal)); }
test "ErrorCode encoding (7)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.ErrorCode.syntax_error)); try std.testing.expectEqual(@as(u8, 6), @intFromEnum(gdb.ErrorCode.out_of_memory)); }
test "SessionState encoding (5)" { try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gdb.SessionState.idle)); try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gdb.SessionState.disconnecting)); }

test "create in Connected" { const s = gdb.gdb_create("g".ptr, 1, 0); try std.testing.expect(s >= 0); defer gdb.gdb_destroy(s); try std.testing.expectEqual(@as(u8, 1), gdb.gdb_state(s)); }
test "create rejects bad consistency" { try std.testing.expectEqual(@as(c_int, -1), gdb.gdb_create("g".ptr, 1, 99)); }
test "add node and edge" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_add_node(s));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_add_node(s));
    try std.testing.expectEqual(@as(u32, 2), gdb.gdb_node_count(s));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_add_edge(s, 0, 1));
    try std.testing.expectEqual(@as(u32, 1), gdb.gdb_edge_count(s));
}
test "add_edge rejects invalid nodes" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_add_edge(s, 0, 1));
}
test "execute_query" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_execute_query(s, 0, "MATCH".ptr, 5));
}
test "execute_query rejects invalid lang" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_execute_query(s, 99, "x".ptr, 1));
}
test "traversal lifecycle" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_begin_traversal(s, 0));
    try std.testing.expectEqual(@as(u8, 3), gdb.gdb_state(s));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_finish_traversal(s));
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_state(s));
}
test "disconnect and cleanup" {
    const s = gdb.gdb_create("g".ptr, 1, 0); defer gdb.gdb_destroy(s);
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_disconnect(s));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_cleanup(s));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_state(s));
}
test "transition table" {
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_can_transition(0, 1));
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_can_transition(1, 3));
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_can_transition(3, 1));
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_can_transition(4, 0));
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_can_transition(0, 3));
}
test "invalid slot safety" {
    try std.testing.expectEqual(@as(u8, 0), gdb.gdb_state(-1));
    try std.testing.expectEqual(@as(u32, 0), gdb.gdb_node_count(-1));
    try std.testing.expectEqual(@as(u8, 1), gdb.gdb_disconnect(-1));
}
