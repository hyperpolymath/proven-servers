// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-smtp protocol.
// Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig.
// Enum classes match Idris2 ABI tags exactly (SmtpABI.Types).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven SMTP server protocol.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenSmtp private constructor(private val slot: Int) : AutoCloseable {

    /** SMTP session state machine (tags 0-8). */
    public enum class SessionState(public val tag: Int) {
        CONNECTED(0), GREETED(1), AUTH_STARTED(2), AUTHENTICATED(3),
        MAIL_FROM(4), RCPT_TO(5), DATA(6), MESSAGE_RECEIVED(7), QUIT(8);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
        }
    }

    /** SMTP SASL authentication mechanisms (tags 0-3). */
    public enum class AuthMechanism(public val tag: Int) {
        PLAIN(0), LOGIN(1), CRAM_MD5(2), XOAUTH2(3);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): AuthMechanism? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun smtp_abi_version(): Int
        @JvmStatic external fun smtp_create_context(): Int
        @JvmStatic external fun smtp_destroy_context(slot: Int)
        @JvmStatic external fun smtp_get_state(slot: Int): Int
        @JvmStatic external fun smtp_get_reply_code(slot: Int): Int
        @JvmStatic external fun smtp_get_recipient_count(slot: Int): Int
        @JvmStatic external fun smtp_get_data_size(slot: Int): Int
        @JvmStatic external fun smtp_get_auth_mechanism(slot: Int): Int
        @JvmStatic external fun smtp_is_authenticated(slot: Int): Int
        @JvmStatic external fun smtp_is_tls_active(slot: Int): Int
        @JvmStatic external fun smtp_greet(slot: Int, isEhlo: Int): Int
        @JvmStatic external fun smtp_authenticate(slot: Int, mech: Int): Int
        @JvmStatic external fun smtp_auth_complete(slot: Int, success: Int): Int
        @JvmStatic external fun smtp_set_sender(slot: Int): Int
        @JvmStatic external fun smtp_add_recipient(slot: Int): Int
        @JvmStatic external fun smtp_start_data(slot: Int): Int
        @JvmStatic external fun smtp_append_data(slot: Int, len: Int): Int
        @JvmStatic external fun smtp_finish_data(slot: Int): Int
        @JvmStatic external fun smtp_reset(slot: Int): Int
        @JvmStatic external fun smtp_quit(slot: Int): Int
        @JvmStatic external fun smtp_enable_tls(slot: Int): Int
        @JvmStatic external fun smtp_can_transition(from: Int, to: Int): Int
    }

    override fun close() { smtp_destroy_context(slot) }

    public val state: SessionState? get() = SessionState.fromTag(smtp_get_state(slot))
    public val replyCode: Int get() = smtp_get_reply_code(slot)
    public val recipientCount: Int get() = smtp_get_recipient_count(slot)
    public val dataSize: Int get() = smtp_get_data_size(slot)
    public val authMechanism: AuthMechanism? get() = AuthMechanism.fromTag(smtp_get_auth_mechanism(slot))
    public val isAuthenticated: Boolean get() = smtp_is_authenticated(slot) == 1
    public val isTlsActive: Boolean get() = smtp_is_tls_active(slot) == 1

    /** HELO/EHLO. Transitions Connected -> Greeted. */
    public fun greet(ehlo: Boolean = true): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_greet(slot, if (ehlo) 1 else 0))
    }

    /** Begin AUTH exchange. Transitions Greeted -> AuthStarted. */
    public fun authenticate(mechanism: AuthMechanism): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_authenticate(slot, mechanism.tag))
    }

    /** Complete AUTH exchange. */
    public fun authComplete(success: Boolean): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_auth_complete(slot, if (success) 1 else 0))
    }

    /** MAIL FROM: set the sender. */
    public fun setSender(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_set_sender(slot))
    }

    /** RCPT TO: add a recipient. */
    public fun addRecipient(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_add_recipient(slot))
    }

    /** DATA: begin message body transfer. */
    public fun startData(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_start_data(slot))
    }

    /** Append data bytes to the message. */
    public fun appendData(length: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_append_data(slot, length))
    }

    /** Finish data transfer. */
    public fun finishData(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_finish_data(slot))
    }

    /** RSET: reset the mail transaction. */
    public fun reset(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_reset(slot))
    }

    /** QUIT: end the session. */
    public fun quit(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_quit(slot))
    }

    /** STARTTLS: enable TLS. */
    public fun enableTls(): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(smtp_enable_tls(slot))
    }

    public companion object {
        @JvmStatic public fun create(): Result<ProvenSmtp> = ProvenError.runCatching {
            ProvenSmtp(ProvenError.checkSlot(smtp_create_context()))
        }

        @JvmStatic public fun abiVersion(): Int = smtp_abi_version()

        @JvmStatic public fun canTransition(from: SessionState, to: SessionState): Boolean =
            smtp_can_transition(from.tag, to.tag) == 1
    }
}
