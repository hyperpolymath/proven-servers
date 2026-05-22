// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! SMTP protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `SmtpABI.Types` and its type definitions:
//! - `SmtpCommand`      — SMTP commands (12 constructors, tags 0-11)
//! - `ReplyCategory`    — reply severity categories (4 constructors, tags 0-3)
//! - `ReplyCode`        — SMTP reply codes (17 constructors, tags 0-16)
//! - `AuthMechanism`    — SASL authentication mechanisms (4 constructors, tags 0-3)
//! - `SmtpExtension`    — ESMTP extensions (7 constructors, tags 0-6)
//! - `SmtpSessionState` — session state machine (9 constructors, tags 0-8)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SMTP Constants
// ===========================================================================

/// Standard SMTP submission port.
pub const SMTP_PORT: u16 = 25;

/// SMTP submission port (RFC 6409).
pub const SUBMISSION_PORT: u16 = 587;

/// SMTPS (implicit TLS) port.
pub const SMTPS_PORT: u16 = 465;

// ===========================================================================
// SmtpCommand (tags 0-11)
// ===========================================================================

/// SMTP protocol commands (RFC 5321).
///
/// Matches `SmtpCommandTag` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SmtpCommand {
    /// HELO — identify client (RFC 821) (tag 0).
    Helo = 0,
    /// EHLO — extended HELO (RFC 1869) (tag 1).
    Ehlo = 1,
    /// MAIL FROM — specify sender (tag 2).
    MailFrom = 2,
    /// RCPT TO — specify recipient (tag 3).
    RcptTo = 3,
    /// DATA — begin message body (tag 4).
    Data = 4,
    /// QUIT — close session (tag 5).
    Quit = 5,
    /// RSET — reset transaction (tag 6).
    Rset = 6,
    /// NOOP — no operation (tag 7).
    Noop = 7,
    /// VRFY — verify address (tag 8).
    Vrfy = 8,
    /// EXPN — expand mailing list (tag 9).
    Expn = 9,
    /// STARTTLS — upgrade to TLS (RFC 3207) (tag 10).
    Starttls = 10,
    /// AUTH — SASL authentication (RFC 4954) (tag 11).
    Auth = 11,
}

impl SmtpCommand {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Helo),
            1 => Some(Self::Ehlo),
            2 => Some(Self::MailFrom),
            3 => Some(Self::RcptTo),
            4 => Some(Self::Data),
            5 => Some(Self::Quit),
            6 => Some(Self::Rset),
            7 => Some(Self::Noop),
            8 => Some(Self::Vrfy),
            9 => Some(Self::Expn),
            10 => Some(Self::Starttls),
            11 => Some(Self::Auth),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The SMTP command verb as a string.
    pub fn verb(self) -> &'static str {
        match self {
            Self::Helo => "HELO",
            Self::Ehlo => "EHLO",
            Self::MailFrom => "MAIL FROM",
            Self::RcptTo => "RCPT TO",
            Self::Data => "DATA",
            Self::Quit => "QUIT",
            Self::Rset => "RSET",
            Self::Noop => "NOOP",
            Self::Vrfy => "VRFY",
            Self::Expn => "EXPN",
            Self::Starttls => "STARTTLS",
            Self::Auth => "AUTH",
        }
    }

    /// Whether this command is part of the mail transaction envelope.
    pub fn is_envelope(self) -> bool {
        matches!(self, Self::MailFrom | Self::RcptTo | Self::Data)
    }

    /// All supported commands.
    pub const ALL: [SmtpCommand; 12] = [
        Self::Helo, Self::Ehlo, Self::MailFrom, Self::RcptTo, Self::Data,
        Self::Quit, Self::Rset, Self::Noop, Self::Vrfy, Self::Expn,
        Self::Starttls, Self::Auth,
    ];
}

impl fmt::Display for SmtpCommand {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.verb())
    }
}

// ===========================================================================
// ReplyCategory (tags 0-3)
// ===========================================================================

/// SMTP reply severity categories (RFC 5321 Section 4.2).
///
/// Matches `ReplyCategory` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReplyCategory {
    /// Positive completion (2xx) (tag 0).
    Positive = 0,
    /// Positive intermediate (3xx) (tag 1).
    Intermediate = 1,
    /// Transient negative (4xx) — retry may succeed (tag 2).
    TransientNegative = 2,
    /// Permanent negative (5xx) — do not retry (tag 3).
    PermanentNegative = 3,
}

impl ReplyCategory {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Positive),
            1 => Some(Self::Intermediate),
            2 => Some(Self::TransientNegative),
            3 => Some(Self::PermanentNegative),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this category indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Positive)
    }

    /// Whether this category indicates an error.
    pub fn is_error(self) -> bool {
        matches!(self, Self::TransientNegative | Self::PermanentNegative)
    }
}

impl fmt::Display for ReplyCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ReplyCode (tags 0-16)
// ===========================================================================

/// SMTP reply codes (RFC 5321).
///
/// Matches `ReplyCode` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReplyCode {
    /// 220 — Service ready (tag 0).
    ServiceReady = 0,
    /// 221 — Service closing transmission channel (tag 1).
    ServiceClosing = 1,
    /// 250 — Requested action OK, completed (tag 2).
    ActionOk = 2,
    /// 251 — User not local, will forward (tag 3).
    WillForward = 3,
    /// 354 — Start mail input (tag 4).
    StartMailInput = 4,
    /// 421 — Service unavailable (tag 5).
    ServiceUnavailable = 5,
    /// 450 — Mailbox busy (tag 6).
    MailboxBusy = 6,
    /// 451 — Local error in processing (tag 7).
    LocalError = 7,
    /// 452 — Insufficient storage (tag 8).
    InsufficientStorage = 8,
    /// 500 — Syntax error, command unrecognised (tag 9).
    SyntaxError = 9,
    /// 501 — Syntax error in parameters (tag 10).
    ParamSyntaxError = 10,
    /// 502 — Command not implemented (tag 11).
    NotImplemented = 11,
    /// 503 — Bad sequence of commands (tag 12).
    BadSequence = 12,
    /// 504 — Parameter not implemented (tag 13).
    ParamNotImplemented = 13,
    /// 550 — Mailbox unavailable (tag 14).
    MailboxUnavailable = 14,
    /// 553 — Mailbox name not allowed (tag 15).
    MailboxNameInvalid = 15,
    /// 554 — Transaction failed (tag 16).
    TransactionFailed = 16,
}

impl ReplyCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ServiceReady),
            1 => Some(Self::ServiceClosing),
            2 => Some(Self::ActionOk),
            3 => Some(Self::WillForward),
            4 => Some(Self::StartMailInput),
            5 => Some(Self::ServiceUnavailable),
            6 => Some(Self::MailboxBusy),
            7 => Some(Self::LocalError),
            8 => Some(Self::InsufficientStorage),
            9 => Some(Self::SyntaxError),
            10 => Some(Self::ParamSyntaxError),
            11 => Some(Self::NotImplemented),
            12 => Some(Self::BadSequence),
            13 => Some(Self::ParamNotImplemented),
            14 => Some(Self::MailboxUnavailable),
            15 => Some(Self::MailboxNameInvalid),
            16 => Some(Self::TransactionFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The numeric SMTP reply code.
    pub fn smtp_code(self) -> u16 {
        match self {
            Self::ServiceReady => 220,
            Self::ServiceClosing => 221,
            Self::ActionOk => 250,
            Self::WillForward => 251,
            Self::StartMailInput => 354,
            Self::ServiceUnavailable => 421,
            Self::MailboxBusy => 450,
            Self::LocalError => 451,
            Self::InsufficientStorage => 452,
            Self::SyntaxError => 500,
            Self::ParamSyntaxError => 501,
            Self::NotImplemented => 502,
            Self::BadSequence => 503,
            Self::ParamNotImplemented => 504,
            Self::MailboxUnavailable => 550,
            Self::MailboxNameInvalid => 553,
            Self::TransactionFailed => 554,
        }
    }

    /// The reply category for this code.
    pub fn category(self) -> ReplyCategory {
        match self.smtp_code() / 100 {
            2 => ReplyCategory::Positive,
            3 => ReplyCategory::Intermediate,
            4 => ReplyCategory::TransientNegative,
            _ => ReplyCategory::PermanentNegative,
        }
    }
}

impl fmt::Display for ReplyCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} {:?}", self.smtp_code(), self)
    }
}

// ===========================================================================
// AuthMechanism (tags 0-3)
// ===========================================================================

/// SMTP SASL authentication mechanisms (RFC 4954).
///
/// Matches `AuthMechTag` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthMechanism {
    /// PLAIN (RFC 4616) (tag 0).
    Plain = 0,
    /// LOGIN (non-standard but widely used) (tag 1).
    Login = 1,
    /// CRAM-MD5 (RFC 2195) (tag 2).
    CramMd5 = 2,
    /// XOAUTH2 (Google extension) (tag 3).
    Xoauth2 = 3,
}

impl AuthMechanism {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Plain),
            1 => Some(Self::Login),
            2 => Some(Self::CramMd5),
            3 => Some(Self::Xoauth2),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The SASL mechanism name string.
    pub fn mechanism_name(self) -> &'static str {
        match self {
            Self::Plain => "PLAIN",
            Self::Login => "LOGIN",
            Self::CramMd5 => "CRAM-MD5",
            Self::Xoauth2 => "XOAUTH2",
        }
    }

    /// Whether this mechanism sends credentials in cleartext
    /// (requires TLS for security).
    pub fn requires_tls(self) -> bool {
        matches!(self, Self::Plain | Self::Login)
    }
}

impl fmt::Display for AuthMechanism {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.mechanism_name())
    }
}

// ===========================================================================
// SmtpExtension (tags 0-6)
// ===========================================================================

/// ESMTP extensions advertised via EHLO response.
///
/// Matches `SmtpExtension` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SmtpExtension {
    /// SIZE — message size declaration (RFC 1870) (tag 0).
    Size = 0,
    /// PIPELINING — command pipelining (RFC 2920) (tag 1).
    Pipelining = 1,
    /// 8BITMIME — 8-bit MIME support (RFC 6152) (tag 2).
    EightBitMime = 2,
    /// STARTTLS — TLS upgrade (RFC 3207) (tag 3).
    Starttls = 3,
    /// AUTH — SASL authentication (RFC 4954) (tag 4).
    Auth = 4,
    /// DSN — delivery status notifications (RFC 3461) (tag 5).
    Dsn = 5,
    /// CHUNKING — binary data chunking (RFC 3030) (tag 6).
    Chunking = 6,
}

impl SmtpExtension {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Size),
            1 => Some(Self::Pipelining),
            2 => Some(Self::EightBitMime),
            3 => Some(Self::Starttls),
            4 => Some(Self::Auth),
            5 => Some(Self::Dsn),
            6 => Some(Self::Chunking),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The ESMTP keyword for this extension.
    pub fn keyword(self) -> &'static str {
        match self {
            Self::Size => "SIZE",
            Self::Pipelining => "PIPELINING",
            Self::EightBitMime => "8BITMIME",
            Self::Starttls => "STARTTLS",
            Self::Auth => "AUTH",
            Self::Dsn => "DSN",
            Self::Chunking => "CHUNKING",
        }
    }
}

impl fmt::Display for SmtpExtension {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.keyword())
    }
}

// ===========================================================================
// SmtpSessionState (tags 0-8)
// ===========================================================================

/// SMTP session state machine (RFC 5321).
///
/// Matches `SmtpSessionState` in `SmtpABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SmtpSessionState {
    /// TCP connection established, awaiting greeting (tag 0).
    Connected = 0,
    /// EHLO/HELO completed, session identified (tag 1).
    Greeted = 1,
    /// AUTH command sent, awaiting challenge/response (tag 2).
    AuthStarted = 2,
    /// Authentication completed successfully (tag 3).
    Authenticated = 3,
    /// MAIL FROM accepted, sender specified (tag 4).
    MailFrom = 4,
    /// At least one RCPT TO accepted (tag 5).
    RcptTo = 5,
    /// DATA command accepted, receiving message body (tag 6).
    Data = 6,
    /// Message body received and accepted (tag 7).
    MessageReceived = 7,
    /// QUIT sent, session ending (tag 8).
    Quit = 8,
}

impl SmtpSessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connected),
            1 => Some(Self::Greeted),
            2 => Some(Self::AuthStarted),
            3 => Some(Self::Authenticated),
            4 => Some(Self::MailFrom),
            5 => Some(Self::RcptTo),
            6 => Some(Self::Data),
            7 => Some(Self::MessageReceived),
            8 => Some(Self::Quit),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Validate whether a state transition is allowed in the SMTP state machine.
    pub fn can_transition_to(self, next: SmtpSessionState) -> bool {
        matches!(
            (self, next),
            (Self::Connected, Self::Greeted)
                | (Self::Greeted, Self::AuthStarted)
                | (Self::Greeted, Self::MailFrom)      // Auth optional
                | (Self::AuthStarted, Self::Authenticated)
                | (Self::AuthStarted, Self::Greeted)   // Auth failed
                | (Self::Authenticated, Self::MailFrom)
                | (Self::MailFrom, Self::RcptTo)
                | (Self::RcptTo, Self::RcptTo)         // Multiple recipients
                | (Self::RcptTo, Self::Data)
                | (Self::Data, Self::MessageReceived)
                | (Self::MessageReceived, Self::MailFrom) // Pipelining
                | (_, Self::Quit)                       // Can quit from any state
        )
    }
}

impl fmt::Display for SmtpSessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn smtp_command_roundtrip() {
        for cmd in SmtpCommand::ALL {
            let tag = cmd.to_tag();
            let decoded = SmtpCommand::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(SmtpCommand::from_tag(12).is_none());
    }

    #[test]
    fn smtp_command_envelope() {
        assert!(SmtpCommand::MailFrom.is_envelope());
        assert!(SmtpCommand::RcptTo.is_envelope());
        assert!(SmtpCommand::Data.is_envelope());
        assert!(!SmtpCommand::Ehlo.is_envelope());
        assert!(!SmtpCommand::Quit.is_envelope());
    }

    #[test]
    fn reply_category_roundtrip() {
        for tag in 0u8..=3 {
            let cat = ReplyCategory::from_tag(tag).expect("valid tag");
            assert_eq!(cat.to_tag(), tag);
        }
        assert!(ReplyCategory::from_tag(4).is_none());
    }

    #[test]
    fn reply_category_classification() {
        assert!(ReplyCategory::Positive.is_success());
        assert!(!ReplyCategory::TransientNegative.is_success());
        assert!(ReplyCategory::TransientNegative.is_error());
        assert!(ReplyCategory::PermanentNegative.is_error());
        assert!(!ReplyCategory::Positive.is_error());
    }

    #[test]
    fn reply_code_roundtrip() {
        for tag in 0u8..=16 {
            let rc = ReplyCode::from_tag(tag).expect("valid tag");
            assert_eq!(rc.to_tag(), tag);
        }
        assert!(ReplyCode::from_tag(17).is_none());
    }

    #[test]
    fn reply_code_smtp_codes() {
        assert_eq!(ReplyCode::ServiceReady.smtp_code(), 220);
        assert_eq!(ReplyCode::ActionOk.smtp_code(), 250);
        assert_eq!(ReplyCode::StartMailInput.smtp_code(), 354);
        assert_eq!(ReplyCode::SyntaxError.smtp_code(), 500);
        assert_eq!(ReplyCode::TransactionFailed.smtp_code(), 554);
    }

    #[test]
    fn reply_code_categories() {
        assert_eq!(ReplyCode::ActionOk.category(), ReplyCategory::Positive);
        assert_eq!(ReplyCode::StartMailInput.category(), ReplyCategory::Intermediate);
        assert_eq!(ReplyCode::MailboxBusy.category(), ReplyCategory::TransientNegative);
        assert_eq!(ReplyCode::SyntaxError.category(), ReplyCategory::PermanentNegative);
    }

    #[test]
    fn auth_mechanism_roundtrip() {
        for tag in 0u8..=3 {
            let mech = AuthMechanism::from_tag(tag).expect("valid tag");
            assert_eq!(mech.to_tag(), tag);
        }
        assert!(AuthMechanism::from_tag(4).is_none());
    }

    #[test]
    fn auth_mechanism_tls_requirement() {
        assert!(AuthMechanism::Plain.requires_tls());
        assert!(AuthMechanism::Login.requires_tls());
        assert!(!AuthMechanism::CramMd5.requires_tls());
        assert!(!AuthMechanism::Xoauth2.requires_tls());
    }

    #[test]
    fn smtp_extension_roundtrip() {
        for tag in 0u8..=6 {
            let ext = SmtpExtension::from_tag(tag).expect("valid tag");
            assert_eq!(ext.to_tag(), tag);
        }
        assert!(SmtpExtension::from_tag(7).is_none());
    }

    #[test]
    fn smtp_session_state_roundtrip() {
        for tag in 0u8..=8 {
            let state = SmtpSessionState::from_tag(tag).expect("valid tag");
            assert_eq!(state.to_tag(), tag);
        }
        assert!(SmtpSessionState::from_tag(9).is_none());
    }

    #[test]
    fn smtp_session_state_transitions() {
        assert!(SmtpSessionState::Connected.can_transition_to(SmtpSessionState::Greeted));
        assert!(SmtpSessionState::Greeted.can_transition_to(SmtpSessionState::MailFrom));
        assert!(SmtpSessionState::Greeted.can_transition_to(SmtpSessionState::AuthStarted));
        assert!(SmtpSessionState::Authenticated.can_transition_to(SmtpSessionState::MailFrom));
        assert!(SmtpSessionState::MailFrom.can_transition_to(SmtpSessionState::RcptTo));
        assert!(SmtpSessionState::RcptTo.can_transition_to(SmtpSessionState::RcptTo));
        assert!(SmtpSessionState::RcptTo.can_transition_to(SmtpSessionState::Data));
        assert!(SmtpSessionState::Data.can_transition_to(SmtpSessionState::MessageReceived));
        assert!(SmtpSessionState::MessageReceived.can_transition_to(SmtpSessionState::MailFrom));
        // Can always quit
        assert!(SmtpSessionState::Connected.can_transition_to(SmtpSessionState::Quit));
        assert!(SmtpSessionState::Data.can_transition_to(SmtpSessionState::Quit));
        // Invalid
        assert!(!SmtpSessionState::Connected.can_transition_to(SmtpSessionState::MailFrom));
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SMTP_PORT, 25);
        assert_eq!(SUBMISSION_PORT, 587);
        assert_eq!(SMTPS_PORT, 465);
    }
}
