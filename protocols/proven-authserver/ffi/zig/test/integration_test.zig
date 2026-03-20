// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-authserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Authentication (success/failure/lockout)
//   - MFA workflow (require/verify)
//   - Token management (issue/count)
//   - Session state transitions (revoke/expire/lock)
//   - Failed attempt tracking
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const authserver = @import("authserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), authserver.authserver_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "AuthMethod encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(authserver.AuthMethod.password));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(authserver.AuthMethod.certificate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(authserver.AuthMethod.oauth2));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(authserver.AuthMethod.saml));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(authserver.AuthMethod.fido2));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(authserver.AuthMethod.kerberos));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(authserver.AuthMethod.ldap));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(authserver.AuthMethod.radius));
}

test "TokenType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(authserver.TokenType.access));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(authserver.TokenType.refresh));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(authserver.TokenType.id));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(authserver.TokenType.api));
}

test "AuthResult encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(authserver.AuthResult.success));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(authserver.AuthResult.invalid_credentials));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(authserver.AuthResult.account_locked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(authserver.AuthResult.account_expired));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(authserver.AuthResult.mfa_required));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(authserver.AuthResult.ip_blocked));
}

test "MFAMethod encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(authserver.MFAMethod.totp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(authserver.MFAMethod.sms));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(authserver.MFAMethod.push));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(authserver.MFAMethod.fido2_mfa));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(authserver.MFAMethod.email));
}

test "SessionState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(authserver.SessionState.active));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(authserver.SessionState.expired));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(authserver.SessionState.revoked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(authserver.SessionState.locked));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Active state" {
    const slot = authserver.authserver_create(0); // Password
    try std.testing.expect(slot >= 0);
    defer authserver.authserver_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_session_state(slot)); // Active
}

test "create rejects invalid method" {
    const slot = authserver.authserver_create(99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    authserver.authserver_destroy(-1);
    authserver.authserver_destroy(999);
}

// =========================================================================
// Authentication
// =========================================================================

test "authenticate succeeds with matching method" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_authenticate(slot, 0)); // Success
}

test "authenticate fails with wrong method" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_authenticate(slot, 1)); // InvalidCredentials
}

test "authenticate locks after max failed attempts" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    // 5 wrong attempts
    var i: u32 = 0;
    while (i < 4) : (i += 1) {
        _ = authserver.authserver_authenticate(slot, 1); // wrong method
    }
    // 5th attempt triggers lockout
    try std.testing.expectEqual(@as(u8, 2), authserver.authserver_authenticate(slot, 1)); // AccountLocked
    try std.testing.expectEqual(@as(u8, 3), authserver.authserver_session_state(slot)); // Locked
}

test "failed_attempts tracks count" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_authenticate(slot, 1); // wrong
    _ = authserver.authserver_authenticate(slot, 2); // wrong
    try std.testing.expectEqual(@as(u32, 2), authserver.authserver_failed_attempts(slot));
}

// =========================================================================
// MFA workflow
// =========================================================================

test "require_mfa then authenticate returns MFARequired" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_require_mfa(slot, 0)); // TOTP
    try std.testing.expectEqual(@as(u8, 4), authserver.authserver_authenticate(slot, 0)); // MFARequired
}

test "verify_mfa then authenticate succeeds" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_require_mfa(slot, 0); // TOTP
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_verify_mfa(slot, 0)); // TOTP
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_authenticate(slot, 0)); // Success
}

test "verify_mfa rejects wrong method" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_require_mfa(slot, 0); // TOTP
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_verify_mfa(slot, 1)); // SMS (wrong)
}

test "verify_mfa rejects when not required" {
    const slot = authserver.authserver_create(0); // Password
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_verify_mfa(slot, 0));
}

// =========================================================================
// Token management
// =========================================================================

test "issue_token increments count" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_issue_token(slot, 0)); // Access
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_issue_token(slot, 1)); // Refresh
    try std.testing.expectEqual(@as(u32, 2), authserver.authserver_token_count(slot));
}

test "issue_token rejects invalid type" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_issue_token(slot, 99));
}

test "issue_token rejected from non-Active state" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_revoke_session(slot);
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_issue_token(slot, 0));
}

// =========================================================================
// Session state transitions
// =========================================================================

test "revoke_session transitions Active -> Revoked" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_revoke_session(slot));
    try std.testing.expectEqual(@as(u8, 2), authserver.authserver_session_state(slot)); // Revoked
}

test "expire_session transitions Active -> Expired" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_expire_session(slot));
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_session_state(slot)); // Expired
}

test "lock_session transitions Active -> Locked" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_lock_session(slot));
    try std.testing.expectEqual(@as(u8, 3), authserver.authserver_session_state(slot)); // Locked
}

test "cannot revoke from Expired" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_expire_session(slot);
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_revoke_session(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "authserver_can_transition matches expected" {
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_can_transition(0, 1)); // Active -> Expired
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_can_transition(0, 2)); // Active -> Revoked
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_can_transition(0, 3)); // Active -> Locked

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_can_transition(1, 0)); // Expired -/-> Active
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_can_transition(2, 0)); // Revoked -/-> Active
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_can_transition(3, 0)); // Locked -/-> Active
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_can_transition(1, 2)); // Expired -/-> Revoked
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), authserver.authserver_session_state(-1));
    try std.testing.expectEqual(@as(u32, 0), authserver.authserver_token_count(-1));
    try std.testing.expectEqual(@as(u32, 0), authserver.authserver_failed_attempts(-1));
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_revoke_session(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot authenticate from Revoked session" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_revoke_session(slot);
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_authenticate(slot, 0)); // InvalidCredentials
}

test "cannot require MFA from Locked session" {
    const slot = authserver.authserver_create(0);
    defer authserver.authserver_destroy(slot);

    _ = authserver.authserver_lock_session(slot);
    try std.testing.expectEqual(@as(u8, 1), authserver.authserver_require_mfa(slot, 0));
}
