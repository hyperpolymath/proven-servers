//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// gRPC protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `GRPC.Types`           -- status codes, stream types, compression
//// - `GRPCABI.Layout`       -- C-ABI tag values for stream states
//// - `GRPCABI.Transitions`  -- HTTP/2 stream state machine (RFC 7540 Section 5.1)

import gleam/option.{type Option, None, Some}

// ===========================================================================
// gRPC Status Code (GRPC.Types.StatusCode)
// ===========================================================================

/// gRPC status codes per the gRPC specification.
///
/// Matches the `StatusCode` type in `GRPC.Types`.
pub type StatusCode {
  GrpcOk
  Cancelled
  Unknown
  InvalidArgument
  DeadlineExceeded
  GrpcNotFound
  AlreadyExists
  PermissionDenied
  ResourceExhausted
  FailedPrecondition
  Aborted
  OutOfRange
  Unimplemented
  Internal
  Unavailable
  DataLoss
  Unauthenticated
}

/// Convert a `StatusCode` to its numeric gRPC code.
pub fn status_to_int(code: StatusCode) -> Int {
  case code {
    GrpcOk -> 0
    Cancelled -> 1
    Unknown -> 2
    InvalidArgument -> 3
    DeadlineExceeded -> 4
    GrpcNotFound -> 5
    AlreadyExists -> 6
    PermissionDenied -> 7
    ResourceExhausted -> 8
    FailedPrecondition -> 9
    Aborted -> 10
    OutOfRange -> 11
    Unimplemented -> 12
    Internal -> 13
    Unavailable -> 14
    DataLoss -> 15
    Unauthenticated -> 16
  }
}

/// Decode from a numeric gRPC status code.
pub fn status_from_int(code: Int) -> Result(StatusCode, Nil) {
  case code {
    0 -> Ok(GrpcOk)
    1 -> Ok(Cancelled)
    2 -> Ok(Unknown)
    3 -> Ok(InvalidArgument)
    4 -> Ok(DeadlineExceeded)
    5 -> Ok(GrpcNotFound)
    6 -> Ok(AlreadyExists)
    7 -> Ok(PermissionDenied)
    8 -> Ok(ResourceExhausted)
    9 -> Ok(FailedPrecondition)
    10 -> Ok(Aborted)
    11 -> Ok(OutOfRange)
    12 -> Ok(Unimplemented)
    13 -> Ok(Internal)
    14 -> Ok(Unavailable)
    15 -> Ok(DataLoss)
    16 -> Ok(Unauthenticated)
    _ -> Error(Nil)
  }
}

/// Whether this status represents success.
pub fn status_is_ok(code: StatusCode) -> Bool {
  code == GrpcOk
}

// ===========================================================================
// Stream Type (GRPC.Types.StreamType)
// ===========================================================================

/// gRPC stream cardinality types.
pub type StreamType {
  /// Single request, single response.
  Unary
  /// Single request, stream of responses.
  ServerStreaming
  /// Stream of requests, single response.
  ClientStreaming
  /// Bidirectional streaming.
  BidiStreaming
}

/// Whether the client sends a stream of messages.
pub fn stream_is_client_streaming(st: StreamType) -> Bool {
  case st {
    ClientStreaming | BidiStreaming -> True
    _ -> False
  }
}

/// Whether the server sends a stream of messages.
pub fn stream_is_server_streaming(st: StreamType) -> Bool {
  case st {
    ServerStreaming | BidiStreaming -> True
    _ -> False
  }
}

// ===========================================================================
// Compression (GRPC.Types.Compression)
// ===========================================================================

/// gRPC message compression algorithms.
pub type Compression {
  Identity
  Gzip
  Deflate
  Snappy
  Zstd
}

/// The encoding name string for a compression algorithm.
pub fn compression_name(c: Compression) -> String {
  case c {
    Identity -> "identity"
    Gzip -> "gzip"
    Deflate -> "deflate"
    Snappy -> "snappy"
    Zstd -> "zstd"
  }
}

// ===========================================================================
// Content Type (GRPC.Types.ContentType)
// ===========================================================================

/// gRPC content type encodings.
pub type GrpcContentType {
  Protobuf
  Json
}

/// The gRPC content-type header value.
pub fn grpc_content_type_header(ct: GrpcContentType) -> String {
  case ct {
    Protobuf -> "application/grpc+proto"
    Json -> "application/grpc+json"
  }
}

// ===========================================================================
// HTTP/2 Stream State (GRPCABI.Layout.StreamState)
// ===========================================================================

/// HTTP/2 stream states (RFC 7540 Section 5.1).
pub type StreamState {
  StreamIdle
  Open
  HalfClosedLocal
  HalfClosedRemote
  Reserved
  Closed
}

/// Convert a `StreamState` to its C-ABI tag value.
pub fn stream_state_to_int(state: StreamState) -> Int {
  case state {
    StreamIdle -> 0
    Open -> 1
    HalfClosedLocal -> 2
    HalfClosedRemote -> 3
    Reserved -> 4
    Closed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn stream_state_from_int(tag: Int) -> Result(StreamState, Nil) {
  case tag {
    0 -> Ok(StreamIdle)
    1 -> Ok(Open)
    2 -> Ok(HalfClosedLocal)
    3 -> Ok(HalfClosedRemote)
    4 -> Ok(Reserved)
    5 -> Ok(Closed)
    _ -> Error(Nil)
  }
}

/// Whether DATA frames can be sent from this state.
pub fn can_send_data(state: StreamState) -> Bool {
  case state {
    Open | HalfClosedRemote -> True
    _ -> False
  }
}

/// Whether DATA frames can be received in this state.
pub fn can_receive_data(state: StreamState) -> Bool {
  case state {
    Open | HalfClosedLocal -> True
    _ -> False
  }
}

/// Whether WINDOW_UPDATE frames can be processed in this state.
pub fn can_update_window(state: StreamState) -> Bool {
  case state {
    Open | HalfClosedLocal | HalfClosedRemote -> True
    _ -> False
  }
}

/// Whether this is the terminal state (Closed).
pub fn stream_is_terminal(state: StreamState) -> Bool {
  state == Closed
}

// ===========================================================================
// Stream Transitions (GRPCABI.Transitions)
// ===========================================================================

/// Named HTTP/2 stream state transitions.
pub type StreamTransition {
  SendHeaders
  LocalEndStream
  RemoteEndStream
  ResetFromOpen
  CloseHalfLocal
  CloseHalfRemote
  PushPromiseRecv
  ReservedToHalf
  ReservedReset
}

/// Validate whether a stream state transition is legal.
///
/// Key invariant: `Closed` is terminal -- no transitions originate from it.
pub fn validate_stream_transition(
  from: StreamState,
  to: StreamState,
) -> Option(StreamTransition) {
  case from, to {
    StreamIdle, Open -> Some(SendHeaders)
    Open, HalfClosedLocal -> Some(LocalEndStream)
    Open, HalfClosedRemote -> Some(RemoteEndStream)
    Open, Closed -> Some(ResetFromOpen)
    HalfClosedLocal, Closed -> Some(CloseHalfLocal)
    HalfClosedRemote, Closed -> Some(CloseHalfRemote)
    StreamIdle, Reserved -> Some(PushPromiseRecv)
    Reserved, HalfClosedRemote -> Some(ReservedToHalf)
    Reserved, Closed -> Some(ReservedReset)
    _, _ -> None
  }
}
