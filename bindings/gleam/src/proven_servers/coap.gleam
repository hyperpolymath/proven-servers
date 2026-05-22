//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// CoAP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CoapABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// CoAP Constants
// ===========================================================================

/// Coap Port constant.
pub const coap_port = 5683

/// Coaps Port constant.
pub const coaps_port = 5684

/// Coap Default Block Size constant.
pub const coap_default_block_size = 1024

// ===========================================================================
// Method
// ===========================================================================

/// CoAP request methods (RFC 7252 Section 5.8).
/// 
/// Matches `Method` in `CoapABI.Types`.
pub type Method {
  /// GET — retrieve a resource representation (tag 0).
  Get
  /// POST — process a resource representation (tag 1).
  Post
  /// PUT — update or create a resource (tag 2).
  Put
  /// DELETE — remove a resource (tag 3).
  Delete
}

/// Convert a `Method` to its C-ABI tag value.
pub fn method_to_int(value: Method) -> Int {
  case value {
    Get -> 0
    Post -> 1
    Put -> 2
    Delete -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn method_from_int(tag: Int) -> Result(Method, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Post)
    2 -> Ok(Put)
    3 -> Ok(Delete)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MessageType
// ===========================================================================

/// CoAP message types (RFC 7252 Section 4.1).
/// 
/// Matches `MessageType` in `CoapABI.Types`.
pub type MessageType {
  /// Confirmable — requires acknowledgement (tag 0).
  Confirmable
  /// Non-confirmable — fire-and-forget (tag 1).
  NonConfirmable
  /// Acknowledgement — reply to a confirmable (tag 2).
  Acknowledgement
  /// Reset — reject a message (tag 3).
  Reset
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    Confirmable -> 0
    NonConfirmable -> 1
    Acknowledgement -> 2
    Reset -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(Confirmable)
    1 -> Ok(NonConfirmable)
    2 -> Ok(Acknowledgement)
    3 -> Ok(Reset)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ContentFormat
// ===========================================================================

/// CoAP content formats (RFC 7252 Section 12.3).
/// 
/// Matches `ContentFormat` in `CoapABI.Types`.
pub type ContentFormat {
  /// text/plain; charset=utf-8 (tag 0).
  TextPlain
  /// application/link-format (tag 1).
  LinkFormat
  /// application/xml (tag 2).
  Xml
  /// application/octet-stream (tag 3).
  OctetStream
  /// application/exi (tag 4).
  Exi
  /// application/json (tag 5).
  Json
  /// application/cbor (tag 6).
  Cbor
}

/// Convert a `ContentFormat` to its C-ABI tag value.
pub fn content_format_to_int(value: ContentFormat) -> Int {
  case value {
    TextPlain -> 0
    LinkFormat -> 1
    Xml -> 2
    OctetStream -> 3
    Exi -> 4
    Json -> 5
    Cbor -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn content_format_from_int(tag: Int) -> Result(ContentFormat, Nil) {
  case tag {
    0 -> Ok(TextPlain)
    1 -> Ok(LinkFormat)
    2 -> Ok(Xml)
    3 -> Ok(OctetStream)
    4 -> Ok(Exi)
    5 -> Ok(Json)
    6 -> Ok(Cbor)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponseClass
// ===========================================================================

/// CoAP response class codes (RFC 7252 Section 5.9).
/// 
/// Matches `ResponseClass` in `CoapABI.Types`.
pub type ResponseClass {
  /// 2.xx Success (tag 0).
  Success
  /// 4.xx Client Error (tag 1).
  ClientError
  /// 5.xx Server Error (tag 2).
  ServerError
  /// Signaling codes — CSM, Ping, Pong, Release, Abort (tag 3).
  Signaling
  /// Empty message (tag 4).
  Empty
}

/// Convert a `ResponseClass` to its C-ABI tag value.
pub fn response_class_to_int(value: ResponseClass) -> Int {
  case value {
    Success -> 0
    ClientError -> 1
    ServerError -> 2
    Signaling -> 3
    Empty -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn response_class_from_int(tag: Int) -> Result(ResponseClass, Nil) {
  case tag {
    0 -> Ok(Success)
    1 -> Ok(ClientError)
    2 -> Ok(ServerError)
    3 -> Ok(Signaling)
    4 -> Ok(Empty)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// CoAP server lifecycle states for the FFI layer.
/// 
/// Matches `SessionState` in `CoapABI.Types`.
pub type SessionState {
  /// No server active (tag 0).
  Idle
  /// Socket bound to a port (tag 1).
  Bound
  /// Actively serving CoAP requests (tag 2).
  Serving
  /// Observing resources (RFC 7641) (tag 3).
  Observing
  /// Server shutting down (tag 4).
  Shutdown
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Bound -> 1
    Serving -> 2
    Observing -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Bound)
    2 -> Ok(Serving)
    3 -> Ok(Observing)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

