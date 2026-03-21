// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! RTSP (Real Time Streaming Protocol) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `RTSPABI.Types` and its type definitions:
//! - `Method`            — RTSP request methods (11 constructors, tags 0-10)
//! - `TransportProtocol` — RTP transport variants (3 constructors, tags 0-2)
//! - `SessionState`      — RTSP session state machine (4 constructors, tags 0-3)
//! - `StatusCode`        — RTSP response status codes (12 constructors, tags 0-11)
//! - `RtspError`         — FFI error codes (7 constructors, tags 0-6)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// RTSP Constants
// ===========================================================================

/// Standard RTSP port (RFC 7826).
pub const RTSP_PORT: u16 = 554;

/// Standard RTSPS (RTSP over TLS) port.
pub const RTSPS_PORT: u16 = 322;

// ===========================================================================
// Method (tags 0-10)
// ===========================================================================

/// RTSP request methods (RFC 7826).
///
/// Matches `Method` in `RTSPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Method {
    /// Retrieve media description (tag 0).
    Describe = 0,
    /// Set up transport for a media stream (tag 1).
    Setup = 1,
    /// Start playback of a media stream (tag 2).
    Play = 2,
    /// Pause playback (tag 3).
    Pause = 3,
    /// Tear down a session and release resources (tag 4).
    Teardown = 4,
    /// Retrieve server/session parameter (tag 5).
    GetParameter = 5,
    /// Set server/session parameter (tag 6).
    SetParameter = 6,
    /// Query server capabilities (tag 7).
    Options = 7,
    /// Post media description to the server (tag 8).
    Announce = 8,
    /// Start recording a media stream (tag 9).
    Record = 9,
    /// Redirect client to a new server (tag 10).
    Redirect = 10,
}

impl Method {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Describe),
            1 => Some(Self::Setup),
            2 => Some(Self::Play),
            3 => Some(Self::Pause),
            4 => Some(Self::Teardown),
            5 => Some(Self::GetParameter),
            6 => Some(Self::SetParameter),
            7 => Some(Self::Options),
            8 => Some(Self::Announce),
            9 => Some(Self::Record),
            10 => Some(Self::Redirect),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The RTSP method name string.
    pub fn name(self) -> &'static str {
        match self {
            Self::Describe => "DESCRIBE",
            Self::Setup => "SETUP",
            Self::Play => "PLAY",
            Self::Pause => "PAUSE",
            Self::Teardown => "TEARDOWN",
            Self::GetParameter => "GET_PARAMETER",
            Self::SetParameter => "SET_PARAMETER",
            Self::Options => "OPTIONS",
            Self::Announce => "ANNOUNCE",
            Self::Record => "RECORD",
            Self::Redirect => "REDIRECT",
        }
    }

    /// Whether this method requires an active session.
    pub fn requires_session(self) -> bool {
        matches!(
            self,
            Self::Play
                | Self::Pause
                | Self::Teardown
                | Self::GetParameter
                | Self::SetParameter
                | Self::Record
        )
    }

    /// All supported methods.
    pub const ALL: [Method; 11] = [
        Self::Describe, Self::Setup, Self::Play, Self::Pause, Self::Teardown,
        Self::GetParameter, Self::SetParameter, Self::Options, Self::Announce,
        Self::Record, Self::Redirect,
    ];
}

impl fmt::Display for Method {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.name())
    }
}

// ===========================================================================
// TransportProtocol (tags 0-2)
// ===========================================================================

/// RTP transport protocol variants used in RTSP SETUP.
///
/// Matches `TransportProtocol` in `RTSPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransportProtocol {
    /// RTP/AVP over UDP unicast (tag 0).
    RtpAvpUdp = 0,
    /// RTP/AVP interleaved over TCP (tag 1).
    RtpAvpTcp = 1,
    /// RTP/AVP over UDP multicast (tag 2).
    RtpAvpUdpMulticast = 2,
}

impl TransportProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RtpAvpUdp),
            1 => Some(Self::RtpAvpTcp),
            2 => Some(Self::RtpAvpUdpMulticast),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this transport uses TCP.
    pub fn is_tcp(self) -> bool {
        matches!(self, Self::RtpAvpTcp)
    }

    /// Whether this transport uses multicast.
    pub fn is_multicast(self) -> bool {
        matches!(self, Self::RtpAvpUdpMulticast)
    }
}

impl fmt::Display for TransportProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// RTSP session state machine.
///
/// Matches `SessionState` in `RTSPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Initial state, no session established (tag 0).
    Init = 0,
    /// Session set up, ready for playback commands (tag 1).
    Ready = 1,
    /// Media is being played back (tag 2).
    Playing = 2,
    /// Media is being recorded (tag 3).
    Recording = 3,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Init),
            1 => Some(Self::Ready),
            2 => Some(Self::Playing),
            3 => Some(Self::Recording),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether media is actively streaming (playing or recording).
    pub fn is_active(self) -> bool {
        matches!(self, Self::Playing | Self::Recording)
    }

    /// Validate whether a state transition is allowed.
    pub fn can_transition_to(self, next: SessionState) -> bool {
        matches!(
            (self, next),
            (Self::Init, Self::Ready)       // SETUP
                | (Self::Ready, Self::Playing)   // PLAY
                | (Self::Ready, Self::Recording) // RECORD
                | (Self::Playing, Self::Ready)   // PAUSE
                | (Self::Recording, Self::Ready) // PAUSE
                | (Self::Ready, Self::Init)      // TEARDOWN
                | (Self::Playing, Self::Init)    // TEARDOWN
                | (Self::Recording, Self::Init)  // TEARDOWN
        )
    }
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StatusCode (tags 0-11)
// ===========================================================================

/// RTSP response status codes (RFC 7826).
///
/// Matches `StatusCode` in `RTSPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCode {
    /// 200 OK (tag 0).
    Ok = 0,
    /// 301 Moved Permanently (tag 1).
    MovedPermanently = 1,
    /// 302 Moved Temporarily (tag 2).
    MovedTemporarily = 2,
    /// 400 Bad Request (tag 3).
    BadRequest = 3,
    /// 401 Unauthorized (tag 4).
    Unauthorized = 4,
    /// 404 Not Found (tag 5).
    NotFound = 5,
    /// 405 Method Not Allowed (tag 6).
    MethodNotAllowed = 6,
    /// 406 Not Acceptable (tag 7).
    NotAcceptable = 7,
    /// 454 Session Not Found (tag 8).
    SessionNotFound = 8,
    /// 500 Internal Server Error (tag 9).
    InternalServerError = 9,
    /// 501 Not Implemented (tag 10).
    NotImplemented = 10,
    /// 503 Service Unavailable (tag 11).
    ServiceUnavailable = 11,
}

impl StatusCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::MovedPermanently),
            2 => Some(Self::MovedTemporarily),
            3 => Some(Self::BadRequest),
            4 => Some(Self::Unauthorized),
            5 => Some(Self::NotFound),
            6 => Some(Self::MethodNotAllowed),
            7 => Some(Self::NotAcceptable),
            8 => Some(Self::SessionNotFound),
            9 => Some(Self::InternalServerError),
            10 => Some(Self::NotImplemented),
            11 => Some(Self::ServiceUnavailable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this status code indicates success (2xx).
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// Whether this status code indicates a client error (4xx).
    pub fn is_client_error(self) -> bool {
        matches!(
            self,
            Self::BadRequest
                | Self::Unauthorized
                | Self::NotFound
                | Self::MethodNotAllowed
                | Self::NotAcceptable
                | Self::SessionNotFound
        )
    }

    /// Whether this status code indicates a server error (5xx).
    pub fn is_server_error(self) -> bool {
        matches!(
            self,
            Self::InternalServerError | Self::NotImplemented | Self::ServiceUnavailable
        )
    }

    /// All supported status codes.
    pub const ALL: [StatusCode; 12] = [
        Self::Ok, Self::MovedPermanently, Self::MovedTemporarily,
        Self::BadRequest, Self::Unauthorized, Self::NotFound,
        Self::MethodNotAllowed, Self::NotAcceptable, Self::SessionNotFound,
        Self::InternalServerError, Self::NotImplemented, Self::ServiceUnavailable,
    ];
}

impl fmt::Display for StatusCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RtspError (tags 0-6)
// ===========================================================================

/// RTSP FFI error codes.
///
/// Matches `RTSPError` in `RTSPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RtspError {
    /// No error (tag 0).
    Ok = 0,
    /// Invalid slot index (tag 1).
    InvalidSlot = 1,
    /// Session not active (tag 2).
    NotActive = 2,
    /// Invalid session state transition (tag 3).
    InvalidTransition = 3,
    /// Method not allowed in current state (tag 4).
    MethodNotAllowed = 4,
    /// Transport setup failed (tag 5).
    TransportError = 5,
    /// Session expired (tag 6).
    SessionExpired = 6,
}

impl RtspError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::InvalidSlot),
            2 => Some(Self::NotActive),
            3 => Some(Self::InvalidTransition),
            4 => Some(Self::MethodNotAllowed),
            5 => Some(Self::TransportError),
            6 => Some(Self::SessionExpired),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this represents a successful outcome.
    pub fn is_ok(self) -> bool {
        matches!(self, Self::Ok)
    }
}

impl fmt::Display for RtspError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for RtspError {}

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
        assert!(Method::from_tag(11).is_none());
    }

    #[test]
    fn method_session_requirement() {
        assert!(!Method::Describe.requires_session());
        assert!(!Method::Options.requires_session());
        assert!(Method::Play.requires_session());
        assert!(Method::Pause.requires_session());
        assert!(Method::Teardown.requires_session());
    }

    #[test]
    fn transport_roundtrip() {
        for tag in 0u8..=2 {
            let tp = TransportProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(tp.to_tag(), tag);
        }
        assert!(TransportProtocol::from_tag(3).is_none());
    }

    #[test]
    fn transport_classification() {
        assert!(TransportProtocol::RtpAvpTcp.is_tcp());
        assert!(!TransportProtocol::RtpAvpUdp.is_tcp());
        assert!(TransportProtocol::RtpAvpUdpMulticast.is_multicast());
        assert!(!TransportProtocol::RtpAvpUdp.is_multicast());
    }

    #[test]
    fn session_state_roundtrip() {
        for tag in 0u8..=3 {
            let ss = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(ss.to_tag(), tag);
        }
        assert!(SessionState::from_tag(4).is_none());
    }

    #[test]
    fn session_state_transitions() {
        assert!(SessionState::Init.can_transition_to(SessionState::Ready));
        assert!(SessionState::Ready.can_transition_to(SessionState::Playing));
        assert!(SessionState::Ready.can_transition_to(SessionState::Recording));
        assert!(SessionState::Playing.can_transition_to(SessionState::Ready));
        assert!(!SessionState::Init.can_transition_to(SessionState::Playing));
    }

    #[test]
    fn status_code_roundtrip() {
        for sc in StatusCode::ALL {
            let tag = sc.to_tag();
            let decoded = StatusCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, sc);
        }
        assert!(StatusCode::from_tag(12).is_none());
    }

    #[test]
    fn status_code_classification() {
        assert!(StatusCode::Ok.is_success());
        assert!(!StatusCode::BadRequest.is_success());
        assert!(StatusCode::BadRequest.is_client_error());
        assert!(StatusCode::InternalServerError.is_server_error());
        assert!(!StatusCode::Ok.is_server_error());
    }

    #[test]
    fn rtsp_error_roundtrip() {
        for tag in 0u8..=6 {
            let re = RtspError::from_tag(tag).expect("valid tag");
            assert_eq!(re.to_tag(), tag);
        }
        assert!(RtspError::from_tag(7).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(RTSP_PORT, 554);
        assert_eq!(RTSPS_PORT, 322);
    }
}
