// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-ptp FFI.
//
// Tests cover:
//   - ABI version check
//   - Clock lifecycle (create, destroy, state queries)
//   - Port state machine transitions (valid and invalid per IEEE 1588)
//   - Clock class and delay mechanism configuration
//   - Message send tracking (total and Sync-specific)
//   - Stateless transition validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const ptp = @import("ptp");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), ptp.ptp_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = ptp.ptp_create(3, 0); // DefaultClass, E2E
    try expect(slot >= 0);
    ptp.ptp_destroy(slot);
}

test "create with invalid clock class returns -1" {
    const slot = ptp.ptp_create(99, 0);
    try expectEqual(@as(c_int, -1), slot);
}

test "create with invalid delay mechanism returns -1" {
    const slot = ptp.ptp_create(0, 99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    ptp.ptp_destroy(-1);
    ptp.ptp_destroy(999);
}

test "double destroy is safe" {
    const slot = ptp.ptp_create(0, 0);
    ptp.ptp_destroy(slot);
    ptp.ptp_destroy(slot);
}

// ── State Queries on Fresh Clock ────────────────────────────────────────

test "fresh clock is in Initializing state" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_get_port_state(slot)); // Initializing
}

test "fresh clock with PrimaryClock class" {
    const slot = ptp.ptp_create(0, 0); // PrimaryClock
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_get_clock_class(slot));
}

test "fresh clock with SlaveOnly class" {
    const slot = ptp.ptp_create(2, 0); // SlaveOnly
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 2), ptp.ptp_get_clock_class(slot));
}

test "fresh clock with E2E delay mechanism" {
    const slot = ptp.ptp_create(0, 0); // E2E
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_get_delay_mechanism(slot));
}

test "fresh clock with P2P delay mechanism" {
    const slot = ptp.ptp_create(0, 1); // P2P
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 1), ptp.ptp_get_delay_mechanism(slot));
}

test "fresh clock has zero message count" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u32, 0), ptp.ptp_get_message_count(slot));
}

test "fresh clock has zero sync count" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u32, 0), ptp.ptp_get_sync_count(slot));
}

test "fresh clock has no error (255)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 255), ptp.ptp_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_port_state on invalid slot returns Initializing" {
    try expectEqual(@as(u8, 0), ptp.ptp_get_port_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), ptp.ptp_get_last_error(-1));
}

// ── Valid State Transitions ─────────────────────────────────────────────

test "Initializing -> Listening (POWERUP)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
    try expectEqual(@as(u8, 3), ptp.ptp_get_port_state(slot));
}

test "Listening -> PreMaster (BMC selects master)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 4)); // -> PreMaster
    try expectEqual(@as(u8, 4), ptp.ptp_get_port_state(slot));
}

test "PreMaster -> Master (qualification)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    _ = ptp.ptp_transition(slot, 4); // -> PreMaster
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 5)); // -> Master
    try expectEqual(@as(u8, 5), ptp.ptp_get_port_state(slot));
}

test "Master path: Initializing -> Listening -> PreMaster -> Master" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 4)); // -> PreMaster
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 5)); // -> Master
    try expectEqual(@as(u8, 5), ptp.ptp_get_port_state(slot));
}

test "Slave path: Initializing -> Listening -> Uncalibrated -> Slave" {
    const slot = ptp.ptp_create(2, 0); // SlaveOnly
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 7)); // -> Uncalibrated
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 8)); // -> Slave
    try expectEqual(@as(u8, 8), ptp.ptp_get_port_state(slot));
}

test "Master -> Listening (announce timeout)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    _ = ptp.ptp_transition(slot, 4); // -> PreMaster
    _ = ptp.ptp_transition(slot, 5); // -> Master
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
}

test "Any state -> Faulty" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 1)); // -> Faulty
    try expectEqual(@as(u8, 1), ptp.ptp_get_port_state(slot));
}

test "Faulty -> Initializing (fault cleared)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 1); // -> Faulty
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 0)); // -> Initializing
}

test "Any state -> Disabled" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 2)); // -> Disabled
}

test "Disabled -> Initializing (enable)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 2); // -> Disabled
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 0)); // -> Initializing
}

// ── Invalid State Transitions ───────────────────────────────────────────

test "Initializing -> Master is invalid" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 3), ptp.ptp_transition(slot, 5)); // InvalidTransition
}

test "Listening -> Master is invalid (must go through PreMaster)" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_transition(slot, 3); // -> Listening
    try expectEqual(@as(u8, 3), ptp.ptp_transition(slot, 5)); // InvalidTransition
}

test "transition on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ptp.ptp_transition(-1, 3)); // InvalidSlot
}

test "transition with invalid state value fails" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 3), ptp.ptp_transition(slot, 99)); // InvalidTransition
}

// ── Message Tracking ────────────────────────────────────────────────────

test "send Sync message increments both counts" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_send_message(slot, 0)); // Sync
    try expectEqual(@as(u32, 1), ptp.ptp_get_message_count(slot));
    try expectEqual(@as(u32, 1), ptp.ptp_get_sync_count(slot));
}

test "send non-Sync message only increments total" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 0), ptp.ptp_send_message(slot, 7)); // Announce
    try expectEqual(@as(u32, 1), ptp.ptp_get_message_count(slot));
    try expectEqual(@as(u32, 0), ptp.ptp_get_sync_count(slot));
}

test "send multiple messages" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    _ = ptp.ptp_send_message(slot, 0); // Sync
    _ = ptp.ptp_send_message(slot, 4); // FollowUp
    _ = ptp.ptp_send_message(slot, 0); // Sync
    _ = ptp.ptp_send_message(slot, 7); // Announce
    try expectEqual(@as(u32, 4), ptp.ptp_get_message_count(slot));
    try expectEqual(@as(u32, 2), ptp.ptp_get_sync_count(slot));
}

test "send message with invalid type fails" {
    const slot = ptp.ptp_create(0, 0);
    defer ptp.ptp_destroy(slot);
    try expectEqual(@as(u8, 4), ptp.ptp_send_message(slot, 99)); // InvalidMessage
}

test "send message on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ptp.ptp_send_message(-1, 0));
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid IEEE 1588 transitions return 1" {
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(0, 3)); // Init -> Listening
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(3, 4)); // Listening -> PreMaster
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(4, 5)); // PreMaster -> Master
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(3, 7)); // Listening -> Uncalibrated
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(7, 8)); // Uncalibrated -> Slave
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(5, 3)); // Master -> Listening
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(8, 3)); // Slave -> Listening
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(1, 0)); // Faulty -> Init
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(2, 0)); // Disabled -> Init
}

test "can_transition: fault and disable from any state" {
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(0, 1)); // Init -> Faulty
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(3, 1)); // Listening -> Faulty
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(5, 1)); // Master -> Faulty
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(0, 2)); // Init -> Disabled
    try expectEqual(@as(u8, 1), ptp.ptp_can_transition(5, 2)); // Master -> Disabled
}

test "can_transition: invalid transitions return 0" {
    try expectEqual(@as(u8, 0), ptp.ptp_can_transition(0, 5)); // Init -> Master
    try expectEqual(@as(u8, 0), ptp.ptp_can_transition(3, 5)); // Listening -> Master
    try expectEqual(@as(u8, 0), ptp.ptp_can_transition(8, 5)); // Slave -> Master
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full master lifecycle: init, listen, premaster, master, send, back to listen" {
    const slot = ptp.ptp_create(0, 0); // PrimaryClock, E2E
    defer ptp.ptp_destroy(slot);

    // Start up
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 4)); // -> PreMaster
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 5)); // -> Master

    // Send messages
    _ = ptp.ptp_send_message(slot, 0); // Sync
    _ = ptp.ptp_send_message(slot, 4); // FollowUp
    _ = ptp.ptp_send_message(slot, 7); // Announce

    try expectEqual(@as(u32, 3), ptp.ptp_get_message_count(slot));
    try expectEqual(@as(u32, 1), ptp.ptp_get_sync_count(slot));

    // Return to listening
    try expectEqual(@as(u8, 0), ptp.ptp_transition(slot, 3)); // -> Listening
    try expectEqual(@as(u8, 3), ptp.ptp_get_port_state(slot));
}
