// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Shared error types for the proven-servers ReScript binding layer.
//
// Provides a unified error variant that aggregates protocol-specific
// error conditions alongside the core ResultCode from ProvenCore.
// All proven-servers FFI calls return result<'a, provenError> so that
// callers get a single, exhaustive error surface to match against.
//
// This module re-exports ProvenCore.resultCode for convenience and
// adds protocol-context wrappers (e.g. which protocol, which operation)
// so upstream code can produce actionable diagnostics without losing
// type safety.

// ===========================================================================
// Error context
// ===========================================================================

/// Identifies the protocol that produced an error.
/// Used to tag errors originating from cross-protocol calls.
type protocol =
  | Httpd
  | Dns
  | Smtp
  | Ftp
  | SshBastion
  | Mqtt
  | Grpc
  | Graphql
  | Tls
  | Firewall
  | Websocket
  | Other(string)

/// Human-readable protocol name.
let protocolAsStr = (p: protocol): string =>
  switch p {
  | Httpd => "httpd"
  | Dns => "dns"
  | Smtp => "smtp"
  | Ftp => "ftp"
  | SshBastion => "ssh-bastion"
  | Mqtt => "mqtt"
  | Grpc => "grpc"
  | Graphql => "graphql"
  | Tls => "tls"
  | Firewall => "firewall"
  | Websocket => "websocket"
  | Other(name) => name
  }

// ===========================================================================
// Proven error type
// ===========================================================================

/// Unified error type for all proven-servers FFI calls.
///
/// Variants cover:
/// - FFI-level failures (null handle, OOM, invalid params)
/// - Protocol-specific decode failures (unknown tag values)
/// - Transition validation failures (illegal state machine moves)
/// - Initialisation / lifecycle failures
type provenError =
  | /// The FFI returned a non-OK ResultCode.
    FfiError({code: ProvenCore.resultCode, message: string})
  | /// The library handle was null or uninitialised.
    HandleError(string)
  | /// A C-ABI tag value could not be decoded to a known variant.
    DecodeError({protocol: protocol, typeName: string, rawTag: int})
  | /// A state machine transition was rejected.
    TransitionError({
      protocol: protocol,
      fromState: string,
      toState: string,
    })
  | /// Library initialisation failed.
    InitError(string)
  | /// An operation is not supported by the current build / platform.
    UnsupportedError(string)
  | /// Catch-all for unexpected errors from the FFI layer.
    UnknownError(string)

// ===========================================================================
// Constructors
// ===========================================================================

/// Build an FfiError from a ResultCode.
let fromResultCode = (code: ProvenCore.resultCode): provenError =>
  FfiError({code, message: ProvenCore.resultDescription(code)})

/// Build a DecodeError for an unknown tag.
let unknownTag = (proto: protocol, typeName: string, rawTag: int): provenError =>
  DecodeError({protocol: proto, typeName, rawTag})

/// Build a TransitionError.
let invalidTransition = (
  proto: protocol,
  ~fromState: string,
  ~toState: string,
): provenError => TransitionError({protocol: proto, fromState, toState})

// ===========================================================================
// Formatting
// ===========================================================================

/// Human-readable error description suitable for logging.
let describe = (err: provenError): string =>
  switch err {
  | FfiError({code, message}) =>
    "FFI error (code " ++
    Belt.Int.toString(ProvenCore.resultCodeToTag(code)) ++
    "): " ++
    message
  | HandleError(msg) => "Handle error: " ++ msg
  | DecodeError({protocol, typeName, rawTag}) =>
    "Decode error in " ++
    protocolAsStr(protocol) ++
    ": unknown " ++
    typeName ++
    " tag " ++
    Belt.Int.toString(rawTag)
  | TransitionError({protocol, fromState, toState}) =>
    "Invalid transition in " ++
    protocolAsStr(protocol) ++
    ": " ++
    fromState ++
    " -> " ++
    toState
  | InitError(msg) => "Initialisation error: " ++ msg
  | UnsupportedError(msg) => "Unsupported: " ++ msg
  | UnknownError(msg) => "Unknown error: " ++ msg
  }

/// Whether this error is recoverable (transient FFI errors, decode mismatches).
let isRecoverable = (err: provenError): bool =>
  switch err {
  | FfiError({code, message: _}) =>
    switch code {
    | ProvenCore.ResultError => true
    | ProvenCore.ResultOk | ProvenCore.InvalidParam | ProvenCore.OutOfMemory | ProvenCore.NullPointer => false
    }
  | DecodeError(_) => true
  | TransitionError(_) => true
  | HandleError(_) | InitError(_) | UnsupportedError(_) | UnknownError(_) => false
  }
