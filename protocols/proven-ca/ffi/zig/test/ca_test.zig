// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ca_test.zig -- Integration tests for proven-ca FFI.
//
// Validates that the Zig FFI matches the Idris2 ABI specification:
//   - Enum tag encodings match Layout.idr
//   - State transitions match Transitions.idr
//   - CA hierarchy matches CanIssue GADT
//   - CRL/OCSP management
//   - Chain validation
//   - Edge cases and impossibility invariants

const std = @import("std");
const ca = @import("ca");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ca.ca_abi_version());
}

// =========================================================================
// Enum encoding seams — match Layout.idr tag assignments
// =========================================================================

test "CertType encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CertType.root));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CertType.intermediate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CertType.end_entity));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CertType.cross_signed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.CertType.code_signing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.CertType.email_protection));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.CertType.ocsp_signing));
}

test "KeyAlgorithm encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.KeyAlgorithm.rsa2048));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.KeyAlgorithm.rsa4096));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.KeyAlgorithm.ecdsa_p256));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.KeyAlgorithm.ecdsa_p384));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.KeyAlgorithm.ed25519));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.KeyAlgorithm.ed448));
}

test "SignatureAlgorithm encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.SignatureAlgorithm.sha256_with_rsa));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.SignatureAlgorithm.sha384_with_rsa));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.SignatureAlgorithm.sha512_with_rsa));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.SignatureAlgorithm.sha256_with_ecdsa));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.SignatureAlgorithm.sha384_with_ecdsa));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.SignatureAlgorithm.pure_ed25519));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.SignatureAlgorithm.pure_ed448));
}

test "CertState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CertState.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CertState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CertState.revoked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CertState.expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.CertState.suspended));
}

test "RevocationReason encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.RevocationReason.unspecified));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.RevocationReason.key_compromise));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.RevocationReason.ca_compromise));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.RevocationReason.affiliation_changed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ca.RevocationReason.superseded));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ca.RevocationReason.cessation_of_operation));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ca.RevocationReason.certificate_hold));
}

test "CRLStatus encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.CRLStatus.current));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.CRLStatus.crl_expired));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.CRLStatus.crl_pending));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.CRLStatus.crl_error));
}

test "OCSPStatus encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ca.OCSPStatus.good));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ca.OCSPStatus.ocsp_revoked));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ca.OCSPStatus.unknown));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ca.OCSPStatus.unavailable));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ca.ca_create();
    try std.testing.expect(slot >= 0);
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(c_int, 0), ca.ca_cert_count(slot));
}

test "destroy is safe with invalid slot" {
    ca.ca_destroy(-1);
    ca.ca_destroy(999);
}

// =========================================================================
// Certificate issuance
// =========================================================================

test "issue cert creates Pending certificate" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    // Issue a Root cert with RSA4096 / SHA384WithRSA
    const cert_id = ca.ca_issue_cert(slot, 0, 1, 1);
    try std.testing.expect(cert_id >= 0);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_cert_state(slot, cert_id)); // Pending
    try std.testing.expectEqual(@as(u8, 0), ca.ca_cert_type(slot, cert_id)); // Root
    try std.testing.expectEqual(@as(u8, 1), ca.ca_cert_key_algo(slot, cert_id)); // RSA4096
    try std.testing.expectEqual(@as(u8, 1), ca.ca_cert_sig_algo(slot, cert_id)); // SHA384WithRSA
    try std.testing.expectEqual(@as(c_int, 1), ca.ca_cert_count(slot));
}

test "issue cert rejects invalid cert type" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_issue_cert(slot, 99, 0, 0));
}

test "issue cert rejects invalid key algo" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_issue_cert(slot, 0, 99, 0));
}

test "issue cert rejects invalid sig algo" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_issue_cert(slot, 0, 0, 99));
}

// =========================================================================
// Certificate lifecycle: full cycle
// =========================================================================

test "full lifecycle: Pending -> Active -> Suspended -> Active -> Revoked" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 4, 5); // EndEntity, Ed25519, PureEd25519
    try std.testing.expect(cert >= 0);

    // Sign: Pending -> Active
    try std.testing.expectEqual(@as(u8, 0), ca.ca_sign_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_cert_state(slot, cert)); // Active

    // Suspend: Active -> Suspended
    try std.testing.expectEqual(@as(u8, 0), ca.ca_suspend_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 4), ca.ca_cert_state(slot, cert)); // Suspended

    // Reinstate: Suspended -> Active
    try std.testing.expectEqual(@as(u8, 0), ca.ca_reinstate_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_cert_state(slot, cert)); // Active

    // Revoke: Active -> Revoked
    try std.testing.expectEqual(@as(u8, 0), ca.ca_revoke_cert(slot, cert, 1)); // KeyCompromise
    try std.testing.expectEqual(@as(u8, 2), ca.ca_cert_state(slot, cert)); // Revoked
}

test "expire: Active -> Expired" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0); // Root, RSA2048, SHA256WithRSA
    _ = ca.ca_sign_cert(slot, cert);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_expire_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 3), ca.ca_cert_state(slot, cert)); // Expired
}

test "renew: Active -> new Pending cert" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 1, 2, 3); // Intermediate, ECDSA_P256, SHA256WithECDSA
    _ = ca.ca_sign_cert(slot, cert);
    const new_cert = ca.ca_renew_cert(slot, cert);
    try std.testing.expect(new_cert >= 0);
    try std.testing.expect(new_cert != cert);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_cert_state(slot, new_cert)); // Pending
    try std.testing.expectEqual(@as(u8, 1), ca.ca_cert_type(slot, new_cert)); // Same type
}

// =========================================================================
// Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "revoked is terminal: cannot sign, suspend, expire, or renew" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_revoke_cert(slot, cert, 0);
    // All transitions from Revoked must fail
    try std.testing.expectEqual(@as(u8, 1), ca.ca_sign_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_suspend_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_expire_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_reinstate_cert(slot, cert));
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_renew_cert(slot, cert));
}

test "expired is terminal: cannot sign, suspend, revoke, or renew" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_expire_cert(slot, cert);
    // All transitions from Expired must fail
    try std.testing.expectEqual(@as(u8, 1), ca.ca_sign_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_suspend_cert(slot, cert));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_revoke_cert(slot, cert, 0));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_reinstate_cert(slot, cert));
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_renew_cert(slot, cert));
}

test "cannot suspend from Pending" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_suspend_cert(slot, cert));
}

test "cannot expire from Pending" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_expire_cert(slot, cert));
}

test "cannot reinstate from Active" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_reinstate_cert(slot, cert));
}

test "revoke from Suspended works" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_suspend_cert(slot, cert);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_revoke_cert(slot, cert, 2)); // CACompromise
    try std.testing.expectEqual(@as(u8, 2), ca.ca_cert_state(slot, cert)); // Revoked
}

test "revoke rejects invalid reason tag" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_revoke_cert(slot, cert, 99));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ca_can_transition matches Transitions.idr ValidCertTransition" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(0, 1)); // Pending -> Active
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(1, 2)); // Active -> Revoked
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(1, 3)); // Active -> Expired
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(1, 4)); // Active -> Suspended
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(1, 0)); // Active -> Pending (Renew)
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(4, 1)); // Suspended -> Active
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(4, 2)); // Suspended -> Revoked
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_transition(0, 2)); // Pending -> Revoked (Reject)

    // Invalid transitions (terminal states, skips)
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(2, 0)); // Revoked -> anything
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(2, 1)); // Revoked -> Active
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(3, 0)); // Expired -> anything
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(3, 1)); // Expired -> Active
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(0, 3)); // Pending -> Expired (skip)
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(0, 4)); // Pending -> Suspended (skip)
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_transition(1, 1)); // Active -> Active (no self-loop)
}

// =========================================================================
// CA hierarchy — CanIssue GADT
// =========================================================================

test "ca_can_issue matches Transitions.idr CanIssue" {
    // Root can issue: Intermediate, CrossSigned, EndEntity
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(0, 1));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(0, 3));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(0, 2));
    // Intermediate can issue: EndEntity, CodeSigning, EmailProtection, OCSPSigning
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(1, 2));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(1, 4));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(1, 5));
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(1, 6));
    // CrossSigned can issue: EndEntity
    try std.testing.expectEqual(@as(u8, 1), ca.ca_can_issue(3, 2));

    // EndEntity cannot issue anything
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(2, 0));
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(2, 1));
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(2, 2));
    // CodeSigning cannot issue anything
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(4, 2));
    // Root cannot issue Root
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(0, 0));
    // Intermediate cannot issue Intermediate
    try std.testing.expectEqual(@as(u8, 0), ca.ca_can_issue(1, 1));
}

// =========================================================================
// Chain validation
// =========================================================================

test "self-signed root chain is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 1, 1); // Root
    _ = ca.ca_sign_cert(slot, root);
    // Root with no issuer (-1) is self-signed and valid
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_chain(slot, root));
}

test "intermediate issued by root chain is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 1, 1); // Root
    _ = ca.ca_sign_cert(slot, root);
    const inter = ca.ca_issue_cert(slot, 1, 2, 3); // Intermediate
    // Set issuer
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_issuer(slot, inter, root));
    _ = ca.ca_sign_cert(slot, inter);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_chain(slot, inter));
}

test "set_issuer rejects invalid hierarchy" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const end1 = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    const end2 = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    // EndEntity cannot issue EndEntity
    try std.testing.expectEqual(@as(u8, 1), ca.ca_set_issuer(slot, end2, end1));
}

test "cert_issuer returns -1 for self-signed" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0);
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_cert_issuer(slot, root));
}

// =========================================================================
// CRL management
// =========================================================================

test "initial CRL status is pending" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), ca.ca_crl_status(slot)); // crl_pending
}

test "update_crl transitions to current" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_update_crl(slot));
    try std.testing.expectEqual(@as(u8, 0), ca.ca_crl_status(slot)); // current
}

test "crl_status on invalid slot returns error" {
    try std.testing.expectEqual(@as(u8, 3), ca.ca_crl_status(-1)); // crl_error fallback
}

// =========================================================================
// OCSP responder
// =========================================================================

test "initial OCSP status is unavailable" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(u8, 3), ca.ca_ocsp_status(slot)); // unavailable
}

test "ocsp_query returns good for active cert" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 4, 5);
    _ = ca.ca_sign_cert(slot, cert);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_ocsp_query(slot, cert)); // good
    // OCSP status should now be 'good' (responder is serving)
    try std.testing.expectEqual(@as(u8, 0), ca.ca_ocsp_status(slot));
}

test "ocsp_query returns revoked for revoked cert" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_revoke_cert(slot, cert, 0);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_ocsp_query(slot, cert)); // revoked
}

test "ocsp_query returns unknown for pending cert" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    try std.testing.expectEqual(@as(u8, 2), ca.ca_ocsp_query(slot, cert)); // unknown
}

test "ocsp_query on invalid slot returns unavailable" {
    try std.testing.expectEqual(@as(u8, 3), ca.ca_ocsp_query(-1, 0)); // unavailable
}

// =========================================================================
// State queries on invalid slots/certs
// =========================================================================

test "queries safe on invalid context slot" {
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_state(-1, 0));
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_type(-1, 0));
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_key_algo(-1, 0));
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_sig_algo(-1, 0));
    try std.testing.expectEqual(@as(c_int, 0), ca.ca_cert_count(-1));
    try std.testing.expectEqual(@as(c_int, -1), ca.ca_cert_issuer(-1, 0));
}

test "queries safe on invalid cert id within valid context" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_state(slot, -1));
    try std.testing.expectEqual(@as(u8, 255), ca.ca_cert_state(slot, 999));
}

// =========================================================================
// KeyUsageBit encoding
// =========================================================================

test "KeyUsageBit encoding matches Layout.idr (9 tags)" {
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
// Validity period
// =========================================================================

test "set_validity enforces notBefore < notAfter" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    // Valid: notBefore=1000, notAfter=2000
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_validity(slot, cert, 1000, 2000));
    try std.testing.expectEqual(@as(u64, 1000), ca.ca_cert_not_before(slot, cert));
    try std.testing.expectEqual(@as(u64, 2000), ca.ca_cert_not_after(slot, cert));
}

test "set_validity rejects notBefore == notAfter" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_set_validity(slot, cert, 1000, 1000));
}

test "set_validity rejects notBefore > notAfter" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), ca.ca_set_validity(slot, cert, 2000, 1000));
}

test "validity unset returns 0 for both timestamps" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0);
    try std.testing.expectEqual(@as(u64, 0), ca.ca_cert_not_before(slot, cert));
    try std.testing.expectEqual(@as(u64, 0), ca.ca_cert_not_after(slot, cert));
}

test "validity queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u64, 0), ca.ca_cert_not_before(-1, 0));
    try std.testing.expectEqual(@as(u64, 0), ca.ca_cert_not_after(-1, 0));
}

// =========================================================================
// Serial numbers (monotonic counter)
// =========================================================================

test "serial numbers are monotonically increasing" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const c1 = ca.ca_issue_cert(slot, 0, 0, 0);
    const c2 = ca.ca_issue_cert(slot, 1, 0, 0);
    const c3 = ca.ca_issue_cert(slot, 2, 0, 0);
    const s1 = ca.ca_cert_serial(slot, c1);
    const s2 = ca.ca_cert_serial(slot, c2);
    const s3 = ca.ca_cert_serial(slot, c3);
    try std.testing.expect(s1 > 0);
    try std.testing.expect(s2 > s1);
    try std.testing.expect(s3 > s2);
}

test "next_serial is always greater than last issued serial" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const next_before = ca.ca_next_serial(slot);
    try std.testing.expect(next_before > 0);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0);
    const serial = ca.ca_cert_serial(slot, cert);
    try std.testing.expectEqual(next_before, serial);
    const next_after = ca.ca_next_serial(slot);
    try std.testing.expect(next_after > serial);
}

test "renewed cert gets new serial" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 1, 2, 3);
    _ = ca.ca_sign_cert(slot, cert);
    const old_serial = ca.ca_cert_serial(slot, cert);
    const new_cert = ca.ca_renew_cert(slot, cert);
    const new_serial = ca.ca_cert_serial(slot, new_cert);
    try std.testing.expect(new_serial > old_serial);
}

test "serial query safe on invalid slot" {
    try std.testing.expectEqual(@as(u64, 0), ca.ca_cert_serial(-1, 0));
    try std.testing.expectEqual(@as(u64, 0), ca.ca_next_serial(-1));
}

// =========================================================================
// Path length constraints
// =========================================================================

test "set path length on CA cert types" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0); // Root
    const inter = ca.ca_issue_cert(slot, 1, 0, 0); // Intermediate
    // Root can have path length
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_path_length(slot, root, 2));
    try std.testing.expectEqual(@as(i32, 2), ca.ca_cert_path_length(slot, root));
    // Intermediate can have path length
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_path_length(slot, inter, 0));
    try std.testing.expectEqual(@as(i32, 0), ca.ca_cert_path_length(slot, inter));
}

test "set path length rejects non-CA cert types" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const ee = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    try std.testing.expectEqual(@as(u8, 1), ca.ca_set_path_length(slot, ee, 1));
    // EndEntity can have -1 (unconstrained/leaf)
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_path_length(slot, ee, -1));
}

test "validate_path_length: child < parent is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0);
    _ = ca.ca_sign_cert(slot, root);
    _ = ca.ca_set_path_length(slot, root, 2);
    const inter = ca.ca_issue_cert(slot, 1, 0, 0);
    _ = ca.ca_set_issuer(slot, inter, root);
    _ = ca.ca_set_path_length(slot, inter, 1);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_path_length(slot, inter));
}

test "validate_path_length: child >= parent is invalid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0);
    _ = ca.ca_sign_cert(slot, root);
    _ = ca.ca_set_path_length(slot, root, 1);
    const inter = ca.ca_issue_cert(slot, 1, 0, 0);
    _ = ca.ca_set_issuer(slot, inter, root);
    _ = ca.ca_set_path_length(slot, inter, 1); // same as parent = violation
    try std.testing.expectEqual(@as(u8, 1), ca.ca_validate_path_length(slot, inter));
}

test "validate_path_length: zero blocks further intermediates" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0);
    _ = ca.ca_sign_cert(slot, root);
    _ = ca.ca_set_path_length(slot, root, 0);
    const inter = ca.ca_issue_cert(slot, 1, 0, 0);
    _ = ca.ca_set_issuer(slot, inter, root);
    _ = ca.ca_set_path_length(slot, inter, 0); // child=0, parent=0 => violation
    try std.testing.expectEqual(@as(u8, 1), ca.ca_validate_path_length(slot, inter));
}

test "validate_path_length: self-signed always valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0);
    _ = ca.ca_set_path_length(slot, root, 2);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_path_length(slot, root));
}

test "path_length defaults to -1 (unconstrained)" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0);
    try std.testing.expectEqual(@as(i32, -1), ca.ca_cert_path_length(slot, cert));
}

test "path_length query safe on invalid slot" {
    try std.testing.expectEqual(@as(i32, -1), ca.ca_cert_path_length(-1, 0));
}

// =========================================================================
// Key usage
// =========================================================================

test "set and get key usage bitmask" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0); // Root
    // Set keyCertSign (bit 5) + cRLSign (bit 6) = 0b01100000 = 0x60 = 96
    const ca_bits: u16 = (1 << 5) | (1 << 6);
    try std.testing.expectEqual(@as(u8, 0), ca.ca_set_key_usage(slot, cert, ca_bits));
    try std.testing.expectEqual(ca_bits, ca.ca_cert_key_usage(slot, cert));
}

test "validate_key_usage: CA cert with keyCertSign is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0); // Root
    _ = ca.ca_set_key_usage(slot, root, (1 << 5) | (1 << 6)); // keyCertSign + cRLSign
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_key_usage(slot, root));
}

test "validate_key_usage: CA cert without keyCertSign is invalid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const root = ca.ca_issue_cert(slot, 0, 0, 0); // Root
    _ = ca.ca_set_key_usage(slot, root, (1 << 0)); // only digitalSignature, no keyCertSign
    try std.testing.expectEqual(@as(u8, 1), ca.ca_validate_key_usage(slot, root));
}

test "validate_key_usage: EndEntity without keyCertSign is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const ee = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    _ = ca.ca_set_key_usage(slot, ee, (1 << 0) | (1 << 2)); // digitalSignature + keyEncipherment
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_key_usage(slot, ee));
}

test "validate_key_usage: EndEntity with keyCertSign is invalid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const ee = ca.ca_issue_cert(slot, 2, 0, 0); // EndEntity
    _ = ca.ca_set_key_usage(slot, ee, (1 << 0) | (1 << 5)); // digitalSignature + keyCertSign
    try std.testing.expectEqual(@as(u8, 1), ca.ca_validate_key_usage(slot, ee));
}

test "validate_key_usage: Intermediate with keyCertSign is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const inter = ca.ca_issue_cert(slot, 1, 0, 0); // Intermediate
    _ = ca.ca_set_key_usage(slot, inter, (1 << 5)); // keyCertSign only
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_key_usage(slot, inter));
}

test "validate_key_usage: CodeSigning without keyCertSign is valid" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cs = ca.ca_issue_cert(slot, 4, 0, 0); // CodeSigning
    _ = ca.ca_set_key_usage(slot, cs, (1 << 0)); // digitalSignature only
    try std.testing.expectEqual(@as(u8, 0), ca.ca_validate_key_usage(slot, cs));
}

test "key_usage defaults to 0 (no bits set)" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 0, 0, 0);
    try std.testing.expectEqual(@as(u16, 0), ca.ca_cert_key_usage(slot, cert));
}

test "key_usage query safe on invalid slot" {
    try std.testing.expectEqual(@as(u16, 0), ca.ca_cert_key_usage(-1, 0));
}

// =========================================================================
// Revocation irreversibility (FFI enforcement)
// =========================================================================

test "revoked cert cannot be re-signed (irreversible)" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_revoke_cert(slot, cert, 1);
    // Attempt to sign again must fail
    try std.testing.expectEqual(@as(u8, 1), ca.ca_sign_cert(slot, cert));
    // State must remain Revoked
    try std.testing.expectEqual(@as(u8, 2), ca.ca_cert_state(slot, cert));
}

test "double revocation is idempotent rejection" {
    const slot = ca.ca_create();
    defer ca.ca_destroy(slot);
    const cert = ca.ca_issue_cert(slot, 2, 0, 0);
    _ = ca.ca_sign_cert(slot, cert);
    _ = ca.ca_revoke_cert(slot, cert, 0);
    // Second revocation attempt fails (already terminal)
    try std.testing.expectEqual(@as(u8, 1), ca.ca_revoke_cert(slot, cert, 0));
}
