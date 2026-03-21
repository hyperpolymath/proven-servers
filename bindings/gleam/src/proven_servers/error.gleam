//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Shared error types for the proven-servers Gleam bindings.
////
//// Provides a unified error type that aggregates protocol-specific
//// error conditions alongside the core `ResultCode` from
//// `proven_servers/core`. All proven-servers FFI calls return
//// `Result(a, ProvenError)` so that callers get a single, exhaustive
//// error surface to match against.

import proven_servers/core

// ===========================================================================
// Protocol identifier
// ===========================================================================

/// Identifies the protocol that produced an error.
/// Used to tag errors originating from cross-protocol calls.
pub type Protocol {
  Httpd
  Dns
  Smtp
  Ftp
  SshBastion
  Mqtt
  Grpc
  Graphql
  Tls
  Firewall
  Websocket
  OtherProtocol(name: String)
}

/// Human-readable protocol name.
pub fn protocol_to_string(protocol: Protocol) -> String {
  case protocol {
    Httpd -> "httpd"
    Dns -> "dns"
    Smtp -> "smtp"
    Ftp -> "ftp"
    SshBastion -> "ssh-bastion"
    Mqtt -> "mqtt"
    Grpc -> "grpc"
    Graphql -> "graphql"
    Tls -> "tls"
    Firewall -> "firewall"
    Websocket -> "websocket"
    OtherProtocol(name) -> name
  }
}

// ===========================================================================
// Unified error type
// ===========================================================================

/// Unified error type for all proven-servers FFI calls.
///
/// Variants cover:
/// - FFI-level failures (null handle, OOM, invalid params)
/// - Protocol-specific decode failures (unknown tag values)
/// - Transition validation failures (illegal state machine moves)
/// - Initialisation / lifecycle failures
pub type ProvenError {
  /// The FFI returned a non-OK ResultCode.
  FfiError(code: core.ResultCode, message: String)
  /// The library handle was null or uninitialised.
  HandleError(message: String)
  /// A C-ABI tag value could not be decoded to a known variant.
  DecodeError(protocol: Protocol, type_name: String, raw_tag: Int)
  /// A state machine transition was rejected.
  TransitionError(protocol: Protocol, from_state: String, to_state: String)
  /// Library initialisation failed.
  InitError(message: String)
  /// An operation is not supported by the current build / platform.
  UnsupportedError(message: String)
  /// Catch-all for unexpected errors from the FFI layer.
  UnknownError(message: String)
}

// ===========================================================================
// Constructors
// ===========================================================================

/// Build an FfiError from a ResultCode.
pub fn from_result_code(code: core.ResultCode) -> ProvenError {
  FfiError(code: code, message: core.result_description(code))
}

/// Build a DecodeError for an unknown tag.
pub fn unknown_tag(
  protocol: Protocol,
  type_name: String,
  raw_tag: Int,
) -> ProvenError {
  DecodeError(protocol: protocol, type_name: type_name, raw_tag: raw_tag)
}

/// Build a TransitionError.
pub fn invalid_transition(
  protocol: Protocol,
  from_state: String,
  to_state: String,
) -> ProvenError {
  TransitionError(
    protocol: protocol,
    from_state: from_state,
    to_state: to_state,
  )
}

// ===========================================================================
// Classification
// ===========================================================================

/// Whether this error is recoverable (transient FFI errors, decode mismatches).
pub fn is_recoverable(error: ProvenError) -> Bool {
  case error {
    FfiError(code: core.ResultError, message: _) -> True
    DecodeError(..) -> True
    TransitionError(..) -> True
    _ -> False
  }
}
