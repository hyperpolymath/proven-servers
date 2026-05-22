// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-snmp FFI.
//
// Tests cover:
//   - ABI version check
//   - Session lifecycle (create, destroy, state queries)
//   - Version management and validation
//   - PDU sending with version compatibility checks
//   - Error status management
//   - Variable binding tracking and limits
//   - Stateless PDU-version validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const snmp = @import("snmp");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), snmp.snmp_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = snmp.snmp_create(0); // V1
    try expect(slot >= 0);
    snmp.snmp_destroy(slot);
}

test "create with invalid version returns -1" {
    const slot = snmp.snmp_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    snmp.snmp_destroy(-1);
    snmp.snmp_destroy(999);
}

test "double destroy is safe" {
    const slot = snmp.snmp_create(0);
    snmp.snmp_destroy(slot);
    snmp.snmp_destroy(slot);
}

// ── State Queries on Fresh Session ──────────────────────────────────────

test "fresh session has correct version" {
    const slot = snmp.snmp_create(2); // V3
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 2), snmp.snmp_get_version(slot));
}

test "fresh session has no error" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_get_error(slot)); // NoError
}

test "fresh session has zero PDU count" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u32, 0), snmp.snmp_get_pdu_count(slot));
}

test "fresh session has zero varbinds" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u32, 0), snmp.snmp_get_varbind_count(slot));
}

test "fresh session has no last PDU type (255)" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 255), snmp.snmp_get_last_pdu_type(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_version on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), snmp.snmp_get_version(-1));
}

test "get_pdu_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), snmp.snmp_get_pdu_count(-1));
}

test "get_last_pdu_type on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), snmp.snmp_get_last_pdu_type(-1));
}

// ── Version Management ──────────────────────────────────────────────────

test "set version succeeds" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_set_version(slot, 2)); // -> V3
    try expectEqual(@as(u8, 2), snmp.snmp_get_version(slot));
}

test "set invalid version fails" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 3), snmp.snmp_set_version(slot, 99)); // InvalidVersion
}

test "set version on invalid slot fails" {
    try expectEqual(@as(u8, 1), snmp.snmp_set_version(-1, 0)); // InvalidSlot
}

// ── PDU Sending ─────────────────────────────────────────────────────────

test "send GetRequest on V1 succeeds" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 0)); // GetRequest
    try expectEqual(@as(u32, 1), snmp.snmp_get_pdu_count(slot));
    try expectEqual(@as(u8, 0), snmp.snmp_get_last_pdu_type(slot));
}

test "send SetRequest on V1 succeeds" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 3)); // SetRequest
}

test "send GetBulkRequest on V1 fails (version mismatch)" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 5), snmp.snmp_send_pdu(slot, 4)); // VersionMismatch
}

test "send InformRequest on V1 fails (version mismatch)" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 5), snmp.snmp_send_pdu(slot, 5)); // VersionMismatch
}

test "send SNMPv2Trap on V1 fails (version mismatch)" {
    const slot = snmp.snmp_create(0); // V1
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 5), snmp.snmp_send_pdu(slot, 6)); // VersionMismatch
}

test "send GetBulkRequest on V2c succeeds" {
    const slot = snmp.snmp_create(1); // V2c
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 4)); // GetBulkRequest
}

test "send InformRequest on V3 succeeds" {
    const slot = snmp.snmp_create(2); // V3
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 5)); // InformRequest
}

test "send invalid PDU type fails" {
    const slot = snmp.snmp_create(2); // V3
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 4), snmp.snmp_send_pdu(slot, 99)); // InvalidPDU
}

test "send PDU on invalid slot fails" {
    try expectEqual(@as(u8, 1), snmp.snmp_send_pdu(-1, 0)); // InvalidSlot
}

test "multiple PDUs increment count" {
    const slot = snmp.snmp_create(2); // V3
    defer snmp.snmp_destroy(slot);
    _ = snmp.snmp_send_pdu(slot, 0);
    _ = snmp.snmp_send_pdu(slot, 1);
    _ = snmp.snmp_send_pdu(slot, 3);
    try expectEqual(@as(u32, 3), snmp.snmp_get_pdu_count(slot));
    try expectEqual(@as(u8, 3), snmp.snmp_get_last_pdu_type(slot)); // SetRequest
}

// ── Error Status Management ─────────────────────────────────────────────

test "set error status succeeds" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_set_error(slot, 5)); // GenErr
    try expectEqual(@as(u8, 5), snmp.snmp_get_error(slot));
}

test "set all valid error statuses" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    var i: u8 = 0;
    while (i <= 15) : (i += 1) {
        try expectEqual(@as(u8, 0), snmp.snmp_set_error(slot, i));
        try expectEqual(i, snmp.snmp_get_error(slot));
    }
}

test "set invalid error status fails" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 6), snmp.snmp_set_error(slot, 99)); // InvalidErrorStatus
}

// ── Variable Binding Tracking ───────────────────────────────────────────

test "add varbind increments count" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_add_varbind(slot));
    try expectEqual(@as(u32, 1), snmp.snmp_get_varbind_count(slot));
    try expectEqual(@as(u8, 0), snmp.snmp_add_varbind(slot));
    try expectEqual(@as(u32, 2), snmp.snmp_get_varbind_count(slot));
}

test "clear varbinds resets count" {
    const slot = snmp.snmp_create(0);
    defer snmp.snmp_destroy(slot);
    _ = snmp.snmp_add_varbind(slot);
    _ = snmp.snmp_add_varbind(slot);
    snmp.snmp_clear_varbinds(slot);
    try expectEqual(@as(u32, 0), snmp.snmp_get_varbind_count(slot));
}

test "add varbind on invalid slot fails" {
    try expectEqual(@as(u8, 1), snmp.snmp_add_varbind(-1)); // InvalidSlot
}

// ── Stateless PDU-Version Validation ────────────────────────────────────

test "can_send_pdu: V1 supports basic PDU types" {
    try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(0, 0)); // V1, GetRequest
    try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(0, 1)); // V1, GetNextRequest
    try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(0, 2)); // V1, GetResponse
    try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(0, 3)); // V1, SetRequest
}

test "can_send_pdu: V1 does not support v2c/v3 PDU types" {
    try expectEqual(@as(u8, 0), snmp.snmp_can_send_pdu(0, 4)); // V1, GetBulkRequest
    try expectEqual(@as(u8, 0), snmp.snmp_can_send_pdu(0, 5)); // V1, InformRequest
    try expectEqual(@as(u8, 0), snmp.snmp_can_send_pdu(0, 6)); // V1, SNMPv2Trap
}

test "can_send_pdu: V2c supports all PDU types" {
    var i: u8 = 0;
    while (i <= 6) : (i += 1) {
        try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(1, i));
    }
}

test "can_send_pdu: V3 supports all PDU types" {
    var i: u8 = 0;
    while (i <= 6) : (i += 1) {
        try expectEqual(@as(u8, 1), snmp.snmp_can_send_pdu(2, i));
    }
}

test "can_send_pdu: invalid PDU type returns 0" {
    try expectEqual(@as(u8, 0), snmp.snmp_can_send_pdu(2, 99));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full session lifecycle: create, configure, send, query, destroy" {
    const slot = snmp.snmp_create(1); // V2c
    defer snmp.snmp_destroy(slot);

    // Add variable bindings
    try expectEqual(@as(u8, 0), snmp.snmp_add_varbind(slot));
    try expectEqual(@as(u8, 0), snmp.snmp_add_varbind(slot));
    try expectEqual(@as(u32, 2), snmp.snmp_get_varbind_count(slot));

    // Send a GetBulkRequest (v2c-only PDU)
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 4));
    try expectEqual(@as(u32, 1), snmp.snmp_get_pdu_count(slot));
    try expectEqual(@as(u8, 4), snmp.snmp_get_last_pdu_type(slot));

    // Clear varbinds, add new ones, send another PDU
    snmp.snmp_clear_varbinds(slot);
    try expectEqual(@as(u32, 0), snmp.snmp_get_varbind_count(slot));
    _ = snmp.snmp_add_varbind(slot);
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 3)); // SetRequest
    try expectEqual(@as(u32, 2), snmp.snmp_get_pdu_count(slot));

    // Upgrade to V3
    try expectEqual(@as(u8, 0), snmp.snmp_set_version(slot, 2));
    try expectEqual(@as(u8, 2), snmp.snmp_get_version(slot));

    // Send InformRequest (v3)
    try expectEqual(@as(u8, 0), snmp.snmp_send_pdu(slot, 5));
    try expectEqual(@as(u32, 3), snmp.snmp_get_pdu_count(slot));
}
