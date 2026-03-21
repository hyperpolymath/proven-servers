// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// kms_test.zig — Integration tests for the proven-kms FFI.
//
// Tests cover:
//   - ABI version check
//   - Key lifecycle (create, destroy, state queries)
//   - Key state transitions (valid and invalid per KMIP)
//   - Operation tracking and state-gating
//   - Stateless transition validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const kms = @import("kms");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), kms.kms_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = kms.kms_create(0, 0); // SymmetricKey, AES128
    try expect(slot >= 0);
    kms.kms_destroy(slot);
}

test "create with invalid object type returns -1" {
    const slot = kms.kms_create(99, 0);
    try expectEqual(@as(c_int, -1), slot);
}

test "create with invalid algorithm returns -1" {
    const slot = kms.kms_create(0, 99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    kms.kms_destroy(-1);
    kms.kms_destroy(999);
}

test "double destroy is safe" {
    const slot = kms.kms_create(0, 0);
    kms.kms_destroy(slot);
    kms.kms_destroy(slot);
}

// ── State Queries on Fresh Key ──────────────────────────────────────────

test "fresh key is in PreActive state" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 0), kms.kms_get_state(slot)); // PreActive
}

test "fresh key has correct object type" {
    const slot = kms.kms_create(2, 0); // PrivateKey
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 2), kms.kms_get_object_type(slot));
}

test "fresh key has correct algorithm" {
    const slot = kms.kms_create(0, 6); // Ed25519
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 6), kms.kms_get_algorithm(slot));
}

test "fresh key has zero operation count" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u32, 0), kms.kms_get_operation_count(slot));
}

test "fresh key has no error (255)" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 255), kms.kms_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns PreActive" {
    try expectEqual(@as(u8, 0), kms.kms_get_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), kms.kms_get_last_error(-1));
}

// ── Valid State Transitions (KMIP lifecycle) ─────────────────────────────

test "PreActive -> Active" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 1)); // Ok
    try expectEqual(@as(u8, 1), kms.kms_get_state(slot)); // Active
}

test "Active -> Deactivated" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1); // -> Active
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 2)); // Ok
    try expectEqual(@as(u8, 2), kms.kms_get_state(slot)); // Deactivated
}

test "Active -> Compromised" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1);
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 3));
    try expectEqual(@as(u8, 3), kms.kms_get_state(slot));
}

test "Active -> Destroyed" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1);
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 4));
    try expectEqual(@as(u8, 4), kms.kms_get_state(slot));
}

test "Deactivated -> Destroyed" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1); // -> Active
    _ = kms.kms_transition(slot, 2); // -> Deactivated
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 4)); // -> Destroyed
}

test "Compromised -> DestroyedCompromised" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1); // -> Active
    _ = kms.kms_transition(slot, 3); // -> Compromised
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 5)); // -> DestroyedCompromised
}

test "PreActive -> Destroyed (discard without activation)" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 4));
}

// ── Invalid State Transitions ───────────────────────────────────────────

test "PreActive -> Deactivated is invalid" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 3), kms.kms_transition(slot, 2)); // InvalidTransition
}

test "Destroyed -> Active is invalid" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 4); // -> Destroyed
    try expectEqual(@as(u8, 3), kms.kms_transition(slot, 1)); // InvalidTransition
}

test "Deactivated -> Active is invalid (no reactivation)" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1); // -> Active
    _ = kms.kms_transition(slot, 2); // -> Deactivated
    try expectEqual(@as(u8, 3), kms.kms_transition(slot, 1)); // InvalidTransition
}

test "transition on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), kms.kms_transition(-1, 1)); // InvalidSlot
}

// ── Operations ──────────────────────────────────────────────────────────

test "operation on active key succeeds" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1); // -> Active
    try expectEqual(@as(u8, 0), kms.kms_perform_operation(slot, 8)); // Encrypt
    try expectEqual(@as(u32, 1), kms.kms_get_operation_count(slot));
}

test "crypto operation on pre-active key is denied" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 4), kms.kms_perform_operation(slot, 8)); // OperationDenied
}

test "operation on destroyed key fails" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 4); // -> Destroyed
    try expectEqual(@as(u8, 7), kms.kms_perform_operation(slot, 1)); // KeyDestroyed
}

test "non-crypto operation on pre-active key succeeds" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    try expectEqual(@as(u8, 0), kms.kms_perform_operation(slot, 1)); // Get
    try expectEqual(@as(u32, 1), kms.kms_get_operation_count(slot));
}

test "invalid operation code fails" {
    const slot = kms.kms_create(0, 0);
    defer kms.kms_destroy(slot);
    _ = kms.kms_transition(slot, 1);
    try expectEqual(@as(u8, 3), kms.kms_perform_operation(slot, 99));
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid KMIP transitions return 1" {
    try expectEqual(@as(u8, 1), kms.kms_can_transition(0, 1)); // PreActive -> Active
    try expectEqual(@as(u8, 1), kms.kms_can_transition(1, 2)); // Active -> Deactivated
    try expectEqual(@as(u8, 1), kms.kms_can_transition(1, 3)); // Active -> Compromised
    try expectEqual(@as(u8, 1), kms.kms_can_transition(1, 4)); // Active -> Destroyed
    try expectEqual(@as(u8, 1), kms.kms_can_transition(2, 4)); // Deactivated -> Destroyed
    try expectEqual(@as(u8, 1), kms.kms_can_transition(3, 5)); // Compromised -> DestroyedCompromised
    try expectEqual(@as(u8, 1), kms.kms_can_transition(0, 4)); // PreActive -> Destroyed
}

test "can_transition: invalid transitions return 0" {
    try expectEqual(@as(u8, 0), kms.kms_can_transition(0, 2)); // PreActive -> Deactivated
    try expectEqual(@as(u8, 0), kms.kms_can_transition(4, 1)); // Destroyed -> Active
    try expectEqual(@as(u8, 0), kms.kms_can_transition(2, 1)); // Deactivated -> Active
    try expectEqual(@as(u8, 0), kms.kms_can_transition(5, 0)); // DestroyedCompromised -> PreActive
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full key lifecycle: create, activate, use, deactivate, destroy" {
    const slot = kms.kms_create(0, 1); // SymmetricKey, AES256
    defer kms.kms_destroy(slot);

    // Activate
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 1));

    // Perform operations
    try expectEqual(@as(u8, 0), kms.kms_perform_operation(slot, 8)); // Encrypt
    try expectEqual(@as(u8, 0), kms.kms_perform_operation(slot, 9)); // Decrypt
    try expectEqual(@as(u32, 2), kms.kms_get_operation_count(slot));

    // Deactivate
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 2));

    // Destroy
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 4));
    try expectEqual(@as(u8, 4), kms.kms_get_state(slot));
}

test "compromise lifecycle: activate, compromise, destroy" {
    const slot = kms.kms_create(1, 6); // PublicKey, Ed25519
    defer kms.kms_destroy(slot);

    _ = kms.kms_transition(slot, 1); // -> Active
    _ = kms.kms_transition(slot, 3); // -> Compromised
    try expectEqual(@as(u8, 0), kms.kms_transition(slot, 5)); // -> DestroyedCompromised
    try expectEqual(@as(u8, 5), kms.kms_get_state(slot));
}
