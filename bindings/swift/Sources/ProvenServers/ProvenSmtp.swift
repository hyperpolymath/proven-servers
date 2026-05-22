// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-smtp protocol.
// Wraps the C-ABI functions from protocols/proven-smtp/ffi/zig/src/smtp.zig.
// Enums match Idris2 ABI tags exactly (SmtpABI.Types).

import Foundation

// MARK: - C interop declarations

@_silgen_name("smtp_abi_version")       private func smtp_abi_version() -> UInt32
@_silgen_name("smtp_create_context")    private func smtp_create_context() -> Int32
@_silgen_name("smtp_destroy_context")   private func smtp_destroy_context(_ slot: Int32)
@_silgen_name("smtp_get_state")         private func smtp_get_state(_ slot: Int32) -> UInt8
@_silgen_name("smtp_get_reply_code")    private func smtp_get_reply_code(_ slot: Int32) -> UInt8
@_silgen_name("smtp_get_recipient_count") private func smtp_get_recipient_count(_ slot: Int32) -> UInt8
@_silgen_name("smtp_get_data_size")     private func smtp_get_data_size(_ slot: Int32) -> UInt32
@_silgen_name("smtp_get_auth_mechanism") private func smtp_get_auth_mechanism(_ slot: Int32) -> UInt8
@_silgen_name("smtp_is_authenticated")  private func smtp_is_authenticated(_ slot: Int32) -> UInt8
@_silgen_name("smtp_is_tls_active")     private func smtp_is_tls_active(_ slot: Int32) -> UInt8
@_silgen_name("smtp_greet")             private func smtp_greet(_ slot: Int32, _ isEhlo: UInt8) -> UInt8
@_silgen_name("smtp_authenticate")      private func smtp_authenticate(_ slot: Int32, _ mech: UInt8) -> UInt8
@_silgen_name("smtp_auth_complete")     private func smtp_auth_complete(_ slot: Int32, _ success: UInt8) -> UInt8
@_silgen_name("smtp_set_sender")        private func smtp_set_sender(_ slot: Int32) -> UInt8
@_silgen_name("smtp_add_recipient")     private func smtp_add_recipient(_ slot: Int32) -> UInt8
@_silgen_name("smtp_start_data")        private func smtp_start_data(_ slot: Int32) -> UInt8
@_silgen_name("smtp_append_data")       private func smtp_append_data(_ slot: Int32, _ len: UInt32) -> UInt8
@_silgen_name("smtp_finish_data")       private func smtp_finish_data(_ slot: Int32) -> UInt8
@_silgen_name("smtp_reset")             private func smtp_reset(_ slot: Int32) -> UInt8
@_silgen_name("smtp_quit")              private func smtp_quit(_ slot: Int32) -> UInt8
@_silgen_name("smtp_enable_tls")        private func smtp_enable_tls(_ slot: Int32) -> UInt8
@_silgen_name("smtp_can_transition")    private func smtp_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// SMTP session state machine (SmtpABI.Types, tags 0-8).
public enum SmtpSessionState: Int, CaseIterable, Sendable {
    /// TCP connection established, awaiting greeting.
    case connected = 0
    /// EHLO/HELO completed, session identified.
    case greeted = 1
    /// AUTH command sent, awaiting challenge/response.
    case authStarted = 2
    /// Authentication completed successfully.
    case authenticated = 3
    /// MAIL FROM accepted, sender specified.
    case mailFrom = 4
    /// At least one RCPT TO accepted.
    case rcptTo = 5
    /// DATA command accepted, receiving message body.
    case data = 6
    /// Message body received and accepted.
    case messageReceived = 7
    /// QUIT sent, session ending.
    case quit = 8

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// SMTP SASL authentication mechanisms (SmtpABI.Types, tags 0-3).
public enum SmtpAuthMechanism: Int, CaseIterable, Sendable {
    /// PLAIN (RFC 4616).
    case plain = 0
    /// LOGIN (non-standard but widely used).
    case login = 1
    /// CRAM-MD5 (RFC 2195).
    case cramMd5 = 2
    /// XOAUTH2 (Google extension).
    case xoauth2 = 3

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven SMTP server protocol FFI.
///
/// Manages an opaque SMTP session context slot in the Zig FFI pool.
/// The context is automatically destroyed when this object is deallocated.
public final class ProvenSmtp: @unchecked Sendable {

    private let slot: Int32

    /// Create a new SMTP session in the Connected state.
    ///
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init() throws {
        self.slot = try ProvenError.checkSlot(smtp_create_context())
    }

    deinit { smtp_destroy_context(slot) }

    /// The ABI version of the linked SMTP library.
    public static var abiVersion: UInt32 { smtp_abi_version() }

    /// The current session state.
    public var state: SmtpSessionState? { SmtpSessionState(tag: smtp_get_state(slot)) }

    /// The last reply code tag (0-16, maps to SMTP reply codes).
    public var replyCode: UInt8 { smtp_get_reply_code(slot) }

    /// The number of recipients in the current transaction.
    public var recipientCount: UInt8 { smtp_get_recipient_count(slot) }

    /// The accumulated message data size in bytes.
    public var dataSize: UInt32 { smtp_get_data_size(slot) }

    /// The current AUTH mechanism, or `nil` if unset.
    public var authMechanism: SmtpAuthMechanism? {
        SmtpAuthMechanism(tag: smtp_get_auth_mechanism(slot))
    }

    /// Whether the session is authenticated.
    public var isAuthenticated: Bool { smtp_is_authenticated(slot) == 1 }

    /// Whether TLS is active.
    public var isTlsActive: Bool { smtp_is_tls_active(slot) == 1 }

    /// HELO/EHLO: greet the server. Transitions Connected -> Greeted.
    ///
    /// - Parameter ehlo: Use EHLO (`true`) or HELO (`false`).
    /// - Throws: ``ProvenError/invalidState`` if not in Connected state.
    public func greet(ehlo: Bool = true) throws {
        try ProvenError.checkStatus(smtp_greet(slot, ehlo ? 1 : 0))
    }

    /// Begin AUTH exchange. Transitions Greeted -> AuthStarted.
    ///
    /// - Parameter mechanism: The SASL authentication mechanism.
    /// - Throws: ``ProvenError/invalidState`` if not in Greeted state.
    public func authenticate(mechanism: SmtpAuthMechanism) throws {
        try ProvenError.checkStatus(smtp_authenticate(slot, mechanism.tag))
    }

    /// Complete AUTH exchange.
    ///
    /// - Parameter success: `true` transitions AuthStarted -> Authenticated;
    ///   `false` transitions AuthStarted -> Greeted.
    /// - Throws: ``ProvenError/invalidState`` if not in AuthStarted state.
    public func authComplete(success: Bool) throws {
        try ProvenError.checkStatus(smtp_auth_complete(slot, success ? 1 : 0))
    }

    /// MAIL FROM: set the sender. Transitions Greeted/Authenticated -> MailFrom.
    public func setSender() throws {
        try ProvenError.checkStatus(smtp_set_sender(slot))
    }

    /// RCPT TO: add a recipient. Transitions MailFrom/RcptTo -> RcptTo.
    public func addRecipient() throws {
        try ProvenError.checkStatus(smtp_add_recipient(slot))
    }

    /// DATA: begin message body transfer. Transitions RcptTo -> Data.
    public func startData() throws {
        try ProvenError.checkStatus(smtp_start_data(slot))
    }

    /// Append data bytes to the message.
    ///
    /// - Parameter length: Number of bytes being appended.
    public func appendData(length: UInt32) throws {
        try ProvenError.checkStatus(smtp_append_data(slot, length))
    }

    /// Finish data transfer. Transitions Data -> MessageReceived.
    public func finishData() throws {
        try ProvenError.checkStatus(smtp_finish_data(slot))
    }

    /// RSET: reset the mail transaction.
    public func reset() throws {
        try ProvenError.checkStatus(smtp_reset(slot))
    }

    /// QUIT: end the session.
    public func quit() throws {
        try ProvenError.checkStatus(smtp_quit(slot))
    }

    /// STARTTLS: enable TLS on the connection.
    public func enableTls() throws {
        try ProvenError.checkStatus(smtp_enable_tls(slot))
    }

    /// Stateless query: check whether a session state transition is valid.
    public static func canTransition(from: SmtpSessionState, to: SmtpSessionState) -> Bool {
        smtp_can_transition(from.tag, to.tag) == 1
    }
}
