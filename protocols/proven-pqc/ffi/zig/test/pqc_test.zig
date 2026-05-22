// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// pqc_test.zig -- Integration tests for proven-pqc FFI.

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

test "PQCAlgorithm encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.PQCAlgorithm.crystals_kyber));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.PQCAlgorithm.crystals_dilithium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.PQCAlgorithm.falcon));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.PQCAlgorithm.sphincs_plus));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.PQCAlgorithm.classic_mceliece));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(pqc.PQCAlgorithm.bike));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(pqc.PQCAlgorithm.hqc));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(pqc.PQCAlgorithm.frodokem));
}

test "NISTLevel encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.NISTLevel.nist_1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.NISTLevel.nist_2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.NISTLevel.nist_3));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.NISTLevel.nist_4));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.NISTLevel.nist_5));
}

test "Operation encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.Operation.keygen));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.Operation.encapsulate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.Operation.decapsulate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.Operation.sign));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.Operation.verify));
}

test "HybridMode encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.HybridMode.classical_only));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.HybridMode.pqc_only));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.HybridMode.hybrid));
}

test "AlgorithmCategory encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.AlgorithmCategory.kem));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.AlgorithmCategory.signature));
}

test "KeyState encoding matches Transitions.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.KeyState.empty));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.KeyState.generating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.KeyState.generated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.KeyState.active));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.KeyState.expired));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(pqc.KeyState.compromised));
}

test "HybridState encoding matches Transitions.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(pqc.HybridState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(pqc.HybridState.classical_selected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(pqc.HybridState.pqc_selected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(pqc.HybridState.negotiated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(pqc.HybridState.complete));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = pqc.pqc_create_context(0, 0); // Kyber, NIST_1
    try std.testing.expect(slot >= 0);
    defer pqc.pqc_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_key_state(slot)); // Empty
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_hybrid_state(slot)); // Idle
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_algorithm(slot)); // Kyber
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_nist_level(slot)); // NIST_1
}

test "create rejects invalid algorithm" {
    try std.testing.expectEqual(@as(c_int, -1), pqc.pqc_create_context(99, 0));
}

test "create rejects invalid NIST level" {
    try std.testing.expectEqual(@as(c_int, -1), pqc.pqc_create_context(0, 99));
}

test "create rejects invalid algorithm+level combination" {
    // Kyber does not support NIST_2 (tag 1)
    try std.testing.expectEqual(@as(c_int, -1), pqc.pqc_create_context(0, 1));
    // FALCON does not support NIST_3 (tag 2)
    try std.testing.expectEqual(@as(c_int, -1), pqc.pqc_create_context(2, 2));
}

test "destroy is safe with invalid slot" {
    pqc.pqc_destroy_context(-1);
    pqc.pqc_destroy_context(999);
}

// =========================================================================
// Full key lifecycle: Empty -> Generating -> Generated -> Active
// =========================================================================

test "full key lifecycle: Empty -> Generating -> Generated -> Active" {
    const slot = pqc.pqc_create_context(0, 0); // Kyber, NIST_1
    defer pqc.pqc_destroy_context(slot);

    // Empty -> Generating
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_begin_keygen(slot));
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_key_state(slot)); // Generating

    // Generating -> Generated (store key material)
    const pk = "public_key_data_placeholder_123";
    const sk = "secret_key_data_placeholder_456";
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len));
    try std.testing.expectEqual(@as(u8, 2), pqc.pqc_key_state(slot)); // Generated
    try std.testing.expectEqual(@as(u32, pk.len), pqc.pqc_public_key_len(slot));
    try std.testing.expectEqual(@as(u32, sk.len), pqc.pqc_secret_key_len(slot));

    // Generated -> Active
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_activate_key(slot));
    try std.testing.expectEqual(@as(u8, 3), pqc.pqc_key_state(slot)); // Active
}

// =========================================================================
// Key lifecycle: expiry and compromise
// =========================================================================

test "expire from Active" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_expire_key(slot));
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_key_state(slot)); // Expired
}

test "expire from Generated (before activation)" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_expire_key(slot));
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_key_state(slot));
}

test "compromise from Active" {
    const slot = pqc.pqc_create_context(1, 1); // Dilithium, NIST_2
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_compromise_key(slot));
    try std.testing.expectEqual(@as(u8, 5), pqc.pqc_key_state(slot)); // Compromised
}

test "compromise rejects from non-Active" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_compromise_key(slot)); // Empty
}

test "expire rejects from Expired (terminal)" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);
    _ = pqc.pqc_expire_key(slot);

    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_expire_key(slot)); // Already Expired
}

test "compromise rejects from Compromised (terminal)" {
    const slot = pqc.pqc_create_context(1, 1);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);
    _ = pqc.pqc_compromise_key(slot);

    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_compromise_key(slot)); // Already Compromised
}

// =========================================================================
// Invalid key transitions
// =========================================================================

test "cannot skip to Active (Empty -> Active)" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_activate_key(slot)); // Empty
}

test "cannot go backwards (Active -> Generating)" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_begin_keygen(slot)); // Active
}

test "finish_keygen rejects null pointers" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_finish_keygen(slot, null, 10, null, 10));
}

test "finish_keygen rejects zero-length keys" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_finish_keygen(slot, pk.ptr, 0, sk.ptr, sk.len));
}

// =========================================================================
// Crypto operations: category enforcement
// =========================================================================

test "encapsulate succeeds with KEM algorithm in Active state" {
    const slot = pqc.pqc_create_context(0, 0); // Kyber (KEM)
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    var ct_len: u32 = 0;
    var ss_len: u32 = 0;
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_encapsulate(slot, null, &ct_len, null, &ss_len));
}

test "sign rejects with KEM algorithm" {
    const slot = pqc.pqc_create_context(0, 0); // Kyber (KEM)
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    var sig_len: u32 = 0;
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_sign(slot, null, 0, null, &sig_len));
}

test "sign succeeds with Signature algorithm in Active state" {
    const slot = pqc.pqc_create_context(1, 1); // Dilithium (Signature)
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    var sig_len: u32 = 0;
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_sign(slot, null, 0, null, &sig_len));
}

test "encapsulate rejects with Signature algorithm" {
    const slot = pqc.pqc_create_context(1, 1); // Dilithium (Signature)
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_begin_keygen(slot);
    const pk = "pk";
    const sk = "sk";
    _ = pqc.pqc_finish_keygen(slot, pk.ptr, pk.len, sk.ptr, sk.len);
    _ = pqc.pqc_activate_key(slot);

    var ct_len: u32 = 0;
    var ss_len: u32 = 0;
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_encapsulate(slot, null, &ct_len, null, &ss_len));
}

test "encapsulate rejects from non-Active state" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    var ct_len: u32 = 0;
    var ss_len: u32 = 0;
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_encapsulate(slot, null, &ct_len, null, &ss_len)); // Empty
}

// =========================================================================
// Algorithm category
// =========================================================================

test "category returns KEM for Kyber, BIKE, HQC, McEliece, FrodoKEM" {
    // Kyber
    const s1 = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(s1);
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_category(s1));

    // BIKE
    const s2 = pqc.pqc_create_context(5, 0);
    defer pqc.pqc_destroy_context(s2);
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_category(s2));
}

test "category returns Signature for Dilithium, FALCON, SPHINCS+" {
    const s1 = pqc.pqc_create_context(1, 1); // Dilithium
    defer pqc.pqc_destroy_context(s1);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_category(s1));

    const s2 = pqc.pqc_create_context(2, 0); // FALCON
    defer pqc.pqc_destroy_context(s2);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_category(s2));
}

// =========================================================================
// Hybrid negotiation lifecycle
// =========================================================================

test "hybrid: classical first path: Idle -> Classical -> Negotiated -> Complete" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_select_classical(slot));
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_hybrid_state(slot)); // ClassicalSelected

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_select_pqc(slot));
    try std.testing.expectEqual(@as(u8, 3), pqc.pqc_hybrid_state(slot)); // Negotiated

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_complete_hybrid(slot));
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_hybrid_state(slot)); // Complete
}

test "hybrid: PQC first path: Idle -> PQCSelected" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_select_pqc(slot));
    try std.testing.expectEqual(@as(u8, 2), pqc.pqc_hybrid_state(slot)); // PQCSelected
}

test "hybrid: direct complete: Idle -> Complete" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_complete_hybrid(slot));
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_hybrid_state(slot)); // Complete
}

test "hybrid: complete rejects from ClassicalSelected (must add PQC)" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_select_classical(slot);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_complete_hybrid(slot)); // ClassicalSelected
}

test "hybrid: select_classical rejects when not Idle" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);

    _ = pqc.pqc_select_classical(slot); // -> ClassicalSelected
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_select_classical(slot)); // rejected
}

test "set_hybrid_mode rejects invalid mode" {
    const slot = pqc.pqc_create_context(0, 0);
    defer pqc.pqc_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_set_hybrid_mode(slot, 99));
}

// =========================================================================
// Stateless key transition table
// =========================================================================

test "pqc_can_key_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(0, 1)); // Empty -> Generating
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(1, 2)); // Generating -> Generated
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(2, 3)); // Generated -> Active
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(3, 4)); // Active -> Expired
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(3, 5)); // Active -> Compromised
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(2, 4)); // Generated -> Expired
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(0, 4)); // Empty -> Expired (abort)
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_key_transition(1, 4)); // Generating -> Expired (abort)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(0, 3)); // Empty -> Active (skip)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(3, 1)); // Active -> Generating (backwards)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(3, 0)); // Active -> Empty (backwards)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(4, 0)); // Expired -> any (terminal)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(5, 0)); // Compromised -> any (terminal)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(4, 3)); // Expired -> Active
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_key_transition(5, 3)); // Compromised -> Active
}

// =========================================================================
// Stateless hybrid transition table
// =========================================================================

test "pqc_can_hybrid_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(0, 1)); // Idle -> Classical
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(0, 2)); // Idle -> PQC
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(1, 3)); // Classical -> Negotiated
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(2, 3)); // PQC -> Negotiated
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(3, 4)); // Negotiated -> Complete
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_can_hybrid_transition(0, 4)); // Idle -> Complete (direct)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_hybrid_transition(0, 3)); // skip to Negotiated
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_hybrid_transition(4, 0)); // Complete -> Idle (terminal)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_hybrid_transition(1, 4)); // Classical -> Complete (skip)
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_can_hybrid_transition(2, 4)); // PQC -> Complete (skip)
}

// =========================================================================
// Algorithm/level validation
// =========================================================================

test "valid_algorithm_level matches Layout.idr cross-type table" {
    // Kyber: 1, 3, 5 valid
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(0, 0)); // NIST_1
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(0, 2)); // NIST_3
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(0, 4)); // NIST_5
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(0, 1)); // NIST_2 invalid
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(0, 3)); // NIST_4 invalid

    // Dilithium: 2, 3, 5 valid
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(1, 1)); // NIST_2
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(1, 2)); // NIST_3
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(1, 0)); // NIST_1 invalid

    // FALCON: 1, 5 valid
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(2, 0)); // NIST_1
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_algorithm_level(2, 4)); // NIST_5
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(2, 2)); // NIST_3 invalid

    // Invalid inputs
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(99, 0));
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_algorithm_level(0, 99));
}

// =========================================================================
// Operation validation
// =========================================================================

test "valid_operation matches Types.idr validOperation" {
    // KEM: keygen, encapsulate, decapsulate
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(0, 0)); // keygen
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(0, 1)); // encapsulate
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(0, 2)); // decapsulate
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_operation(0, 3)); // sign invalid
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_operation(0, 4)); // verify invalid

    // Signature: keygen, sign, verify
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(1, 0)); // keygen
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(1, 3)); // sign
    try std.testing.expectEqual(@as(u8, 1), pqc.pqc_valid_operation(1, 4)); // verify
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_operation(1, 1)); // encapsulate invalid
    try std.testing.expectEqual(@as(u8, 0), pqc.pqc_valid_operation(1, 2)); // decapsulate invalid
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_key_state(-1)); // Expired fallback
    try std.testing.expectEqual(@as(u8, 4), pqc.pqc_hybrid_state(-1)); // Complete fallback
    try std.testing.expectEqual(@as(u8, 255), pqc.pqc_algorithm(-1));
    try std.testing.expectEqual(@as(u8, 255), pqc.pqc_nist_level(-1));
    try std.testing.expectEqual(@as(u8, 255), pqc.pqc_hybrid_mode(-1));
    try std.testing.expectEqual(@as(u8, 255), pqc.pqc_category(-1));
    try std.testing.expectEqual(@as(u32, 0), pqc.pqc_public_key_len(-1));
    try std.testing.expectEqual(@as(u32, 0), pqc.pqc_secret_key_len(-1));
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    for (&slots) |*s| {
        s.* = pqc.pqc_create_context(0, 0);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| pqc.pqc_destroy_context(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), pqc.pqc_create_context(0, 0));
}
