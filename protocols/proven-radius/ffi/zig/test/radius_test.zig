// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// radius_test.zig -- Integration tests for proven-radius FFI.
//
// Validates that the Zig FFI implementation matches the Idris2 ABI
// definitions in Layout.idr, Transitions.idr, and Foreign.idr.
//
// Test categories:
//   1.  ABI version
//   2.  Enum encoding seams (PacketType, AttributeType, ServiceType,
//       AuthMethod, SessionState, RadiusResult)
//   3.  Session lifecycle (create/destroy)
//   4.  Full AAA state machine transitions
//   5.  Invalid transitions (impossibility proofs)
//   6.  Shared secret management
//   7.  Attribute TLV encoding
//   8.  Stateless transition table (radius_can_transition)
//   9.  State queries on invalid slots
//   10. Pool exhaustion

const std = @import("std");
const radius = @import("radius");

// =========================================================================
// 1. ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), radius.radius_abi_version());
}

// =========================================================================
// 2. Enum encoding seams
// =========================================================================

test "PacketType encoding matches Layout.idr (6 tags, RFC 2865 codes)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.PacketType.access_request));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.PacketType.access_accept));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.PacketType.access_reject));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.PacketType.accounting_request));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.PacketType.accounting_response));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(radius.PacketType.access_challenge));
}

test "AttributeType encoding matches Layout.idr (9 tags, RFC 2865 types)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.AttributeType.user_name));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.AttributeType.user_password));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.AttributeType.nas_ip_address));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.AttributeType.nas_port));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.AttributeType.service_type));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(radius.AttributeType.framed_protocol));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(radius.AttributeType.framed_ip_address));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(radius.AttributeType.reply_message));
    try std.testing.expectEqual(@as(u8, 27), @intFromEnum(radius.AttributeType.session_timeout));
}

test "ServiceType encoding matches Layout.idr (6 tags, RFC 2865 Section 5.6)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.ServiceType.login));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.ServiceType.framed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.ServiceType.callback_login));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.ServiceType.callback_framed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.ServiceType.outbound));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.ServiceType.administrative));
}

test "AuthMethod encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.AuthMethod.pap));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.AuthMethod.chap));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.AuthMethod.mschap));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.AuthMethod.mschapv2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.AuthMethod.eap));
}

test "SessionState encoding matches Transitions.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.SessionState.authenticating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.SessionState.authorized));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.SessionState.rejected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.SessionState.challenged));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.SessionState.accounting));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.SessionState.complete));
}

test "RadiusResult encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.RadiusResult.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.RadiusResult.err));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.RadiusResult.invalid_param));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.RadiusResult.pool_exhausted));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.RadiusResult.bad_secret));
}

// =========================================================================
// 3. Session lifecycle (create/destroy)
// =========================================================================

test "create with PAP returns valid slot in Idle state" {
    const slot = radius.radius_session_create(0); // PAP
    try std.testing.expect(slot >= 0);
    defer radius.radius_session_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // idle
}

test "create with each AuthMethod succeeds" {
    // PAP=0, CHAP=1, MSCHAP=2, MSCHAPv2=3, EAP=4
    var i: u8 = 0;
    while (i <= 4) : (i += 1) {
        const slot = radius.radius_session_create(i);
        try std.testing.expect(slot >= 0);
        try std.testing.expectEqual(i, radius.radius_get_auth_method(slot));
        radius.radius_session_destroy(slot);
    }
}

test "create rejects invalid auth method" {
    try std.testing.expectEqual(@as(c_int, -1), radius.radius_session_create(5));
    try std.testing.expectEqual(@as(c_int, -1), radius.radius_session_create(99));
    try std.testing.expectEqual(@as(c_int, -1), radius.radius_session_create(255));
}

test "destroy is safe with invalid slot indices" {
    radius.radius_session_destroy(-1);
    radius.radius_session_destroy(-999);
    radius.radius_session_destroy(64);
    radius.radius_session_destroy(999);
}

test "destroy frees slot for reuse" {
    const slot1 = radius.radius_session_create(0);
    try std.testing.expect(slot1 >= 0);
    radius.radius_session_destroy(slot1);

    // Slot should be available again
    const slot2 = radius.radius_session_create(1);
    try std.testing.expect(slot2 >= 0);
    defer radius.radius_session_destroy(slot2);
    // Reused slot should be in fresh Idle state with new auth method
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot2)); // idle
    try std.testing.expectEqual(@as(u8, 1), radius.radius_get_auth_method(slot2)); // CHAP
}

// =========================================================================
// 4. Full AAA state machine transitions
// =========================================================================

test "full AAA lifecycle: Idle -> Authenticating -> Authorized -> Accounting -> Complete -> Idle" {
    const slot = radius.radius_session_create(0); // PAP
    defer radius.radius_session_destroy(slot);

    // Idle -> Authenticating (BeginAuth)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 42));
    try std.testing.expectEqual(@as(u8, 1), radius.radius_session_state(slot));
    try std.testing.expectEqual(@as(u8, 42), radius.radius_get_packet_id(slot));

    // Authenticating -> Authorized (AcceptAuth)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 2), radius.radius_session_state(slot));

    // Authorized -> Accounting (BeginAccounting)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_accounting(slot));
    try std.testing.expectEqual(@as(u8, 5), radius.radius_session_state(slot));

    // Accounting -> Complete (EndAccounting)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_accounting(slot));
    try std.testing.expectEqual(@as(u8, 6), radius.radius_session_state(slot));

    // Complete -> Idle (EndSession/SessionDone)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot));
}

test "lifecycle: Idle -> Authenticating -> Authorized -> Complete (skip accounting)" {
    const slot = radius.radius_session_create(1); // CHAP
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 7));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));

    // Authorized -> Complete (EndAuthorized, skipping accounting)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot));
    try std.testing.expectEqual(@as(u8, 6), radius.radius_session_state(slot)); // complete

    // Complete -> Idle
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // idle
}

test "lifecycle: Idle -> Authenticating -> Rejected -> Idle" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_reject_auth(slot));
    try std.testing.expectEqual(@as(u8, 3), radius.radius_session_state(slot)); // rejected

    // Rejected -> Idle (RejectionDone)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // idle
}

test "lifecycle: Idle -> Authenticating -> Challenged -> Authenticating -> Authorized" {
    const slot = radius.radius_session_create(4); // EAP
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 10));

    // Authenticating -> Challenged (ChallengeAuth)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_challenge_auth(slot));
    try std.testing.expectEqual(@as(u8, 4), radius.radius_session_state(slot)); // challenged

    // Challenged -> Authenticating (RespondChallenge)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_respond_challenge(slot));
    try std.testing.expectEqual(@as(u8, 1), radius.radius_session_state(slot)); // authenticating

    // Now accept
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 2), radius.radius_session_state(slot)); // authorized
}

test "lifecycle: Challenged -> Idle (ChallengeTimeout)" {
    const slot = radius.radius_session_create(4); // EAP
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 20));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_challenge_auth(slot));

    // Challenged -> Idle (timeout)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // idle
}

test "multiple challenge-response rounds before accept" {
    const slot = radius.radius_session_create(4); // EAP
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 30));

    // Round 1: challenge then respond
    try std.testing.expectEqual(@as(u8, 0), radius.radius_challenge_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_respond_challenge(slot));

    // Round 2: challenge then respond
    try std.testing.expectEqual(@as(u8, 0), radius.radius_challenge_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_respond_challenge(slot));

    // Round 3: challenge then respond
    try std.testing.expectEqual(@as(u8, 0), radius.radius_challenge_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_respond_challenge(slot));

    // Finally accept
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 2), radius.radius_session_state(slot)); // authorized
}

// =========================================================================
// 5. Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "idle cannot authorize directly (must authenticate first)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), radius.radius_accept_auth(slot)); // err
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // still idle
}

test "idle cannot reject directly (must authenticate first)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), radius.radius_reject_auth(slot)); // err
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(slot)); // still idle
}

test "idle cannot challenge directly" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), radius.radius_challenge_auth(slot)); // err
}

test "idle cannot begin accounting (must authorize first)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_accounting(slot)); // err
}

test "idle cannot end accounting" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), radius.radius_end_accounting(slot)); // err
}

test "authenticating cannot begin accounting (must authorize first)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_accounting(slot)); // err
}

test "authorized cannot re-authenticate" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));

    // Cannot go back to authenticating
    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_auth(slot, 2)); // err
}

test "accounting cannot re-authenticate" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_accounting(slot));

    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_auth(slot, 3)); // err
}

test "rejected cannot authorize" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_reject_auth(slot));

    try std.testing.expectEqual(@as(u8, 1), radius.radius_accept_auth(slot)); // err
    try std.testing.expectEqual(@as(u8, 3), radius.radius_session_state(slot)); // still rejected
}

test "complete cannot begin auth (must return to idle first)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot)); // -> complete

    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_auth(slot, 2)); // err
}

test "complete cannot begin accounting" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_accept_auth(slot));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_end_session(slot)); // -> complete

    try std.testing.expectEqual(@as(u8, 1), radius.radius_begin_accounting(slot)); // err
}

// =========================================================================
// 6. Shared secret management
// =========================================================================

test "set_secret succeeds for active session" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const secret = "testing123";
    try std.testing.expectEqual(@as(u8, 0), radius.radius_set_secret(slot, secret.ptr, secret.len));
}

test "set_secret rejects zero-length secret" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const secret = "x";
    try std.testing.expectEqual(@as(u8, 4), radius.radius_set_secret(slot, secret.ptr, 0)); // bad_secret
}

test "set_secret rejects oversized secret (>128 bytes)" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const secret = "x";
    try std.testing.expectEqual(@as(u8, 4), radius.radius_set_secret(slot, secret.ptr, 129)); // bad_secret
}

test "set_secret rejects invalid slot" {
    const secret = "testing123";
    try std.testing.expectEqual(@as(u8, 2), radius.radius_set_secret(-1, secret.ptr, secret.len)); // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_set_secret(999, secret.ptr, secret.len)); // invalid_param
}

// =========================================================================
// 7. Attribute TLV encoding
// =========================================================================

test "add_attribute succeeds" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const user = "alice";
    try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 1, user.ptr, user.len)); // UserName
    try std.testing.expectEqual(@as(u8, 1), radius.radius_get_attribute_count(slot));
}

test "add multiple attributes" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const user = "bob";
    const pass = "secret";
    const msg = "Welcome";

    try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 1, user.ptr, user.len));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 2, pass.ptr, pass.len));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 18, msg.ptr, msg.len));
    try std.testing.expectEqual(@as(u8, 3), radius.radius_get_attribute_count(slot));
}

test "add_attribute rejects zero-length value" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const val = "x";
    try std.testing.expectEqual(@as(u8, 2), radius.radius_add_attribute(slot, 1, val.ptr, 0)); // invalid_param
}

test "add_attribute rejects invalid slot" {
    const val = "test";
    try std.testing.expectEqual(@as(u8, 2), radius.radius_add_attribute(-1, 1, val.ptr, val.len)); // invalid_param
}

test "attribute pool exhaustion after 32 attributes" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    const val = "x";
    var i: u8 = 0;
    // Fill all 32 attribute slots
    while (i < 32) : (i += 1) {
        try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 1, val.ptr, val.len));
    }
    try std.testing.expectEqual(@as(u8, 32), radius.radius_get_attribute_count(slot));

    // 33rd should fail with pool_exhausted
    try std.testing.expectEqual(@as(u8, 3), radius.radius_add_attribute(slot, 1, val.ptr, val.len)); // pool_exhausted
}

test "begin_auth clears attributes for new auth round" {
    const slot = radius.radius_session_create(0);
    defer radius.radius_session_destroy(slot);

    // Add some attributes in idle (allowed by the API)
    const val = "test";
    try std.testing.expectEqual(@as(u8, 0), radius.radius_add_attribute(slot, 1, val.ptr, val.len));
    try std.testing.expectEqual(@as(u8, 1), radius.radius_get_attribute_count(slot));

    // Begin auth should clear attributes
    try std.testing.expectEqual(@as(u8, 0), radius.radius_begin_auth(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_attribute_count(slot));
}

// =========================================================================
// 8. Stateless transition table (radius_can_transition)
// =========================================================================

test "radius_can_transition valid transitions match Transitions.idr" {
    // All 11 valid transitions from ValidRadiusTransition
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(0, 1)); // Idle -> Authenticating
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(1, 2)); // Authenticating -> Authorized
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(1, 3)); // Authenticating -> Rejected
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(1, 4)); // Authenticating -> Challenged
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(4, 1)); // Challenged -> Authenticating
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(2, 5)); // Authorized -> Accounting
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(5, 6)); // Accounting -> Complete
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(2, 6)); // Authorized -> Complete
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(6, 0)); // Complete -> Idle
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(3, 0)); // Rejected -> Idle
    try std.testing.expectEqual(@as(u8, 1), radius.radius_can_transition(4, 0)); // Challenged -> Idle
}

test "radius_can_transition invalid transitions rejected" {
    // Impossibility proofs from Transitions.idr
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 2)); // Idle -> Authorized (skip!)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 3)); // Idle -> Rejected (skip!)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(6, 1)); // Complete -> Authenticating
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(3, 2)); // Rejected -> Authorized
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(5, 1)); // Accounting -> Authenticating
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(2, 1)); // Authorized -> Authenticating
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(6, 5)); // Complete -> Accounting
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 0)); // Idle -> Idle (self)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(1, 1)); // Auth -> Auth (self)
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 5)); // Idle -> Accounting
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 6)); // Idle -> Complete
}

test "radius_can_transition with out-of-range tags returns 0" {
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(7, 0));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 7));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(255, 255));
}

// =========================================================================
// 9. State queries on invalid slots
// =========================================================================

test "state queries safe on negative slot" {
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(-1));  // idle fallback
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_auth_method(-1)); // PAP fallback
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_packet_id(-1));   // 0 fallback
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_attribute_count(-1)); // 0 fallback
}

test "state queries safe on out-of-range slot" {
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(64));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_session_state(999));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_auth_method(64));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_packet_id(64));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_get_attribute_count(64));
}

test "transition functions return invalid_param for bad slots" {
    try std.testing.expectEqual(@as(u8, 2), radius.radius_begin_auth(-1, 0));     // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_accept_auth(-1));        // invalid_param (via doTransition)
    try std.testing.expectEqual(@as(u8, 2), radius.radius_reject_auth(999));       // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_challenge_auth(-1));     // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_respond_challenge(-1));  // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_begin_accounting(-1));   // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_end_accounting(-1));     // invalid_param
    try std.testing.expectEqual(@as(u8, 2), radius.radius_end_session(-1));        // invalid_param
}

// =========================================================================
// 10. Pool exhaustion
// =========================================================================

test "session pool exhaustion returns -1 after 64 slots" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    // Fill all 64 slots
    for (&slots) |*s| {
        s.* = radius.radius_session_create(0);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| radius.radius_session_destroy(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), radius.radius_session_create(0));
}

test "session reuse after full pool drain" {
    // Create and destroy a session, verify slot reclamation
    const slot1 = radius.radius_session_create(0);
    try std.testing.expect(slot1 >= 0);
    radius.radius_session_destroy(slot1);

    // Should be able to create a new session in the freed slot
    const slot2 = radius.radius_session_create(2); // MSCHAP
    try std.testing.expect(slot2 >= 0);
    defer radius.radius_session_destroy(slot2);
    try std.testing.expectEqual(@as(u8, 2), radius.radius_get_auth_method(slot2)); // MSCHAP
}

// =========================================================================
// Constants verification
// =========================================================================

test "constants match Layout.idr" {
    try std.testing.expectEqual(@as(usize, 20), radius.PACKET_HEADER_SIZE);
    try std.testing.expectEqual(@as(usize, 4096), radius.MAX_PACKET_SIZE);
    try std.testing.expectEqual(@as(usize, 2), radius.ATTRIBUTE_HEADER_SIZE);
    try std.testing.expectEqual(@as(usize, 253), radius.MAX_ATTRIBUTE_VALUE_LEN);
}
