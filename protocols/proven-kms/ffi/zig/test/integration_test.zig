// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-kms FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const kms = @import("kms");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), kms.kms_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ObjectType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kms.ObjectType.symmetric_key));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kms.ObjectType.public_key));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kms.ObjectType.private_key));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kms.ObjectType.secret_data));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kms.ObjectType.certificate));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kms.ObjectType.opaque_data));
}

test "Operation encoding matches Types.idr (15 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kms.Operation.create));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kms.Operation.get));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kms.Operation.activate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kms.Operation.revoke));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kms.Operation.destroy));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kms.Operation.locate));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kms.Operation.register));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(kms.Operation.rekey));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(kms.Operation.encrypt));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(kms.Operation.decrypt));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(kms.Operation.sign));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(kms.Operation.verify));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(kms.Operation.wrap));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(kms.Operation.unwrap));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(kms.Operation.mac));
}

test "KeyState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kms.KeyState.pre_active));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kms.KeyState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kms.KeyState.deactivated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kms.KeyState.compromised));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kms.KeyState.destroyed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kms.KeyState.destroyed_compromised));
}

test "Algorithm encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kms.Algorithm.aes128));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kms.Algorithm.aes256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kms.Algorithm.rsa2048));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kms.Algorithm.rsa4096));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kms.Algorithm.ecdsa_p256));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kms.Algorithm.ecdsa_p384));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kms.Algorithm.ed25519));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(kms.Algorithm.chacha20_poly1305));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(kms.Algorithm.hmac_sha256));
}

test "KMSError encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kms.KMSError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kms.KMSError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kms.KMSError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kms.KMSError.invalid_transition));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kms.KMSError.operation_denied));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kms.KMSError.capacity_exhausted));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kms.KMSError.unsupported_alg));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(kms.KMSError.key_destroyed));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = kms.kms_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer kms.kms_destroy(slot);
    const state = kms.kms_get_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    kms.kms_destroy(-1);
    kms.kms_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), kms.kms_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), kms.kms_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = kms.kms_get_state(-1);
    _ = kms.kms_get_state(-1);
    _ = kms.kms_get_object_type(-1);
    _ = kms.kms_get_algorithm(-1);
}

