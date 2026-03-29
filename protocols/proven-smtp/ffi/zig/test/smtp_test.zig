// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// smtp_test.zig -- Integration tests for proven-smtp FFI.

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

test "SmtpCommandTag encoding matches Layout.idr (12 tags)" {
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

test "ReplyCode encoding matches Layout.idr (17 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.ReplyCode.service_ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.ReplyCode.action_ok));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.ReplyCode.start_mail_input));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(smtp.ReplyCode.syntax_error));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(smtp.ReplyCode.bad_sequence));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(smtp.ReplyCode.transaction_failed));
}

test "AuthMechTag encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.AuthMechTag.plain));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.AuthMechTag.login));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.AuthMechTag.cram_md5));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.AuthMechTag.xoauth2));
}

test "SmtpExtension encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.SmtpExtension.size));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.SmtpExtension.pipelining));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.SmtpExtension.eight_bit_mime));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.SmtpExtension.starttls));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smtp.SmtpExtension.auth));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smtp.SmtpExtension.dsn));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smtp.SmtpExtension.chunking));
}

test "SmtpSessionState encoding matches Layout.idr (9 tags)" {
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

test "ReplyCategory encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smtp.ReplyCategory.positive));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smtp.ReplyCategory.intermediate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smtp.ReplyCategory.transient_negative));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smtp.ReplyCategory.permanent_negative));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const slot = smtp.smtp_create_context();
    try std.testing.expect(slot >= 0);
    defer smtp.smtp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_get_state(slot)); // connected
}

test "destroy is safe with invalid slot" {
    smtp.smtp_destroy_context(-1);
    smtp.smtp_destroy_context(999);
}

// =========================================================================
// Full SMTP lifecycle: Connected -> Greeted -> MailFrom -> RcptTo ->
//                      Data -> MessageReceived -> Quit
// =========================================================================

test "full lifecycle without auth (relay path)" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    // Connected -> Greeted (EHLO)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_get_state(slot));

    // Greeted -> MailFrom
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 4), smtp.smtp_get_state(slot));

    // MailFrom -> RcptTo
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 5), smtp.smtp_get_state(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_get_recipient_count(slot));

    // RcptTo -> Data
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));
    try std.testing.expectEqual(@as(u8, 6), smtp.smtp_get_state(slot));

    // Append some data
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_append_data(slot, 1024));
    try std.testing.expectEqual(@as(u32, 1024), smtp.smtp_get_data_size(slot));

    // Data -> MessageReceived
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_finish_data(slot));
    try std.testing.expectEqual(@as(u8, 7), smtp.smtp_get_state(slot));

    // MessageReceived -> Quit
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_quit(slot));
    try std.testing.expectEqual(@as(u8, 8), smtp.smtp_get_state(slot));
}

// =========================================================================
// AUTH flow
// =========================================================================

test "full lifecycle with AUTH PLAIN" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    // Greet
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));

    // AUTH PLAIN (mech=0)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 0));
    try std.testing.expectEqual(@as(u8, 2), smtp.smtp_get_state(slot)); // auth_started
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_get_auth_mechanism(slot));

    // Auth succeeds
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_auth_complete(slot, 1));
    try std.testing.expectEqual(@as(u8, 3), smtp.smtp_get_state(slot)); // authenticated
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_is_authenticated(slot));

    // Mail flow works from authenticated
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_finish_data(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_quit(slot));
}

test "AUTH failure returns to Greeted" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 1)); // LOGIN
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_auth_complete(slot, 0)); // failure
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_get_state(slot)); // greeted
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_is_authenticated(slot));
}

test "AUTH rejected with invalid mechanism" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_authenticate(slot, 99)); // invalid
}

test "AUTH CRAM_MD5 mechanism tag" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 2)); // CRAM-MD5
    try std.testing.expectEqual(@as(u8, 2), smtp.smtp_get_auth_mechanism(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_auth_complete(slot, 1));
    try std.testing.expectEqual(@as(u8, 3), smtp.smtp_get_state(slot));
}

test "AUTH XOAUTH2 mechanism tag" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 3)); // XOAUTH2
    try std.testing.expectEqual(@as(u8, 3), smtp.smtp_get_auth_mechanism(slot));
}

// =========================================================================
// STARTTLS
// =========================================================================

test "STARTTLS enables TLS from Greeted" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_is_tls_active(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_enable_tls(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_is_tls_active(slot));
}

test "STARTTLS rejected if already active" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_enable_tls(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_enable_tls(slot)); // rejected
}

test "STARTTLS rejected from Connected" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_enable_tls(slot)); // must greet first
}

// =========================================================================
// Multiple recipients
// =========================================================================

test "multiple recipients tracked correctly" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));

    // Add 5 recipients
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    }
    try std.testing.expectEqual(@as(u8, 5), smtp.smtp_get_recipient_count(slot));
}

// =========================================================================
// DATA accumulation
// =========================================================================

test "data accumulates across multiple appends" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_append_data(slot, 500));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_append_data(slot, 300));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_append_data(slot, 200));
    try std.testing.expectEqual(@as(u32, 1000), smtp.smtp_get_data_size(slot));
}

test "data rejects overflow beyond 10 MiB" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));

    // Append 10 MiB
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_append_data(slot, 10_485_760));
    // One more byte should fail
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_append_data(slot, 1));
}

// =========================================================================
// RSET
// =========================================================================

test "RSET from MailFrom returns to Greeted" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_reset(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_get_state(slot)); // greeted
}

test "RSET from MessageReceived preserves auth" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_auth_complete(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_finish_data(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_reset(slot));
    // Should return to Authenticated since we authenticated earlier
    try std.testing.expectEqual(@as(u8, 3), smtp.smtp_get_state(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_is_authenticated(slot));
}

test "RSET clears recipient count and data size" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 2), smtp.smtp_get_recipient_count(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_get_recipient_count(slot));
}

// =========================================================================
// Impossibility tests (invalid transitions)
// =========================================================================

test "cannot DATA before RCPT_TO (from MailFrom)" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    // Should be rejected: no recipients yet
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_start_data(slot));
    try std.testing.expectEqual(@as(u8, 4), smtp.smtp_get_state(slot)); // still MailFrom
}

test "cannot AUTH after already authenticated" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_authenticate(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_auth_complete(slot, 1));
    // Should be rejected: already authenticated, state is Authenticated not Greeted
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_authenticate(slot, 0));
}

test "cannot MAIL FROM from Connected (must greet first)" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_set_sender(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_get_state(slot)); // still connected
}

test "cannot greet twice" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    // Second greet rejected (already in Greeted state)
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_greet(slot, 1));
}

test "cannot QUIT from Data state" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_add_recipient(slot));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_start_data(slot));
    // Cannot QUIT during DATA phase
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_quit(slot));
}

test "cannot advance from Quit (terminal)" {
    const slot = smtp.smtp_create_context();
    defer smtp.smtp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_quit(slot));
    // All operations should be rejected from Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_greet(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_set_sender(slot));
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_quit(slot)); // can't quit twice
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "smtp_can_transition matches Transitions.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(0, 1)); // Connected -> Greeted
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(1, 2)); // Greeted -> AuthStarted
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(2, 3)); // AuthStarted -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(2, 1)); // AuthStarted -> Greeted (failure)
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(3, 4)); // Authenticated -> MailFrom
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(1, 4)); // Greeted -> MailFrom (relay)
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(4, 5)); // MailFrom -> RcptTo
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(5, 5)); // RcptTo -> RcptTo
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(5, 6)); // RcptTo -> Data
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(6, 7)); // Data -> MessageReceived
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(7, 1)); // MessageReceived -> Greeted
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(7, 3)); // MessageReceived -> Authenticated

    // RSET edges
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(4, 1)); // MailFrom -> Greeted
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(5, 1)); // RcptTo -> Greeted

    // QUIT edges
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(0, 8)); // Connected -> Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(1, 8)); // Greeted -> Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(3, 8)); // Authenticated -> Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(4, 8)); // MailFrom -> Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(5, 8)); // RcptTo -> Quit
    try std.testing.expectEqual(@as(u8, 1), smtp.smtp_can_transition(7, 8)); // MessageReceived -> Quit

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(8, 0)); // Quit -> Connected (terminal!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(8, 1)); // Quit -> Greeted (terminal!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(0, 4)); // Connected -> MailFrom (skip!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(4, 6)); // MailFrom -> Data (no RCPT_TO!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(3, 2)); // Authenticated -> AuthStarted (re-auth!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(7, 6)); // MessageReceived -> Data (backwards!)
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_can_transition(0, 6)); // Connected -> Data (skip everything!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 8), smtp.smtp_get_state(-1)); // quit fallback
    try std.testing.expectEqual(@as(u8, 255), smtp.smtp_get_reply_code(-1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_get_recipient_count(-1));
    try std.testing.expectEqual(@as(u32, 0), smtp.smtp_get_data_size(-1));
    try std.testing.expectEqual(@as(u8, 255), smtp.smtp_get_auth_mechanism(-1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_is_authenticated(-1));
    try std.testing.expectEqual(@as(u8, 0), smtp.smtp_is_tls_active(-1));
}
