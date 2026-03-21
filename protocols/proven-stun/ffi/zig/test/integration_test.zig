// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-stun FFI.
//
// Tests cover:
//   - ABI version check
//   - Session lifecycle (create, destroy, state queries)
//   - Transport protocol management
//   - Message sending and type tracking
//   - Message receiving and type tracking
//   - Error code management
//   - Send and receive counters
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const stun = @import("stun");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), stun.stun_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = stun.stun_create(0); // UDP
    try expect(slot >= 0);
    stun.stun_destroy(slot);
}

test "create with invalid transport returns -1" {
    const slot = stun.stun_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    stun.stun_destroy(-1);
    stun.stun_destroy(999);
}

test "double destroy is safe" {
    const slot = stun.stun_create(0);
    stun.stun_destroy(slot);
    stun.stun_destroy(slot);
}

// ── State Queries on Fresh Session ──────────────────────────────────────

test "fresh session has specified transport" {
    const slot = stun.stun_create(3); // DTLS
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 3), stun.stun_get_transport(slot));
}

test "fresh session has no error (255)" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 255), stun.stun_get_error(slot));
}

test "fresh session has zero send count" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u32, 0), stun.stun_get_send_count(slot));
}

test "fresh session has zero recv count" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u32, 0), stun.stun_get_recv_count(slot));
}

test "fresh session has no last sent (255)" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 255), stun.stun_get_last_sent(slot));
}

test "fresh session has no last recv (255)" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 255), stun.stun_get_last_recv(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_transport on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), stun.stun_get_transport(-1));
}

test "get_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), stun.stun_get_error(-1));
}

test "get_send_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), stun.stun_get_send_count(-1));
}

test "get_last_sent on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), stun.stun_get_last_sent(-1));
}

// ── Transport Management ────────────────────────────────────────────────

test "set transport succeeds" {
    const slot = stun.stun_create(0); // UDP
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 0), stun.stun_set_transport(slot, 2)); // TLS
    try expectEqual(@as(u8, 2), stun.stun_get_transport(slot));
}

test "set invalid transport fails" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 4), stun.stun_set_transport(slot, 99)); // InvalidTransport
}

test "set transport on invalid slot fails" {
    try expectEqual(@as(u8, 1), stun.stun_set_transport(-1, 0)); // InvalidSlot
}

// ── Message Sending ─────────────────────────────────────────────────────

test "send BindingRequest succeeds" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 0)); // BindingRequest
    try expectEqual(@as(u32, 1), stun.stun_get_send_count(slot));
    try expectEqual(@as(u8, 0), stun.stun_get_last_sent(slot));
}

test "send all message types" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    var i: u8 = 0;
    while (i <= 11) : (i += 1) {
        try expectEqual(@as(u8, 0), stun.stun_send_message(slot, i));
    }
    try expectEqual(@as(u32, 12), stun.stun_get_send_count(slot));
    try expectEqual(@as(u8, 11), stun.stun_get_last_sent(slot)); // ChannelBind
}

test "send invalid message type fails" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 3), stun.stun_send_message(slot, 99)); // InvalidMessageType
}

test "send on invalid slot fails" {
    try expectEqual(@as(u8, 1), stun.stun_send_message(-1, 0)); // InvalidSlot
}

// ── Message Receiving ───────────────────────────────────────────────────

test "receive BindingResponse succeeds" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, 1)); // BindingResponse
    try expectEqual(@as(u32, 1), stun.stun_get_recv_count(slot));
    try expectEqual(@as(u8, 1), stun.stun_get_last_recv(slot));
}

test "receive all message types" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    var i: u8 = 0;
    while (i <= 11) : (i += 1) {
        try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, i));
    }
    try expectEqual(@as(u32, 12), stun.stun_get_recv_count(slot));
}

test "receive invalid message type fails" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 3), stun.stun_receive_message(slot, 99)); // InvalidMessageType
}

test "receive on invalid slot fails" {
    try expectEqual(@as(u8, 1), stun.stun_receive_message(-1, 0)); // InvalidSlot
}

// ── Error Code Management ───────────────────────────────────────────────

test "set error code succeeds" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 0), stun.stun_set_error(slot, 1)); // BadRequest
    try expectEqual(@as(u8, 1), stun.stun_get_error(slot));
}

test "set all valid error codes" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    var i: u8 = 0;
    while (i <= 7) : (i += 1) {
        try expectEqual(@as(u8, 0), stun.stun_set_error(slot, i));
        try expectEqual(i, stun.stun_get_error(slot));
    }
}

test "set invalid error code fails" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    try expectEqual(@as(u8, 5), stun.stun_set_error(slot, 99)); // InvalidErrorCode
}

test "clear error" {
    const slot = stun.stun_create(0);
    defer stun.stun_destroy(slot);
    _ = stun.stun_set_error(slot, 2);
    stun.stun_clear_error(slot);
    try expectEqual(@as(u8, 255), stun.stun_get_error(slot));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full STUN binding lifecycle: request, response, error" {
    const slot = stun.stun_create(0); // UDP
    defer stun.stun_destroy(slot);

    // Send BindingRequest
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 0));
    try expectEqual(@as(u32, 1), stun.stun_get_send_count(slot));

    // Receive BindingResponse
    try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, 1));
    try expectEqual(@as(u32, 1), stun.stun_get_recv_count(slot));

    // Upgrade to TLS
    try expectEqual(@as(u8, 0), stun.stun_set_transport(slot, 2));

    // Send AllocateRequest
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 3));
    try expectEqual(@as(u32, 2), stun.stun_get_send_count(slot));
    try expectEqual(@as(u8, 3), stun.stun_get_last_sent(slot));

    // Receive AllocateError with Unauthorized
    try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, 5));
    _ = stun.stun_set_error(slot, 2); // Unauthorized
    try expectEqual(@as(u8, 2), stun.stun_get_error(slot));

    // Clear error and retry
    stun.stun_clear_error(slot);
    try expectEqual(@as(u8, 255), stun.stun_get_error(slot));
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 3)); // AllocateRequest again
    try expectEqual(@as(u32, 3), stun.stun_get_send_count(slot));
}

test "TURN relay lifecycle: allocate, permission, channel bind" {
    const slot = stun.stun_create(3); // DTLS
    defer stun.stun_destroy(slot);

    // AllocateRequest -> AllocateResponse
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 3));
    try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, 4));

    // CreatePermission
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 10));

    // ChannelBind
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 11));

    // Data relay
    try expectEqual(@as(u8, 0), stun.stun_send_message(slot, 8)); // SendIndication
    try expectEqual(@as(u8, 0), stun.stun_receive_message(slot, 9)); // DataIndication

    try expectEqual(@as(u32, 4), stun.stun_get_send_count(slot));
    try expectEqual(@as(u32, 2), stun.stun_get_recv_count(slot));
}
