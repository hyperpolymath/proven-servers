// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-rtsp FFI.
//
// Tests cover:
//   - ABI version check
//   - Session lifecycle (create, destroy, state queries)
//   - State machine transitions (valid and invalid per RFC 7826)
//   - Method execution and state validation
//   - Transport protocol configuration
//   - Method counting and status code tracking
//   - Stateless transition validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const rtsp = @import("rtsp");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), rtsp.rtsp_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = rtsp.rtsp_create(0); // RTP/AVP/UDP
    try expect(slot >= 0);
    rtsp.rtsp_destroy(slot);
}

test "create with TCP transport" {
    const slot = rtsp.rtsp_create(1); // RTP/AVP/TCP
    try expect(slot >= 0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 1), rtsp.rtsp_get_transport(slot));
}

test "create with invalid transport returns -1" {
    const slot = rtsp.rtsp_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    rtsp.rtsp_destroy(-1);
    rtsp.rtsp_destroy(999);
}

test "double destroy is safe" {
    const slot = rtsp.rtsp_create(0);
    rtsp.rtsp_destroy(slot);
    rtsp.rtsp_destroy(slot);
}

// ── State Queries on Fresh Session ──────────────────────────────────────

test "fresh session is in Init state" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_get_state(slot)); // Init
}

test "fresh session has UDP transport" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_get_transport(slot)); // RTP_AVP_UDP
}

test "fresh session has zero method count" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u32, 0), rtsp.rtsp_get_method_count(slot));
}

test "fresh session has OK status" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_get_last_status(slot)); // OK
}

test "fresh session has no error (255)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 255), rtsp.rtsp_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns Init" {
    try expectEqual(@as(u8, 0), rtsp.rtsp_get_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), rtsp.rtsp_get_last_error(-1));
}

// ── Valid State Transitions ─────────────────────────────────────────────

test "Init -> Ready (SETUP)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 1)); // -> Ready
    try expectEqual(@as(u8, 1), rtsp.rtsp_get_state(slot));
}

test "Ready -> Playing (PLAY)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 2)); // -> Playing
    try expectEqual(@as(u8, 2), rtsp.rtsp_get_state(slot));
}

test "Ready -> Recording (RECORD)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 3)); // -> Recording
    try expectEqual(@as(u8, 3), rtsp.rtsp_get_state(slot));
}

test "Playing -> Ready (PAUSE)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 1)); // -> Ready
    try expectEqual(@as(u8, 1), rtsp.rtsp_get_state(slot));
}

test "Recording -> Ready (PAUSE)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 3); // -> Recording
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 1)); // -> Ready
}

test "Ready -> Init (TEARDOWN) resets method count" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_execute_method(slot, 7); // OPTIONS
    try expect(rtsp.rtsp_get_method_count(slot) > 0);
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 0)); // -> Init (teardown)
    try expectEqual(@as(u32, 0), rtsp.rtsp_get_method_count(slot));
}

test "Playing -> Init (TEARDOWN)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 0)); // -> Init
}

// ── Invalid State Transitions ───────────────────────────────────────────

test "Init -> Playing is invalid (must SETUP first)" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 3), rtsp.rtsp_transition(slot, 2)); // InvalidTransition
}

test "Init -> Recording is invalid" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 3), rtsp.rtsp_transition(slot, 3)); // InvalidTransition
}

test "Playing -> Recording is invalid" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 3), rtsp.rtsp_transition(slot, 3)); // InvalidTransition
}

test "transition on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), rtsp.rtsp_transition(-1, 1)); // InvalidSlot
}

test "transition with invalid state value fails" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 3), rtsp.rtsp_transition(slot, 99)); // InvalidTransition
}

// ── Method Execution ────────────────────────────────────────────────────

test "DESCRIBE valid in Init" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 0)); // DESCRIBE
    try expectEqual(@as(u32, 1), rtsp.rtsp_get_method_count(slot));
}

test "OPTIONS valid in Init" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 7)); // OPTIONS
}

test "SETUP valid in Init" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 1)); // SETUP
}

test "PLAY invalid in Init" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 4), rtsp.rtsp_execute_method(slot, 2)); // MethodNotAllowed
}

test "PLAY valid in Ready" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 2)); // PLAY
}

test "TEARDOWN valid in Ready" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 4)); // TEARDOWN
}

test "PAUSE valid in Playing" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 3)); // PAUSE
}

test "GET_PARAMETER valid in Playing" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 5)); // GET_PARAMETER
}

test "SETUP invalid in Playing" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing
    try expectEqual(@as(u8, 4), rtsp.rtsp_execute_method(slot, 1)); // MethodNotAllowed
}

test "RECORD valid in Recording" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_transition(slot, 3); // -> Recording
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 9)); // RECORD
}

test "invalid method tag returns MethodNotAllowed" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 4), rtsp.rtsp_execute_method(slot, 99));
}

test "execute method on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), rtsp.rtsp_execute_method(-1, 0));
}

test "failed method sets status to MethodNotAllowed" {
    const slot = rtsp.rtsp_create(0);
    defer rtsp.rtsp_destroy(slot);
    _ = rtsp.rtsp_execute_method(slot, 2); // PLAY in Init -> fail
    try expectEqual(@as(u8, 6), rtsp.rtsp_get_last_status(slot)); // MethodNotAllowed
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid RFC 7826 transitions return 1" {
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(0, 1)); // Init -> Ready
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(1, 2)); // Ready -> Playing
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(1, 3)); // Ready -> Recording
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(2, 1)); // Playing -> Ready
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(3, 1)); // Recording -> Ready
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(1, 0)); // Ready -> Init
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(2, 0)); // Playing -> Init
    try expectEqual(@as(u8, 1), rtsp.rtsp_can_transition(3, 0)); // Recording -> Init
}

test "can_transition: invalid transitions return 0" {
    try expectEqual(@as(u8, 0), rtsp.rtsp_can_transition(0, 2)); // Init -> Playing
    try expectEqual(@as(u8, 0), rtsp.rtsp_can_transition(0, 3)); // Init -> Recording
    try expectEqual(@as(u8, 0), rtsp.rtsp_can_transition(2, 3)); // Playing -> Recording
    try expectEqual(@as(u8, 0), rtsp.rtsp_can_transition(3, 2)); // Recording -> Playing
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full lifecycle: describe, setup, play, pause, teardown" {
    const slot = rtsp.rtsp_create(0); // UDP transport
    defer rtsp.rtsp_destroy(slot);

    // Describe content
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 0)); // DESCRIBE

    // Setup session
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 1)); // SETUP
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 1)); // -> Ready

    // Start playback
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 2)); // PLAY
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 2)); // -> Playing

    // Keepalive
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 5)); // GET_PARAMETER

    // Pause
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 3)); // PAUSE
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 1)); // -> Ready

    // Teardown
    try expectEqual(@as(u8, 0), rtsp.rtsp_execute_method(slot, 4)); // TEARDOWN
    try expectEqual(@as(u8, 0), rtsp.rtsp_transition(slot, 0)); // -> Init

    try expectEqual(@as(u32, 0), rtsp.rtsp_get_method_count(slot)); // Reset after teardown
}

test "multicast session lifecycle" {
    const slot = rtsp.rtsp_create(2); // Multicast
    defer rtsp.rtsp_destroy(slot);
    try expectEqual(@as(u8, 2), rtsp.rtsp_get_transport(slot)); // Multicast

    _ = rtsp.rtsp_execute_method(slot, 7); // OPTIONS
    _ = rtsp.rtsp_execute_method(slot, 1); // SETUP
    _ = rtsp.rtsp_transition(slot, 1); // -> Ready
    _ = rtsp.rtsp_execute_method(slot, 2); // PLAY
    _ = rtsp.rtsp_transition(slot, 2); // -> Playing

    try expectEqual(@as(u32, 3), rtsp.rtsp_get_method_count(slot));
    try expectEqual(@as(u8, 0), rtsp.rtsp_get_last_status(slot)); // OK
}
