// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// bgp_test.zig -- Integration tests for proven-bgp FFI.
//
// Verifies that the Zig state machine enforcement matches the Idris2
// formal specification in BGPABI.Layout, BGPABI.Transitions, and BGP.FSM.

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

test "BGPState encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.BGPState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.BGPState.connect));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.BGPState.active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.BGPState.open_sent));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.BGPState.open_confirm));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.BGPState.established));
}

test "BGPEvent encoding matches Layout.idr (19 tags)" {
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

test "MessageType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.MessageType.open));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.MessageType.update));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.MessageType.notification));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.MessageType.keepalive));
}

test "ErrorCode encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.ErrorCode.message_header_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.ErrorCode.open_message_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.ErrorCode.update_message_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bgp.ErrorCode.hold_timer_expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bgp.ErrorCode.fsm_error));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bgp.ErrorCode.cease));
}

test "Origin encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.Origin.igp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.Origin.egp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bgp.Origin.incomplete));
}

test "ASPathSegmentType encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bgp.ASPathSegmentType.as_set));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bgp.ASPathSegmentType.as_sequence));
}

test "PathAttrType encoding matches Layout.idr (8 tags)" {
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
// Lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    try std.testing.expect(slot >= 0);
    defer bgp.bgp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 65001), bgp.bgp_local_as(slot));
    try std.testing.expectEqual(@as(u32, 65002), bgp.bgp_peer_as(slot));
    try std.testing.expectEqual(@as(u16, 90), bgp.bgp_hold_time(slot));
}

test "destroy is safe with invalid slot" {
    bgp.bgp_destroy(-1);
    bgp.bgp_destroy(999);
}

// =========================================================================
// FSM: full session setup (Idle -> Connect -> OpenSent -> OpenConfirm -> Established)
// =========================================================================

test "full session setup: Idle -> Established" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    // Idle -> Connect (ManualStart, event tag 0)
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_apply_event(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_state(slot)); // Connect

    // Connect -> OpenSent (TcpCRAcked, event tag 8)
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_apply_event(slot, 8));
    try std.testing.expectEqual(@as(u8, 3), bgp.bgp_state(slot)); // OpenSent

    // OpenSent -> OpenConfirm (BGPOpenReceived, event tag 11)
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_apply_event(slot, 11));
    try std.testing.expectEqual(@as(u8, 4), bgp.bgp_state(slot)); // OpenConfirm

    // OpenConfirm -> Established (KeepAliveMsg, event tag 16)
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_apply_event(slot, 16));
    try std.testing.expectEqual(@as(u8, 5), bgp.bgp_state(slot)); // Established
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_is_established(slot));
}

test "AutomaticStart also moves Idle -> Connect" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    // AutomaticStart = event tag 2
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_apply_event(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_state(slot));
}

// =========================================================================
// FSM: Connect state transitions
// =========================================================================

test "Connect: TcpConnectionFails -> Active" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 10); // TcpConnectionFails
    try std.testing.expectEqual(@as(u8, 2), bgp.bgp_state(slot)); // Active
}

test "Connect: ManualStop -> Idle" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 1); // ManualStop
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot)); // Idle
}

test "Connect: ConnectRetryTimerExpires -> Connect" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 3); // ConnectRetryTimerExpires
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_state(slot)); // still Connect
}

test "Connect: BGPOpenReceived -> OpenConfirm" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 11); // BGPOpenReceived
    try std.testing.expectEqual(@as(u8, 4), bgp.bgp_state(slot)); // OpenConfirm
}

// =========================================================================
// FSM: Active state transitions
// =========================================================================

test "Active: ConnectRetryTimerExpires -> Connect" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 10); // TcpFails -> Active
    _ = bgp.bgp_apply_event(slot, 3); // ConnectRetryTimerExpires
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_state(slot)); // Connect
}

test "Active: TcpCRAcked -> OpenSent" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // Idle -> Connect
    _ = bgp.bgp_apply_event(slot, 10); // -> Active
    _ = bgp.bgp_apply_event(slot, 8); // TcpCRAcked
    try std.testing.expectEqual(@as(u8, 3), bgp.bgp_state(slot)); // OpenSent
}

// =========================================================================
// FSM: OpenSent state transitions
// =========================================================================

test "OpenSent: TcpConnectionFails -> Active" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // -> Connect
    _ = bgp.bgp_apply_event(slot, 8); // -> OpenSent
    _ = bgp.bgp_apply_event(slot, 10); // TcpConnectionFails
    try std.testing.expectEqual(@as(u8, 2), bgp.bgp_state(slot)); // Active
}

test "OpenSent: HoldTimerExpires -> Idle" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // -> Connect
    _ = bgp.bgp_apply_event(slot, 8); // -> OpenSent
    _ = bgp.bgp_apply_event(slot, 4); // HoldTimerExpires
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot)); // Idle
}

// =========================================================================
// FSM: OpenConfirm state transitions
// =========================================================================

test "OpenConfirm: KeepaliveTimerExpires -> OpenConfirm" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // -> Connect
    _ = bgp.bgp_apply_event(slot, 8); // -> OpenSent
    _ = bgp.bgp_apply_event(slot, 11); // -> OpenConfirm
    _ = bgp.bgp_apply_event(slot, 5); // KeepaliveTimerExpires
    try std.testing.expectEqual(@as(u8, 4), bgp.bgp_state(slot)); // still OpenConfirm
}

test "OpenConfirm: HoldTimerExpires -> Idle" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0); // -> Connect
    _ = bgp.bgp_apply_event(slot, 8); // -> OpenSent
    _ = bgp.bgp_apply_event(slot, 11); // -> OpenConfirm
    _ = bgp.bgp_apply_event(slot, 4); // HoldTimerExpires
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot)); // Idle
}

// =========================================================================
// FSM: Established state transitions
// =========================================================================

test "Established: UpdateMsg -> stays Established" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    // Full path to Established
    _ = bgp.bgp_apply_event(slot, 0); // -> Connect
    _ = bgp.bgp_apply_event(slot, 8); // -> OpenSent
    _ = bgp.bgp_apply_event(slot, 11); // -> OpenConfirm
    _ = bgp.bgp_apply_event(slot, 16); // -> Established

    _ = bgp.bgp_apply_event(slot, 17); // UpdateMsg
    try std.testing.expectEqual(@as(u8, 5), bgp.bgp_state(slot));
}

test "Established: KeepAliveMsg -> stays Established" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);

    _ = bgp.bgp_apply_event(slot, 16); // KeepAliveMsg again
    try std.testing.expectEqual(@as(u8, 5), bgp.bgp_state(slot));
}

test "Established: UpdateMsgErr -> Idle" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);

    _ = bgp.bgp_apply_event(slot, 18); // UpdateMsgErr
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot));
}

test "Established: ManualStop -> Idle" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);

    _ = bgp.bgp_apply_event(slot, 1); // ManualStop
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(slot));
}

// =========================================================================
// Route management
// =========================================================================

test "can add and withdraw routes in Established state" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    // Get to Established
    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);

    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_exchange(slot));
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_routes_received(slot));

    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_add_route(slot));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_add_route(slot));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_add_route(slot));
    try std.testing.expectEqual(@as(u32, 3), bgp.bgp_routes_received(slot));

    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_withdraw_route(slot));
    try std.testing.expectEqual(@as(u32, 2), bgp.bgp_routes_received(slot));
}

test "cannot add routes when not Established" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_add_route(slot));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_exchange(slot));
}

test "routes cleared when leaving Established" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    // Get to Established and add routes
    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);
    _ = bgp.bgp_add_route(slot);
    _ = bgp.bgp_add_route(slot);
    try std.testing.expectEqual(@as(u32, 2), bgp.bgp_routes_received(slot));

    // ManualStop -> Idle (routes should be cleared)
    _ = bgp.bgp_apply_event(slot, 1);
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_routes_received(slot));
}

test "cannot withdraw when no routes" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    _ = bgp.bgp_apply_event(slot, 0);
    _ = bgp.bgp_apply_event(slot, 8);
    _ = bgp.bgp_apply_event(slot, 11);
    _ = bgp.bgp_apply_event(slot, 16);

    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_withdraw_route(slot));
}

// =========================================================================
// Invalid event rejection
// =========================================================================

test "apply_event rejects invalid event tag" {
    const slot = bgp.bgp_create(65001, 65002, 90);
    defer bgp.bgp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_apply_event(slot, 99));
}

test "apply_event rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_apply_event(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_apply_event(999, 0));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "bgp_can_transition matches Transitions.idr" {
    // Valid forward transitions
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(0, 1)); // Idle->Connect
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(1, 3)); // Connect->OpenSent
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(1, 2)); // Connect->Active
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(1, 4)); // Connect->OpenConfirm
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(1, 0)); // Connect->Idle
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(2, 1)); // Active->Connect
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(2, 3)); // Active->OpenSent
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(2, 4)); // Active->OpenConfirm
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(2, 0)); // Active->Idle
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(3, 4)); // OpenSent->OpenConfirm
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(3, 2)); // OpenSent->Active
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(3, 0)); // OpenSent->Idle
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(4, 5)); // OpenConfirm->Established
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(4, 4)); // OpenConfirm->OpenConfirm
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(4, 0)); // OpenConfirm->Idle
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(5, 5)); // Established->Established
    try std.testing.expectEqual(@as(u8, 1), bgp.bgp_can_transition(5, 0)); // Established->Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(0, 5)); // Idle->Established
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(0, 3)); // Idle->OpenSent
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(5, 1)); // Established->Connect
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(5, 2)); // Established->Active
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_transition(0, 0)); // Idle->Idle (self-loop not a transition)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_state(-1));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_is_established(-1));
    try std.testing.expectEqual(@as(u8, 0), bgp.bgp_can_exchange(-1));
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_connect_retry_count(-1));
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_routes_received(-1));
    try std.testing.expectEqual(@as(u16, 0), bgp.bgp_hold_time(-1));
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_local_as(-1));
    try std.testing.expectEqual(@as(u32, 0), bgp.bgp_peer_as(-1));
}
