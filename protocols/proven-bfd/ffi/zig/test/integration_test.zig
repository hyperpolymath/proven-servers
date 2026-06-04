// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-bfd FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - BFD FSM transitions (Down -> Init -> Up -> Down)
//   - Admin down
//   - Packet counting
//   - Teardown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const bfd = @import("bfd");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), bfd.bfd_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "BfdState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bfd.BfdState.admin_down));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bfd.BfdState.down));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bfd.BfdState.init));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bfd.BfdState.up));
}

test "Diagnostic encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bfd.Diagnostic.no_diagnostic));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bfd.Diagnostic.control_detection_time_expired));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bfd.Diagnostic.echo_function_failed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bfd.Diagnostic.neighbor_signaled_session_down));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bfd.Diagnostic.forwarding_plane_reset));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(bfd.Diagnostic.path_down));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(bfd.Diagnostic.concatenated_path_down));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(bfd.Diagnostic.administratively_down));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(bfd.Diagnostic.reverse_concatenated_path_down));
}

test "SessionMode encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bfd.SessionMode.async_mode));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bfd.SessionMode.demand_mode));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(bfd.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(bfd.SessionState.ss_down));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(bfd.SessionState.negotiating));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(bfd.SessionState.established));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(bfd.SessionState.teardown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Down state" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    try std.testing.expect(slot >= 0);
    defer bfd.bfd_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_state(slot)); // Down
}

test "create rejects zero discriminator" {
    const slot = bfd.bfd_create(0, 1000000, 1000000, 3, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects zero detect_mult" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid mode" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    bfd.bfd_destroy(-1);
    bfd.bfd_destroy(999);
}

// =========================================================================
// BFD FSM transitions
// =========================================================================

test "peer_init transitions Down -> Negotiating" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_peer_init(slot));
    try std.testing.expectEqual(@as(u8, 2), bfd.bfd_state(slot)); // Negotiating
}

test "peer_up transitions Negotiating -> Established" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_peer_up(slot));
    try std.testing.expectEqual(@as(u8, 3), bfd.bfd_state(slot)); // Established
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_is_up(slot));
}

test "peer_down transitions Established -> Down" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_peer_down(slot, 1)); // detection time expired
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_state(slot)); // Down
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_is_up(slot));
}

test "admin_down transitions to Teardown" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_admin_down(slot));
    try std.testing.expectEqual(@as(u8, 4), bfd.bfd_state(slot)); // Teardown
}

test "admin_down from Down transitions to Teardown" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_admin_down(slot));
    try std.testing.expectEqual(@as(u8, 4), bfd.bfd_state(slot));
}

// =========================================================================
// Packet counting
// =========================================================================

test "send_packet increments counter from Established" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);

    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_send_packet(slot));
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_send_packet(slot));
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_send_packet(slot));
    try std.testing.expectEqual(@as(u64, 3), bfd.bfd_packets_sent(slot));
}

test "send_packet rejects from Down state" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_send_packet(slot));
}

// =========================================================================
// Teardown / Cleanup
// =========================================================================

test "teardown transitions Established -> Teardown" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);

    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_teardown(slot));
    try std.testing.expectEqual(@as(u8, 4), bfd.bfd_state(slot));
}

test "cleanup transitions Teardown -> Idle" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_teardown(slot);
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_state(slot)); // Idle
}

test "cleanup clears packet counter" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);
    _ = bfd.bfd_send_packet(slot);
    _ = bfd.bfd_teardown(slot);
    _ = bfd.bfd_cleanup(slot);
    try std.testing.expectEqual(@as(u64, 0), bfd.bfd_packets_sent(slot));
}

test "cleanup rejected from non-Teardown state" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "bfd_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(0, 1)); // Idle -> Down
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(1, 2)); // Down -> Negotiating
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(2, 3)); // Negotiating -> Established
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(3, 1)); // Established -> Down
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(1, 4)); // Down -> Teardown
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(2, 4)); // Negotiating -> Teardown
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(3, 4)); // Established -> Teardown
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_can_transition(4, 0)); // Teardown -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_can_transition(0, 3)); // Idle -/-> Established
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_can_transition(4, 1)); // Teardown -/-> Down
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_can_transition(0, 4)); // Idle -/-> Teardown
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_can_transition(1, 3)); // Down -/-> Established
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_state(-1));
    try std.testing.expectEqual(@as(u8, 0), bfd.bfd_is_up(-1));
    try std.testing.expectEqual(@as(u64, 0), bfd.bfd_packets_sent(-1));
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_init(-1));
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_up(-1));
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_teardown(-1));
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot peer_up from Down" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_up(slot));
}

test "cannot peer_down from Negotiating" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_down(slot, 0));
}

test "peer_down rejects invalid diagnostic" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_down(slot, 99));
}

test "cannot peer_init from Established" {
    const slot = bfd.bfd_create(1, 1000000, 1000000, 3, 0);
    defer bfd.bfd_destroy(slot);

    _ = bfd.bfd_peer_init(slot);
    _ = bfd.bfd_peer_up(slot);
    try std.testing.expectEqual(@as(u8, 1), bfd.bfd_peer_init(slot));
}
