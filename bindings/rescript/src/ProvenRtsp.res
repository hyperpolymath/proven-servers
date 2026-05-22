// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP (Real Time Streaming Protocol) types for the proven-servers ABI.
//
// Mirrors the Idris2 module RTSPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard RTSP port (RFC 7826).
let rtspPort = 554

/// Standard RTSPS (RTSP over TLS) port.
let rtspsPort = 322

// ===========================================================================
// Method (tags 0-10)
// ===========================================================================

/// Standard RTSP port (RFC 7826).
type method =
  | @as(0) Describe
  | @as(1) Setup
  | @as(2) Play
  | @as(3) Pause
  | @as(4) Teardown
  | @as(5) GetParameter
  | @as(6) SetParameter
  | @as(7) Options
  | @as(8) Announce
  | @as(9) Record
  | @as(10) Redirect

/// Decode from the C-ABI tag value.
let methodFromTag = (tag: int): option<method> =>
  switch tag {
  | 0 => Some(Describe)
  | 1 => Some(Setup)
  | 2 => Some(Play)
  | 3 => Some(Pause)
  | 4 => Some(Teardown)
  | 5 => Some(GetParameter)
  | 6 => Some(SetParameter)
  | 7 => Some(Options)
  | 8 => Some(Announce)
  | 9 => Some(Record)
  | 10 => Some(Redirect)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodToTag = (v: method): int =>
  switch v {
  | Describe => 0
  | Setup => 1
  | Play => 2
  | Pause => 3
  | Teardown => 4
  | GetParameter => 5
  | SetParameter => 6
  | Options => 7
  | Announce => 8
  | Record => 9
  | Redirect => 10
  }

/// Whether this method requires an active session.
let methodRequiresSession = (v: method): bool =>
  switch v {
  | Play | Pause | Teardown | GetParameter | SetParameter | Record => true
  | _ => false
  }

// ===========================================================================
// TransportProtocol (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type transportProtocol =
  | @as(0) RtpAvpUdp
  | @as(1) RtpAvpTcp
  | @as(2) RtpAvpUdpMulticast

/// Decode from the C-ABI tag value.
let transportProtocolFromTag = (tag: int): option<transportProtocol> =>
  switch tag {
  | 0 => Some(RtpAvpUdp)
  | 1 => Some(RtpAvpTcp)
  | 2 => Some(RtpAvpUdpMulticast)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transportProtocolToTag = (v: transportProtocol): int =>
  switch v {
  | RtpAvpUdp => 0
  | RtpAvpTcp => 1
  | RtpAvpUdpMulticast => 2
  }

/// Whether this transport uses TCP.
let transportProtocolIsTcp = (v: transportProtocol): bool =>
  switch v {
  | RtpAvpTcp => true
  | _ => false
  }

/// Whether this transport uses multicast.
let transportProtocolIsMulticast = (v: transportProtocol): bool =>
  switch v {
  | RtpAvpUdpMulticast => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Init
  | @as(1) Ready
  | @as(2) Playing
  | @as(3) Recording

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Init)
  | 1 => Some(Ready)
  | 2 => Some(Playing)
  | 3 => Some(Recording)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Init => 0
  | Ready => 1
  | Playing => 2
  | Recording => 3
  }

/// Validate whether a state transition is allowed.
let sessionStateCanTransitionTo = (from: sessionState, to: sessionState): bool =>
  switch (from, to) {
  | _ => false
  }

/// Whether media is actively streaming (playing or recording).
let sessionStateIsActive = (v: sessionState): bool =>
  switch v {
  | Playing | Recording => true
  | _ => false
  }

// ===========================================================================
// StatusCode (tags 0-11)
// ===========================================================================

/// Decode from an ABI tag value.
type statusCode =
  | @as(0) Ok
  | @as(1) MovedPermanently
  | @as(2) MovedTemporarily
  | @as(3) BadRequest
  | @as(4) Unauthorized
  | @as(5) NotFound
  | @as(6) MethodNotAllowed
  | @as(7) NotAcceptable
  | @as(8) SessionNotFound
  | @as(9) InternalServerError
  | @as(10) NotImplemented
  | @as(11) ServiceUnavailable

/// Decode from the C-ABI tag value.
let statusCodeFromTag = (tag: int): option<statusCode> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(MovedPermanently)
  | 2 => Some(MovedTemporarily)
  | 3 => Some(BadRequest)
  | 4 => Some(Unauthorized)
  | 5 => Some(NotFound)
  | 6 => Some(MethodNotAllowed)
  | 7 => Some(NotAcceptable)
  | 8 => Some(SessionNotFound)
  | 9 => Some(InternalServerError)
  | 10 => Some(NotImplemented)
  | 11 => Some(ServiceUnavailable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusCodeToTag = (v: statusCode): int =>
  switch v {
  | Ok => 0
  | MovedPermanently => 1
  | MovedTemporarily => 2
  | BadRequest => 3
  | Unauthorized => 4
  | NotFound => 5
  | MethodNotAllowed => 6
  | NotAcceptable => 7
  | SessionNotFound => 8
  | InternalServerError => 9
  | NotImplemented => 10
  | ServiceUnavailable => 11
  }

/// Whether this status code indicates success (2xx).
let statusCodeIsSuccess = (v: statusCode): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

/// Whether this status code indicates a client error (4xx).
let statusCodeIsClientError = (v: statusCode): bool =>
  switch v {
  | BadRequest | Unauthorized | NotFound | MethodNotAllowed | NotAcceptable | SessionNotFound => true
  | _ => false
  }

/// Whether this status code indicates a server error (5xx).
let statusCodeIsServerError = (v: statusCode): bool =>
  switch v {
  | InternalServerError | NotImplemented | ServiceUnavailable => true
  | _ => false
  }

// ===========================================================================
// RtspError (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type rtspError =
  | @as(0) Ok
  | @as(1) InvalidSlot
  | @as(2) NotActive
  | @as(3) InvalidTransition
  | @as(4) MethodNotAllowed
  | @as(5) TransportError
  | @as(6) SessionExpired

/// Decode from the C-ABI tag value.
let rtspErrorFromTag = (tag: int): option<rtspError> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(InvalidSlot)
  | 2 => Some(NotActive)
  | 3 => Some(InvalidTransition)
  | 4 => Some(MethodNotAllowed)
  | 5 => Some(TransportError)
  | 6 => Some(SessionExpired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let rtspErrorToTag = (v: rtspError): int =>
  switch v {
  | Ok => 0
  | InvalidSlot => 1
  | NotActive => 2
  | InvalidTransition => 3
  | MethodNotAllowed => 4
  | TransportError => 5
  | SessionExpired => 6
  }

/// Whether this represents a successful outcome.
let rtspErrorIsOk = (v: rtspError): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

