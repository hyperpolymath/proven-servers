// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-smtp protocol.
// Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>SMTP session states (tags 0-8).</summary>
    public enum SmtpSessionState : byte
    {
        Connected = 0, Greeted = 1, AuthStarted = 2, Authenticated = 3,
        MailFrom = 4, RcptTo = 5, Data = 6, MessageReceived = 7, Quit = 8
    }

    /// <summary>SASL authentication mechanisms (tags 0-3).</summary>
    public enum SmtpAuthMechanism : byte
    {
        Plain = 0, Login = 1, CramMd5 = 2, Xoauth2 = 3
    }

    /// <summary>
    /// C# bindings for the proven SMTP server protocol (RFC 5321).
    /// Lifecycle: Connected -> Greeted -> [Auth] -> MailFrom -> RcptTo -> Data -> MessageReceived -> Quit.
    /// </summary>
    public static class ProvenSmtp
    {
        private const string Lib = "proven_smtp";

        [DllImport(Lib)] private static extern uint smtp_abi_version();
        [DllImport(Lib)] private static extern int smtp_create_context();
        [DllImport(Lib)] private static extern void smtp_destroy_context(int slot);
        [DllImport(Lib)] private static extern byte smtp_get_state(int slot);
        [DllImport(Lib)] private static extern byte smtp_get_reply_code(int slot);
        [DllImport(Lib)] private static extern byte smtp_get_recipient_count(int slot);
        [DllImport(Lib)] private static extern uint smtp_get_data_size(int slot);
        [DllImport(Lib)] private static extern byte smtp_get_auth_mechanism(int slot);
        [DllImport(Lib)] private static extern byte smtp_is_authenticated(int slot);
        [DllImport(Lib)] private static extern byte smtp_is_tls_active(int slot);
        [DllImport(Lib)] private static extern byte smtp_greet(int slot, byte isEhlo);
        [DllImport(Lib)] private static extern byte smtp_authenticate(int slot, byte mech);
        [DllImport(Lib)] private static extern byte smtp_auth_complete(int slot, byte success);
        [DllImport(Lib)] private static extern byte smtp_set_sender(int slot);
        [DllImport(Lib)] private static extern byte smtp_add_recipient(int slot);
        [DllImport(Lib)] private static extern byte smtp_start_data(int slot);
        [DllImport(Lib)] private static extern byte smtp_append_data(int slot, uint len);
        [DllImport(Lib)] private static extern byte smtp_finish_data(int slot);
        [DllImport(Lib)] private static extern byte smtp_reset(int slot);
        [DllImport(Lib)] private static extern byte smtp_quit(int slot);
        [DllImport(Lib)] private static extern byte smtp_enable_tls(int slot);
        [DllImport(Lib)] private static extern byte smtp_can_transition(byte from, byte to);

        public static uint AbiVersion() => smtp_abi_version();

        public static int CreateContext() => ProvenError.CheckSlot(smtp_create_context());
        public static void DestroyContext(int slot) => smtp_destroy_context(slot);

        public static SmtpSessionState? GetState(int slot)
        {
            byte tag = smtp_get_state(slot);
            return tag <= 8 ? (SmtpSessionState)tag : null;
        }

        public static byte GetReplyCode(int slot) => smtp_get_reply_code(slot);
        public static byte GetRecipientCount(int slot) => smtp_get_recipient_count(slot);
        public static uint GetDataSize(int slot) => smtp_get_data_size(slot);

        public static SmtpAuthMechanism? GetAuthMechanism(int slot)
        {
            byte tag = smtp_get_auth_mechanism(slot);
            return tag <= 3 ? (SmtpAuthMechanism)tag : null;
        }

        public static bool IsAuthenticated(int slot) => smtp_is_authenticated(slot) == 1;
        public static bool IsTlsActive(int slot) => smtp_is_tls_active(slot) == 1;

        /// <summary>HELO/EHLO. Transitions Connected -> Greeted.</summary>
        /// <param name="ehlo">true for EHLO, false for HELO.</param>
        public static void Greet(int slot, bool ehlo) =>
            ProvenError.CheckStatus(smtp_greet(slot, (byte)(ehlo ? 1 : 0)));

        /// <summary>Begin AUTH exchange. Transitions Greeted -> AuthStarted.</summary>
        public static void Authenticate(int slot, SmtpAuthMechanism mechanism) =>
            ProvenError.CheckStatus(smtp_authenticate(slot, (byte)mechanism));

        /// <summary>Complete AUTH. success=true -> Authenticated, false -> Greeted.</summary>
        public static void AuthComplete(int slot, bool success) =>
            ProvenError.CheckStatus(smtp_auth_complete(slot, (byte)(success ? 1 : 0)));

        /// <summary>MAIL FROM. Transitions Greeted/Authenticated -> MailFrom.</summary>
        public static void SetSender(int slot) => ProvenError.CheckStatus(smtp_set_sender(slot));

        /// <summary>RCPT TO. Transitions MailFrom/RcptTo -> RcptTo.</summary>
        public static void AddRecipient(int slot) => ProvenError.CheckStatus(smtp_add_recipient(slot));

        /// <summary>DATA. Transitions RcptTo -> Data.</summary>
        public static void StartData(int slot) => ProvenError.CheckStatus(smtp_start_data(slot));

        /// <summary>Append data bytes.</summary>
        public static void AppendData(int slot, uint len) =>
            ProvenError.CheckStatus(smtp_append_data(slot, len));

        /// <summary>Finish data (end-of-data). Transitions Data -> MessageReceived.</summary>
        public static void FinishData(int slot) => ProvenError.CheckStatus(smtp_finish_data(slot));

        /// <summary>RSET. Returns to Greeted or Authenticated.</summary>
        public static void Reset(int slot) => ProvenError.CheckStatus(smtp_reset(slot));

        /// <summary>QUIT. Transitions to Quit.</summary>
        public static void Quit(int slot) => ProvenError.CheckStatus(smtp_quit(slot));

        /// <summary>STARTTLS. Enable TLS.</summary>
        public static void EnableTls(int slot) => ProvenError.CheckStatus(smtp_enable_tls(slot));

        public static bool CanTransition(SmtpSessionState from, SmtpSessionState to) =>
            smtp_can_transition((byte)from, (byte)to) == 1;
    }
}
