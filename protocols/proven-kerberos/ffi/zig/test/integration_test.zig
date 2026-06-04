// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-kerberos FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const kerberos = @import("kerberos");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), kerberos.krb_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.MessageType.as_req));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.MessageType.as_rep));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.MessageType.tgs_req));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.MessageType.tgs_rep));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.MessageType.ap_req));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kerberos.MessageType.ap_rep));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kerberos.MessageType.krb_error));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(kerberos.MessageType.krb_safe));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(kerberos.MessageType.krb_priv));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(kerberos.MessageType.krb_cred));
}

test "EncryptionType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.EncryptionType.aes256_cts_hmac_sha1));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.EncryptionType.aes128_cts_hmac_sha1));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.EncryptionType.aes256_cts_hmac_sha384));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.EncryptionType.rc4_hmac));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.EncryptionType.des3_cbc_sha1));
}

test "PrincipalType encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.PrincipalType.nt_unknown));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.PrincipalType.nt_principal));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.PrincipalType.nt_srv_inst));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.PrincipalType.nt_srv_hst));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.PrincipalType.nt_uid));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kerberos.PrincipalType.nt_x500));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kerberos.PrincipalType.nt_enterprise));
}

test "TicketFlag encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.TicketFlag.forwardable));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.TicketFlag.forwarded));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.TicketFlag.proxiable));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.TicketFlag.proxy));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.TicketFlag.renewable));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kerberos.TicketFlag.pre_authent));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kerberos.TicketFlag.hw_authent));
}

test "ErrorCode encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.ErrorCode.kdc_err_none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.ErrorCode.kdc_err_name_exp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.ErrorCode.kdc_err_service_exp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.ErrorCode.kdc_err_bad_pvno));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.ErrorCode.kdc_err_c_old_mast_kvno));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(kerberos.ErrorCode.kdc_err_s_old_mast_kvno));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(kerberos.ErrorCode.kdc_err_c_principal_unknown));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(kerberos.ErrorCode.kdc_err_s_principal_unknown));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(kerberos.ErrorCode.kdc_err_preauth_failed));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(kerberos.ErrorCode.kdc_err_preauth_required));
}

test "AuthState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.AuthState.initial));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.AuthState.tgt_obtained));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.AuthState.service_ticket_obtained));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.AuthState.authenticated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(kerberos.AuthState.auth_failed));
}

test "EncStrength encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.EncStrength.strong));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.EncStrength.medium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.EncStrength.weak));
}

test "PreAuthType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.PreAuthType.pa_enc_timestamp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.PreAuthType.pa_etype_info2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.PreAuthType.pa_fx_fast));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.PreAuthType.pa_fx_cookie));
}

test "NegotiationState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(kerberos.NegotiationState.neg_idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(kerberos.NegotiationState.proposed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(kerberos.NegotiationState.selected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(kerberos.NegotiationState.neg_failed));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = kerberos.krb_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer kerberos.krb_destroy(slot);
    const state = kerberos.krb_auth_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    kerberos.krb_destroy(-1);
    kerberos.krb_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), kerberos.krb_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), kerberos.krb_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = kerberos.krb_auth_state(-1);
    _ = kerberos.krb_ticket_flags_count(-1);
}

