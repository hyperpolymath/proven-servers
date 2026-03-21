// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP (Constrained Application Protocol) types for the proven-servers ABI.
//
// Mirrors the Idris2 module CoapABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard CoAP port (RFC 7252).
let coapPort = 5683

/// Standard CoAPS (CoAP over DTLS) port (RFC 7252).
let coapsPort = 5684

/// Default CoAP block size (RFC 7959).
let coapDefaultBlockSize = 1024

// ===========================================================================
// Method (tags 0-3)
// ===========================================================================

/// Standard CoAP port (RFC 7252).
type method =
  | @as(0) Get
  | @as(1) Post
  | @as(2) Put
  | @as(3) Delete

/// Decode from the C-ABI tag value.
let methodFromTag = (tag: int): option<method> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Post)
  | 2 => Some(Put)
  | 3 => Some(Delete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let methodToTag = (v: method): int =>
  switch v {
  | Get => 0
  | Post => 1
  | Put => 2
  | Delete => 3
  }

/// Whether this method is safe (does not alter server state).
let methodIsSafe = (v: method): bool =>
  switch v {
  | Get => true
  | _ => false
  }

/// Whether this method is idempotent.
let methodIsIdempotent = (v: method): bool =>
  switch v {
  | Get | Put | Delete => true
  | _ => false
  }

// ===========================================================================
// MessageType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type messageType =
  | @as(0) Confirmable
  | @as(1) NonConfirmable
  | @as(2) Acknowledgement
  | @as(3) Reset

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(Confirmable)
  | 1 => Some(NonConfirmable)
  | 2 => Some(Acknowledgement)
  | 3 => Some(Reset)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | Confirmable => 0
  | NonConfirmable => 1
  | Acknowledgement => 2
  | Reset => 3
  }

/// Whether this message type requires a response.
let messageTypeRequiresResponse = (v: messageType): bool =>
  switch v {
  | Confirmable => true
  | _ => false
  }

/// Whether this message type is a response.
let messageTypeIsResponse = (v: messageType): bool =>
  switch v {
  | Acknowledgement | Reset => true
  | _ => false
  }

// ===========================================================================
// ContentFormat (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type contentFormat =
  | @as(0) TextPlain
  | @as(1) LinkFormat
  | @as(2) Xml
  | @as(3) OctetStream
  | @as(4) Exi
  | @as(5) Json
  | @as(6) Cbor

/// Decode from the C-ABI tag value.
let contentFormatFromTag = (tag: int): option<contentFormat> =>
  switch tag {
  | 0 => Some(TextPlain)
  | 1 => Some(LinkFormat)
  | 2 => Some(Xml)
  | 3 => Some(OctetStream)
  | 4 => Some(Exi)
  | 5 => Some(Json)
  | 6 => Some(Cbor)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let contentFormatToTag = (v: contentFormat): int =>
  switch v {
  | TextPlain => 0
  | LinkFormat => 1
  | Xml => 2
  | OctetStream => 3
  | Exi => 4
  | Json => 5
  | Cbor => 6
  }

/// Whether this format is text-based (human-readable).
let contentFormatIsTextBased = (v: contentFormat): bool =>
  switch v {
  | TextPlain | LinkFormat | Xml | Json => true
  | _ => false
  }

// ===========================================================================
// ResponseClass (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type responseClass =
  | @as(0) Success
  | @as(1) ClientError
  | @as(2) ServerError
  | @as(3) Signaling
  | @as(4) Empty

/// Decode from the C-ABI tag value.
let responseClassFromTag = (tag: int): option<responseClass> =>
  switch tag {
  | 0 => Some(Success)
  | 1 => Some(ClientError)
  | 2 => Some(ServerError)
  | 3 => Some(Signaling)
  | 4 => Some(Empty)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseClassToTag = (v: responseClass): int =>
  switch v {
  | Success => 0
  | ClientError => 1
  | ServerError => 2
  | Signaling => 3
  | Empty => 4
  }

/// Whether this response class indicates success.
let responseClassIsSuccess = (v: responseClass): bool =>
  switch v {
  | Success => true
  | _ => false
  }

/// Whether this response class indicates an error.
let responseClassIsError = (v: responseClass): bool =>
  switch v {
  | ClientError | ServerError => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Bound
  | @as(2) Serving
  | @as(3) Observing
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Bound)
  | 2 => Some(Serving)
  | 3 => Some(Observing)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Bound => 1
  | Serving => 2
  | Observing => 3
  | Shutdown => 4
  }

/// Whether the server is ready to handle requests.
let sessionStateIsActive = (v: sessionState): bool =>
  switch v {
  | Serving | Observing => true
  | _ => false
  }

