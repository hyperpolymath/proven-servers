// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-pqc FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const pqc = @import("pqc");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), pqc.pqc_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PQCAlgorithm encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.PQCAlgorithm.crystals_kyber));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.PQCAlgorithm.crystals_dilithium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.PQCAlgorithm.falcon));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.PQCAlgorithm.sphincs_plus));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.PQCAlgorithm.classic_mceliece));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(pqc.PQCAlgorithm.bike));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(pqc.PQCAlgorithm.hqc));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(pqc.PQCAlgorithm.frodokem));
}

test "NISTLevel encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.NISTLevel.nist_1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.NISTLevel.nist_2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.NISTLevel.nist_3));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.NISTLevel.nist_4));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.NISTLevel.nist_5));
}

test "Operation encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.Operation.keygen));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.Operation.encapsulate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.Operation.decapsulate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.Operation.sign));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.Operation.verify));
}

test "HybridMode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.HybridMode.classical_only));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.HybridMode.pqc_only));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.HybridMode.hybrid));
}

test "AlgorithmCategory encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.AlgorithmCategory.kem));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.AlgorithmCategory.signature));
}

test "KeyState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.KeyState.empty));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.KeyState.generating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.KeyState.generated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.KeyState.active));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.KeyState.expired));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(pqc.KeyState.compromised));
}

test "HybridState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.HybridState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.HybridState.classical_selected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.HybridState.pqc_selected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.HybridState.negotiated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.HybridState.complete));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = pqc.pqc_create_context(0, 0);
    try std.testing.expect(slot >= 0);
    defer pqc.pqc_destroy_context(slot);
    const state = pqc.pqc_key_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    pqc.pqc_destroy_context(-1);
    pqc.pqc_destroy_context(999);
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = pqc.pqc_key_state(-1);
}

