//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SMTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `SMTP.Command`          -- SMTP commands (RFC 5321 Section 4.1)
//// - `SMTP.Reply`            -- reply codes and categories (RFC 5321 Section 4.2)
//// - `SMTPABI.Layout`        -- C-ABI tag values for all types
//// - `SMTPABI.Transitions`   -- session state machine

// ===========================================================================
// SMTP Constants
// ===========================================================================

/// Standard SMTP port (RFC 5321).
pub const smtp_port = 25

/// SMTP submission port (RFC 6409).
pub const submission_port = 587

/// SMTPS (implicit TLS) port.
pub const smtps_port = 465

// ===========================================================================
// SmtpCommand (tags 0-11)
// ===========================================================================

/// SMTP protocol commands (RFC 5321).
///
/// Tag values match `SmtpCommandTag` in `SmtpABI.Layout`.
pub type SmtpCommand {
  /// HELO -- identify client (tag 0).
  Helo
  /// EHLO -- extended HELO (tag 1).
  Ehlo
  /// MAIL FROM -- specify sender (tag 2).
  MailFrom
  /// RCPT TO -- specify recipient (tag 3).
  RcptTo
  /// DATA -- begin message body (tag 4).
  Data
  /// QUIT -- close session (tag 5).
  SmtpQuit
  /// RSET -- reset transaction (tag 6).
  Rset
  /// NOOP -- no operation (tag 7).
  SmtpNoop
  /// VRFY -- verify address (tag 8).
  Vrfy
  /// EXPN -- expand mailing list (tag 9).
  Expn
  /// STARTTLS -- upgrade to TLS (tag 10).
  Starttls
  /// AUTH -- SASL authentication (tag 11).
  SmtpAuth
}

/// Convert a `SmtpCommand` to its C-ABI tag value.
pub fn command_to_int(cmd: SmtpCommand) -> Int {
  case cmd {
    Helo -> 0
    Ehlo -> 1
    MailFrom -> 2
    RcptTo -> 3
    Data -> 4
    SmtpQuit -> 5
    Rset -> 6
    SmtpNoop -> 7
    Vrfy -> 8
    Expn -> 9
    Starttls -> 10
    SmtpAuth -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(SmtpCommand, Nil) {
  case tag {
    0 -> Ok(Helo)
    1 -> Ok(Ehlo)
    2 -> Ok(MailFrom)
    3 -> Ok(RcptTo)
    4 -> Ok(Data)
    5 -> Ok(SmtpQuit)
    6 -> Ok(Rset)
    7 -> Ok(SmtpNoop)
    8 -> Ok(Vrfy)
    9 -> Ok(Expn)
    10 -> Ok(Starttls)
    11 -> Ok(SmtpAuth)
    _ -> Error(Nil)
  }
}

/// The SMTP command verb as a string.
pub fn command_verb(cmd: SmtpCommand) -> String {
  case cmd {
    Helo -> "HELO"
    Ehlo -> "EHLO"
    MailFrom -> "MAIL FROM"
    RcptTo -> "RCPT TO"
    Data -> "DATA"
    SmtpQuit -> "QUIT"
    Rset -> "RSET"
    SmtpNoop -> "NOOP"
    Vrfy -> "VRFY"
    Expn -> "EXPN"
    Starttls -> "STARTTLS"
    SmtpAuth -> "AUTH"
  }
}

/// Whether this command is part of the mail transaction envelope.
pub fn command_is_envelope(cmd: SmtpCommand) -> Bool {
  case cmd {
    MailFrom | RcptTo | Data -> True
    _ -> False
  }
}

// ===========================================================================
// ReplyCategory (tags 0-3)
// ===========================================================================

/// SMTP reply severity categories (RFC 5321 Section 4.2).
pub type ReplyCategory {
  /// Positive completion (2xx).
  Positive
  /// Positive intermediate (3xx).
  Intermediate
  /// Transient negative (4xx) -- retry may succeed.
  TransientNegative
  /// Permanent negative (5xx) -- do not retry.
  PermanentNegative
}

/// Convert a `ReplyCategory` to its C-ABI tag value.
pub fn reply_category_to_int(cat: ReplyCategory) -> Int {
  case cat {
    Positive -> 0
    Intermediate -> 1
    TransientNegative -> 2
    PermanentNegative -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn reply_category_from_int(tag: Int) -> Result(ReplyCategory, Nil) {
  case tag {
    0 -> Ok(Positive)
    1 -> Ok(Intermediate)
    2 -> Ok(TransientNegative)
    3 -> Ok(PermanentNegative)
    _ -> Error(Nil)
  }
}

/// Whether this category indicates success.
pub fn reply_category_is_success(cat: ReplyCategory) -> Bool {
  cat == Positive
}

/// Whether this category indicates an error.
pub fn reply_category_is_error(cat: ReplyCategory) -> Bool {
  case cat {
    TransientNegative | PermanentNegative -> True
    _ -> False
  }
}

// ===========================================================================
// ReplyCode (tags 0-16)
// ===========================================================================

/// SMTP reply codes (RFC 5321).
///
/// Tag values match `ReplyCode` in `SmtpABI.Types`.
pub type ReplyCode {
  /// 220 -- Service ready (tag 0).
  ServiceReady
  /// 221 -- Service closing (tag 1).
  ServiceClosing
  /// 250 -- Action OK (tag 2).
  ActionOk
  /// 251 -- Will forward (tag 3).
  WillForward
  /// 354 -- Start mail input (tag 4).
  StartMailInput
  /// 421 -- Service unavailable (tag 5).
  SmtpServiceUnavailable
  /// 450 -- Mailbox busy (tag 6).
  MailboxBusy
  /// 451 -- Local error (tag 7).
  LocalError
  /// 452 -- Insufficient storage (tag 8).
  InsufficientStorage
  /// 500 -- Syntax error (tag 9).
  SyntaxError
  /// 501 -- Parameter syntax error (tag 10).
  ParamSyntaxError
  /// 502 -- Not implemented (tag 11).
  SmtpNotImplemented
  /// 503 -- Bad sequence (tag 12).
  BadSequence
  /// 504 -- Parameter not implemented (tag 13).
  ParamNotImplemented
  /// 550 -- Mailbox unavailable (tag 14).
  MailboxUnavailable
  /// 553 -- Mailbox name invalid (tag 15).
  MailboxNameInvalid
  /// 554 -- Transaction failed (tag 16).
  TransactionFailed
}

/// Convert a `ReplyCode` to its C-ABI tag value.
pub fn reply_code_to_int(code: ReplyCode) -> Int {
  case code {
    ServiceReady -> 0
    ServiceClosing -> 1
    ActionOk -> 2
    WillForward -> 3
    StartMailInput -> 4
    SmtpServiceUnavailable -> 5
    MailboxBusy -> 6
    LocalError -> 7
    InsufficientStorage -> 8
    SyntaxError -> 9
    ParamSyntaxError -> 10
    SmtpNotImplemented -> 11
    BadSequence -> 12
    ParamNotImplemented -> 13
    MailboxUnavailable -> 14
    MailboxNameInvalid -> 15
    TransactionFailed -> 16
  }
}

/// Decode from a C-ABI tag value.
pub fn reply_code_from_int(tag: Int) -> Result(ReplyCode, Nil) {
  case tag {
    0 -> Ok(ServiceReady)
    1 -> Ok(ServiceClosing)
    2 -> Ok(ActionOk)
    3 -> Ok(WillForward)
    4 -> Ok(StartMailInput)
    5 -> Ok(SmtpServiceUnavailable)
    6 -> Ok(MailboxBusy)
    7 -> Ok(LocalError)
    8 -> Ok(InsufficientStorage)
    9 -> Ok(SyntaxError)
    10 -> Ok(ParamSyntaxError)
    11 -> Ok(SmtpNotImplemented)
    12 -> Ok(BadSequence)
    13 -> Ok(ParamNotImplemented)
    14 -> Ok(MailboxUnavailable)
    15 -> Ok(MailboxNameInvalid)
    16 -> Ok(TransactionFailed)
    _ -> Error(Nil)
  }
}

/// The numeric SMTP reply code (e.g. 220, 250).
pub fn reply_code_numeric(code: ReplyCode) -> Int {
  case code {
    ServiceReady -> 220
    ServiceClosing -> 221
    ActionOk -> 250
    WillForward -> 251
    StartMailInput -> 354
    SmtpServiceUnavailable -> 421
    MailboxBusy -> 450
    LocalError -> 451
    InsufficientStorage -> 452
    SyntaxError -> 500
    ParamSyntaxError -> 501
    SmtpNotImplemented -> 502
    BadSequence -> 503
    ParamNotImplemented -> 504
    MailboxUnavailable -> 550
    MailboxNameInvalid -> 553
    TransactionFailed -> 554
  }
}

/// The reply category for a given reply code.
pub fn reply_code_category(code: ReplyCode) -> ReplyCategory {
  let numeric = reply_code_numeric(code)
  case numeric / 100 {
    2 -> Positive
    3 -> Intermediate
    4 -> TransientNegative
    _ -> PermanentNegative
  }
}

// ===========================================================================
// AuthMechanism (tags 0-3)
// ===========================================================================

/// SMTP SASL authentication mechanisms (RFC 4954).
pub type AuthMechanism {
  /// PLAIN (RFC 4616).
  Plain
  /// LOGIN (non-standard but widely used).
  Login
  /// CRAM-MD5 (RFC 2195).
  CramMd5
  /// XOAUTH2 (Google extension).
  Xoauth2
}

/// Convert an `AuthMechanism` to its C-ABI tag value.
pub fn auth_mechanism_to_int(mech: AuthMechanism) -> Int {
  case mech {
    Plain -> 0
    Login -> 1
    CramMd5 -> 2
    Xoauth2 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_mechanism_from_int(tag: Int) -> Result(AuthMechanism, Nil) {
  case tag {
    0 -> Ok(Plain)
    1 -> Ok(Login)
    2 -> Ok(CramMd5)
    3 -> Ok(Xoauth2)
    _ -> Error(Nil)
  }
}

/// The SASL mechanism name string.
pub fn auth_mechanism_name(mech: AuthMechanism) -> String {
  case mech {
    Plain -> "PLAIN"
    Login -> "LOGIN"
    CramMd5 -> "CRAM-MD5"
    Xoauth2 -> "XOAUTH2"
  }
}

/// Whether this mechanism sends credentials in cleartext (requires TLS).
pub fn auth_mechanism_requires_tls(mech: AuthMechanism) -> Bool {
  case mech {
    Plain | Login -> True
    _ -> False
  }
}

// ===========================================================================
// SmtpExtension (tags 0-6)
// ===========================================================================

/// ESMTP extensions advertised via EHLO response.
pub type SmtpExtension {
  ExtSize
  ExtPipelining
  ExtEightBitMime
  ExtStarttls
  ExtAuth
  ExtDsn
  ExtChunking
}

/// Convert a `SmtpExtension` to its C-ABI tag value.
pub fn extension_to_int(ext: SmtpExtension) -> Int {
  case ext {
    ExtSize -> 0
    ExtPipelining -> 1
    ExtEightBitMime -> 2
    ExtStarttls -> 3
    ExtAuth -> 4
    ExtDsn -> 5
    ExtChunking -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn extension_from_int(tag: Int) -> Result(SmtpExtension, Nil) {
  case tag {
    0 -> Ok(ExtSize)
    1 -> Ok(ExtPipelining)
    2 -> Ok(ExtEightBitMime)
    3 -> Ok(ExtStarttls)
    4 -> Ok(ExtAuth)
    5 -> Ok(ExtDsn)
    6 -> Ok(ExtChunking)
    _ -> Error(Nil)
  }
}

/// The ESMTP keyword for this extension.
pub fn extension_keyword(ext: SmtpExtension) -> String {
  case ext {
    ExtSize -> "SIZE"
    ExtPipelining -> "PIPELINING"
    ExtEightBitMime -> "8BITMIME"
    ExtStarttls -> "STARTTLS"
    ExtAuth -> "AUTH"
    ExtDsn -> "DSN"
    ExtChunking -> "CHUNKING"
  }
}

// ===========================================================================
// SmtpSessionState (tags 0-8)
// ===========================================================================

/// SMTP session state machine (RFC 5321).
pub type SmtpSessionState {
  SmtpConnected
  SmtpGreeted
  SmtpAuthStarted
  SmtpAuthenticated
  SmtpMailFrom
  SmtpRcptTo
  SmtpData
  SmtpMessageReceived
  SmtpSessionQuit
}

/// Convert a `SmtpSessionState` to its C-ABI tag value.
pub fn session_state_to_int(state: SmtpSessionState) -> Int {
  case state {
    SmtpConnected -> 0
    SmtpGreeted -> 1
    SmtpAuthStarted -> 2
    SmtpAuthenticated -> 3
    SmtpMailFrom -> 4
    SmtpRcptTo -> 5
    SmtpData -> 6
    SmtpMessageReceived -> 7
    SmtpSessionQuit -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SmtpSessionState, Nil) {
  case tag {
    0 -> Ok(SmtpConnected)
    1 -> Ok(SmtpGreeted)
    2 -> Ok(SmtpAuthStarted)
    3 -> Ok(SmtpAuthenticated)
    4 -> Ok(SmtpMailFrom)
    5 -> Ok(SmtpRcptTo)
    6 -> Ok(SmtpData)
    7 -> Ok(SmtpMessageReceived)
    8 -> Ok(SmtpSessionQuit)
    _ -> Error(Nil)
  }
}

/// Validate whether an SMTP session state transition is allowed.
pub fn can_transition(
  from: SmtpSessionState,
  to: SmtpSessionState,
) -> Bool {
  case from, to {
    SmtpConnected, SmtpGreeted -> True
    SmtpGreeted, SmtpAuthStarted -> True
    SmtpGreeted, SmtpMailFrom -> True
    SmtpAuthStarted, SmtpAuthenticated -> True
    SmtpAuthStarted, SmtpGreeted -> True
    SmtpAuthenticated, SmtpMailFrom -> True
    SmtpMailFrom, SmtpRcptTo -> True
    SmtpRcptTo, SmtpRcptTo -> True
    SmtpRcptTo, SmtpData -> True
    SmtpData, SmtpMessageReceived -> True
    SmtpMessageReceived, SmtpMailFrom -> True
    _, SmtpSessionQuit -> True
    _, _ -> False
  }
}
