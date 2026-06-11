// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ca FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ca = @import("ca");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ca.ca_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "CertType encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CertType.root));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CertType.intermediate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CertType.end_entity));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CertType.cross_signed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.CertType.code_signing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.CertType.email_protection));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.CertType.ocsp_signing));
}

test "KeyAlgorithm encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.KeyAlgorithm.rsa2048));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.KeyAlgorithm.rsa4096));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.KeyAlgorithm.ecdsa_p256));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.KeyAlgorithm.ecdsa_p384));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.KeyAlgorithm.ed25519));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.KeyAlgorithm.ed448));
}

test "SignatureAlgorithm encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.SignatureAlgorithm.sha256_with_rsa));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.SignatureAlgorithm.sha384_with_rsa));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.SignatureAlgorithm.sha512_with_rsa));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.SignatureAlgorithm.sha256_with_ecdsa));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.SignatureAlgorithm.sha384_with_ecdsa));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.SignatureAlgorithm.pure_ed25519));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.SignatureAlgorithm.pure_ed448));
}

test "CertState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CertState.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CertState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CertState.revoked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CertState.expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.CertState.suspended));
}

test "RevocationReason encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.RevocationReason.unspecified));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.RevocationReason.key_compromise));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.RevocationReason.ca_compromise));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.RevocationReason.affiliation_changed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.RevocationReason.superseded));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.RevocationReason.cessation_of_operation));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.RevocationReason.certificate_hold));
}

test "CRLStatus encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CRLStatus.current));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CRLStatus.crl_expired));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CRLStatus.crl_pending));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CRLStatus.crl_error));
}

test "OCSPStatus encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.OCSPStatus.good));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.OCSPStatus.ocsp_revoked));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.OCSPStatus.unknown));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.OCSPStatus.unavailable));
}

test "Extension encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.Extension.basic_constraints));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.Extension.key_usage));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.Extension.ext_key_usage));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.Extension.subject_alt_name));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.Extension.authority_info_access));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.Extension.crl_distribution_points));
}

test "KeyUsageBit encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.KeyUsageBit.digital_signature));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.KeyUsageBit.non_repudiation));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.KeyUsageBit.key_encipherment));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.KeyUsageBit.data_encipherment));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.KeyUsageBit.key_agreement));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.KeyUsageBit.key_cert_sign));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.KeyUsageBit.crl_sign));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ca.KeyUsageBit.encipher_only));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ca.KeyUsageBit.decipher_only));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ca.ca_create();
    try std.testing.expect(slot >= 0);
    defer ca.ca_destroy(slot);
    const state = ca.ca_cert_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ca.ca_destroy(-1);
    ca.ca_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ca.ca_cert_state(-1);
    _ = ca.ca_cert_count(-1);
}

