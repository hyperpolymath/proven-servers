//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// XMPP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `XmppABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// XMPP Constants
// ===========================================================================

/// Xmpp Client Port constant.
pub const xmpp_client_port = 5222

/// Xmpp Server Port constant.
pub const xmpp_server_port = 5269

/// Xmpps Port constant.
pub const xmpps_port = 5223

// ===========================================================================
// StanzaType
// ===========================================================================

/// XMPP stanza types (RFC 6120 Section 8).
/// 
/// Matches `StanzaType` in `XMPPABI.Types`.
/// The three fundamental XML stanza types in the XMPP protocol.
pub type StanzaType {
  /// Message stanza — asynchronous messaging (tag 0).
  Message
  /// Presence stanza — availability broadcasting (tag 1).
  Presence
  /// IQ (Info/Query) stanza — request/response (tag 2).
  Iq
}

/// Convert a `StanzaType` to its C-ABI tag value.
pub fn stanza_type_to_int(value: StanzaType) -> Int {
  case value {
    Message -> 0
    Presence -> 1
    Iq -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn stanza_type_from_int(tag: Int) -> Result(StanzaType, Nil) {
  case tag {
    0 -> Ok(Message)
    1 -> Ok(Presence)
    2 -> Ok(Iq)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MessageType
// ===========================================================================

/// XMPP message types (RFC 6121 Section 5.2.2).
/// 
/// Matches `MessageType` in `XMPPABI.Types`.
pub type MessageType {
  /// One-to-one chat message (tag 0).
  Chat
  /// Error message (tag 1).
  MessageTypeError
  /// Multi-user chat / groupchat message (tag 2).
  Groupchat
  /// Headline / news message (tag 3).
  Headline
  /// Normal (standalone) message — default type (tag 4).
  Normal
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    Chat -> 0
    MessageTypeError -> 1
    Groupchat -> 2
    Headline -> 3
    Normal -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(Chat)
    1 -> Ok(MessageTypeError)
    2 -> Ok(Groupchat)
    3 -> Ok(Headline)
    4 -> Ok(Normal)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PresenceType
// ===========================================================================

/// XMPP presence show values (RFC 6121 Section 4.7.2.1).
/// 
/// Matches `PresenceType` in `XMPPABI.Types`.
pub type PresenceType {
  /// Available — online and ready to communicate (tag 0).
  Available
  /// Away — temporarily absent (tag 1).
  Away
  /// Do Not Disturb — busy, should not be interrupted (tag 2).
  Dnd
  /// Extended Away — away for a longer period (tag 3).
  Xa
  /// Unavailable — offline (tag 4).
  Unavailable
}

/// Convert a `PresenceType` to its C-ABI tag value.
pub fn presence_type_to_int(value: PresenceType) -> Int {
  case value {
    Available -> 0
    Away -> 1
    Dnd -> 2
    Xa -> 3
    Unavailable -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn presence_type_from_int(tag: Int) -> Result(PresenceType, Nil) {
  case tag {
    0 -> Ok(Available)
    1 -> Ok(Away)
    2 -> Ok(Dnd)
    3 -> Ok(Xa)
    4 -> Ok(Unavailable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IqType
// ===========================================================================

/// XMPP IQ (Info/Query) stanza types (RFC 6120 Section 8.2.3).
/// 
/// Matches `IQType` in `XMPPABI.Types`.
pub type IqType {
  /// Get — request information (tag 0).
  Get
  /// Set — provide information or make a request (tag 1).
  Set
  /// Result — successful response (tag 2).
  Result
  /// Error — error response (tag 3).
  IqTypeError
}

/// Convert a `IqType` to its C-ABI tag value.
pub fn iq_type_to_int(value: IqType) -> Int {
  case value {
    Get -> 0
    Set -> 1
    Result -> 2
    IqTypeError -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn iq_type_from_int(tag: Int) -> Result(IqType, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Set)
    2 -> Ok(Result)
    3 -> Ok(IqTypeError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StreamError
// ===========================================================================

/// XMPP stream-level error conditions (RFC 6120 Section 4.9.3).
/// 
/// Matches `StreamError` in `XMPPABI.Types`.
pub type StreamError {
  /// Malformed XML or protocol violation (tag 0).
  BadFormat
  /// Resource conflict (tag 1).
  Conflict
  /// Connection timed out (tag 2).
  ConnectionTimeout
  /// Remote host is no longer available (tag 3).
  HostGone
  /// Remote host is unknown (tag 4).
  HostUnknown
  /// Entity is not authorised (tag 5).
  NotAuthorized
  /// Policy violation (tag 6).
  PolicyViolation
  /// Server resource constraint (tag 7).
  ResourceConstraint
  /// System is shutting down (tag 8).
  SystemShutdown
}

/// Convert a `StreamError` to its C-ABI tag value.
pub fn stream_error_to_int(value: StreamError) -> Int {
  case value {
    BadFormat -> 0
    Conflict -> 1
    ConnectionTimeout -> 2
    HostGone -> 3
    HostUnknown -> 4
    NotAuthorized -> 5
    PolicyViolation -> 6
    ResourceConstraint -> 7
    SystemShutdown -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn stream_error_from_int(tag: Int) -> Result(StreamError, Nil) {
  case tag {
    0 -> Ok(BadFormat)
    1 -> Ok(Conflict)
    2 -> Ok(ConnectionTimeout)
    3 -> Ok(HostGone)
    4 -> Ok(HostUnknown)
    5 -> Ok(NotAuthorized)
    6 -> Ok(PolicyViolation)
    7 -> Ok(ResourceConstraint)
    8 -> Ok(SystemShutdown)
    _ -> Error(Nil)
  }
}

