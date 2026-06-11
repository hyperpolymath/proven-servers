// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-voip FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Dialog state transitions (Early -> Confirmed -> Terminated)
//   - SIP method request sending
//   - SIP response code reception
//   - CSeq management
//   - Registration binding management
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const voip = @import("voip");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), voip.voip_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Method encoding matches Types.idr (13 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(voip.Method.invite));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(voip.Method.ack));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(voip.Method.bye));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(voip.Method.cancel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(voip.Method.register));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(voip.Method.options));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(voip.Method.info));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(voip.Method.update));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(voip.Method.subscribe));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(voip.Method.notify));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(voip.Method.refer));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(voip.Method.message));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(voip.Method.prack));
}

test "ResponseCode encoding matches Types.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(voip.ResponseCode.trying));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(voip.ResponseCode.ok));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(voip.ResponseCode.busy_here));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(voip.ResponseCode.service_unavailable));
}

test "DialogState encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(voip.DialogState.early));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(voip.DialogState.confirmed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(voip.DialogState.terminated));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Early state" {
    const call_id = "call-001@example.com";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    try std.testing.expect(slot >= 0);
    defer voip.voip_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), voip.voip_state(slot)); // Early
}

test "create rejects empty call_id" {
    const call_id = "x";
    const slot = voip.voip_create(call_id.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    voip.voip_destroy(-1);
    voip.voip_destroy(999);
}

// =========================================================================
// Dialog state transitions
// =========================================================================

test "confirm transitions Early -> Confirmed" {
    const call_id = "call-002";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), voip.voip_confirm(slot));
    try std.testing.expectEqual(@as(u8, 1), voip.voip_state(slot)); // Confirmed
}

test "terminate from Early" {
    const call_id = "call-003";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), voip.voip_terminate(slot));
    try std.testing.expectEqual(@as(u8, 2), voip.voip_state(slot)); // Terminated
}

test "terminate from Confirmed" {
    const call_id = "call-004";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_confirm(slot);
    try std.testing.expectEqual(@as(u8, 0), voip.voip_terminate(slot));
    try std.testing.expectEqual(@as(u8, 2), voip.voip_state(slot));
}

test "confirm rejected from Confirmed" {
    const call_id = "call-005";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_confirm(slot);
    try std.testing.expectEqual(@as(u8, 1), voip.voip_confirm(slot));
}

test "terminate rejected from Terminated" {
    const call_id = "call-006";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_terminate(slot);
    try std.testing.expectEqual(@as(u8, 1), voip.voip_terminate(slot));
}

// =========================================================================
// SIP request/response
// =========================================================================

test "send_request increments CSeq and request_count" {
    const call_id = "call-007";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    const initial_cseq = voip.voip_cseq(slot);
    try std.testing.expectEqual(@as(u8, 0), voip.voip_send_request(slot, 0)); // INVITE
    try std.testing.expectEqual(initial_cseq + 1, voip.voip_cseq(slot));
    try std.testing.expectEqual(@as(u32, 1), voip.voip_request_count(slot));
}

test "send_request rejects invalid method tag" {
    const call_id = "call-008";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), voip.voip_send_request(slot, 99));
}

test "send_request rejected from Terminated" {
    const call_id = "call-009";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_terminate(slot);
    try std.testing.expectEqual(@as(u8, 1), voip.voip_send_request(slot, 0));
}

test "BYE rejected from Early state" {
    const call_id = "call-010";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), voip.voip_send_request(slot, 2)); // BYE
}

test "BYE accepted from Confirmed state" {
    const call_id = "call-011";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_confirm(slot);
    try std.testing.expectEqual(@as(u8, 0), voip.voip_send_request(slot, 2)); // BYE
}

test "recv_response increments response_count" {
    const call_id = "call-012";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), voip.voip_recv_response(slot, 3)); // OK
    try std.testing.expectEqual(@as(u32, 1), voip.voip_response_count(slot));
}

test "recv_response rejected from Terminated" {
    const call_id = "call-013";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    _ = voip.voip_terminate(slot);
    try std.testing.expectEqual(@as(u8, 1), voip.voip_recv_response(slot, 3));
}

// =========================================================================
// Registration
// =========================================================================

test "register adds contact binding" {
    const call_id = "call-014";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    const contact = "sip:alice@atlanta.com";
    try std.testing.expectEqual(@as(u8, 0), voip.voip_register(
        slot, contact.ptr, contact.len, 3600,
    ));
    try std.testing.expectEqual(@as(u32, 1), voip.voip_registration_count(slot));
}

test "register rejects empty contact" {
    const call_id = "call-015";
    const slot = voip.voip_create(call_id.ptr, call_id.len);
    defer voip.voip_destroy(slot);

    const contact = "x";
    try std.testing.expectEqual(@as(u8, 1), voip.voip_register(
        slot, contact.ptr, 0, 3600,
    ));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "voip_can_transition matches dialog state machine" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), voip.voip_can_transition(0, 1)); // Early -> Confirmed
    try std.testing.expectEqual(@as(u8, 1), voip.voip_can_transition(0, 2)); // Early -> Terminated
    try std.testing.expectEqual(@as(u8, 1), voip.voip_can_transition(1, 2)); // Confirmed -> Terminated

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), voip.voip_can_transition(1, 0)); // Confirmed -/-> Early
    try std.testing.expectEqual(@as(u8, 0), voip.voip_can_transition(2, 0)); // Terminated -/-> Early
    try std.testing.expectEqual(@as(u8, 0), voip.voip_can_transition(2, 1)); // Terminated -/-> Confirmed
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), voip.voip_state(-1));
    try std.testing.expectEqual(@as(u32, 0), voip.voip_cseq(-1));
    try std.testing.expectEqual(@as(u32, 0), voip.voip_request_count(-1));
    try std.testing.expectEqual(@as(u32, 0), voip.voip_response_count(-1));
    try std.testing.expectEqual(@as(u32, 0), voip.voip_registration_count(-1));
    try std.testing.expectEqual(@as(u8, 1), voip.voip_confirm(-1));
    try std.testing.expectEqual(@as(u8, 1), voip.voip_terminate(-1));
}
