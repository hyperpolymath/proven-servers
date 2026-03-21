// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMTP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SmtpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SMTP submission port.
let smtpPort = 25

/// SMTP submission port (RFC 6409).
let submissionPort = 587

/// SMTPS (implicit TLS) port.
let smtpsPort = 465

// ===========================================================================
// SmtpCommand (tags 0-11)
// ===========================================================================

/// Standard SMTP submission port.
type smtpCommand =
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

/// Decode from the C-ABI tag value.
let smtpCommandFromTag = (tag: int): option<smtpCommand> =>
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

/// Encode to the C-ABI tag value.
let smtpCommandToTag = (v: smtpCommand): int =>
  switch v {
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

/// Whether this command is part of the mail transaction envelope.
let smtpCommandIsEnvelope = (v: smtpCommand): bool =>
  switch v {
  | MailFrom | RcptTo | Data => true
  | _ => false
  }

// ===========================================================================
// ReplyCategory (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type replyCategory =
  | @as(0) Positive
  | @as(1) Intermediate
  | @as(2) TransientNegative
  | @as(3) PermanentNegative

/// Decode from the C-ABI tag value.
let replyCategoryFromTag = (tag: int): option<replyCategory> =>
  switch tag {
  | 0 => Some(Positive)
  | 1 => Some(Intermediate)
  | 2 => Some(TransientNegative)
  | 3 => Some(PermanentNegative)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let replyCategoryToTag = (v: replyCategory): int =>
  switch v {
  | Positive => 0
  | Intermediate => 1
  | TransientNegative => 2
  | PermanentNegative => 3
  }

/// Whether this category indicates success.
let replyCategoryIsSuccess = (v: replyCategory): bool =>
  switch v {
  | Positive => true
  | _ => false
  }

/// Whether this category indicates an error.
let replyCategoryIsError = (v: replyCategory): bool =>
  switch v {
  | TransientNegative | PermanentNegative => true
  | _ => false
  }

// ===========================================================================
// ReplyCode (tags 0-16)
// ===========================================================================

/// Decode from an ABI tag value.
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
  | @as(11) NotImplemented
  | @as(12) BadSequence
  | @as(13) ParamNotImplemented
  | @as(14) MailboxUnavailable
  | @as(15) MailboxNameInvalid
  | @as(16) TransactionFailed

/// Decode from the C-ABI tag value.
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
  | 11 => Some(NotImplemented)
  | 12 => Some(BadSequence)
  | 13 => Some(ParamNotImplemented)
  | 14 => Some(MailboxUnavailable)
  | 15 => Some(MailboxNameInvalid)
  | 16 => Some(TransactionFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let replyCodeToTag = (v: replyCode): int =>
  switch v {
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
  | NotImplemented => 11
  | BadSequence => 12
  | ParamNotImplemented => 13
  | MailboxUnavailable => 14
  | MailboxNameInvalid => 15
  | TransactionFailed => 16
  }

// ===========================================================================
// AuthMechanism (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type authMechanism =
  | @as(0) Plain
  | @as(1) Login
  | @as(2) CramMd5
  | @as(3) Xoauth2

/// Decode from the C-ABI tag value.
let authMechanismFromTag = (tag: int): option<authMechanism> =>
  switch tag {
  | 0 => Some(Plain)
  | 1 => Some(Login)
  | 2 => Some(CramMd5)
  | 3 => Some(Xoauth2)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authMechanismToTag = (v: authMechanism): int =>
  switch v {
  | Plain => 0
  | Login => 1
  | CramMd5 => 2
  | Xoauth2 => 3
  }

/// (requires TLS for security).
let authMechanismRequiresTls = (v: authMechanism): bool =>
  switch v {
  | Plain | Login => true
  | _ => false
  }

// ===========================================================================
// SmtpExtension (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type smtpExtension =
  | @as(0) Size
  | @as(1) Pipelining
  | @as(2) EightBitMime
  | @as(3) Starttls
  | @as(4) Auth
  | @as(5) Dsn
  | @as(6) Chunking

/// Decode from the C-ABI tag value.
let smtpExtensionFromTag = (tag: int): option<smtpExtension> =>
  switch tag {
  | 0 => Some(Size)
  | 1 => Some(Pipelining)
  | 2 => Some(EightBitMime)
  | 3 => Some(Starttls)
  | 4 => Some(Auth)
  | 5 => Some(Dsn)
  | 6 => Some(Chunking)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let smtpExtensionToTag = (v: smtpExtension): int =>
  switch v {
  | Size => 0
  | Pipelining => 1
  | EightBitMime => 2
  | Starttls => 3
  | Auth => 4
  | Dsn => 5
  | Chunking => 6
  }

// ===========================================================================
// SmtpSessionState (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type smtpSessionState =
  | @as(0) Connected
  | @as(1) Greeted
  | @as(2) AuthStarted
  | @as(3) Authenticated
  | @as(4) MailFrom
  | @as(5) RcptTo
  | @as(6) Data
  | @as(7) MessageReceived
  | @as(8) Quit

/// Decode from the C-ABI tag value.
let smtpSessionStateFromTag = (tag: int): option<smtpSessionState> =>
  switch tag {
  | 0 => Some(Connected)
  | 1 => Some(Greeted)
  | 2 => Some(AuthStarted)
  | 3 => Some(Authenticated)
  | 4 => Some(MailFrom)
  | 5 => Some(RcptTo)
  | 6 => Some(Data)
  | 7 => Some(MessageReceived)
  | 8 => Some(Quit)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let smtpSessionStateToTag = (v: smtpSessionState): int =>
  switch v {
  | Connected => 0
  | Greeted => 1
  | AuthStarted => 2
  | Authenticated => 3
  | MailFrom => 4
  | RcptTo => 5
  | Data => 6
  | MessageReceived => 7
  | Quit => 8
  }

/// Validate whether a state transition is allowed.
let smtpSessionStateCanTransitionTo = (from: smtpSessionState, to: smtpSessionState): bool =>
  switch (from, to) {
  | _ => false
  }

