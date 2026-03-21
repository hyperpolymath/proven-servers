// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN types for the proven-servers ABI.
//
// Mirrors the Idris2 module StunABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard STUN port.
let stunPort = 3478

/// Standard STUN TLS port.
let stunTlsPort = 5349

// ===========================================================================
// MessageType (tags 0-11)
// ===========================================================================

/// Standard STUN port.
type messageType =
  | @as(0) BindingRequest
  | @as(1) BindingResponse
  | @as(2) BindingError
  | @as(3) AllocateRequest
  | @as(4) AllocateResponse
  | @as(5) AllocateError
  | @as(6) RefreshRequest
  | @as(7) RefreshResponse
  | @as(8) SendIndication
  | @as(9) DataIndication
  | @as(10) CreatePermission
  | @as(11) ChannelBind

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(BindingRequest)
  | 1 => Some(BindingResponse)
  | 2 => Some(BindingError)
  | 3 => Some(AllocateRequest)
  | 4 => Some(AllocateResponse)
  | 5 => Some(AllocateError)
  | 6 => Some(RefreshRequest)
  | 7 => Some(RefreshResponse)
  | 8 => Some(SendIndication)
  | 9 => Some(DataIndication)
  | 10 => Some(CreatePermission)
  | 11 => Some(ChannelBind)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | BindingRequest => 0
  | BindingResponse => 1
  | BindingError => 2
  | AllocateRequest => 3
  | AllocateResponse => 4
  | AllocateError => 5
  | RefreshRequest => 6
  | RefreshResponse => 7
  | SendIndication => 8
  | DataIndication => 9
  | CreatePermission => 10
  | ChannelBind => 11
  }

/// Whether this is a request message.
let messageTypeIsRequest = (v: messageType): bool =>
  switch v {
  | BindingRequest | AllocateRequest | RefreshRequest | CreatePermission | ChannelBind => true
  | _ => false
  }

/// Whether this is a TURN-specific message.
let messageTypeIsTurn = (v: messageType): bool =>
  switch v {
  | AllocateRequest | AllocateResponse | AllocateError | RefreshRequest | RefreshResponse | SendIndication | DataIndication | CreatePermission | ChannelBind => true
  | _ => false
  }

// ===========================================================================
// TransportProtocol (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type transportProtocol =
  | @as(0) Udp
  | @as(1) Tcp
  | @as(2) Tls
  | @as(3) Dtls

/// Decode from the C-ABI tag value.
let transportProtocolFromTag = (tag: int): option<transportProtocol> =>
  switch tag {
  | 0 => Some(Udp)
  | 1 => Some(Tcp)
  | 2 => Some(Tls)
  | 3 => Some(Dtls)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transportProtocolToTag = (v: transportProtocol): int =>
  switch v {
  | Udp => 0
  | Tcp => 1
  | Tls => 2
  | Dtls => 3
  }

// ===========================================================================
// ErrorCode (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) TryAlternate
  | @as(1) BadRequest
  | @as(2) Unauthorized
  | @as(3) Forbidden
  | @as(4) MobilityForbidden
  | @as(5) StaleNonce
  | @as(6) ServerError
  | @as(7) InsufficientCapacity

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(TryAlternate)
  | 1 => Some(BadRequest)
  | 2 => Some(Unauthorized)
  | 3 => Some(Forbidden)
  | 4 => Some(MobilityForbidden)
  | 5 => Some(StaleNonce)
  | 6 => Some(ServerError)
  | 7 => Some(InsufficientCapacity)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | TryAlternate => 0
  | BadRequest => 1
  | Unauthorized => 2
  | Forbidden => 3
  | MobilityForbidden => 4
  | StaleNonce => 5
  | ServerError => 6
  | InsufficientCapacity => 7
  }

