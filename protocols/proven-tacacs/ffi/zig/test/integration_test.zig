// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-tacacs FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Authentication start/continue/status
//   - Authorization request/status
//   - Accounting record/status
//   - Session state transitions
//   - Disconnect / cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Session count tracking
//   - Impossibility (invalid transitions)

const std = @import("std");
const tacacs = @import("tacacs");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), tacacs.tacacs_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PacketType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.PacketType.authentication));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.PacketType.authorization));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.PacketType.accounting));
}

test "AuthenType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AuthenType.ascii));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AuthenType.pap));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AuthenType.chap));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tacacs.AuthenType.mschapv1));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tacacs.AuthenType.mschapv2));
}

test "AuthenAction encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AuthenAction.login));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AuthenAction.change_pass));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AuthenAction.send_auth));
}

test "AuthenStatus encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AuthenStatus.pass));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AuthenStatus.fail));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AuthenStatus.get_data));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tacacs.AuthenStatus.get_user));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tacacs.AuthenStatus.get_pass));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(tacacs.AuthenStatus.restart));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(tacacs.AuthenStatus.authen_error));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(tacacs.AuthenStatus.follow));
}

test "AuthorStatus encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AuthorStatus.pass_add));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AuthorStatus.pass_repl));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AuthorStatus.author_fail));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tacacs.AuthorStatus.author_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tacacs.AuthorStatus.author_follow));
}

test "AcctStatus encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AcctStatus.acct_success));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AcctStatus.acct_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AcctStatus.acct_follow));
}

test "AcctFlag encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.AcctFlag.start));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.AcctFlag.stop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.AcctFlag.watchdog));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tacacs.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tacacs.SessionState.authenticating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tacacs.SessionState.authorizing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tacacs.SessionState.active));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tacacs.SessionState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const secret = "shared-secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    try std.testing.expect(slot >= 0);
    defer tacacs.tacacs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_state(slot)); // Idle
}

test "create rejects empty secret" {
    const secret = "x";
    const slot = tacacs.tacacs_create(secret.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    tacacs.tacacs_destroy(-1);
    tacacs.tacacs_destroy(999);
}

// =========================================================================
// Authentication
// =========================================================================

test "authen_start transitions Idle -> Authenticating" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_authen_start(
        slot, 0, 0, user.ptr, user.len, port.ptr, port.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_state(slot)); // Authenticating
}

test "authen_start rejects invalid action" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_authen_start(
        slot, 99, 0, user.ptr, user.len, port.ptr, port.len,
    ));
}

test "authen_continue returns status" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);

    const data = "password123";
    const status = tacacs.tacacs_authen_continue(slot, data.ptr, data.len);
    try std.testing.expectEqual(@as(u8, 0), status); // pass
}

test "authen_status returns last status" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_authen_status(slot)); // pass
}

// =========================================================================
// Authorization
// =========================================================================

test "author_request transitions Authenticating -> Authorizing" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);

    const service = "shell";
    const status = tacacs.tacacs_author_request(slot, user.ptr, user.len, service.ptr, service.len);
    try std.testing.expectEqual(@as(u8, 0), status); // pass_add
    try std.testing.expectEqual(@as(u8, 2), tacacs.tacacs_state(slot)); // Authorizing
}

test "author_request rejects from Idle" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const service = "shell";
    const status = tacacs.tacacs_author_request(slot, user.ptr, user.len, service.ptr, service.len);
    try std.testing.expectEqual(@as(u8, 3), status); // author_error
}

// =========================================================================
// Accounting
// =========================================================================

test "acct_record transitions Authorizing -> Active" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);
    const service = "shell";
    _ = tacacs.tacacs_author_request(slot, user.ptr, user.len, service.ptr, service.len);

    const status = tacacs.tacacs_acct_record(slot, 0, user.ptr, user.len); // start
    try std.testing.expectEqual(@as(u8, 0), status); // acct_success
    try std.testing.expectEqual(@as(u8, 3), tacacs.tacacs_state(slot)); // Active
}

test "acct_record rejects invalid flag" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);
    const service = "shell";
    _ = tacacs.tacacs_author_request(slot, user.ptr, user.len, service.ptr, service.len);

    const status = tacacs.tacacs_acct_record(slot, 99, user.ptr, user.len);
    try std.testing.expectEqual(@as(u8, 1), status); // acct_error
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Active -> Closing" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "tty0";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);
    const service = "shell";
    _ = tacacs.tacacs_author_request(slot, user.ptr, user.len, service.ptr, service.len);
    _ = tacacs.tacacs_acct_record(slot, 0, user.ptr, user.len);

    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), tacacs.tacacs_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);

    const user = "admin";
    const port = "";
    _ = tacacs.tacacs_authen_start(slot, 0, 0, user.ptr, user.len, port.ptr, port.len);
    _ = tacacs.tacacs_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_state(slot)); // Idle
}

test "cleanup rejected from non-Closing state" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_cleanup(slot));
}

test "disconnect rejected from Idle" {
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    defer tacacs.tacacs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_disconnect(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "tacacs_can_transition matches Types.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(0, 1)); // Idle -> Authenticating
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(1, 2)); // Authenticating -> Authorizing
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(2, 3)); // Authorizing -> Active
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(1, 4)); // Authenticating -> Closing
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(2, 4)); // Authorizing -> Closing
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(3, 4)); // Active -> Closing
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_can_transition(4, 0)); // Closing -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_can_transition(0, 2)); // Idle -/-> Authorizing
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_can_transition(0, 3)); // Idle -/-> Active
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_can_transition(4, 1)); // Closing -/-> Authenticating
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_can_transition(3, 1)); // Active -/-> Authenticating
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), tacacs.tacacs_state(-1));
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), tacacs.tacacs_cleanup(-1));
}

// =========================================================================
// Session count
// =========================================================================

test "session_count tracks active sessions" {
    const initial = tacacs.tacacs_session_count();
    const secret = "secret";
    const slot = tacacs.tacacs_create(secret.ptr, secret.len);
    try std.testing.expectEqual(initial + 1, tacacs.tacacs_session_count());
    tacacs.tacacs_destroy(slot);
    try std.testing.expectEqual(initial, tacacs.tacacs_session_count());
}
