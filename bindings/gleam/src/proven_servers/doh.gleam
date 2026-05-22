//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DNS-over-HTTPS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DohABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DNS-over-HTTPS Constants
// ===========================================================================

/// Doh Port constant.
pub const doh_port = 443

// ===========================================================================
// ContentType
// ===========================================================================

/// DoH content types.
/// 
/// Matches `ContentType` in `DohABI.Types`.
pub type ContentType {
  /// application/dns-message (tag 0).
  DnsMessage
  /// application/dns-json (tag 1).
  DnsJson
}

/// Convert a `ContentType` to its C-ABI tag value.
pub fn content_type_to_int(value: ContentType) -> Int {
  case value {
    DnsMessage -> 0
    DnsJson -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn content_type_from_int(tag: Int) -> Result(ContentType, Nil) {
  case tag {
    0 -> Ok(DnsMessage)
    1 -> Ok(DnsJson)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RequestMethod
// ===========================================================================

/// DoH HTTP request methods.
/// 
/// Matches `RequestMethod` in `DohABI.Types`.
pub type RequestMethod {
  /// Get (tag 0).
  Get
  /// Post (tag 1).
  Post
}

/// Convert a `RequestMethod` to its C-ABI tag value.
pub fn request_method_to_int(value: RequestMethod) -> Int {
  case value {
    Get -> 0
    Post -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn request_method_from_int(tag: Int) -> Result(RequestMethod, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Post)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// WireFormat
// ===========================================================================

/// DNS wire format.
/// 
/// Matches `WireFormat` in `DohABI.Types`.
pub type WireFormat {
  /// Binary (tag 0).
  Binary
  /// Json (tag 1).
  Json
}

/// Convert a `WireFormat` to its C-ABI tag value.
pub fn wire_format_to_int(value: WireFormat) -> Int {
  case value {
    Binary -> 0
    Json -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn wire_format_from_int(tag: Int) -> Result(WireFormat, Nil) {
  case tag {
    0 -> Ok(Binary)
    1 -> Ok(Json)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorReason
// ===========================================================================

/// DoH-specific error reasons.
/// 
/// Matches `ErrorReason` in `DohABI.Types`.
pub type ErrorReason {
  /// BadContentType (tag 0).
  BadContentType
  /// BadMethod (tag 1).
  BadMethod
  /// PayloadTooLarge (tag 2).
  PayloadTooLarge
  /// UpstreamTimeout (tag 3).
  UpstreamTimeout
  /// UpstreamError (tag 4).
  UpstreamError
}

/// Convert a `ErrorReason` to its C-ABI tag value.
pub fn error_reason_to_int(value: ErrorReason) -> Int {
  case value {
    BadContentType -> 0
    BadMethod -> 1
    PayloadTooLarge -> 2
    UpstreamTimeout -> 3
    UpstreamError -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn error_reason_from_int(tag: Int) -> Result(ErrorReason, Nil) {
  case tag {
    0 -> Ok(BadContentType)
    1 -> Ok(BadMethod)
    2 -> Ok(PayloadTooLarge)
    3 -> Ok(UpstreamTimeout)
    4 -> Ok(UpstreamError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// DoH session lifecycle states.
/// 
/// Matches `SessionState` in `DohABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Bound (tag 1).
  Bound
  /// Serving (tag 2).
  Serving
  /// Resolving (tag 3).
  Resolving
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Bound -> 1
    Serving -> 2
    Resolving -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Bound)
    2 -> Ok(Serving)
    3 -> Ok(Resolving)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

