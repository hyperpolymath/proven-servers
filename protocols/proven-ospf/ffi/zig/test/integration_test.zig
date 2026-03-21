// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-ospf FFI.
//
// Tests cover:
//   - ABI version check
//   - Neighbor lifecycle (create, destroy, state queries)
//   - State machine transitions (valid and invalid per RFC 2328)
//   - Packet send tracking
//   - LSA database management and limits
//   - Area type configuration
//   - Stateless transition validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const ospf = @import("ospf");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), ospf.ospf_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = ospf.ospf_create(0); // Normal area
    try expect(slot >= 0);
    ospf.ospf_destroy(slot);
}

test "create with invalid area type returns -1" {
    const slot = ospf.ospf_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    ospf.ospf_destroy(-1);
    ospf.ospf_destroy(999);
}

test "double destroy is safe" {
    const slot = ospf.ospf_create(0);
    ospf.ospf_destroy(slot);
    ospf.ospf_destroy(slot);
}

// ── State Queries on Fresh Neighbor ─────────────────────────────────────

test "fresh neighbor is in Down state" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_get_state(slot)); // Down
}

test "fresh neighbor has Normal area type" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_get_area_type(slot)); // Normal
}

test "fresh neighbor with Stub area type" {
    const slot = ospf.ospf_create(1); // Stub
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 1), ospf.ospf_get_area_type(slot));
}

test "fresh neighbor with NSSA area type" {
    const slot = ospf.ospf_create(3); // NSSA
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 3), ospf.ospf_get_area_type(slot));
}

test "fresh neighbor has zero LSA count" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u32, 0), ospf.ospf_get_lsa_count(slot));
}

test "fresh neighbor has zero packet count" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u32, 0), ospf.ospf_get_packet_count(slot));
}

test "fresh neighbor has no error (255)" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 255), ospf.ospf_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns Down" {
    try expectEqual(@as(u8, 0), ospf.ospf_get_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), ospf.ospf_get_last_error(-1));
}

// ── Valid State Transitions ─────────────────────────────────────────────

test "Down -> Init (received Hello)" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 2)); // Ok -> Init
    try expectEqual(@as(u8, 2), ospf.ospf_get_state(slot));
}

test "Down -> Attempt (NBMA)" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 1)); // Ok -> Attempt
    try expectEqual(@as(u8, 1), ospf.ospf_get_state(slot));
}

test "Init -> TwoWay" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    _ = ospf.ospf_transition(slot, 2); // -> Init
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 3)); // -> TwoWay
    try expectEqual(@as(u8, 3), ospf.ospf_get_state(slot));
}

test "Full adjacency path: Down -> Init -> TwoWay -> ExStart -> Exchange -> Loading -> Full" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 2)); // -> Init
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 3)); // -> TwoWay
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 4)); // -> ExStart
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 5)); // -> Exchange
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 6)); // -> Loading
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 7)); // -> Full
    try expectEqual(@as(u8, 7), ospf.ospf_get_state(slot));
}

test "Full -> Down (neighbor lost) resets counters" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    _ = ospf.ospf_transition(slot, 2); // -> Init
    _ = ospf.ospf_transition(slot, 3); // -> TwoWay
    _ = ospf.ospf_transition(slot, 4); // -> ExStart
    _ = ospf.ospf_transition(slot, 5); // -> Exchange
    _ = ospf.ospf_transition(slot, 6); // -> Loading
    _ = ospf.ospf_transition(slot, 7); // -> Full
    _ = ospf.ospf_send_packet(slot, 0); // Send a Hello
    try expect(ospf.ospf_get_packet_count(slot) > 0);
    try expectEqual(@as(u8, 0), ospf.ospf_transition(slot, 0)); // -> Down
    try expectEqual(@as(u32, 0), ospf.ospf_get_packet_count(slot));
}

// ── Invalid State Transitions ───────────────────────────────────────────

test "Down -> Full is invalid" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 3), ospf.ospf_transition(slot, 7)); // InvalidTransition
}

test "Init -> Exchange is invalid (must go through TwoWay/ExStart)" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    _ = ospf.ospf_transition(slot, 2); // -> Init
    try expectEqual(@as(u8, 3), ospf.ospf_transition(slot, 5)); // InvalidTransition
}

test "transition on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ospf.ospf_transition(-1, 2)); // InvalidSlot
}

// ── Packet Tracking ─────────────────────────────────────────────────────

test "send packet increments count" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_send_packet(slot, 0)); // Hello
    try expectEqual(@as(u32, 1), ospf.ospf_get_packet_count(slot));
    try expectEqual(@as(u8, 0), ospf.ospf_send_packet(slot, 3)); // LinkStateUpdate
    try expectEqual(@as(u32, 2), ospf.ospf_get_packet_count(slot));
}

test "send packet with invalid type fails" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 4), ospf.ospf_send_packet(slot, 99)); // InvalidPacket
}

test "send packet on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ospf.ospf_send_packet(-1, 0)); // InvalidSlot
}

// ── LSA Management ──────────────────────────────────────────────────────

test "add LSA increments count" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 0), ospf.ospf_add_lsa(slot, 0)); // RouterLSA
    try expectEqual(@as(u32, 1), ospf.ospf_get_lsa_count(slot));
    try expectEqual(@as(u8, 0), ospf.ospf_add_lsa(slot, 1)); // NetworkLSA
    try expectEqual(@as(u32, 2), ospf.ospf_get_lsa_count(slot));
}

test "add LSA with invalid type fails" {
    const slot = ospf.ospf_create(0);
    defer ospf.ospf_destroy(slot);
    try expectEqual(@as(u8, 4), ospf.ospf_add_lsa(slot, 99)); // InvalidPacket
}

test "add LSA on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ospf.ospf_add_lsa(-1, 0)); // InvalidSlot
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid RFC 2328 transitions return 1" {
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(0, 1)); // Down -> Attempt
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(0, 2)); // Down -> Init
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(1, 2)); // Attempt -> Init
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(2, 3)); // Init -> TwoWay
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(3, 4)); // TwoWay -> ExStart
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(4, 5)); // ExStart -> Exchange
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(5, 6)); // Exchange -> Loading
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(6, 7)); // Loading -> Full
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(7, 0)); // Full -> Down
}

test "can_transition: any active state -> Down returns 1" {
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(1, 0)); // Attempt -> Down
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(2, 0)); // Init -> Down
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(3, 0)); // TwoWay -> Down
    try expectEqual(@as(u8, 1), ospf.ospf_can_transition(5, 0)); // Exchange -> Down
}

test "can_transition: invalid transitions return 0" {
    try expectEqual(@as(u8, 0), ospf.ospf_can_transition(0, 7)); // Down -> Full
    try expectEqual(@as(u8, 0), ospf.ospf_can_transition(2, 5)); // Init -> Exchange
    try expectEqual(@as(u8, 0), ospf.ospf_can_transition(7, 3)); // Full -> TwoWay
}
