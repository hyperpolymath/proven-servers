// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-dns FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const dns = @import("dns");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dns.dns_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "RecordType encoding matches Types.idr (15 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.RecordType.a));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.RecordType.aaaa));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.RecordType.cname));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.RecordType.mx));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.RecordType.ns));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dns.RecordType.ptr));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dns.RecordType.soa));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dns.RecordType.srv));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(dns.RecordType.txt));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(dns.RecordType.caa));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(dns.RecordType.dnskey));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(dns.RecordType.ds));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(dns.RecordType.rrsig));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(dns.RecordType.nsec));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(dns.RecordType.nsec3));
}

test "QueryClass encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.QueryClass.in_));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.QueryClass.ch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.QueryClass.hs));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.QueryClass.any));
}

test "Opcode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.Opcode.query));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.Opcode.iquery));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.Opcode.status));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.Opcode.notify));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.Opcode.update));
}

test "ResponseCode encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.ResponseCode.no_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.ResponseCode.form_err));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.ResponseCode.serv_fail));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.ResponseCode.nx_domain));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.ResponseCode.not_imp));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dns.ResponseCode.refused));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dns.ResponseCode.yx_domain));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dns.ResponseCode.yx_rrset));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(dns.ResponseCode.nx_rrset));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(dns.ResponseCode.not_auth));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(dns.ResponseCode.not_zone));
}

test "DnsState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnsState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnsState.query_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnsState.lookup));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnsState.response_building));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.DnsState.sent));
}

test "DnssecState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnssecState.disabled));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnssecState.enabled));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnssecState.key_loaded));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnssecState.validated));
}

test "DnssecAlgorithm encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnssecAlgorithm.rsa_sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnssecAlgorithm.rsa_sha512));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnssecAlgorithm.ecdsa_p256_sha256));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnssecAlgorithm.ecdsa_p384_sha384));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.DnssecAlgorithm.ed25519));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = dns.dns_create_context();
    try std.testing.expect(slot >= 0);
    defer dns.dns_destroy_context(slot);
    const state = dns.dns_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    dns.dns_destroy_context(-1);
    dns.dns_destroy_context(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = dns.dns_state(-1);
    _ = dns.dns_answer_count(-1);
    _ = dns.dns_authority_count(-1);
    _ = dns.dns_additional_count(-1);
}

