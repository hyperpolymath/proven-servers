// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-smtp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const smtp = @import("smtp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), smtp.smtp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SmtpCommandTag encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.SmtpCommandTag.helo));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.SmtpCommandTag.ehlo));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.SmtpCommandTag.mail_from));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.SmtpCommandTag.rcpt_to));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.SmtpCommandTag.data));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smtp.SmtpCommandTag.quit));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smtp.SmtpCommandTag.rset));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(smtp.SmtpCommandTag.noop));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(smtp.SmtpCommandTag.vrfy));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(smtp.SmtpCommandTag.expn));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(smtp.SmtpCommandTag.starttls));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(smtp.SmtpCommandTag.auth));
}

test "ReplyCategory encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.ReplyCategory.positive));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.ReplyCategory.intermediate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.ReplyCategory.transient_negative));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.ReplyCategory.permanent_negative));
}

test "ReplyCode encoding matches Types.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.ReplyCode.service_ready));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.ReplyCode.service_closing));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.ReplyCode.action_ok));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.ReplyCode.will_forward));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.ReplyCode.start_mail_input));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smtp.ReplyCode.service_unavailable));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smtp.ReplyCode.mailbox_busy));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(smtp.ReplyCode.local_error));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(smtp.ReplyCode.insufficient_storage));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(smtp.ReplyCode.syntax_error));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(smtp.ReplyCode.param_syntax_error));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(smtp.ReplyCode.not_implemented));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(smtp.ReplyCode.bad_sequence));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(smtp.ReplyCode.param_not_implemented));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(smtp.ReplyCode.mailbox_unavailable));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(smtp.ReplyCode.mailbox_name_invalid));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(smtp.ReplyCode.transaction_failed));
}

test "AuthMechTag encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.AuthMechTag.plain));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.AuthMechTag.login));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.AuthMechTag.cram_md5));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.AuthMechTag.xoauth2));
}

test "SmtpExtension encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.SmtpExtension.size));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.SmtpExtension.pipelining));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.SmtpExtension.eight_bit_mime));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.SmtpExtension.starttls));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.SmtpExtension.auth));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smtp.SmtpExtension.dsn));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smtp.SmtpExtension.chunking));
}

test "SmtpSessionState encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.SmtpSessionState.connected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.SmtpSessionState.greeted));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.SmtpSessionState.auth_started));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.SmtpSessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.SmtpSessionState.mail_from));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smtp.SmtpSessionState.rcpt_to));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smtp.SmtpSessionState.data));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(smtp.SmtpSessionState.message_received));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(smtp.SmtpSessionState.quit));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = smtp.smtp_create_context();
    try std.testing.expect(slot >= 0);
    defer smtp.smtp_destroy_context(slot);
    const state = smtp.smtp_get_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    smtp.smtp_destroy_context(-1);
    smtp.smtp_destroy_context(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = smtp.smtp_get_state(-1);
    _ = smtp.smtp_get_state(-1);
    _ = smtp.smtp_get_reply_code(-1);
    _ = smtp.smtp_get_recipient_count(-1);
}

