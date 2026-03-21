// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! VoIP (Voice over IP / SIP) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `VoIPABI.Types` and its type definitions:
//! - `Method`       — SIP request methods (13 constructors, tags 0-12)
//! - `ResponseCode` — SIP response codes (17 constructors, tags 0-16)
//! - `DialogState`  — SIP dialog lifecycle (3 constructors, tags 0-2)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// VoIP Constants
// ===========================================================================

/// Standard SIP port (RFC 3261).
pub const SIP_PORT: u16 = 5060;

/// Standard SIP over TLS (SIPS) port (RFC 3261).
pub const SIPS_PORT: u16 = 5061;

// ===========================================================================
// Method (tags 0-12)
// ===========================================================================

/// SIP request methods (RFC 3261 and extensions).
///
/// Matches `Method` in `VoIPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Method {
    /// INVITE — initiate a session (tag 0).
    Invite = 0,
    /// ACK — confirm INVITE reception (tag 1).
    Ack = 1,
    /// BYE — terminate a session (tag 2).
    Bye = 2,
    /// CANCEL — cancel a pending request (tag 3).
    Cancel = 3,
    /// REGISTER — register contact URI (tag 4).
    Register = 4,
    /// OPTIONS — query capabilities (tag 5).
    Options = 5,
    /// INFO — send mid-session information (tag 6).
    Info = 6,
    /// UPDATE — modify session parameters (tag 7).
    Update = 7,
    /// SUBSCRIBE — request event notification (tag 8).
    Subscribe = 8,
    /// NOTIFY — deliver event notification (tag 9).
    Notify = 9,
    /// REFER — ask recipient to issue a request (tag 10).
    Refer = 10,
    /// MESSAGE — instant messaging (tag 11).
    Message = 11,
    /// PRACK — provisional response acknowledgement (tag 12).
    Prack = 12,
}

impl Method {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Invite),
            1 => Some(Self::Ack),
            2 => Some(Self::Bye),
            3 => Some(Self::Cancel),
            4 => Some(Self::Register),
            5 => Some(Self::Options),
            6 => Some(Self::Info),
            7 => Some(Self::Update),
            8 => Some(Self::Subscribe),
            9 => Some(Self::Notify),
            10 => Some(Self::Refer),
            11 => Some(Self::Message),
            12 => Some(Self::Prack),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The SIP method name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::Invite => "INVITE",
            Self::Ack => "ACK",
            Self::Bye => "BYE",
            Self::Cancel => "CANCEL",
            Self::Register => "REGISTER",
            Self::Options => "OPTIONS",
            Self::Info => "INFO",
            Self::Update => "UPDATE",
            Self::Subscribe => "SUBSCRIBE",
            Self::Notify => "NOTIFY",
            Self::Refer => "REFER",
            Self::Message => "MESSAGE",
            Self::Prack => "PRACK",
        }
    }

    /// Whether this method creates or modifies a dialog.
    pub fn is_dialog_creating(self) -> bool {
        matches!(self, Self::Invite | Self::Subscribe)
    }

    /// Whether this method is related to session management.
    pub fn is_session_related(self) -> bool {
        matches!(
            self,
            Self::Invite | Self::Ack | Self::Bye | Self::Cancel
                | Self::Update | Self::Prack
        )
    }

    /// Whether this method is related to event notification.
    pub fn is_event_related(self) -> bool {
        matches!(self, Self::Subscribe | Self::Notify)
    }

    /// All supported methods.
    pub const ALL: [Method; 13] = [
        Self::Invite, Self::Ack, Self::Bye, Self::Cancel, Self::Register,
        Self::Options, Self::Info, Self::Update, Self::Subscribe, Self::Notify,
        Self::Refer, Self::Message, Self::Prack,
    ];
}

impl fmt::Display for Method {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// ResponseCode (tags 0-16)
// ===========================================================================

/// SIP response codes (RFC 3261).
///
/// Matches `ResponseCode` in `VoIPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseCode {
    /// 100 Trying (tag 0).
    Trying = 0,
    /// 180 Ringing (tag 1).
    Ringing = 1,
    /// 183 Session Progress (tag 2).
    SessionProgress = 2,
    /// 200 OK (tag 3).
    Ok = 3,
    /// 300 Multiple Choices (tag 4).
    MultipleChoices = 4,
    /// 301 Moved Permanently (tag 5).
    MovedPermanently = 5,
    /// 302 Moved Temporarily (tag 6).
    MovedTemporarily = 6,
    /// 400 Bad Request (tag 7).
    BadRequest = 7,
    /// 401 Unauthorized (tag 8).
    Unauthorized = 8,
    /// 403 Forbidden (tag 9).
    Forbidden = 9,
    /// 404 Not Found (tag 10).
    NotFound = 10,
    /// 405 Method Not Allowed (tag 11).
    MethodNotAllowed = 11,
    /// 408 Request Timeout (tag 12).
    RequestTimeout = 12,
    /// 486 Busy Here (tag 13).
    BusyHere = 13,
    /// 603 Decline (tag 14).
    Decline = 14,
    /// 500 Server Internal Error (tag 15).
    ServerInternalError = 15,
    /// 503 Service Unavailable (tag 16).
    ServiceUnavailable = 16,
}

impl ResponseCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Trying),
            1 => Some(Self::Ringing),
            2 => Some(Self::SessionProgress),
            3 => Some(Self::Ok),
            4 => Some(Self::MultipleChoices),
            5 => Some(Self::MovedPermanently),
            6 => Some(Self::MovedTemporarily),
            7 => Some(Self::BadRequest),
            8 => Some(Self::Unauthorized),
            9 => Some(Self::Forbidden),
            10 => Some(Self::NotFound),
            11 => Some(Self::MethodNotAllowed),
            12 => Some(Self::RequestTimeout),
            13 => Some(Self::BusyHere),
            14 => Some(Self::Decline),
            15 => Some(Self::ServerInternalError),
            16 => Some(Self::ServiceUnavailable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a provisional (1xx) response.
    pub fn is_provisional(self) -> bool {
        matches!(self, Self::Trying | Self::Ringing | Self::SessionProgress)
    }

    /// Whether this is a success (2xx) response.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// Whether this is a redirection (3xx) response.
    pub fn is_redirect(self) -> bool {
        matches!(
            self,
            Self::MultipleChoices | Self::MovedPermanently | Self::MovedTemporarily
        )
    }

    /// Whether this is a client error (4xx) response.
    pub fn is_client_error(self) -> bool {
        matches!(
            self,
            Self::BadRequest | Self::Unauthorized | Self::Forbidden
                | Self::NotFound | Self::MethodNotAllowed | Self::RequestTimeout
                | Self::BusyHere
        )
    }

    /// Whether this is a server error (5xx) response.
    pub fn is_server_error(self) -> bool {
        matches!(self, Self::ServerInternalError | Self::ServiceUnavailable)
    }

    /// Whether this is a global failure (6xx) response.
    pub fn is_global_failure(self) -> bool {
        matches!(self, Self::Decline)
    }

    /// Whether this response is a final response (non-provisional).
    pub fn is_final(self) -> bool {
        !self.is_provisional()
    }

    /// All supported response codes.
    pub const ALL: [ResponseCode; 17] = [
        Self::Trying, Self::Ringing, Self::SessionProgress, Self::Ok,
        Self::MultipleChoices, Self::MovedPermanently, Self::MovedTemporarily,
        Self::BadRequest, Self::Unauthorized, Self::Forbidden, Self::NotFound,
        Self::MethodNotAllowed, Self::RequestTimeout, Self::BusyHere,
        Self::Decline, Self::ServerInternalError, Self::ServiceUnavailable,
    ];
}

impl fmt::Display for ResponseCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DialogState (tags 0-2)
// ===========================================================================

/// SIP dialog state machine (RFC 3261 Section 12).
///
/// Matches `DialogState` in `VoIPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DialogState {
    /// Early dialog — provisional response received (tag 0).
    Early = 0,
    /// Confirmed dialog — final 2xx response received (tag 1).
    Confirmed = 1,
    /// Terminated — BYE sent or received (tag 2).
    Terminated = 2,
}

impl DialogState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Early),
            1 => Some(Self::Confirmed),
            2 => Some(Self::Terminated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether media can flow in this state.
    pub fn can_carry_media(self) -> bool {
        matches!(self, Self::Early | Self::Confirmed)
    }

    /// Whether the dialog is active (not terminated).
    pub fn is_active(self) -> bool {
        !matches!(self, Self::Terminated)
    }

    /// All supported dialog states.
    pub const ALL: [DialogState; 3] = [Self::Early, Self::Confirmed, Self::Terminated];
}

impl fmt::Display for DialogState {
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
    fn method_roundtrip() {
        for m in Method::ALL {
            let tag = m.to_tag();
            let decoded = Method::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, m);
        }
        assert!(Method::from_tag(13).is_none());
    }

    #[test]
    fn method_classification() {
        assert!(Method::Invite.is_dialog_creating());
        assert!(Method::Subscribe.is_dialog_creating());
        assert!(!Method::Bye.is_dialog_creating());
        assert!(Method::Invite.is_session_related());
        assert!(Method::Bye.is_session_related());
        assert!(!Method::Register.is_session_related());
        assert!(Method::Subscribe.is_event_related());
        assert!(Method::Notify.is_event_related());
        assert!(!Method::Invite.is_event_related());
    }

    #[test]
    fn response_code_roundtrip() {
        for rc in ResponseCode::ALL {
            let tag = rc.to_tag();
            let decoded = ResponseCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, rc);
        }
        assert!(ResponseCode::from_tag(17).is_none());
    }

    #[test]
    fn response_code_classification() {
        assert!(ResponseCode::Trying.is_provisional());
        assert!(ResponseCode::Ringing.is_provisional());
        assert!(!ResponseCode::Ok.is_provisional());
        assert!(ResponseCode::Ok.is_success());
        assert!(!ResponseCode::BadRequest.is_success());
        assert!(ResponseCode::MovedPermanently.is_redirect());
        assert!(ResponseCode::BadRequest.is_client_error());
        assert!(ResponseCode::BusyHere.is_client_error());
        assert!(ResponseCode::ServerInternalError.is_server_error());
        assert!(ResponseCode::Decline.is_global_failure());
        assert!(ResponseCode::Ok.is_final());
        assert!(!ResponseCode::Trying.is_final());
    }

    #[test]
    fn dialog_state_roundtrip() {
        for ds in DialogState::ALL {
            let tag = ds.to_tag();
            let decoded = DialogState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ds);
        }
        assert!(DialogState::from_tag(3).is_none());
    }

    #[test]
    fn dialog_state_classification() {
        assert!(DialogState::Early.can_carry_media());
        assert!(DialogState::Confirmed.can_carry_media());
        assert!(!DialogState::Terminated.can_carry_media());
        assert!(DialogState::Early.is_active());
        assert!(!DialogState::Terminated.is_active());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(SIP_PORT, 5060);
        assert_eq!(SIPS_PORT, 5061);
    }
}
