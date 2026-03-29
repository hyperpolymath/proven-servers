// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// tls_test.zig -- Integration tests for proven-tls FFI.

const std = @import("std");
const tls = @import("tls");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), tls.tls_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "TlsVersion encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.TlsVersion.tls12));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tls.TlsVersion.tls13));
}

test "CipherSuite encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.CipherSuite.aes_128_gcm_sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tls.CipherSuite.aes_256_gcm_sha384));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tls.CipherSuite.chacha20_poly1305_sha256));
}

test "HandshakeState encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.HandshakeState.client_hello));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tls.HandshakeState.server_hello));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tls.HandshakeState.encrypted_extensions));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tls.HandshakeState.certificate));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tls.HandshakeState.certificate_verify));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(tls.HandshakeState.finished));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(tls.HandshakeState.established));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(tls.HandshakeState.closed));
}

test "CertValidation encoding matches Layout.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.CertValidation.valid));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tls.CertValidation.self_signed));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(tls.CertValidation.weak_signature));
}

test "AlertLevel encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.AlertLevel.warning));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tls.AlertLevel.fatal));
}

test "AlertDescription encoding matches Layout.idr (25 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tls.AlertDescription.close_notify));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(tls.AlertDescription.handshake_failure));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(tls.AlertDescription.unknown_ca));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(tls.AlertDescription.internal_error));
    try std.testing.expectEqual(@as(u8, 24), @intFromEnum(tls.AlertDescription.no_application_protocol));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = tls.tls_create(1, 0); // TLS 1.3, AES-128-GCM
    try std.testing.expect(slot >= 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), tls.tls_state(slot)); // client_hello
}

test "create with TLS 1.2 and ChaCha20" {
    const slot = tls.tls_create(0, 2); // TLS 1.2, ChaCha20
    try std.testing.expect(slot >= 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), tls.tls_version(slot)); // tls12
    try std.testing.expectEqual(@as(u8, 2), tls.tls_cipher(slot));  // chacha20
}

test "create rejects invalid version" {
    try std.testing.expectEqual(@as(c_int, -1), tls.tls_create(99, 0));
}

test "create rejects invalid cipher" {
    try std.testing.expectEqual(@as(c_int, -1), tls.tls_create(1, 99));
}

test "destroy is safe with invalid slot" {
    tls.tls_destroy(-1);
    tls.tls_destroy(999);
}

// =========================================================================
// Valid transitions — full handshake sequence
// =========================================================================

test "full handshake: ClientHello -> ... -> Established" {
    const slot = tls.tls_create(1, 0); // TLS 1.3
    defer tls.tls_destroy(slot);

    // ClientHello -> ServerHello
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 1), tls.tls_state(slot));

    // ServerHello -> EncryptedExtensions
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 2), tls.tls_state(slot));

    // EncryptedExtensions -> Certificate
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 3), tls.tls_state(slot));

    // Certificate -> CertificateVerify
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 4), tls.tls_state(slot));

    // CertificateVerify -> Finished
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 5), tls.tls_state(slot));

    // Finished -> Established
    try std.testing.expectEqual(@as(u8, 0), tls.tls_advance(slot));
    try std.testing.expectEqual(@as(u8, 6), tls.tls_state(slot));

    // Cannot advance past Established
    try std.testing.expectEqual(@as(u8, 1), tls.tls_advance(slot));
}

test "can_send only true when Established" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);

    // ClientHello — cannot send
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_send(slot));

    // Advance to Established
    _ = tls.tls_advance(slot); // -> ServerHello
    _ = tls.tls_advance(slot); // -> EncryptedExtensions
    _ = tls.tls_advance(slot); // -> Certificate
    _ = tls.tls_advance(slot); // -> CertificateVerify
    _ = tls.tls_advance(slot); // -> Finished
    _ = tls.tls_advance(slot); // -> Established

    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_send(slot));
}

// =========================================================================
// KeyUpdate: Established -> Established
// =========================================================================

test "key_update succeeds from Established" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);

    // Advance to Established
    var i: u8 = 0;
    while (i < 6) : (i += 1) _ = tls.tls_advance(slot);

    try std.testing.expectEqual(@as(u8, 0), tls.tls_key_update(slot));
    try std.testing.expectEqual(@as(u8, 6), tls.tls_state(slot)); // still Established
}

test "key_update rejected from non-Established" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tls.tls_key_update(slot)); // ClientHello
}

// =========================================================================
// Graceful close: Established -> Closed
// =========================================================================

test "close succeeds from Established" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);

    var i: u8 = 0;
    while (i < 6) : (i += 1) _ = tls.tls_advance(slot);

    try std.testing.expectEqual(@as(u8, 0), tls.tls_close(slot));
    try std.testing.expectEqual(@as(u8, 7), tls.tls_state(slot)); // closed
    try std.testing.expectEqual(@as(u8, 0), tls.tls_last_alert(slot)); // close_notify
}

test "close rejected from non-Established" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tls.tls_close(slot));
}

// =========================================================================
// Abort: any pre-Closed -> Closed with alert
// =========================================================================

test "abort from ClientHello" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), tls.tls_abort(slot, 5)); // handshake_failure
    try std.testing.expectEqual(@as(u8, 7), tls.tls_state(slot)); // closed
    try std.testing.expectEqual(@as(u8, 5), tls.tls_last_alert(slot));
}

test "abort from Certificate" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    _ = tls.tls_advance(slot); // -> ServerHello
    _ = tls.tls_advance(slot); // -> EncryptedExtensions
    _ = tls.tls_advance(slot); // -> Certificate
    try std.testing.expectEqual(@as(u8, 0), tls.tls_abort(slot, 6)); // bad_certificate
    try std.testing.expectEqual(@as(u8, 7), tls.tls_state(slot));
}

test "cannot abort from Closed (terminal)" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    _ = tls.tls_abort(slot, 18); // internal_error -> Closed
    try std.testing.expectEqual(@as(u8, 1), tls.tls_abort(slot, 18)); // rejected
}

// =========================================================================
// Invalid transitions (impossibility proofs)
// =========================================================================

test "cannot advance from Closed" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    _ = tls.tls_abort(slot, 0); // -> Closed
    try std.testing.expectEqual(@as(u8, 1), tls.tls_advance(slot)); // rejected
}

test "cannot skip handshake to Established" {
    // The only way to reach Established is through all intermediate states
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    // After one advance we are at ServerHello(1), not Established(6)
    _ = tls.tls_advance(slot);
    try std.testing.expect(tls.tls_state(slot) != 6);
}

// =========================================================================
// Certificate validation
// =========================================================================

test "validate_cert records status" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);

    // Initially no cert status
    try std.testing.expectEqual(@as(u8, 255), tls.tls_cert_status(slot));

    // Record Valid
    try std.testing.expectEqual(@as(u8, 0), tls.tls_validate_cert(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), tls.tls_cert_status(slot));

    // Record Expired
    try std.testing.expectEqual(@as(u8, 0), tls.tls_validate_cert(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), tls.tls_cert_status(slot));
}

test "validate_cert rejects invalid tag" {
    const slot = tls.tls_create(1, 0);
    defer tls.tls_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tls.tls_validate_cert(slot, 99));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "tls_can_transition matches Transitions.idr" {
    // Forward handshake sequence
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(0, 1)); // CH -> SH
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(1, 2)); // SH -> EE
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(2, 3)); // EE -> Cert
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(3, 4)); // Cert -> CV
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(4, 5)); // CV -> Finished
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(5, 6)); // Finished -> Established
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(6, 6)); // KeyUpdate
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(6, 7)); // Established -> Closed

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(0, 7)); // CH -> Closed
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(3, 7)); // Cert -> Closed
    try std.testing.expectEqual(@as(u8, 1), tls.tls_can_transition(5, 7)); // Finished -> Closed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_transition(7, 0)); // Closed -> CH (terminal!)
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_transition(7, 6)); // Closed -> Established
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_transition(0, 6)); // CH -> Established (skip!)
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_transition(6, 1)); // Established -> SH (backwards!)
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_transition(3, 1)); // Cert -> SH (backwards!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 7), tls.tls_state(-1));   // closed fallback
    try std.testing.expectEqual(@as(u8, 255), tls.tls_version(-1));
    try std.testing.expectEqual(@as(u8, 255), tls.tls_cipher(-1));
    try std.testing.expectEqual(@as(u8, 0), tls.tls_can_send(-1));
    try std.testing.expectEqual(@as(u8, 255), tls.tls_last_alert(-1));
    try std.testing.expectEqual(@as(u8, 255), tls.tls_cert_status(-1));
}
