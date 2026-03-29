// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// authconn_test.zig — Integration tests for proven-authconn FFI.
//
// Validates:
//   - ABI version consistency
//   - Session lifecycle state machine (all valid transitions)
//   - Token lifecycle (issue, refresh, revoke)
//   - Invalid transition rejection
//   - NULL handle safety
//   - Enum tag consistency with C header and Idris2 Layout.idr

const std = @import("std");
const testing = std.testing;
const authconn = @import("authconn");

// ---------------------------------------------------------------------------
// ABI Version
// ---------------------------------------------------------------------------

test "ABI version returns 1" {
    try testing.expectEqual(@as(u32, 1), authconn.authconn_abi_version());
}

// ---------------------------------------------------------------------------
// Session Lifecycle
// ---------------------------------------------------------------------------

test "create session returns valid handle in unauthenticated state" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err);
    try testing.expect(h != null);
    try testing.expectEqual(authconn.AuthError.none, err);
    try testing.expectEqual(authconn.AuthState.unauthenticated, authconn.authconn_session_state(h));
    authconn.authconn_destroy_session(h);
}

test "direct auth: unauthenticated -> authenticated (password)" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    const result = authconn.authconn_authenticate(h, null, 0, .hashed);
    try testing.expectEqual(authconn.AuthError.none, result);
    try testing.expectEqual(authconn.AuthState.authenticated, authconn.authconn_session_state(h));
    authconn.authconn_destroy_session(h);
}

test "MFA auth: unauthenticated -> challenging -> authenticated" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.mfa, &err).?;

    // Step 1: authenticate goes to challenging
    const auth_result = authconn.authconn_authenticate(h, null, 0, .opaque_);
    try testing.expectEqual(authconn.AuthError.none, auth_result);
    try testing.expectEqual(authconn.AuthState.challenging, authconn.authconn_session_state(h));

    // Step 2: respond to challenge
    const challenge_result = authconn.authconn_challenge_respond(h, null, 0);
    try testing.expectEqual(authconn.AuthError.none, challenge_result);
    try testing.expectEqual(authconn.AuthState.authenticated, authconn.authconn_session_state(h));

    authconn.authconn_destroy_session(h);
}

test "revoke: authenticated -> revoked" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    _ = authconn.authconn_authenticate(h, null, 0, .hashed);
    const result = authconn.authconn_revoke(h);
    try testing.expectEqual(authconn.AuthError.none, result);
    try testing.expectEqual(authconn.AuthState.revoked, authconn.authconn_session_state(h));
    authconn.authconn_destroy_session(h);
}

test "reset from revoked: revoked -> unauthenticated" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    _ = authconn.authconn_authenticate(h, null, 0, .hashed);
    _ = authconn.authconn_revoke(h);
    const result = authconn.authconn_reset(h);
    try testing.expectEqual(authconn.AuthError.none, result);
    try testing.expectEqual(authconn.AuthState.unauthenticated, authconn.authconn_session_state(h));
    authconn.authconn_destroy_session(h);
}

// ---------------------------------------------------------------------------
// Invalid Transitions
// ---------------------------------------------------------------------------

test "cannot authenticate when already authenticated" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    _ = authconn.authconn_authenticate(h, null, 0, .hashed);
    const result = authconn.authconn_authenticate(h, null, 0, .hashed);
    try testing.expect(result != authconn.AuthError.none);
    authconn.authconn_destroy_session(h);
}

test "cannot challenge-respond when unauthenticated" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    const result = authconn.authconn_challenge_respond(h, null, 0);
    try testing.expect(result != authconn.AuthError.none);
    authconn.authconn_destroy_session(h);
}

test "cannot revoke when unauthenticated" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    const result = authconn.authconn_revoke(h);
    try testing.expect(result != authconn.AuthError.none);
    authconn.authconn_destroy_session(h);
}

// ---------------------------------------------------------------------------
// Token Lifecycle
// ---------------------------------------------------------------------------

test "issue token from authenticated session" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    _ = authconn.authconn_authenticate(h, null, 0, .hashed);

    const t = authconn.authconn_issue_token(h, &err);
    try testing.expect(t != null);
    try testing.expectEqual(authconn.AuthError.none, err);
    try testing.expectEqual(authconn.TokenState.valid, authconn.authconn_token_state(t));

    authconn.authconn_revoke_token(t);
    authconn.authconn_destroy_session(h);
}

test "cannot issue token from unauthenticated session" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;

    const t = authconn.authconn_issue_token(h, &err);
    try testing.expect(t == null);
    try testing.expect(err != authconn.AuthError.none);

    authconn.authconn_destroy_session(h);
}

test "refresh token returns new valid token" {
    var err: authconn.AuthError = .none;
    const h = authconn.authconn_create_session(.password_hash, &err).?;
    _ = authconn.authconn_authenticate(h, null, 0, .hashed);

    const t = authconn.authconn_issue_token(h, &err).?;
    const new_t = authconn.authconn_refresh_token(t, &err);
    try testing.expect(new_t != null);
    try testing.expectEqual(authconn.AuthError.none, err);
    try testing.expectEqual(authconn.TokenState.valid, authconn.authconn_token_state(new_t));

    authconn.authconn_revoke_token(new_t);
    authconn.authconn_destroy_session(h);
}

// ---------------------------------------------------------------------------
// NULL Handle Safety
// ---------------------------------------------------------------------------

test "NULL session handle safety" {
    try testing.expectEqual(authconn.AuthState.unauthenticated, authconn.authconn_session_state(null));
    try testing.expect(authconn.authconn_authenticate(null, null, 0, .hashed) != authconn.AuthError.none);
    try testing.expect(authconn.authconn_challenge_respond(null, null, 0) != authconn.AuthError.none);
    try testing.expect(authconn.authconn_revoke(null) != authconn.AuthError.none);
    try testing.expect(authconn.authconn_reset(null) != authconn.AuthError.none);
    authconn.authconn_destroy_session(null); // must not crash
}

test "NULL token handle safety" {
    try testing.expectEqual(authconn.TokenState.expired, authconn.authconn_token_state(null));
    authconn.authconn_revoke_token(null); // must not crash

    var err: authconn.AuthError = .none;
    try testing.expect(authconn.authconn_issue_token(null, &err) == null);
    try testing.expect(authconn.authconn_refresh_token(null, &err) == null);
}

// ---------------------------------------------------------------------------
// Enum Tag Consistency
// ---------------------------------------------------------------------------

test "AuthMethod enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(authconn.AuthMethod.password_hash));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(authconn.AuthMethod.certificate));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(authconn.AuthMethod.token));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(authconn.AuthMethod.mfa));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(authconn.AuthMethod.kerberos));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(authconn.AuthMethod.saml));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(authconn.AuthMethod.oidc));
}

test "AuthState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(authconn.AuthState.unauthenticated));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(authconn.AuthState.challenging));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(authconn.AuthState.authenticated));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(authconn.AuthState.expired));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(authconn.AuthState.revoked));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(authconn.AuthState.locked));
}

test "TokenState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(authconn.TokenState.valid));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(authconn.TokenState.expired));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(authconn.TokenState.revoked));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(authconn.TokenState.refreshing));
}

test "CredentialType enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(authconn.CredentialType.opaque_));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(authconn.CredentialType.hashed));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(authconn.CredentialType.encrypted));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(authconn.CredentialType.delegated));
}

test "AuthError enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(authconn.AuthError.none));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(authconn.AuthError.invalid_credentials));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(authconn.AuthError.account_locked));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(authconn.AuthError.token_expired));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(authconn.AuthError.mfa_required));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(authconn.AuthError.provider_unavailable));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(authconn.AuthError.insufficient_scope));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(authconn.AuthError.session_expired));
}
