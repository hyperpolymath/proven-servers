// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gRPC protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - GRPC.Types           -- status codes, stream types, compression, content types
// - GRPCABI.Layout       -- C-ABI tag values for stream states
// - GRPCABI.Transitions  -- HTTP/2 stream state machine (RFC 7540 Section 5.1)
//
// The HTTP/2 stream lifecycle is modelled via streamState and
// validateStreamTransition, matching the formal proofs in
// GRPCABI.Transitions (including impossibility proofs like closedIsTerminal).

// ===========================================================================
// gRPC Status Code (GRPC.Types.StatusCode)
// ===========================================================================

/// gRPC status codes per the gRPC specification.
/// Matches the StatusCode type in GRPC.Types.
/// Discriminant values are the standard gRPC numeric codes.
type statusCode =
  | @as(0) GrpcOk
  | @as(1) Cancelled
  | @as(2) Unknown
  | @as(3) InvalidArgument
  | @as(4) DeadlineExceeded
  | @as(5) NotFound
  | @as(6) AlreadyExists
  | @as(7) PermissionDenied
  | @as(8) ResourceExhausted
  | @as(9) FailedPrecondition
  | @as(10) Aborted
  | @as(11) OutOfRange
  | @as(12) Unimplemented
  | @as(13) Internal
  | @as(14) Unavailable
  | @as(15) DataLoss
  | @as(16) Unauthenticated

/// Decode from a numeric gRPC status code.
let statusCodeFromCode = (code: int): option<statusCode> =>
  switch code {
  | 0 => Some(GrpcOk)
  | 1 => Some(Cancelled)
  | 2 => Some(Unknown)
  | 3 => Some(InvalidArgument)
  | 4 => Some(DeadlineExceeded)
  | 5 => Some(NotFound)
  | 6 => Some(AlreadyExists)
  | 7 => Some(PermissionDenied)
  | 8 => Some(ResourceExhausted)
  | 9 => Some(FailedPrecondition)
  | 10 => Some(Aborted)
  | 11 => Some(OutOfRange)
  | 12 => Some(Unimplemented)
  | 13 => Some(Internal)
  | 14 => Some(Unavailable)
  | 15 => Some(DataLoss)
  | 16 => Some(Unauthenticated)
  | _ => None
  }

/// Encode to a numeric gRPC status code.
let statusCodeToCode = (sc: statusCode): int =>
  switch sc {
  | GrpcOk => 0
  | Cancelled => 1
  | Unknown => 2
  | InvalidArgument => 3
  | DeadlineExceeded => 4
  | NotFound => 5
  | AlreadyExists => 6
  | PermissionDenied => 7
  | ResourceExhausted => 8
  | FailedPrecondition => 9
  | Aborted => 10
  | OutOfRange => 11
  | Unimplemented => 12
  | Internal => 13
  | Unavailable => 14
  | DataLoss => 15
  | Unauthenticated => 16
  }

/// Whether this status represents success.
let statusCodeIsOk = (sc: statusCode): bool =>
  switch sc {
  | GrpcOk => true
  | Cancelled | Unknown | InvalidArgument | DeadlineExceeded | NotFound | AlreadyExists
  | PermissionDenied | ResourceExhausted | FailedPrecondition | Aborted | OutOfRange
  | Unimplemented | Internal | Unavailable | DataLoss | Unauthenticated => false
  }

// ===========================================================================
// Stream Type (GRPC.Types.StreamType)
// ===========================================================================

/// gRPC stream cardinality types.
/// Matches StreamType in GRPC.Types.
type streamType =
  | @as(0) Unary
  | @as(1) ServerStreaming
  | @as(2) ClientStreaming
  | @as(3) BidiStreaming

/// Whether the client sends a stream of messages.
let streamTypeIsClientStreaming = (st: streamType): bool =>
  switch st {
  | ClientStreaming | BidiStreaming => true
  | Unary | ServerStreaming => false
  }

/// Whether the server sends a stream of messages.
let streamTypeIsServerStreaming = (st: streamType): bool =>
  switch st {
  | ServerStreaming | BidiStreaming => true
  | Unary | ClientStreaming => false
  }

// ===========================================================================
// Compression (GRPC.Types.Compression)
// ===========================================================================

/// gRPC message compression algorithms.
/// Matches Compression in GRPC.Types.
type compression =
  | @as(0) Identity
  | @as(1) Gzip
  | @as(2) Deflate
  | @as(3) Snappy
  | @as(4) Zstd

/// Human-readable compression name.
let compressionAsStr = (c: compression): string =>
  switch c {
  | Identity => "identity"
  | Gzip => "gzip"
  | Deflate => "deflate"
  | Snappy => "snappy"
  | Zstd => "zstd"
  }

// ===========================================================================
// Content Type (GRPC.Types.ContentType)
// ===========================================================================

/// gRPC content type encodings.
/// Matches ContentType in GRPC.Types.
type grpcContentType =
  | @as(0) Protobuf
  | @as(1) Json

/// The gRPC content-type header value.
let grpcContentTypeHeader = (ct: grpcContentType): string =>
  switch ct {
  | Protobuf => "application/grpc+proto"
  | Json => "application/grpc+json"
  }

// ===========================================================================
// HTTP/2 Stream State (GRPCABI.Layout.StreamState)
// ===========================================================================

/// HTTP/2 stream states (RFC 7540 Section 5.1).
/// Used as the state index for the gRPC stream lifecycle state machine
/// in GRPCABI.Transitions.
type streamState =
  | @as(0) StreamIdle
  | @as(1) StreamOpen
  | @as(2) HalfClosedLocal
  | @as(3) HalfClosedRemote
  | @as(4) Reserved
  | @as(5) Closed

/// Decode from a C-ABI tag value.
let streamStateFromTag = (tag: int): option<streamState> =>
  switch tag {
  | 0 => Some(StreamIdle)
  | 1 => Some(StreamOpen)
  | 2 => Some(HalfClosedLocal)
  | 3 => Some(HalfClosedRemote)
  | 4 => Some(Reserved)
  | 5 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let streamStateToTag = (ss: streamState): int =>
  switch ss {
  | StreamIdle => 0
  | StreamOpen => 1
  | HalfClosedLocal => 2
  | HalfClosedRemote => 3
  | Reserved => 4
  | Closed => 5
  }

/// Whether DATA frames can be sent (local direction) from this state.
/// Matches CanSendData witnesses in GRPCABI.Transitions.
let streamCanSendData = (ss: streamState): bool =>
  switch ss {
  | StreamOpen | HalfClosedRemote => true
  | StreamIdle | HalfClosedLocal | Reserved | Closed => false
  }

/// Whether DATA frames can be received (remote direction) in this state.
/// Matches CanReceiveData witnesses in GRPCABI.Transitions.
let streamCanReceiveData = (ss: streamState): bool =>
  switch ss {
  | StreamOpen | HalfClosedLocal => true
  | StreamIdle | HalfClosedRemote | Reserved | Closed => false
  }

/// Whether WINDOW_UPDATE frames can be processed in this state.
/// Matches CanUpdateWindow witnesses in GRPCABI.Transitions.
let streamCanUpdateWindow = (ss: streamState): bool =>
  switch ss {
  | StreamOpen | HalfClosedLocal | HalfClosedRemote => true
  | StreamIdle | Reserved | Closed => false
  }

/// Whether this is the terminal state (Closed).
/// Relates to the closedIsTerminal impossibility proof in GRPCABI.Transitions.
let streamIsTerminal = (ss: streamState): bool =>
  switch ss {
  | Closed => true
  | StreamIdle | StreamOpen | HalfClosedLocal | HalfClosedRemote | Reserved => false
  }

/// Named HTTP/2 stream state transitions.
/// Each variant corresponds to a constructor of ValidStreamTransition
/// in GRPCABI.Transitions.
type streamTransition =
  | SendHeaders
  | LocalEndStream
  | RemoteEndStream
  | ResetFromOpen
  | CloseHalfLocal
  | CloseHalfRemote
  | PushPromiseRecv
  | ReservedToHalf
  | ReservedReset

// validateStreamTransition removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md
