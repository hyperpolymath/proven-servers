//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// RTSP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `RtspABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// RTSP Constants
// ===========================================================================

/// Rtsp Port constant.
pub const rtsp_port = 554

/// Rtsps Port constant.
pub const rtsps_port = 322

// ===========================================================================
// Method
// ===========================================================================

/// RTSP request methods (RFC 7826).
/// 
/// Matches `Method` in `RTSPABI.Types`.
pub type Method {
  /// Retrieve media description (tag 0).
  Describe
  /// Set up transport for a media stream (tag 1).
  Setup
  /// Start playback of a media stream (tag 2).
  Play
  /// Pause playback (tag 3).
  Pause
  /// Tear down a session and release resources (tag 4).
  Teardown
  /// Retrieve server/session parameter (tag 5).
  GetParameter
  /// Set server/session parameter (tag 6).
  SetParameter
  /// Query server capabilities (tag 7).
  Options
  /// Post media description to the server (tag 8).
  Announce
  /// Start recording a media stream (tag 9).
  Record
  /// Redirect client to a new server (tag 10).
  Redirect
}

/// Convert a `Method` to its C-ABI tag value.
pub fn method_to_int(value: Method) -> Int {
  case value {
    Describe -> 0
    Setup -> 1
    Play -> 2
    Pause -> 3
    Teardown -> 4
    GetParameter -> 5
    SetParameter -> 6
    Options -> 7
    Announce -> 8
    Record -> 9
    Redirect -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn method_from_int(tag: Int) -> Result(Method, Nil) {
  case tag {
    0 -> Ok(Describe)
    1 -> Ok(Setup)
    2 -> Ok(Play)
    3 -> Ok(Pause)
    4 -> Ok(Teardown)
    5 -> Ok(GetParameter)
    6 -> Ok(SetParameter)
    7 -> Ok(Options)
    8 -> Ok(Announce)
    9 -> Ok(Record)
    10 -> Ok(Redirect)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransportProtocol
// ===========================================================================

/// RTP transport protocol variants used in RTSP SETUP.
/// 
/// Matches `TransportProtocol` in `RTSPABI.Types`.
pub type TransportProtocol {
  /// RTP/AVP over UDP unicast (tag 0).
  RtpAvpUdp
  /// RTP/AVP interleaved over TCP (tag 1).
  RtpAvpTcp
  /// RTP/AVP over UDP multicast (tag 2).
  RtpAvpUdpMulticast
}

/// Convert a `TransportProtocol` to its C-ABI tag value.
pub fn transport_protocol_to_int(value: TransportProtocol) -> Int {
  case value {
    RtpAvpUdp -> 0
    RtpAvpTcp -> 1
    RtpAvpUdpMulticast -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn transport_protocol_from_int(tag: Int) -> Result(TransportProtocol, Nil) {
  case tag {
    0 -> Ok(RtpAvpUdp)
    1 -> Ok(RtpAvpTcp)
    2 -> Ok(RtpAvpUdpMulticast)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// RTSP session state machine.
/// 
/// Matches `SessionState` in `RTSPABI.Types`.
pub type SessionState {
  /// Initial state, no session established (tag 0).
  Init
  /// Session set up, ready for playback commands (tag 1).
  Ready
  /// Media is being played back (tag 2).
  Playing
  /// Media is being recorded (tag 3).
  Recording
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Init -> 0
    Ready -> 1
    Playing -> 2
    Recording -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Init)
    1 -> Ok(Ready)
    2 -> Ok(Playing)
    3 -> Ok(Recording)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn session_state_can_transition_to(from: SessionState, to: SessionState) -> Bool {
  case from, to {
    Init, Ready -> True
    Ready, Playing -> True
    Ready, Recording -> True
    Playing, Ready -> True
    Recording, Ready -> True
    Ready, Init -> True
    Playing, Init -> True
    Recording, Init -> True
    _, _ -> False
  }
}

// ===========================================================================
// StatusCode
// ===========================================================================

/// RTSP response status codes (RFC 7826).
/// 
/// Matches `StatusCode` in `RTSPABI.Types`.
pub type StatusCode {
  /// 200 OK (tag 0).
  StatusCodeOk
  /// 301 Moved Permanently (tag 1).
  MovedPermanently
  /// 302 Moved Temporarily (tag 2).
  MovedTemporarily
  /// 400 Bad Request (tag 3).
  BadRequest
  /// 401 Unauthorized (tag 4).
  Unauthorized
  /// 404 Not Found (tag 5).
  NotFound
  /// 405 Method Not Allowed (tag 6).
  StatusCodeMethodNotAllowed
  /// 406 Not Acceptable (tag 7).
  NotAcceptable
  /// 454 Session Not Found (tag 8).
  SessionNotFound
  /// 500 Internal Server Error (tag 9).
  InternalServerError
  /// 501 Not Implemented (tag 10).
  NotImplemented
  /// 503 Service Unavailable (tag 11).
  ServiceUnavailable
}

/// Convert a `StatusCode` to its C-ABI tag value.
pub fn status_code_to_int(value: StatusCode) -> Int {
  case value {
    StatusCodeOk -> 0
    MovedPermanently -> 1
    MovedTemporarily -> 2
    BadRequest -> 3
    Unauthorized -> 4
    NotFound -> 5
    StatusCodeMethodNotAllowed -> 6
    NotAcceptable -> 7
    SessionNotFound -> 8
    InternalServerError -> 9
    NotImplemented -> 10
    ServiceUnavailable -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn status_code_from_int(tag: Int) -> Result(StatusCode, Nil) {
  case tag {
    0 -> Ok(StatusCodeOk)
    1 -> Ok(MovedPermanently)
    2 -> Ok(MovedTemporarily)
    3 -> Ok(BadRequest)
    4 -> Ok(Unauthorized)
    5 -> Ok(NotFound)
    6 -> Ok(StatusCodeMethodNotAllowed)
    7 -> Ok(NotAcceptable)
    8 -> Ok(SessionNotFound)
    9 -> Ok(InternalServerError)
    10 -> Ok(NotImplemented)
    11 -> Ok(ServiceUnavailable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RtspError
// ===========================================================================

/// RTSP FFI error codes.
/// 
/// Matches `RTSPError` in `RTSPABI.Types`.
pub type RtspError {
  /// No error (tag 0).
  RtspErrorOk
  /// Invalid slot index (tag 1).
  InvalidSlot
  /// Session not active (tag 2).
  NotActive
  /// Invalid session state transition (tag 3).
  InvalidTransition
  /// Method not allowed in current state (tag 4).
  RtspErrorMethodNotAllowed
  /// Transport setup failed (tag 5).
  TransportError
  /// Session expired (tag 6).
  SessionExpired
}

/// Convert a `RtspError` to its C-ABI tag value.
pub fn rtsp_error_to_int(value: RtspError) -> Int {
  case value {
    RtspErrorOk -> 0
    InvalidSlot -> 1
    NotActive -> 2
    InvalidTransition -> 3
    RtspErrorMethodNotAllowed -> 4
    TransportError -> 5
    SessionExpired -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn rtsp_error_from_int(tag: Int) -> Result(RtspError, Nil) {
  case tag {
    0 -> Ok(RtspErrorOk)
    1 -> Ok(InvalidSlot)
    2 -> Ok(NotActive)
    3 -> Ok(InvalidTransition)
    4 -> Ok(RtspErrorMethodNotAllowed)
    5 -> Ok(TransportError)
    6 -> Ok(SessionExpired)
    _ -> Error(Nil)
  }
}

