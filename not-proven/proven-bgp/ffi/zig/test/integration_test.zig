// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-bgp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const bgp = @import("bgp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), bgp.bgp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "BGPState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.BGPState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.BGPState.connect));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.BGPState.active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.BGPState.open_sent));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.BGPState.open_confirm));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.BGPState.established));
}

test "BGPEvent encoding matches Types.idr (19 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.BGPEvent.manual_start));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.BGPEvent.manual_stop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.BGPEvent.automatic_start));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.BGPEvent.connect_retry_timer_expires));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.BGPEvent.hold_timer_expires));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.BGPEvent.keepalive_timer_expires));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(bgp.BGPEvent.delay_open_timer_expires));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(bgp.BGPEvent.tcp_connection_valid));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(bgp.BGPEvent.tcp_cr_acked));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(bgp.BGPEvent.tcp_connection_confirmed));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(bgp.BGPEvent.tcp_connection_fails));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(bgp.BGPEvent.bgp_open_received));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(bgp.BGPEvent.bgp_header_err));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(bgp.BGPEvent.bgp_open_msg_err));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(bgp.BGPEvent.notif_msg_ver_err));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(bgp.BGPEvent.notif_msg));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(bgp.BGPEvent.keepalive_msg));
    try std.testing.expectEqual(@as(u8, 17), @intFromEnum(bgp.BGPEvent.update_msg));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(bgp.BGPEvent.update_msg_err));
}

test "MessageType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.MessageType.open));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.MessageType.update));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.MessageType.notification));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.MessageType.keepalive));
}

test "ErrorCode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.ErrorCode.message_header_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.ErrorCode.open_message_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.ErrorCode.update_message_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.ErrorCode.hold_timer_expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.ErrorCode.fsm_error));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.ErrorCode.cease));
}

test "Origin encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.Origin.igp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.Origin.egp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.Origin.incomplete));
}

test "ASPathSegmentType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.ASPathSegmentType.as_set));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.ASPathSegmentType.as_sequence));
}

test "PathAttrType encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.PathAttrType.origin));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.PathAttrType.as_path));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.PathAttrType.next_hop));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.PathAttrType.med));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.PathAttrType.local_pref));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.PathAttrType.atomic_aggr));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(bgp.PathAttrType.aggregator));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(bgp.PathAttrType.unknown));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = bgp.bgp_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer bgp.bgp_destroy(slot);
    const state = bgp.bgp_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    bgp.bgp_destroy(-1);
    bgp.bgp_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = bgp.bgp_state(-1);
    _ = bgp.bgp_is_established(-1);
    _ = bgp.bgp_connect_retry_count(-1);
}

