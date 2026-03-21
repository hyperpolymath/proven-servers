// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module RadiusABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard RADIUS authentication port (RFC 2865).
let radiusAuthPort = 1812

/// Standard RADIUS accounting port (RFC 2866).
let radiusAcctPort = 1813

// ===========================================================================
// PacketType (tags 0-11)
// ===========================================================================

/// Standard RADIUS authentication port (RFC 2865).
type packetType =
  | @as(1) AccessRequest
  | @as(2) AccessAccept
  | @as(3) AccessReject
  | @as(4) AccountingRequest
  | @as(5) AccountingResponse
  | @as(11) AccessChallenge

/// Decode from the C-ABI tag value.
let packetTypeFromTag = (tag: int): option<packetType> =>
  switch tag {
  | 1 => Some(AccessRequest)
  | 2 => Some(AccessAccept)
  | 3 => Some(AccessReject)
  | 4 => Some(AccountingRequest)
  | 5 => Some(AccountingResponse)
  | 11 => Some(AccessChallenge)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let packetTypeToTag = (v: packetType): int =>
  switch v {
  | AccessRequest => 1
  | AccessAccept => 2
  | AccessReject => 3
  | AccountingRequest => 4
  | AccountingResponse => 5
  | AccessChallenge => 11
  }

/// Whether this packet is an authentication request/response.
let packetTypeIsAuth = (v: packetType): bool =>
  switch v {
  | AccessRequest | AccessAccept | AccessReject | AccessChallenge => true
  | _ => false
  }

/// Whether this packet is an accounting request/response.
let packetTypeIsAccounting = (v: packetType): bool =>
  switch v {
  | AccountingRequest | AccountingResponse => true
  | _ => false
  }

/// Whether this packet is a request (client -> server).
let packetTypeIsRequest = (v: packetType): bool =>
  switch v {
  | AccessRequest | AccountingRequest => true
  | _ => false
  }

// ===========================================================================
// AttributeType (tags 0-27)
// ===========================================================================

/// Decode from an ABI tag value.
type attributeType =
  | @as(1) UserName
  | @as(2) UserPassword
  | @as(4) NasIpAddress
  | @as(5) NasPort
  | @as(6) ServiceType
  | @as(7) FramedProtocol
  | @as(8) FramedIpAddress
  | @as(18) ReplyMessage
  | @as(27) SessionTimeout

/// Decode from the C-ABI tag value.
let attributeTypeFromTag = (tag: int): option<attributeType> =>
  switch tag {
  | 1 => Some(UserName)
  | 2 => Some(UserPassword)
  | 4 => Some(NasIpAddress)
  | 5 => Some(NasPort)
  | 6 => Some(ServiceType)
  | 7 => Some(FramedProtocol)
  | 8 => Some(FramedIpAddress)
  | 18 => Some(ReplyMessage)
  | 27 => Some(SessionTimeout)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let attributeTypeToTag = (v: attributeType): int =>
  switch v {
  | UserName => 1
  | UserPassword => 2
  | NasIpAddress => 4
  | NasPort => 5
  | ServiceType => 6
  | FramedProtocol => 7
  | FramedIpAddress => 8
  | ReplyMessage => 18
  | SessionTimeout => 27
  }

/// Whether this attribute contains sensitive data.
let attributeTypeIsSensitive = (v: attributeType): bool =>
  switch v {
  | UserPassword => true
  | _ => false
  }

// ===========================================================================
// ServiceType (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type serviceType =
  | @as(1) Login
  | @as(2) Framed
  | @as(3) CallbackLogin
  | @as(4) CallbackFramed
  | @as(5) Outbound
  | @as(6) Administrative

/// Decode from the C-ABI tag value.
let serviceTypeFromTag = (tag: int): option<serviceType> =>
  switch tag {
  | 1 => Some(Login)
  | 2 => Some(Framed)
  | 3 => Some(CallbackLogin)
  | 4 => Some(CallbackFramed)
  | 5 => Some(Outbound)
  | 6 => Some(Administrative)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serviceTypeToTag = (v: serviceType): int =>
  switch v {
  | Login => 1
  | Framed => 2
  | CallbackLogin => 3
  | CallbackFramed => 4
  | Outbound => 5
  | Administrative => 6
  }

// ===========================================================================
// AuthMethod (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type authMethod =
  | @as(0) Pap
  | @as(1) Chap
  | @as(2) Mschap
  | @as(3) Mschapv2
  | @as(4) Eap

/// Decode from the C-ABI tag value.
let authMethodFromTag = (tag: int): option<authMethod> =>
  switch tag {
  | 0 => Some(Pap)
  | 1 => Some(Chap)
  | 2 => Some(Mschap)
  | 3 => Some(Mschapv2)
  | 4 => Some(Eap)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authMethodToTag = (v: authMethod): int =>
  switch v {
  | Pap => 0
  | Chap => 1
  | Mschap => 2
  | Mschapv2 => 3
  | Eap => 4
  }

/// Whether this method is considered legacy/weak.
let authMethodIsLegacy = (v: authMethod): bool =>
  switch v {
  | Pap | Mschap => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Authenticating
  | @as(2) Authorized
  | @as(3) Rejected
  | @as(4) Challenged
  | @as(5) Accounting
  | @as(6) Complete

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Authenticating)
  | 2 => Some(Authorized)
  | 3 => Some(Rejected)
  | 4 => Some(Challenged)
  | 5 => Some(Accounting)
  | 6 => Some(Complete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Authenticating => 1
  | Authorized => 2
  | Rejected => 3
  | Challenged => 4
  | Accounting => 5
  | Complete => 6
  }

/// Whether this is a terminal state.
let sessionStateIsTerminal = (v: sessionState): bool =>
  switch v {
  | Rejected | Complete => true
  | _ => false
  }

// ===========================================================================
// RadiusResult (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type radiusResult =
  | @as(0) Ok
  | @as(1) Err
  | @as(2) InvalidParam
  | @as(3) PoolExhausted
  | @as(4) BadSecret

/// Decode from the C-ABI tag value.
let radiusResultFromTag = (tag: int): option<radiusResult> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(Err)
  | 2 => Some(InvalidParam)
  | 3 => Some(PoolExhausted)
  | 4 => Some(BadSecret)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let radiusResultToTag = (v: radiusResult): int =>
  switch v {
  | Ok => 0
  | Err => 1
  | InvalidParam => 2
  | PoolExhausted => 3
  | BadSecret => 4
  }

/// Whether this result indicates success.
let radiusResultIsSuccess = (v: radiusResult): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

