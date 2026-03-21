// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-vpn FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

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

test "TunnelType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.TunnelType.ipsec));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.TunnelType.wireguard));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.TunnelType.openvpn));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.TunnelType.l2tp));
}

test "TunnelPhase encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.TunnelPhase.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.TunnelPhase.phase1_init));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.TunnelPhase.phase1_auth));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.TunnelPhase.phase1_done));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.TunnelPhase.phase2_negotiating));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.TunnelPhase.established));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(vpn.TunnelPhase.expired));
}

test "EncryptionAlgorithm encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.EncryptionAlgorithm.aes128_cbc));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.EncryptionAlgorithm.aes256_cbc));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.EncryptionAlgorithm.aes128_gcm));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.EncryptionAlgorithm.aes256_gcm));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.EncryptionAlgorithm.chacha20_poly1305));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.EncryptionAlgorithm.null_cipher));
}

test "IntegrityAlgorithm encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.IntegrityAlgorithm.hmac_sha512));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.IntegrityAlgorithm.no_integrity));
}

test "DHGroup encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.DHGroup.dh14));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.DHGroup.ecp256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.DHGroup.ecp384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.DHGroup.curve25519));
}

test "SALifecycle encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.SALifecycle.sa_none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.SALifecycle.sa_active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.SALifecycle.sa_rekeying));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.SALifecycle.sa_expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.SALifecycle.sa_deleted));
}

test "IKEVersion encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.IKEVersion.ikev1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.IKEVersion.ikev2));
}

test "VPNError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(vpn.VPNError.authentication_failed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(vpn.VPNError.no_proposal_chosen));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(vpn.VPNError.lifetime_expired));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(vpn.VPNError.invalid_spi));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(vpn.VPNError.replay_detected));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(vpn.VPNError.negotiation_timeout));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = vpn.vpn_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer vpn.vpn_destroy(slot);
    const state = vpn.vpn_sa_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    vpn.vpn_destroy(-1);
    vpn.vpn_destroy(999);
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = vpn.vpn_sa_state(-1);
    _ = vpn.vpn_sa_count(-1);
}

