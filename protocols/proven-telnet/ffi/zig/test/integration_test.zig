// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-telnet FFI.
//
// INSECURE PROTOCOL -- for legacy interoperability only.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Command sending
//   - Option negotiation (WILL/WONT/DO/DONT)
//   - Session activation
//   - Subnegotiation lifecycle
//   - Data sending
//   - Disconnect / cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Session count tracking
//   - Impossibility (invalid transitions)

const std = @import("std");
const telnet = @import("telnet");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), telnet.telnet_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Command encoding matches Types.idr (16 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(telnet.Command.se));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(telnet.Command.nop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(telnet.Command.data_mark));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(telnet.Command.brk));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(telnet.Command.go_ahead));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(telnet.Command.will));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(telnet.Command.wont));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(telnet.Command.do_));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(telnet.Command.dont));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(telnet.Command.iac));
}

test "TelnetOption encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(telnet.TelnetOption.echo));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(telnet.TelnetOption.suppress_go_ahead));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(telnet.TelnetOption.terminal_type));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(telnet.TelnetOption.window_size));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(telnet.TelnetOption.environment));
}

test "NegotiationState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(telnet.NegotiationState.inactive));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(telnet.NegotiationState.will_sent));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(telnet.NegotiationState.do_sent));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(telnet.NegotiationState.active));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(telnet.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(telnet.SessionState.negotiating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(telnet.SessionState.active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(telnet.SessionState.subneg));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(telnet.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = telnet.telnet_create();
    try std.testing.expect(slot >= 0);
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_state(slot)); // Idle
}

test "destroy is safe with invalid slot" {
    telnet.telnet_destroy(-1);
    telnet.telnet_destroy(999);
}

// =========================================================================
// Negotiation
// =========================================================================

test "negotiate WILL transitions Idle -> Negotiating" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    // WILL(11) ECHO(0)
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_negotiate(slot, 11, 0));
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_state(slot)); // Negotiating
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_option_state(slot, 0)); // will_sent
}

test "negotiate DO sets do_sent" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    // DO(13) SUPPRESS_GO_AHEAD(1)
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_negotiate(slot, 13, 1));
    try std.testing.expectEqual(@as(u8, 2), telnet.telnet_option_state(slot, 1)); // do_sent
}

test "negotiate WONT resets to inactive" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0); // WILL ECHO
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_option_state(slot, 0)); // will_sent
    _ = telnet.telnet_negotiate(slot, 12, 0); // WONT ECHO
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_option_state(slot, 0)); // inactive
}

test "negotiate rejects invalid command" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_negotiate(slot, 5, 0)); // NOP is not negotiation
}

test "negotiate rejects invalid option" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_negotiate(slot, 11, 99));
}

// =========================================================================
// Activation
// =========================================================================

test "activate transitions Negotiating -> Active" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0); // WILL ECHO
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_activate(slot));
    try std.testing.expectEqual(@as(u8, 2), telnet.telnet_state(slot)); // Active
}

test "activate rejected from Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_activate(slot));
}

// =========================================================================
// Subnegotiation
// =========================================================================

test "subneg lifecycle Active -> Subneg -> Active" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0);
    _ = telnet.telnet_activate(slot);

    // Begin subneg for TERMINAL_TYPE(4)
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_subneg_begin(slot, 4));
    try std.testing.expectEqual(@as(u8, 3), telnet.telnet_state(slot)); // Subneg

    // Send subneg data
    const data = "xterm-256color";
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_subneg_data(slot, data.ptr, data.len));

    // End subneg
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_subneg_end(slot));
    try std.testing.expectEqual(@as(u8, 2), telnet.telnet_state(slot)); // Active
    try std.testing.expectEqual(@as(u8, 3), telnet.telnet_option_state(slot, 4)); // active
}

test "subneg_begin rejected from Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_subneg_begin(slot, 0));
}

// =========================================================================
// Data sending
// =========================================================================

test "send_data succeeds from Active" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0);
    _ = telnet.telnet_activate(slot);

    const data = "hello world";
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_send_data(slot, data.ptr, data.len));
}

test "send_data rejected from Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    const data = "hello";
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_send_data(slot, data.ptr, data.len));
}

// =========================================================================
// Commands
// =========================================================================

test "send_command succeeds from Negotiating" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0);
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_send_command(slot, 1)); // NOP
}

test "send_command rejected from Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_send_command(slot, 1));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Active -> Closing" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0);
    _ = telnet.telnet_activate(slot);

    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), telnet.telnet_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);

    _ = telnet.telnet_negotiate(slot, 11, 0);
    _ = telnet.telnet_activate(slot);
    _ = telnet.telnet_disconnect(slot);

    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_state(slot)); // Idle
}

test "disconnect rejected from Idle" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_disconnect(slot));
}

test "cleanup rejected from non-Closing state" {
    const slot = telnet.telnet_create();
    defer telnet.telnet_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "telnet_can_transition matches Types.idr" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(0, 1)); // Idle -> Negotiating
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(1, 2)); // Negotiating -> Active
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(2, 3)); // Active -> Subneg
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(3, 2)); // Subneg -> Active
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(1, 4)); // Negotiating -> Closing
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(2, 4)); // Active -> Closing
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(3, 4)); // Subneg -> Closing
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_can_transition(4, 0)); // Closing -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_can_transition(0, 2)); // Idle -/-> Active
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_can_transition(0, 3)); // Idle -/-> Subneg
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_can_transition(4, 1)); // Closing -/-> Negotiating
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_can_transition(4, 2)); // Closing -/-> Active
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_state(-1));
    try std.testing.expectEqual(@as(u8, 0), telnet.telnet_option_state(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), telnet.telnet_cleanup(-1));
}

// =========================================================================
// Session count
// =========================================================================

test "session_count tracks active sessions" {
    const initial = telnet.telnet_session_count();
    const slot = telnet.telnet_create();
    try std.testing.expectEqual(initial + 1, telnet.telnet_session_count());
    telnet.telnet_destroy(slot);
    try std.testing.expectEqual(initial, telnet.telnet_session_count());
}
