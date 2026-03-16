// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// vpn_test.zig -- Integration tests for proven-vpn FFI.

const std = @import("std");
const vpn = @import("vpn");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), vpn.vpn_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "TunnelType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.TunnelType.ipsec));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.TunnelType.wireguard));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.TunnelType.openvpn));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.TunnelType.l2tp));
}

test "TunnelPhase encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.TunnelPhase.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.TunnelPhase.phase1_init));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.TunnelPhase.phase1_auth));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.TunnelPhase.phase1_done));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.TunnelPhase.phase2_negotiating));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.TunnelPhase.established));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(vpn.TunnelPhase.expired));
}

test "EncryptionAlgorithm encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.EncryptionAlgorithm.aes128_cbc));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.EncryptionAlgorithm.aes256_cbc));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.EncryptionAlgorithm.aes128_gcm));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.EncryptionAlgorithm.aes256_gcm));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.EncryptionAlgorithm.chacha20_poly1305));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.EncryptionAlgorithm.null_cipher));
}

test "IntegrityAlgorithm encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha512));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.IntegrityAlgorithm.no_integrity));
}

test "DHGroup encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.DHGroup.dh14));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.DHGroup.ecp256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.DHGroup.ecp384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.DHGroup.curve25519));
}

test "SALifecycle encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.SALifecycle.sa_none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.SALifecycle.sa_active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.SALifecycle.sa_rekeying));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.SALifecycle.sa_expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.SALifecycle.sa_deleted));
}

test "IKEVersion encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.IKEVersion.ikev1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.IKEVersion.ikev2));
}

test "VPNError encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.VPNError.authentication_failed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.VPNError.no_proposal_chosen));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.VPNError.lifetime_expired));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.VPNError.invalid_spi));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.VPNError.replay_detected));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.VPNError.negotiation_timeout));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = vpn.vpn_create(0, 1); // IPSec, IKEv2
    try std.testing.expect(slot >= 0);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_phase(slot)); // Idle
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_tunnel_type(slot)); // IPSec
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_ike_version(slot)); // IKEv2
}

test "create rejects invalid tunnel type" {
    try std.testing.expectEqual(@as(c_int, -1), vpn.vpn_create(99, 1));
}

test "create rejects invalid IKE version" {
    try std.testing.expectEqual(@as(c_int, -1), vpn.vpn_create(0, 99));
}

test "destroy is safe with invalid slot" {
    vpn.vpn_destroy(-1);
    vpn.vpn_destroy(999);
}

// =========================================================================
// Full tunnel establishment: Idle -> P1Init -> P1Done -> P2Neg -> Established
// =========================================================================

test "full lifecycle: Idle -> Phase1Init -> Phase1Done -> Phase2Negotiating -> Established" {
    const slot = vpn.vpn_create(1, 1); // WireGuard, IKEv2
    defer vpn.vpn_destroy(slot);

    // Idle -> Phase1Init (DH exchange with Curve25519)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_begin_phase1(slot, 3));
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_phase(slot)); // Phase1Init

    // Phase1Init -> Phase1Done (AUTH with AES-256-GCM + HMAC-SHA256)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_complete_phase1_auth(slot, 3, 1));
    try std.testing.expectEqual(@as(u8, 3), vpn.vpn_phase(slot)); // Phase1Done

    // Phase1Done -> Phase2Negotiating (Child SA with ChaCha20 + no integrity + ECP384)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_begin_phase2(slot, 4, 4, 2));
    try std.testing.expectEqual(@as(u8, 4), vpn.vpn_phase(slot)); // Phase2Negotiating

    // Phase2Negotiating -> Established (create SA with SPI=0x1000)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_establish(slot, 0x1000));
    try std.testing.expectEqual(@as(u8, 5), vpn.vpn_phase(slot)); // Established
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_transfer(slot));
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_rekey(slot));
}

// =========================================================================
// SA management
// =========================================================================

test "SA created during establishment has Active state" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    // Drive to Established
    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 3, 1);
    _ = vpn.vpn_begin_phase2(slot, 3, 1, 0);
    _ = vpn.vpn_establish(slot, 0xABCD);

    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_sa_state(slot, 0xABCD)); // SAActive
    try std.testing.expectEqual(@as(u32, 1), vpn.vpn_sa_count(slot));
    try std.testing.expectEqual(@as(u8, 3), vpn.vpn_sa_encryption(slot, 0xABCD)); // AES256GCM
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_sa_integrity(slot, 0xABCD)); // HMACSHA256
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_dh_group(slot, 0xABCD)); // DH14
}

test "SA rekey lifecycle: Active -> Rekeying -> new Active + old Deleted" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 1);
    _ = vpn.vpn_complete_phase1_auth(slot, 2, 1);
    _ = vpn.vpn_begin_phase2(slot, 2, 1, 1);
    _ = vpn.vpn_establish(slot, 100);

    // Begin rekey
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_begin_rekey(slot, 100));
    try std.testing.expectEqual(@as(u8, 2), vpn.vpn_sa_state(slot, 100)); // SARekeying

    // Complete rekey (old SPI=100, new SPI=200)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_complete_rekey(slot, 100, 200));
    try std.testing.expectEqual(@as(u8, 4), vpn.vpn_sa_state(slot, 100)); // SADeleted
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_sa_state(slot, 200)); // SAActive
}

test "SA explicit delete from Active" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 0, 0);
    _ = vpn.vpn_begin_phase2(slot, 0, 0, 0);
    _ = vpn.vpn_establish(slot, 500);

    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_delete(slot, 500));
    try std.testing.expectEqual(@as(u8, 4), vpn.vpn_sa_state(slot, 500)); // SADeleted
}

test "SA nonexistent SPI returns SANone" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_state(slot, 999)); // SANone
    try std.testing.expectEqual(@as(u8, 255), vpn.vpn_sa_encryption(slot, 999));
}

// =========================================================================
// Expiry and restart
// =========================================================================

test "expire from Established" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 0, 0);
    _ = vpn.vpn_begin_phase2(slot, 0, 0, 0);
    _ = vpn.vpn_establish(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_expire(slot));
    try std.testing.expectEqual(@as(u8, 6), vpn.vpn_phase(slot)); // Expired
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_transfer(slot));
}

test "expire from Phase1Init" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_expire(slot));
    try std.testing.expectEqual(@as(u8, 6), vpn.vpn_phase(slot));
}

test "expire rejects from Idle" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_expire(slot));
}

test "expire rejects from Expired" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_expire(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_expire(slot));
}

test "restart from Expired resets to Idle" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_expire(slot);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_restart(slot));
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_phase(slot)); // Idle
}

test "restart rejects if not Expired" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_restart(slot)); // Idle
}

// =========================================================================
// Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "cannot skip Phase1 Init (Idle -> Phase1Auth)" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_complete_phase1_auth(slot, 0, 0)); // Idle, not Phase1Init
}

test "cannot skip to Established (Idle -> Established)" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_establish(slot, 1));
}

test "cannot begin Phase2 without Phase1 done" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_begin_phase2(slot, 0, 0, 0)); // Idle
}

test "begin_phase1 rejects invalid DH group" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_begin_phase1(slot, 99));
}

test "complete_phase1_auth rejects invalid encryption tag" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    _ = vpn.vpn_begin_phase1(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_complete_phase1_auth(slot, 99, 0));
}

test "establish rejects SPI 0" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 0, 0);
    _ = vpn.vpn_begin_phase2(slot, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_establish(slot, 0));
}

// =========================================================================
// Stateless phase transition table
// =========================================================================

test "vpn_can_phase_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(0, 1)); // Idle -> Phase1Init
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(1, 2)); // Phase1Init -> Phase1Auth
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(2, 3)); // Phase1Auth -> Phase1Done
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(3, 4)); // Phase1Done -> Phase2Neg
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(4, 5)); // Phase2Neg -> Established
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(5, 4)); // Established -> Phase2Neg (rekey child)
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(5, 1)); // Established -> Phase1Init (full rekey)
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(1, 6)); // Phase1Init -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(2, 6)); // Phase1Auth -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(3, 6)); // Phase1Done -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(4, 6)); // Phase2Neg -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(5, 6)); // Established -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_phase_transition(6, 0)); // Expired -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(0, 2)); // skip Phase1Init
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(0, 3)); // skip to Phase1Done
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(0, 5)); // skip to Established
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(6, 5)); // Expired -> Established
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(0, 6)); // Idle -> Expired
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_phase_transition(6, 1)); // Expired -> Phase1Init
}

// =========================================================================
// Stateless SA transition table
// =========================================================================

test "vpn_can_sa_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(0, 1)); // None -> Active
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(1, 2)); // Active -> Rekeying
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(2, 1)); // Rekeying -> Active
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(1, 3)); // Active -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(2, 3)); // Rekeying -> Expired
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(1, 4)); // Active -> Deleted
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_can_sa_transition(2, 4)); // Rekeying -> Deleted

    // Invalid transitions (terminal states cannot leave)
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_sa_transition(3, 0)); // Expired -> None
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_sa_transition(3, 1)); // Expired -> Active
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_sa_transition(4, 0)); // Deleted -> None
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_sa_transition(4, 1)); // Deleted -> Active
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_sa_transition(0, 2)); // None -> Rekeying (skip create)
}

// =========================================================================
// Capability queries
// =========================================================================

test "can_transfer false when not Established" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_transfer(slot)); // Idle
}

test "can_rekey false when not Established" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_rekey(slot)); // Idle
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 6), vpn.vpn_phase(-1)); // Expired fallback
    try std.testing.expectEqual(@as(u8, 255), vpn.vpn_tunnel_type(-1));
    try std.testing.expectEqual(@as(u8, 255), vpn.vpn_ike_version(-1));
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_transfer(-1));
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_can_rekey(-1));
    try std.testing.expectEqual(@as(u32, 0), vpn.vpn_sa_count(-1));
    try std.testing.expectEqual(@as(u8, 0), vpn.vpn_sa_state(-1, 0));
}

// =========================================================================
// SA delete rejects invalid state
// =========================================================================

test "sa_delete rejects from Deleted state" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 0, 0);
    _ = vpn.vpn_begin_phase2(slot, 0, 0, 0);
    _ = vpn.vpn_establish(slot, 42);
    _ = vpn.vpn_sa_delete(slot, 42);

    // Already deleted -- should reject
    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_sa_delete(slot, 42));
}

test "sa_begin_rekey rejects from non-Active state" {
    const slot = vpn.vpn_create(0, 1);
    defer vpn.vpn_destroy(slot);

    _ = vpn.vpn_begin_phase1(slot, 0);
    _ = vpn.vpn_complete_phase1_auth(slot, 0, 0);
    _ = vpn.vpn_begin_phase2(slot, 0, 0, 0);
    _ = vpn.vpn_establish(slot, 77);
    _ = vpn.vpn_sa_delete(slot, 77);

    try std.testing.expectEqual(@as(u8, 1), vpn.vpn_sa_begin_rekey(slot, 77)); // Deleted
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    for (&slots) |*s| {
        s.* = vpn.vpn_create(0, 1);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| vpn.vpn_destroy(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), vpn.vpn_create(0, 1));
}
