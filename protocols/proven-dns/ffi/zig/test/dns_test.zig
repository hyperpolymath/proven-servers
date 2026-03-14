// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// dns_test.zig -- Integration tests for proven-dns FFI.

const std = @import("std");
const dns = @import("dns");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dns.dns_abi_version());
}

// =========================================================================
// Enum encoding seams — RecordType (15 tags)
// =========================================================================

test "RecordType encoding matches Layout.idr (15 tags)" {
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

// =========================================================================
// Enum encoding seams — QueryClass (4 tags)
// =========================================================================

test "QueryClass encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.QueryClass.in_));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.QueryClass.ch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.QueryClass.hs));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.QueryClass.any));
}

// =========================================================================
// Enum encoding seams — Opcode (5 tags)
// =========================================================================

test "Opcode encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.Opcode.query));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.Opcode.iquery));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.Opcode.status));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.Opcode.notify));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.Opcode.update));
}

// =========================================================================
// Enum encoding seams — ResponseCode (11 tags)
// =========================================================================

test "ResponseCode encoding matches Layout.idr (11 tags)" {
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

// =========================================================================
// Enum encoding seams — DnsState (5 tags)
// =========================================================================

test "DnsState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnsState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnsState.query_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnsState.lookup));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnsState.response_building));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.DnsState.sent));
}

// =========================================================================
// Enum encoding seams — DnssecState (4 tags)
// =========================================================================

test "DnssecState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnssecState.disabled));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnssecState.enabled));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnssecState.key_loaded));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnssecState.validated));
}

// =========================================================================
// Enum encoding seams — DnssecAlgorithm (5 tags)
// =========================================================================

test "DnssecAlgorithm encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dns.DnssecAlgorithm.rsa_sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dns.DnssecAlgorithm.rsa_sha512));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dns.DnssecAlgorithm.ecdsa_p256_sha256));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dns.DnssecAlgorithm.ecdsa_p384_sha384));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dns.DnssecAlgorithm.ed25519));
}

// =========================================================================
// Lifecycle — create and destroy
// =========================================================================

test "create returns valid slot" {
    const slot = dns.dns_create_context();
    try std.testing.expect(slot >= 0);
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), dns.dns_state(slot)); // idle
    try std.testing.expectEqual(@as(u8, 0), dns.dns_dnssec_state(slot)); // disabled
}

test "destroy is safe with invalid slot" {
    dns.dns_destroy_context(-1);
    dns.dns_destroy_context(999);
}

// =========================================================================
// Full lifecycle — Idle -> QueryReceived -> Lookup -> Building -> Sent
// =========================================================================

test "full lifecycle: Idle -> QueryReceived -> Lookup -> ResponseBuilding -> Sent" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Build a minimal DNS query: 12-byte header + question (root name, A, IN)
    // Transaction ID = 0x1234, standard query, QDCOUNT=1
    var query_buf: [17]u8 = .{
        0x12, 0x34, // Transaction ID
        0x01, 0x00, // Flags: RD=1
        0x00, 0x01, // QDCOUNT=1
        0x00, 0x00, // ANCOUNT=0
        0x00, 0x00, // NSCOUNT=0
        0x00, 0x00, // ARCOUNT=0
        0x00, // QNAME: root (0-length label)
        0x00, 0x01, // QTYPE: A (1)
        0x00, 0x01, // QCLASS: IN (1)
    };

    // Idle -> QueryReceived
    try std.testing.expectEqual(@as(u8, 0), dns.dns_parse_query(slot, &query_buf, 17));
    try std.testing.expectEqual(@as(u8, 1), dns.dns_state(slot)); // query_received
    try std.testing.expectEqual(@as(u8, 0), dns.dns_query_rtype(slot)); // A
    try std.testing.expectEqual(@as(u8, 0), dns.dns_query_class(slot)); // IN

    // QueryReceived -> Lookup
    try std.testing.expectEqual(@as(u8, 0), dns.dns_begin_lookup(slot));
    try std.testing.expectEqual(@as(u8, 2), dns.dns_state(slot)); // lookup

    // Lookup -> ResponseBuilding
    try std.testing.expectEqual(@as(u8, 0), dns.dns_begin_response(slot));
    try std.testing.expectEqual(@as(u8, 3), dns.dns_state(slot)); // response_building

    // Add an A record answer: 93.184.216.34 (4 bytes rdata)
    var rdata: [4]u8 = .{ 93, 184, 216, 34 };
    try std.testing.expectEqual(@as(u8, 0), dns.dns_add_answer(slot, 0, 0, 300, &rdata, 4));
    try std.testing.expectEqual(@as(u16, 1), dns.dns_answer_count(slot));

    // Set rcode to NoError
    try std.testing.expectEqual(@as(u8, 0), dns.dns_set_rcode(slot, 0));

    // Build response
    var out_buf: [4096]u8 = undefined;
    var out_len: u16 = 0;
    try std.testing.expectEqual(@as(u8, 0), dns.dns_build_response(slot, &out_buf, &out_len));
    try std.testing.expectEqual(@as(u8, 4), dns.dns_state(slot)); // sent
    try std.testing.expect(out_len > 12); // at least a header
}

// =========================================================================
// Parse query rejects too-short buffer
// =========================================================================

test "parse_query rejects short buffer" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    var short_buf: [4]u8 = .{ 0, 0, 0, 0 };
    try std.testing.expectEqual(@as(u8, 1), dns.dns_parse_query(slot, &short_buf, 4));
    try std.testing.expectEqual(@as(u8, 0), dns.dns_state(slot)); // still idle
}

test "parse_query rejects null buffer" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_parse_query(slot, null, 12));
}

// =========================================================================
// Response codes
// =========================================================================

test "set_rcode sets response code" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Advance to ResponseBuilding
    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    // Set NXDOMAIN
    try std.testing.expectEqual(@as(u8, 0), dns.dns_set_rcode(slot, 3));
    try std.testing.expectEqual(@as(u8, 3), dns.dns_rcode(slot));

    // Set SERVFAIL
    try std.testing.expectEqual(@as(u8, 0), dns.dns_set_rcode(slot, 2));
    try std.testing.expectEqual(@as(u8, 2), dns.dns_rcode(slot));
}

test "set_rcode rejects invalid tag" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    try std.testing.expectEqual(@as(u8, 1), dns.dns_set_rcode(slot, 99));
}

test "set_rcode rejects wrong state" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_set_rcode(slot, 0)); // idle
}

// =========================================================================
// Record types — all 15
// =========================================================================

test "add all 15 record types as answers" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Advance to ResponseBuilding
    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    var rdata: [4]u8 = .{ 1, 2, 3, 4 };
    var tag: u8 = 0;
    while (tag <= 14) : (tag += 1) {
        try std.testing.expectEqual(@as(u8, 0), dns.dns_add_answer(slot, tag, 0, 300, &rdata, 4));
    }
    try std.testing.expectEqual(@as(u16, 15), dns.dns_answer_count(slot));
}

test "add_answer rejects invalid record type" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    var rdata: [4]u8 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(u8, 1), dns.dns_add_answer(slot, 15, 0, 300, &rdata, 4));
    try std.testing.expectEqual(@as(u8, 1), dns.dns_add_answer(slot, 255, 0, 300, &rdata, 4));
}

// =========================================================================
// Authority and additional sections
// =========================================================================

test "add authority and additional records" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    var rdata: [4]u8 = .{ 10, 0, 0, 1 };
    try std.testing.expectEqual(@as(u8, 0), dns.dns_add_authority(slot, 4, 0, 86400, &rdata, 4)); // NS
    try std.testing.expectEqual(@as(u8, 0), dns.dns_add_additional(slot, 0, 0, 300, &rdata, 4)); // A
    try std.testing.expectEqual(@as(u16, 1), dns.dns_authority_count(slot));
    try std.testing.expectEqual(@as(u16, 1), dns.dns_additional_count(slot));
}

// =========================================================================
// DNSSEC state machine
// =========================================================================

test "DNSSEC enable, load key, sign" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Advance to ResponseBuilding
    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    // Disabled -> Enabled
    try std.testing.expectEqual(@as(u8, 0), dns.dns_enable_dnssec(slot));
    try std.testing.expectEqual(@as(u8, 1), dns.dns_dnssec_state(slot)); // enabled

    // Enabled -> KeyLoaded (Ed25519)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_load_dnssec_key(slot, 4));
    try std.testing.expectEqual(@as(u8, 2), dns.dns_dnssec_state(slot)); // key_loaded

    // KeyLoaded -> Validated (sign response)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_sign_response(slot));
    try std.testing.expectEqual(@as(u8, 3), dns.dns_dnssec_state(slot)); // validated

    // Validate succeeds
    try std.testing.expectEqual(@as(u8, 0), dns.dns_validate_dnssec(slot));
}

test "DNSSEC enable rejects double enable" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), dns.dns_enable_dnssec(slot));
    try std.testing.expectEqual(@as(u8, 1), dns.dns_enable_dnssec(slot)); // already enabled
}

test "DNSSEC load key rejects without enable" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_load_dnssec_key(slot, 4)); // not enabled
}

test "DNSSEC load key rejects invalid algorithm" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    _ = dns.dns_enable_dnssec(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_load_dnssec_key(slot, 99));
}

test "DNSSEC sign requires ResponseBuilding state" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    _ = dns.dns_enable_dnssec(slot);
    _ = dns.dns_load_dnssec_key(slot, 0);
    // Still in Idle, not ResponseBuilding
    try std.testing.expectEqual(@as(u8, 1), dns.dns_sign_response(slot));
}

test "DNSSEC validate fails when not validated" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_validate_dnssec(slot));
}

// =========================================================================
// Impossibility: wrong state transitions
// =========================================================================

test "cannot advance from Idle to Lookup (skip)" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_begin_lookup(slot)); // idle, not query_received
}

test "cannot advance from Idle to ResponseBuilding (skip)" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dns.dns_begin_response(slot)); // idle, not lookup
}

test "cannot add records in Idle state" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    var rdata: [4]u8 = .{ 1, 2, 3, 4 };
    try std.testing.expectEqual(@as(u8, 1), dns.dns_add_answer(slot, 0, 0, 300, &rdata, 4));
}

test "cannot build response from Idle" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);
    var out_buf: [512]u8 = undefined;
    var out_len: u16 = 0;
    try std.testing.expectEqual(@as(u8, 1), dns.dns_build_response(slot, &out_buf, &out_len));
}

test "cannot parse query after Sent (terminal)" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Complete full lifecycle
    var query_buf: [12]u8 = .{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    _ = dns.dns_parse_query(slot, &query_buf, 12);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    var out_buf: [4096]u8 = undefined;
    var out_len: u16 = 0;
    _ = dns.dns_build_response(slot, &out_buf, &out_len);

    // Now in Sent state — cannot parse another query
    try std.testing.expectEqual(@as(u8, 4), dns.dns_state(slot)); // sent
    try std.testing.expectEqual(@as(u8, 1), dns.dns_parse_query(slot, &query_buf, 12));
}

// =========================================================================
// Wire code mapping
// =========================================================================

test "recordTypeToWire maps all 15 types correctly" {
    try std.testing.expectEqual(@as(u16, 1), dns.recordTypeToWire(0)); // A
    try std.testing.expectEqual(@as(u16, 28), dns.recordTypeToWire(1)); // AAAA
    try std.testing.expectEqual(@as(u16, 5), dns.recordTypeToWire(2)); // CNAME
    try std.testing.expectEqual(@as(u16, 15), dns.recordTypeToWire(3)); // MX
    try std.testing.expectEqual(@as(u16, 2), dns.recordTypeToWire(4)); // NS
    try std.testing.expectEqual(@as(u16, 12), dns.recordTypeToWire(5)); // PTR
    try std.testing.expectEqual(@as(u16, 6), dns.recordTypeToWire(6)); // SOA
    try std.testing.expectEqual(@as(u16, 33), dns.recordTypeToWire(7)); // SRV
    try std.testing.expectEqual(@as(u16, 16), dns.recordTypeToWire(8)); // TXT
    try std.testing.expectEqual(@as(u16, 257), dns.recordTypeToWire(9)); // CAA
    try std.testing.expectEqual(@as(u16, 48), dns.recordTypeToWire(10)); // DNSKEY
    try std.testing.expectEqual(@as(u16, 43), dns.recordTypeToWire(11)); // DS
    try std.testing.expectEqual(@as(u16, 46), dns.recordTypeToWire(12)); // RRSIG
    try std.testing.expectEqual(@as(u16, 47), dns.recordTypeToWire(13)); // NSEC
    try std.testing.expectEqual(@as(u16, 50), dns.recordTypeToWire(14)); // NSEC3
    try std.testing.expectEqual(@as(u16, 0), dns.recordTypeToWire(255)); // invalid
}

test "queryClassToWire maps all 4 classes correctly" {
    try std.testing.expectEqual(@as(u16, 1), dns.queryClassToWire(0)); // IN
    try std.testing.expectEqual(@as(u16, 3), dns.queryClassToWire(1)); // CH
    try std.testing.expectEqual(@as(u16, 4), dns.queryClassToWire(2)); // HS
    try std.testing.expectEqual(@as(u16, 255), dns.queryClassToWire(3)); // ANY
    try std.testing.expectEqual(@as(u16, 0), dns.queryClassToWire(99)); // invalid
}

// =========================================================================
// Message building — verify header structure
// =========================================================================

test "built response has correct header structure" {
    const slot = dns.dns_create_context();
    defer dns.dns_destroy_context(slot);

    // Query with transaction ID 0xABCD, A record, IN class
    var query_buf: [17]u8 = .{
        0xAB, 0xCD, // Transaction ID
        0x01, 0x00, // Flags
        0x00, 0x01, // QDCOUNT=1
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, // QNAME: root
        0x00, 0x01, // QTYPE: A
        0x00, 0x01, // QCLASS: IN
    };

    _ = dns.dns_parse_query(slot, &query_buf, 17);
    _ = dns.dns_begin_lookup(slot);
    _ = dns.dns_begin_response(slot);

    // Add 2 answers, 1 authority
    var rdata: [4]u8 = .{ 1, 2, 3, 4 };
    _ = dns.dns_add_answer(slot, 0, 0, 60, &rdata, 4);
    _ = dns.dns_add_answer(slot, 0, 0, 120, &rdata, 4);
    _ = dns.dns_add_authority(slot, 4, 0, 3600, &rdata, 4);
    _ = dns.dns_set_rcode(slot, 0); // NoError

    var out_buf: [4096]u8 = undefined;
    var out_len: u16 = 0;
    _ = dns.dns_build_response(slot, &out_buf, &out_len);

    // Verify transaction ID
    try std.testing.expectEqual(@as(u8, 0xAB), out_buf[0]);
    try std.testing.expectEqual(@as(u8, 0xCD), out_buf[1]);

    // Verify QR=1, AA=1, RD=1
    try std.testing.expectEqual(@as(u8, 0x85), out_buf[2]);
    // Verify RA=1, RCODE=0
    try std.testing.expectEqual(@as(u8, 0x80), out_buf[3]);

    // Verify QDCOUNT=1
    try std.testing.expectEqual(@as(u8, 0), out_buf[4]);
    try std.testing.expectEqual(@as(u8, 1), out_buf[5]);

    // Verify ANCOUNT=2
    try std.testing.expectEqual(@as(u8, 0), out_buf[6]);
    try std.testing.expectEqual(@as(u8, 2), out_buf[7]);

    // Verify NSCOUNT=1
    try std.testing.expectEqual(@as(u8, 0), out_buf[8]);
    try std.testing.expectEqual(@as(u8, 1), out_buf[9]);

    // Verify ARCOUNT=0
    try std.testing.expectEqual(@as(u8, 0), out_buf[10]);
    try std.testing.expectEqual(@as(u8, 0), out_buf[11]);
}

// =========================================================================
// Stateless transition tables
// =========================================================================

test "dns_can_transition matches Transitions.idr" {
    // Forward lifecycle sequence
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(0, 1)); // Idle -> QueryReceived
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(1, 2)); // QueryReceived -> Lookup
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(2, 3)); // Lookup -> ResponseBuilding
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(3, 4)); // ResponseBuilding -> Sent

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(0, 4)); // Idle -> Sent
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(1, 4)); // QueryReceived -> Sent
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_transition(2, 4)); // Lookup -> Sent

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(4, 0)); // Sent -> Idle (terminal!)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(4, 3)); // Sent -> Building
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(0, 3)); // Idle -> Building (skip!)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(3, 0)); // Building -> Idle (backwards!)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_transition(2, 1)); // Lookup -> Received (backwards!)
}

test "dns_can_dnssec_transition matches Transitions.idr" {
    // Forward DNSSEC sequence
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_dnssec_transition(0, 1)); // Disabled -> Enabled
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_dnssec_transition(1, 2)); // Enabled -> KeyLoaded
    try std.testing.expectEqual(@as(u8, 1), dns.dns_can_dnssec_transition(2, 3)); // KeyLoaded -> Validated

    // Invalid DNSSEC transitions
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_dnssec_transition(3, 0)); // Validated -> Disabled (no revert!)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_dnssec_transition(0, 2)); // Disabled -> KeyLoaded (skip!)
    try std.testing.expectEqual(@as(u8, 0), dns.dns_can_dnssec_transition(0, 3)); // Disabled -> Validated (skip!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), dns.dns_state(-1)); // sent fallback
    try std.testing.expectEqual(@as(u8, 0), dns.dns_dnssec_state(-1)); // disabled fallback
    try std.testing.expectEqual(@as(u8, 2), dns.dns_rcode(-1)); // servfail fallback
    try std.testing.expectEqual(@as(u16, 0), dns.dns_answer_count(-1));
    try std.testing.expectEqual(@as(u16, 0), dns.dns_authority_count(-1));
    try std.testing.expectEqual(@as(u16, 0), dns.dns_additional_count(-1));
    try std.testing.expectEqual(@as(u8, 255), dns.dns_query_rtype(-1));
    try std.testing.expectEqual(@as(u8, 255), dns.dns_query_class(-1));
}
