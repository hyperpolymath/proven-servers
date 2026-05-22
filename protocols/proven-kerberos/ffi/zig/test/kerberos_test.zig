// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// kerberos_test.zig -- Integration tests for proven-kerberos FFI.

const std = @import("std");
const krb = @import("kerberos");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), krb.krb_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Layout.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.MessageType.as_req));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.MessageType.as_rep));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.MessageType.tgs_req));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.MessageType.tgs_rep));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(krb.MessageType.ap_req));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(krb.MessageType.ap_rep));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(krb.MessageType.krb_error));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(krb.MessageType.krb_safe));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(krb.MessageType.krb_priv));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(krb.MessageType.krb_cred));
}

test "EncryptionType encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.EncryptionType.aes256_cts_hmac_sha1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.EncryptionType.aes128_cts_hmac_sha1));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.EncryptionType.aes256_cts_hmac_sha384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.EncryptionType.rc4_hmac));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(krb.EncryptionType.des3_cbc_sha1));
}

test "PrincipalType encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.PrincipalType.nt_unknown));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.PrincipalType.nt_principal));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.PrincipalType.nt_srv_inst));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.PrincipalType.nt_srv_hst));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(krb.PrincipalType.nt_uid));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(krb.PrincipalType.nt_x500));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(krb.PrincipalType.nt_enterprise));
}

test "TicketFlag encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.TicketFlag.forwardable));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.TicketFlag.forwarded));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.TicketFlag.proxiable));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.TicketFlag.proxy));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(krb.TicketFlag.renewable));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(krb.TicketFlag.pre_authent));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(krb.TicketFlag.hw_authent));
}

test "ErrorCode encoding matches Layout.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.ErrorCode.kdc_err_none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.ErrorCode.kdc_err_name_exp));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(krb.ErrorCode.kdc_err_c_principal_unknown));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(krb.ErrorCode.kdc_err_preauth_failed));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(krb.ErrorCode.kdc_err_preauth_required));
}

test "AuthState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.AuthState.initial));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.AuthState.tgt_obtained));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.AuthState.service_ticket_obtained));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.AuthState.authenticated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(krb.AuthState.auth_failed));
}

test "EncStrength encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.EncStrength.strong));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.EncStrength.medium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.EncStrength.weak));
}

test "PreAuthType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.PreAuthType.pa_enc_timestamp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.PreAuthType.pa_etype_info2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.PreAuthType.pa_fx_fast));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.PreAuthType.pa_fx_cookie));
}

test "NegotiationState encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(krb.NegotiationState.neg_idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(krb.NegotiationState.proposed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(krb.NegotiationState.selected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(krb.NegotiationState.neg_failed));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    try std.testing.expect(slot >= 0);
    defer krb.krb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), krb.krb_auth_state(slot)); // Initial
}

test "create rejects null realm" {
    try std.testing.expectEqual(@as(c_int, -1), krb.krb_create(null, 5));
}

test "create rejects zero-length realm" {
    const realm = "X";
    try std.testing.expectEqual(@as(c_int, -1), krb.krb_create(realm.ptr, 0));
}

test "destroy is safe with invalid slot" {
    krb.krb_destroy(-1);
    krb.krb_destroy(999);
}

// =========================================================================
// Full authentication lifecycle: Initial -> TGT -> ServiceTicket -> Auth
// =========================================================================

test "full lifecycle: Initial -> TGTObtained -> ServiceTicketObtained -> Authenticated" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    // Set client principal
    const client = "alice";
    try std.testing.expectEqual(@as(u8, 0), krb.krb_set_client_principal(slot, client.ptr, client.len, 1));

    // Initial -> TGTObtained (AS exchange)
    try std.testing.expectEqual(@as(u8, 0), krb.krb_obtain_tgt(slot));
    try std.testing.expectEqual(@as(u8, 1), krb.krb_auth_state(slot)); // TGTObtained
    try std.testing.expectEqual(@as(u8, 1), krb.krb_has_tgt(slot));

    // Set service principal
    const service = "krbtgt/EXAMPLE.COM";
    try std.testing.expectEqual(@as(u8, 0), krb.krb_set_service_principal(slot, service.ptr, service.len, 2));

    // TGTObtained -> ServiceTicketObtained (TGS exchange)
    try std.testing.expectEqual(@as(u8, 0), krb.krb_obtain_service_ticket(slot));
    try std.testing.expectEqual(@as(u8, 2), krb.krb_auth_state(slot)); // ServiceTicketObtained
    try std.testing.expectEqual(@as(u8, 1), krb.krb_has_service_ticket(slot));

    // ServiceTicketObtained -> Authenticated (AP exchange)
    try std.testing.expectEqual(@as(u8, 0), krb.krb_authenticate(slot));
    try std.testing.expectEqual(@as(u8, 3), krb.krb_auth_state(slot)); // Authenticated
    try std.testing.expectEqual(@as(u8, 1), krb.krb_has_access(slot));
}

// =========================================================================
// Failure and recovery
// =========================================================================

test "fail from Initial sets error code" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    // Fail with KDC_ERR_PREAUTH_FAILED (tag 8)
    try std.testing.expectEqual(@as(u8, 0), krb.krb_fail(slot, 8));
    try std.testing.expectEqual(@as(u8, 4), krb.krb_auth_state(slot)); // AuthFailed
    try std.testing.expectEqual(@as(u8, 8), krb.krb_last_error(slot));
}

test "fail from TGTObtained" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot); // -> TGTObtained

    try std.testing.expectEqual(@as(u8, 0), krb.krb_fail(slot, 2)); // KDC_ERR_SERVICE_EXP
    try std.testing.expectEqual(@as(u8, 4), krb.krb_auth_state(slot));
}

test "fail rejects invalid error code" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_fail(slot, 99)); // invalid
}

test "cannot fail from AuthFailed (already failed)" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    _ = krb.krb_fail(slot, 0); // -> AuthFailed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_fail(slot, 1)); // rejected
}

test "retry resets from AuthFailed to Initial" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    _ = krb.krb_fail(slot, 8); // -> AuthFailed
    try std.testing.expectEqual(@as(u8, 0), krb.krb_retry(slot));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_auth_state(slot)); // Initial
    try std.testing.expectEqual(@as(u8, 0), krb.krb_last_error(slot)); // cleared
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_tgt(slot)); // cleared
}

test "retry rejects if not in AuthFailed" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_retry(slot)); // Initial, not AuthFailed
}

// =========================================================================
// Re-authentication
// =========================================================================

test "reauth from Authenticated returns to Initial" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot);
    const service = "http/server.example.com";
    _ = krb.krb_set_service_principal(slot, service.ptr, service.len, 3);
    _ = krb.krb_obtain_service_ticket(slot);
    _ = krb.krb_authenticate(slot);

    try std.testing.expectEqual(@as(u8, 0), krb.krb_reauth(slot));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_auth_state(slot)); // Initial
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_tgt(slot)); // cleared
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_service_ticket(slot)); // cleared
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_access(slot)); // no longer
}

test "reauth rejects if not Authenticated" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_reauth(slot)); // Initial
}

// =========================================================================
// TGT renewal
// =========================================================================

test "renew TGT succeeds from TGTObtained" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot);

    try std.testing.expectEqual(@as(u8, 0), krb.krb_renew_tgt(slot));
    try std.testing.expectEqual(@as(u8, 1), krb.krb_auth_state(slot)); // still TGTObtained
}

test "renew TGT rejects if not TGTObtained" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_renew_tgt(slot)); // Initial
}

// =========================================================================
// Principal management
// =========================================================================

test "set_client_principal rejects invalid ptype" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const name = "alice";
    try std.testing.expectEqual(@as(u8, 1), krb.krb_set_client_principal(slot, name.ptr, name.len, 99));
}

test "set_client_principal rejects null name" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_set_client_principal(slot, null, 5, 1));
}

test "set_service_principal rejects from AuthFailed" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    _ = krb.krb_fail(slot, 0); // -> AuthFailed
    const svc = "http/server";
    try std.testing.expectEqual(@as(u8, 1), krb.krb_set_service_principal(slot, svc.ptr, svc.len, 3));
}

// =========================================================================
// Encryption negotiation
// =========================================================================

test "propose and negotiate encryption types" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    // Client proposes AES256, AES128, RC4
    const client_types = [_]u8{ 0, 1, 3 };
    try std.testing.expectEqual(@as(u8, 0), krb.krb_propose_enctypes(slot, &client_types, 3));
    try std.testing.expectEqual(@as(u8, 1), krb.krb_negotiation_state(slot)); // Proposed

    // Server supports AES128 and RC4
    const server_types = [_]u8{ 1, 3 };
    const selected = krb.krb_negotiate_enctype(slot, &server_types, 2);
    try std.testing.expectEqual(@as(u8, 1), selected); // AES128 (stronger than RC4)
    try std.testing.expectEqual(@as(u8, 2), krb.krb_negotiation_state(slot)); // Selected
    try std.testing.expectEqual(@as(u8, 1), krb.krb_selected_enctype(slot));
}

test "negotiation selects strongest common cipher (AES256)" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    // Client proposes all five
    const client_types = [_]u8{ 0, 1, 2, 3, 4 };
    _ = krb.krb_propose_enctypes(slot, &client_types, 5);

    // Server supports AES256-SHA1 and AES256-SHA384
    const server_types = [_]u8{ 0, 2 };
    const selected = krb.krb_negotiate_enctype(slot, &server_types, 2);
    try std.testing.expectEqual(@as(u8, 0), selected); // AES256_CTS_HMAC_SHA1 (strongest)
}

test "negotiation fails with no common cipher" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    // Client proposes only AES256
    const client_types = [_]u8{0};
    _ = krb.krb_propose_enctypes(slot, &client_types, 1);

    // Server only supports RC4
    const server_types = [_]u8{3};
    const selected = krb.krb_negotiate_enctype(slot, &server_types, 1);
    try std.testing.expectEqual(@as(u8, 255), selected); // no match
    try std.testing.expectEqual(@as(u8, 3), krb.krb_negotiation_state(slot)); // NegFailed
}

test "propose rejects invalid enc type tag" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const types = [_]u8{ 0, 99 }; // 99 is invalid
    try std.testing.expectEqual(@as(u8, 1), krb.krb_propose_enctypes(slot, &types, 2));
}

test "cannot propose twice (already proposed)" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const types = [_]u8{0};
    _ = krb.krb_propose_enctypes(slot, &types, 1);
    try std.testing.expectEqual(@as(u8, 1), krb.krb_propose_enctypes(slot, &types, 1)); // rejected
}

test "selected_enctype returns 255 before negotiation" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 255), krb.krb_selected_enctype(slot));
}

// =========================================================================
// Ticket flag management
// =========================================================================

test "add and query ticket flags" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot);

    // No flags initially
    try std.testing.expectEqual(@as(u32, 0), krb.krb_ticket_flags_count(slot));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_ticket_flag(slot, 0)); // Forwardable

    // Add Forwardable (0) and Renewable (4)
    try std.testing.expectEqual(@as(u8, 0), krb.krb_add_ticket_flag(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_add_ticket_flag(slot, 4));
    try std.testing.expectEqual(@as(u32, 2), krb.krb_ticket_flags_count(slot));
    try std.testing.expectEqual(@as(u8, 1), krb.krb_has_ticket_flag(slot, 0)); // Forwardable set
    try std.testing.expectEqual(@as(u8, 1), krb.krb_has_ticket_flag(slot, 4)); // Renewable set
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_ticket_flag(slot, 1)); // Forwarded not set
}

test "add_ticket_flag rejects invalid flag tag" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_add_ticket_flag(slot, 99));
}

test "add_ticket_flag rejects if not TGTObtained" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_add_ticket_flag(slot, 0)); // Initial state
}

// =========================================================================
// Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "cannot skip AS exchange (Initial -> ServiceTicketObtained)" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const svc = "http/server";
    _ = krb.krb_set_service_principal(slot, svc.ptr, svc.len, 3);
    try std.testing.expectEqual(@as(u8, 1), krb.krb_obtain_service_ticket(slot)); // rejected
}

test "cannot skip TGS exchange (Initial -> Authenticated)" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_authenticate(slot)); // rejected
}

test "cannot obtain TGT without client principal" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_obtain_tgt(slot)); // no client set
}

test "cannot obtain service ticket without service principal" {
    const realm = "EXAMPLE.COM";
    const slot = krb.krb_create(realm.ptr, realm.len);
    defer krb.krb_destroy(slot);

    const client = "alice";
    _ = krb.krb_set_client_principal(slot, client.ptr, client.len, 1);
    _ = krb.krb_obtain_tgt(slot);

    try std.testing.expectEqual(@as(u8, 1), krb.krb_obtain_service_ticket(slot)); // no service set
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "krb_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(0, 1)); // Initial -> TGTObtained
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(1, 2)); // TGT -> ServiceTicket
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(2, 3)); // ServiceTicket -> Auth
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(0, 4)); // Initial -> AuthFailed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(1, 4)); // TGT -> AuthFailed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(2, 4)); // ServiceTicket -> AuthFailed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(3, 4)); // Auth -> AuthFailed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(3, 0)); // Auth -> Initial (reauth)
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(4, 0)); // AuthFailed -> Initial (retry)
    try std.testing.expectEqual(@as(u8, 1), krb.krb_can_transition(1, 1)); // TGT -> TGT (renew)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(0, 2)); // skip AS exchange
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(0, 3)); // skip to Auth
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(1, 3)); // skip AP exchange
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(4, 1)); // Failed -> TGT
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(4, 2)); // Failed -> ServiceTicket
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(4, 3)); // Failed -> Auth
    try std.testing.expectEqual(@as(u8, 0), krb.krb_can_transition(3, 1)); // Auth -> TGT (backwards)
}

test "krb_neg_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), krb.krb_neg_can_transition(0, 1)); // NegIdle -> Proposed
    try std.testing.expectEqual(@as(u8, 1), krb.krb_neg_can_transition(1, 2)); // Proposed -> Selected
    try std.testing.expectEqual(@as(u8, 1), krb.krb_neg_can_transition(1, 3)); // Proposed -> NegFailed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), krb.krb_neg_can_transition(0, 2)); // skip proposal
    try std.testing.expectEqual(@as(u8, 0), krb.krb_neg_can_transition(2, 0)); // Selected terminal
    try std.testing.expectEqual(@as(u8, 0), krb.krb_neg_can_transition(2, 1)); // Selected terminal
    try std.testing.expectEqual(@as(u8, 0), krb.krb_neg_can_transition(3, 0)); // NegFailed terminal
}

// =========================================================================
// Encryption strength classification
// =========================================================================

test "krb_enc_strength matches Layout.idr encTypeStrength" {
    try std.testing.expectEqual(@as(u8, 0), krb.krb_enc_strength(0)); // AES256-SHA1 -> Strong
    try std.testing.expectEqual(@as(u8, 0), krb.krb_enc_strength(2)); // AES256-SHA384 -> Strong
    try std.testing.expectEqual(@as(u8, 1), krb.krb_enc_strength(1)); // AES128-SHA1 -> Medium
    try std.testing.expectEqual(@as(u8, 2), krb.krb_enc_strength(3)); // RC4-HMAC -> Weak
    try std.testing.expectEqual(@as(u8, 2), krb.krb_enc_strength(4)); // DES3-CBC-SHA1 -> Weak
    try std.testing.expectEqual(@as(u8, 255), krb.krb_enc_strength(99)); // invalid
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), krb.krb_auth_state(-1)); // AuthFailed fallback
    try std.testing.expectEqual(@as(u8, 3), krb.krb_negotiation_state(-1)); // NegFailed fallback
    try std.testing.expectEqual(@as(u8, 255), krb.krb_selected_enctype(-1));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_tgt(-1));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_service_ticket(-1));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_access(-1));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_last_error(-1));
    try std.testing.expectEqual(@as(u32, 0), krb.krb_ticket_flags_count(-1));
    try std.testing.expectEqual(@as(u8, 0), krb.krb_has_ticket_flag(-1, 0));
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    const realm = "EXAMPLE.COM";
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    // Fill all 64 slots
    for (&slots) |*s| {
        s.* = krb.krb_create(realm.ptr, realm.len);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| krb.krb_destroy(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), krb.krb_create(realm.ptr, realm.len));
}
