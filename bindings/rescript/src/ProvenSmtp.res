// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - SMTP.Command           -- SMTP commands (RFC 5321 Section 4.1)
// - SMTP.Reply             -- reply codes and categories (RFC 5321 Section 4.2)
// - SMTPABI.Layout         -- C-ABI tag values for all types
// - SMTPABI.Transitions    -- session state machine with impossibility proofs
//
// All tag values match smtpCommandTagToTag, replyCodeToTag, etc. in
// SMTPABI.Layout exactly.

// ===========================================================================
// SMTP Command Tag (SMTPABI.Layout.SmtpCommandTag, tags 0-11)
// ===========================================================================

/// SMTP command verbs as a flat enum for ABI transport.
/// String parameters (domain, path) are carried separately.
/// Matches SmtpCommandTag in SMTPABI.Layout.
type commandTag =
  | @as(0) Helo
  | @as(1) Ehlo
  | @as(2) MailFrom
  | @as(3) RcptTo
  | @as(4) Data
  | @as(5) Quit
  | @as(6) Rset
  | @as(7) Noop
  | @as(8) Vrfy
  | @as(9) Expn
  | @as(10) Starttls
  | @as(11) Auth

/// Decode from C-ABI tag value.
let commandTagFromTag = (tag: int): option<commandTag> =>
  switch tag {
  | 0 => Some(Helo)
  | 1 => Some(Ehlo)
  | 2 => Some(MailFrom)
  | 3 => Some(RcptTo)
  | 4 => Some(Data)
  | 5 => Some(Quit)
  | 6 => Some(Rset)
  | 7 => Some(Noop)
  | 8 => Some(Vrfy)
  | 9 => Some(Expn)
  | 10 => Some(Starttls)
  | 11 => Some(Auth)
  | _ => None
  }

/// Encode to C-ABI tag value.
let commandTagToTag = (cmd: commandTag): int =>
  switch cmd {
  | Helo => 0
  | Ehlo => 1
  | MailFrom => 2
  | RcptTo => 3
  | Data => 4
  | Quit => 5
  | Rset => 6
  | Noop => 7
  | Vrfy => 8
  | Expn => 9
  | Starttls => 10
  | Auth => 11
  }

/// SMTP verb keyword string.
let commandTagVerb = (cmd: commandTag): string =>
  switch cmd {
  | Helo => "HELO"
  | Ehlo => "EHLO"
  | MailFrom => "MAIL"
  | RcptTo => "RCPT"
  | Data => "DATA"
  | Quit => "QUIT"
  | Rset => "RSET"
  | Noop => "NOOP"
  | Vrfy => "VRFY"
  | Expn => "EXPN"
  | Starttls => "STARTTLS"
  | Auth => "AUTH"
  }

/// Whether the command requires an active session (post-HELO/EHLO).
/// Matches requiresSession in SMTP.Command.
let commandTagRequiresSession = (cmd: commandTag): bool =>
  switch cmd {
  | Helo | Ehlo | Quit | Noop | Rset => false
  | MailFrom | RcptTo | Data | Vrfy | Expn | Starttls | Auth => true
  }

/// Whether the command resets the mail transaction state.
/// Matches resetsTransaction in SMTP.Command.
let commandTagResetsTransaction = (cmd: commandTag): bool =>
  switch cmd {
  | Rset | Helo | Ehlo => true
  | _ => false
  }

// ===========================================================================
// Reply Category (SMTPABI.Layout, tags 0-3)
// ===========================================================================

/// SMTP reply code categories based on the first digit (RFC 5321 Section 4.2.1).
/// Matches ReplyCategory in SMTP.Reply.
type replyCategory =
  | @as(0) Positive
  | @as(1) Intermediate
  | @as(2) TransientNegative
  | @as(3) PermanentNegative

/// Decode from C-ABI tag value.
let replyCategoryFromTag = (tag: int): option<replyCategory> =>
  switch tag {
  | 0 => Some(Positive)
  | 1 => Some(Intermediate)
  | 2 => Some(TransientNegative)
  | 3 => Some(PermanentNegative)
  | _ => None
  }

/// Encode to C-ABI tag value.
let replyCategoryToTag = (cat: replyCategory): int =>
  switch cat {
  | Positive => 0
  | Intermediate => 1
  | TransientNegative => 2
  | PermanentNegative => 3
  }

/// Display name.
let replyCategoryAsStr = (cat: replyCategory): string =>
  switch cat {
  | Positive => "Positive"
  | Intermediate => "Intermediate"
  | TransientNegative => "TransientNegative"
  | PermanentNegative => "PermanentNegative"
  }

// ===========================================================================
// Reply Code (SMTPABI.Layout.ReplyCode, tags 0-16)
// ===========================================================================

/// Standard SMTP reply codes (RFC 5321 Section 4.2).
/// Matches ReplyCode in SMTP.Reply.
type replyCode =
  | @as(0) ServiceReady
  | @as(1) ServiceClosing
  | @as(2) ActionOk
  | @as(3) WillForward
  | @as(4) StartMailInput
  | @as(5) ServiceUnavailable
  | @as(6) MailboxBusy
  | @as(7) LocalError
  | @as(8) InsufficientStorage
  | @as(9) SyntaxError
  | @as(10) ParamSyntaxError
  | @as(11) SmtpNotImplemented
  | @as(12) BadSequence
  | @as(13) ParamNotImplemented
  | @as(14) MailboxUnavailable
  | @as(15) MailboxNameInvalid
  | @as(16) TransactionFailed

/// Decode from C-ABI tag value.
let replyCodeFromTag = (tag: int): option<replyCode> =>
  switch tag {
  | 0 => Some(ServiceReady)
  | 1 => Some(ServiceClosing)
  | 2 => Some(ActionOk)
  | 3 => Some(WillForward)
  | 4 => Some(StartMailInput)
  | 5 => Some(ServiceUnavailable)
  | 6 => Some(MailboxBusy)
  | 7 => Some(LocalError)
  | 8 => Some(InsufficientStorage)
  | 9 => Some(SyntaxError)
  | 10 => Some(ParamSyntaxError)
  | 11 => Some(SmtpNotImplemented)
  | 12 => Some(BadSequence)
  | 13 => Some(ParamNotImplemented)
  | 14 => Some(MailboxUnavailable)
  | 15 => Some(MailboxNameInvalid)
  | 16 => Some(TransactionFailed)
  | _ => None
  }

/// Encode to C-ABI tag value.
let replyCodeToTag = (code: replyCode): int =>
  switch code {
  | ServiceReady => 0
  | ServiceClosing => 1
  | ActionOk => 2
  | WillForward => 3
  | StartMailInput => 4
  | ServiceUnavailable => 5
  | MailboxBusy => 6
  | LocalError => 7
  | InsufficientStorage => 8
  | SyntaxError => 9
  | ParamSyntaxError => 10
  | SmtpNotImplemented => 11
  | BadSequence => 12
  | ParamNotImplemented => 13
  | MailboxUnavailable => 14
  | MailboxNameInvalid => 15
  | TransactionFailed => 16
  }

/// The numeric SMTP reply code (e.g. 220, 250, 550).
/// Matches replyToCode in SMTP.Reply.
let replyNumericCode = (code: replyCode): int =>
  switch code {
  | ServiceReady => 220
  | ServiceClosing => 221
  | ActionOk => 250
  | WillForward => 251
  | StartMailInput => 354
  | ServiceUnavailable => 421
  | MailboxBusy => 450
  | LocalError => 451
  | InsufficientStorage => 452
  | SyntaxError => 500
  | ParamSyntaxError => 501
  | SmtpNotImplemented => 502
  | BadSequence => 503
  | ParamNotImplemented => 504
  | MailboxUnavailable => 550
  | MailboxNameInvalid => 553
  | TransactionFailed => 554
  }

/// Default message text for each reply code.
/// Matches defaultMessage in SMTP.Reply.
let replyDefaultMessage = (code: replyCode): string =>
  switch code {
  | ServiceReady => "Service ready"
  | ServiceClosing => "Service closing transmission channel"
  | ActionOk => "OK"
  | WillForward => "User not local; will forward"
  | StartMailInput => "Start mail input; end with <CRLF>.<CRLF>"
  | ServiceUnavailable => "Service not available"
  | MailboxBusy => "Mailbox busy"
  | LocalError => "Local error in processing"
  | InsufficientStorage => "Insufficient system storage"
  | SyntaxError => "Syntax error, command unrecognised"
  | ParamSyntaxError => "Syntax error in parameters"
  | SmtpNotImplemented => "Command not implemented"
  | BadSequence => "Bad sequence of commands"
  | ParamNotImplemented => "Command parameter not implemented"
  | MailboxUnavailable => "Mailbox unavailable"
  | MailboxNameInvalid => "Mailbox name not allowed"
  | TransactionFailed => "Transaction failed"
  }

/// Categorise a reply code.
/// Matches categorise in SMTP.Reply.
let replyCategory = (code: replyCode): replyCategory => {
  let tag = replyCodeToTag(code)
  if tag <= 3 {
    Positive
  } else if tag == 4 {
    Intermediate
  } else if tag <= 8 {
    TransientNegative
  } else {
    PermanentNegative
  }
}

/// Whether the reply indicates success (2xx).
let replyIsPositive = (code: replyCode): bool => replyCategory(code) == Positive

/// Whether the reply indicates a permanent error (5xx).
let replyIsPermanentError = (code: replyCode): bool =>
  replyCategory(code) == PermanentNegative

/// Whether the reply indicates a transient error (4xx, worth retrying).
let replyIsTransientError = (code: replyCode): bool =>
  replyCategory(code) == TransientNegative

// ===========================================================================
// Auth Mechanism (SMTPABI.Layout.AuthMechTag, tags 0-3)
// ===========================================================================

/// SMTP AUTH mechanisms.
/// Matches AuthMechTag in SMTPABI.Layout.
type authMechanism =
  | @as(0) Plain
  | @as(1) Login
  | @as(2) CramMd5
  | @as(3) Xoauth2

/// Decode from C-ABI tag value.
let authMechanismFromTag = (tag: int): option<authMechanism> =>
  switch tag {
  | 0 => Some(Plain)
  | 1 => Some(Login)
  | 2 => Some(CramMd5)
  | 3 => Some(Xoauth2)
  | _ => None
  }

/// Encode to C-ABI tag value.
let authMechanismToTag = (mech: authMechanism): int =>
  switch mech {
  | Plain => 0
  | Login => 1
  | CramMd5 => 2
  | Xoauth2 => 3
  }

/// ESMTP AUTH mechanism name string.
let authMechanismAsStr = (mech: authMechanism): string =>
  switch mech {
  | Plain => "PLAIN"
  | Login => "LOGIN"
  | CramMd5 => "CRAM-MD5"
  | Xoauth2 => "XOAUTH2"
  }

// ===========================================================================
// SMTP Extension (SMTPABI.Layout.SmtpExtension, tags 0-6)
// ===========================================================================

/// SMTP service extensions advertised in EHLO response.
/// Matches SmtpExtension in SMTPABI.Layout.
type smtpExtension =
  | @as(0) ExtSize
  | @as(1) ExtPipelining
  | @as(2) Ext8BitMime
  | @as(3) ExtStarttls
  | @as(4) ExtAuth
  | @as(5) ExtDsn
  | @as(6) ExtChunking

/// Decode from C-ABI tag value.
let smtpExtensionFromTag = (tag: int): option<smtpExtension> =>
  switch tag {
  | 0 => Some(ExtSize)
  | 1 => Some(ExtPipelining)
  | 2 => Some(Ext8BitMime)
  | 3 => Some(ExtStarttls)
  | 4 => Some(ExtAuth)
  | 5 => Some(ExtDsn)
  | 6 => Some(ExtChunking)
  | _ => None
  }

/// Encode to C-ABI tag value.
let smtpExtensionToTag = (ext: smtpExtension): int =>
  switch ext {
  | ExtSize => 0
  | ExtPipelining => 1
  | Ext8BitMime => 2
  | ExtStarttls => 3
  | ExtAuth => 4
  | ExtDsn => 5
  | ExtChunking => 6
  }

/// ESMTP keyword string.
let smtpExtensionKeyword = (ext: smtpExtension): string =>
  switch ext {
  | ExtSize => "SIZE"
  | ExtPipelining => "PIPELINING"
  | Ext8BitMime => "8BITMIME"
  | ExtStarttls => "STARTTLS"
  | ExtAuth => "AUTH"
  | ExtDsn => "DSN"
  | ExtChunking => "CHUNKING"
  }

// ===========================================================================
// Session State (SMTPABI.Layout.SmtpSessionState, tags 0-8)
// ===========================================================================

/// Extended SMTP session states for the ABI lifecycle.
/// Matches SmtpSessionState in SMTPABI.Layout.
type sessionState =
  | @as(0) Connected
  | @as(1) Greeted
  | @as(2) AuthStarted
  | @as(3) Authenticated
  | @as(4) SmtpMailFrom
  | @as(5) SmtpRcptTo
  | @as(6) SmtpData
  | @as(7) MessageReceived
  | @as(8) SmtpQuit

/// Decode from C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Connected)
  | 1 => Some(Greeted)
  | 2 => Some(AuthStarted)
  | 3 => Some(Authenticated)
  | 4 => Some(SmtpMailFrom)
  | 5 => Some(SmtpRcptTo)
  | 6 => Some(SmtpData)
  | 7 => Some(MessageReceived)
  | 8 => Some(SmtpQuit)
  | _ => None
  }

/// Encode to C-ABI tag value.
let sessionStateToTag = (s: sessionState): int =>
  switch s {
  | Connected => 0
  | Greeted => 1
  | AuthStarted => 2
  | Authenticated => 3
  | SmtpMailFrom => 4
  | SmtpRcptTo => 5
  | SmtpData => 6
  | MessageReceived => 7
  | SmtpQuit => 8
  }

/// Whether this is a terminal state (Quit).
let sessionStateIsTerminal = (s: sessionState): bool =>
  switch s {
  | SmtpQuit => true
  | _ => false
  }

// ===========================================================================
// Session Transition (SMTPABI.Transitions)
// ===========================================================================

/// Named SMTP session lifecycle transitions.
/// Each variant corresponds to a constructor of ValidSmtpTransition
/// in SMTPABI.Transitions.
type sessionTransition =
  | Greet
  | StartAuth
  | AuthSuccess
  | AuthFailure
  | AuthMailFrom
  | RelayMailFrom
  | AddRecipient
  | AddMoreRecipients
  | BeginData
  | FinishData
  | ResetToGreeted
  | ResetToAuth
  | ResetFromMailFrom
  | ResetFromRcptTo
  | QuitFromConnected
  | QuitFromGreeted
  | QuitFromAuth
  | QuitFromMailFrom
  | QuitFromRcptTo
  | QuitFromMsgRecv

/// Validate whether an SMTP session state transition is legal.
/// Mirrors validateSmtpTransition in SMTPABI.Transitions.
let validateSessionTransition = (
  from: sessionState,
  to: sessionState,
): option<sessionTransition> =>
  switch (from, to) {
  | (Connected, Greeted) => Some(Greet)
  | (Greeted, AuthStarted) => Some(StartAuth)
  | (AuthStarted, Authenticated) => Some(AuthSuccess)
  | (AuthStarted, Greeted) => Some(AuthFailure)
  | (Authenticated, SmtpMailFrom) => Some(AuthMailFrom)
  | (Greeted, SmtpMailFrom) => Some(RelayMailFrom)
  | (SmtpMailFrom, SmtpRcptTo) => Some(AddRecipient)
  | (SmtpRcptTo, SmtpRcptTo) => Some(AddMoreRecipients)
  | (SmtpRcptTo, SmtpData) => Some(BeginData)
  | (SmtpData, MessageReceived) => Some(FinishData)
  | (MessageReceived, Greeted) => Some(ResetToGreeted)
  | (MessageReceived, Authenticated) => Some(ResetToAuth)
  | (SmtpMailFrom, Greeted) => Some(ResetFromMailFrom)
  | (SmtpRcptTo, Greeted) => Some(ResetFromRcptTo)
  | (Connected, SmtpQuit) => Some(QuitFromConnected)
  | (Greeted, SmtpQuit) => Some(QuitFromGreeted)
  | (Authenticated, SmtpQuit) => Some(QuitFromAuth)
  | (SmtpMailFrom, SmtpQuit) => Some(QuitFromMailFrom)
  | (SmtpRcptTo, SmtpQuit) => Some(QuitFromRcptTo)
  | (MessageReceived, SmtpQuit) => Some(QuitFromMsgRecv)
  | _ => None
  }

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SMTP port (RFC 5321).
let smtpPort = 25

/// SMTP submission port (RFC 6409).
let submissionPort = 587

/// SMTPS (implicit TLS) port.
let smtpsPort = 465

/// Maximum command line length in bytes (RFC 5321 Section 4.5.3.1.4).
let maxCommandLineLength = 512

/// Maximum reply line length in bytes (RFC 5321 Section 4.5.3.1.5).
let maxReplyLineLength = 512

/// Maximum text line length in bytes (RFC 5321 Section 4.5.3.1.6).
let maxTextLineLength = 998
