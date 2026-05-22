// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP (Extensible Messaging and Presence Protocol) types for the
//
// Mirrors the Idris2 module XMPPABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard XMPP client-to-server port (RFC 6120).
let xmppClientPort = 5222

/// Standard XMPP server-to-server port (RFC 6120).
let xmppServerPort = 5269

/// XMPP over TLS (XMPPS) port for direct TLS connections.
let xmppsPort = 5223

// ===========================================================================
// StanzaType (tags 0-2)
// ===========================================================================

/// Standard XMPP client-to-server port (RFC 6120).
type stanzaType =
  | @as(0) Message
  | @as(1) Presence
  | @as(2) Iq

/// Decode from the C-ABI tag value.
let stanzaTypeFromTag = (tag: int): option<stanzaType> =>
  switch tag {
  | 0 => Some(Message)
  | 1 => Some(Presence)
  | 2 => Some(Iq)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let stanzaTypeToTag = (v: stanzaType): int =>
  switch v {
  | Message => 0
  | Presence => 1
  | Iq => 2
  }

// ===========================================================================
// MessageType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type messageType =
  | @as(0) Chat
  | @as(1) Error
  | @as(2) Groupchat
  | @as(3) Headline
  | @as(4) Normal

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(Chat)
  | 1 => Some(Error)
  | 2 => Some(Groupchat)
  | 3 => Some(Headline)
  | 4 => Some(Normal)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | Chat => 0
  | Error => 1
  | Groupchat => 2
  | Headline => 3
  | Normal => 4
  }

/// Whether this message type expects a reply.
let messageTypeExpectsReply = (v: messageType): bool =>
  switch v {
  | Chat | Normal => true
  | _ => false
  }

/// Whether this message type is for multi-party communication.
let messageTypeIsMultiParty = (v: messageType): bool =>
  switch v {
  | Groupchat => true
  | _ => false
  }

// ===========================================================================
// PresenceType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type presenceType =
  | @as(0) Available
  | @as(1) Away
  | @as(2) Dnd
  | @as(3) Xa
  | @as(4) Unavailable

/// Decode from the C-ABI tag value.
let presenceTypeFromTag = (tag: int): option<presenceType> =>
  switch tag {
  | 0 => Some(Available)
  | 1 => Some(Away)
  | 2 => Some(Dnd)
  | 3 => Some(Xa)
  | 4 => Some(Unavailable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let presenceTypeToTag = (v: presenceType): int =>
  switch v {
  | Available => 0
  | Away => 1
  | Dnd => 2
  | Xa => 3
  | Unavailable => 4
  }

/// Whether the entity is online (any form of availability).
let presenceTypeIsOnline = (v: presenceType): bool =>
  switch v {
  | Unavailable => false
  | _ => true
  }

/// Whether the entity is actively available for communication.
let presenceTypeIsAvailable = (v: presenceType): bool =>
  switch v {
  | Available => true
  | _ => false
  }

// ===========================================================================
// IqType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type iqType =
  | @as(0) Get
  | @as(1) Set
  | @as(2) Result
  | @as(3) Error

/// Decode from the C-ABI tag value.
let iqTypeFromTag = (tag: int): option<iqType> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Set)
  | 2 => Some(Result)
  | 3 => Some(Error)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let iqTypeToTag = (v: iqType): int =>
  switch v {
  | Get => 0
  | Set => 1
  | Result => 2
  | Error => 3
  }

/// Whether this IQ type is a request (requires a response).
let iqTypeIsRequest = (v: iqType): bool =>
  switch v {
  | Get | Set => true
  | _ => false
  }

/// Whether this IQ type is a response.
let iqTypeIsResponse = (v: iqType): bool =>
  switch v {
  | Result | Error => true
  | _ => false
  }

// ===========================================================================
// StreamError (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type streamError =
  | @as(0) BadFormat
  | @as(1) Conflict
  | @as(2) ConnectionTimeout
  | @as(3) HostGone
  | @as(4) HostUnknown
  | @as(5) NotAuthorized
  | @as(6) PolicyViolation
  | @as(7) ResourceConstraint
  | @as(8) SystemShutdown

/// Decode from the C-ABI tag value.
let streamErrorFromTag = (tag: int): option<streamError> =>
  switch tag {
  | 0 => Some(BadFormat)
  | 1 => Some(Conflict)
  | 2 => Some(ConnectionTimeout)
  | 3 => Some(HostGone)
  | 4 => Some(HostUnknown)
  | 5 => Some(NotAuthorized)
  | 6 => Some(PolicyViolation)
  | 7 => Some(ResourceConstraint)
  | 8 => Some(SystemShutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let streamErrorToTag = (v: streamError): int =>
  switch v {
  | BadFormat => 0
  | Conflict => 1
  | ConnectionTimeout => 2
  | HostGone => 3
  | HostUnknown => 4
  | NotAuthorized => 5
  | PolicyViolation => 6
  | ResourceConstraint => 7
  | SystemShutdown => 8
  }

/// Whether this error is related to security/authorisation.
let streamErrorIsSecurityError = (v: streamError): bool =>
  switch v {
  | NotAuthorized | PolicyViolation => true
  | _ => false
  }

/// Whether this error is likely transient and the connection can be retried.
let streamErrorIsRetryable = (v: streamError): bool =>
  switch v {
  | ConnectionTimeout | ResourceConstraint | SystemShutdown => true
  | _ => false
  }

