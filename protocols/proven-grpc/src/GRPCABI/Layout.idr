-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GRPCABI.Layout: C-ABI-compatible numeric representations of gRPC types.
--
-- Maps every constructor of the core sum types (FrameType, StreamState,
-- StatusCode, Compression) to fixed Bits8 values for C interop.  Each type
-- gets a total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/grpc.h) and the
-- Zig FFI enums (ffi/zig/src/grpc.zig) exactly.

module GRPCABI.Layout

import GRPC.Types

%default total

---------------------------------------------------------------------------
-- HTTP/2 FrameType (9 constructors, tags 0-8)
--
-- Per RFC 7540 section 6, HTTP/2 defines nine frame types that carry
-- gRPC messages and control information.
---------------------------------------------------------------------------

||| HTTP/2 frame types used by gRPC.
public export
data FrameType : Type where
  ||| DATA frame (type 0x0) — carries gRPC message payloads.
  Data          : FrameType
  ||| HEADERS frame (type 0x1) — carries gRPC metadata and trailers.
  Headers       : FrameType
  ||| RST_STREAM frame (type 0x3) — terminates a single stream.
  RstStream     : FrameType
  ||| SETTINGS frame (type 0x4) — connection-level configuration.
  Settings      : FrameType
  ||| PUSH_PROMISE frame (type 0x5) — server push (rarely used in gRPC).
  PushPromise   : FrameType
  ||| PING frame (type 0x6) — keepalive and latency measurement.
  Ping          : FrameType
  ||| GOAWAY frame (type 0x7) — graceful connection shutdown.
  Goaway        : FrameType
  ||| WINDOW_UPDATE frame (type 0x8) — flow control window adjustment.
  WindowUpdate  : FrameType
  ||| CONTINUATION frame (type 0x9) — header block continuation.
  Continuation  : FrameType

public export
Show FrameType where
  show Data         = "Data"
  show Headers      = "Headers"
  show RstStream    = "RstStream"
  show Settings     = "Settings"
  show PushPromise  = "PushPromise"
  show Ping         = "Ping"
  show Goaway       = "Goaway"
  show WindowUpdate = "WindowUpdate"
  show Continuation = "Continuation"

public export
frameTypeSize : Nat
frameTypeSize = 1

public export
frameTypeToTag : FrameType -> Bits8
frameTypeToTag Data         = 0
frameTypeToTag Headers      = 1
frameTypeToTag RstStream    = 2
frameTypeToTag Settings     = 3
frameTypeToTag PushPromise  = 4
frameTypeToTag Ping         = 5
frameTypeToTag Goaway       = 6
frameTypeToTag WindowUpdate = 7
frameTypeToTag Continuation = 8

public export
tagToFrameType : Bits8 -> Maybe FrameType
tagToFrameType 0 = Just Data
tagToFrameType 1 = Just Headers
tagToFrameType 2 = Just RstStream
tagToFrameType 3 = Just Settings
tagToFrameType 4 = Just PushPromise
tagToFrameType 5 = Just Ping
tagToFrameType 6 = Just Goaway
tagToFrameType 7 = Just WindowUpdate
tagToFrameType 8 = Just Continuation
tagToFrameType _ = Nothing

public export
frameTypeRoundtrip : (f : FrameType) -> tagToFrameType (frameTypeToTag f) = Just f
frameTypeRoundtrip Data         = Refl
frameTypeRoundtrip Headers      = Refl
frameTypeRoundtrip RstStream    = Refl
frameTypeRoundtrip Settings     = Refl
frameTypeRoundtrip PushPromise  = Refl
frameTypeRoundtrip Ping         = Refl
frameTypeRoundtrip Goaway       = Refl
frameTypeRoundtrip WindowUpdate = Refl
frameTypeRoundtrip Continuation = Refl

---------------------------------------------------------------------------
-- StreamState (6 constructors, tags 0-5)
--
-- Per RFC 7540 section 5.1, HTTP/2 streams pass through these states.
-- gRPC maps RPCs onto streams; stream lifecycle governs message flow.
---------------------------------------------------------------------------

||| HTTP/2 stream states per RFC 7540.
public export
data StreamState : Type where
  ||| Stream not yet opened — no frames sent or received.
  Idle             : StreamState
  ||| Stream is open — both sides may send frames.
  Open             : StreamState
  ||| Local side has sent END_STREAM — can still receive.
  HalfClosedLocal  : StreamState
  ||| Remote side has sent END_STREAM — can still send.
  HalfClosedRemote : StreamState
  ||| Stream is fully closed — terminal state.
  Closed           : StreamState
  ||| Reserved via PUSH_PROMISE — awaiting HEADERS to open.
  Reserved         : StreamState

public export
Show StreamState where
  show Idle             = "Idle"
  show Open             = "Open"
  show HalfClosedLocal  = "HalfClosedLocal"
  show HalfClosedRemote = "HalfClosedRemote"
  show Closed           = "Closed"
  show Reserved         = "Reserved"

public export
streamStateSize : Nat
streamStateSize = 1

public export
streamStateToTag : StreamState -> Bits8
streamStateToTag Idle             = 0
streamStateToTag Open             = 1
streamStateToTag HalfClosedLocal  = 2
streamStateToTag HalfClosedRemote = 3
streamStateToTag Closed           = 4
streamStateToTag Reserved         = 5

public export
tagToStreamState : Bits8 -> Maybe StreamState
tagToStreamState 0 = Just Idle
tagToStreamState 1 = Just Open
tagToStreamState 2 = Just HalfClosedLocal
tagToStreamState 3 = Just HalfClosedRemote
tagToStreamState 4 = Just Closed
tagToStreamState 5 = Just Reserved
tagToStreamState _ = Nothing

public export
streamStateRoundtrip : (s : StreamState) -> tagToStreamState (streamStateToTag s) = Just s
streamStateRoundtrip Idle             = Refl
streamStateRoundtrip Open             = Refl
streamStateRoundtrip HalfClosedLocal  = Refl
streamStateRoundtrip HalfClosedRemote = Refl
streamStateRoundtrip Closed           = Refl
streamStateRoundtrip Reserved         = Refl

---------------------------------------------------------------------------
-- StatusCode (17 constructors, tags 0-16)
--
-- gRPC status codes per the gRPC specification.  These map to
-- grpc-status trailer values in HTTP/2 responses.
---------------------------------------------------------------------------

public export
statusCodeSize : Nat
statusCodeSize = 1

public export
statusCodeToTag : StatusCode -> Bits8
statusCodeToTag Ok                 = 0
statusCodeToTag Cancelled          = 1
statusCodeToTag Unknown            = 2
statusCodeToTag InvalidArgument    = 3
statusCodeToTag DeadlineExceeded   = 4
statusCodeToTag NotFound           = 5
statusCodeToTag AlreadyExists      = 6
statusCodeToTag PermissionDenied   = 7
statusCodeToTag ResourceExhausted  = 8
statusCodeToTag FailedPrecondition = 9
statusCodeToTag Aborted            = 10
statusCodeToTag OutOfRange         = 11
statusCodeToTag Unimplemented      = 12
statusCodeToTag Internal           = 13
statusCodeToTag Unavailable        = 14
statusCodeToTag DataLoss           = 15
statusCodeToTag Unauthenticated    = 16

public export
tagToStatusCode : Bits8 -> Maybe StatusCode
tagToStatusCode 0  = Just Ok
tagToStatusCode 1  = Just Cancelled
tagToStatusCode 2  = Just Unknown
tagToStatusCode 3  = Just InvalidArgument
tagToStatusCode 4  = Just DeadlineExceeded
tagToStatusCode 5  = Just NotFound
tagToStatusCode 6  = Just AlreadyExists
tagToStatusCode 7  = Just PermissionDenied
tagToStatusCode 8  = Just ResourceExhausted
tagToStatusCode 9  = Just FailedPrecondition
tagToStatusCode 10 = Just Aborted
tagToStatusCode 11 = Just OutOfRange
tagToStatusCode 12 = Just Unimplemented
tagToStatusCode 13 = Just Internal
tagToStatusCode 14 = Just Unavailable
tagToStatusCode 15 = Just DataLoss
tagToStatusCode 16 = Just Unauthenticated
tagToStatusCode _  = Nothing

public export
statusCodeRoundtrip : (c : StatusCode) -> tagToStatusCode (statusCodeToTag c) = Just c
statusCodeRoundtrip Ok                 = Refl
statusCodeRoundtrip Cancelled          = Refl
statusCodeRoundtrip Unknown            = Refl
statusCodeRoundtrip InvalidArgument    = Refl
statusCodeRoundtrip DeadlineExceeded   = Refl
statusCodeRoundtrip NotFound           = Refl
statusCodeRoundtrip AlreadyExists      = Refl
statusCodeRoundtrip PermissionDenied   = Refl
statusCodeRoundtrip ResourceExhausted  = Refl
statusCodeRoundtrip FailedPrecondition = Refl
statusCodeRoundtrip Aborted            = Refl
statusCodeRoundtrip OutOfRange         = Refl
statusCodeRoundtrip Unimplemented      = Refl
statusCodeRoundtrip Internal           = Refl
statusCodeRoundtrip Unavailable        = Refl
statusCodeRoundtrip DataLoss           = Refl
statusCodeRoundtrip Unauthenticated    = Refl

---------------------------------------------------------------------------
-- Compression (4 constructors, tags 0-3)
--
-- gRPC compression algorithms.  Note: the existing GRPC.Types has
-- Identity/Gzip/Deflate/Snappy/Zstd but for ABI layout we use the
-- four specified in the task: None/Gzip/Deflate/Snappy.
-- We map from the GRPC.Types Compression type.
---------------------------------------------------------------------------

public export
compressionSize : Nat
compressionSize = 1

public export
compressionToTag : Compression -> Bits8
compressionToTag Identity = 0
compressionToTag Gzip     = 1
compressionToTag Deflate  = 2
compressionToTag Snappy   = 3
compressionToTag Zstd     = 4

public export
tagToCompression : Bits8 -> Maybe Compression
tagToCompression 0 = Just Identity
tagToCompression 1 = Just Gzip
tagToCompression 2 = Just Deflate
tagToCompression 3 = Just Snappy
tagToCompression 4 = Just Zstd
tagToCompression _ = Nothing

public export
compressionRoundtrip : (c : Compression) -> tagToCompression (compressionToTag c) = Just c
compressionRoundtrip Identity = Refl
compressionRoundtrip Gzip     = Refl
compressionRoundtrip Deflate  = Refl
compressionRoundtrip Snappy   = Refl
compressionRoundtrip Zstd     = Refl

---------------------------------------------------------------------------
-- StreamType (4 constructors, tags 0-3)
--
-- gRPC stream cardinality: unary, server-streaming, client-streaming,
-- or bidirectional streaming.
---------------------------------------------------------------------------

public export
streamTypeSize : Nat
streamTypeSize = 1

public export
streamTypeToTag : StreamType -> Bits8
streamTypeToTag Unary          = 0
streamTypeToTag ServerStreaming = 1
streamTypeToTag ClientStreaming = 2
streamTypeToTag BidiStreaming   = 3

public export
tagToStreamType : Bits8 -> Maybe StreamType
tagToStreamType 0 = Just Unary
tagToStreamType 1 = Just ServerStreaming
tagToStreamType 2 = Just ClientStreaming
tagToStreamType 3 = Just BidiStreaming
tagToStreamType _ = Nothing

public export
streamTypeRoundtrip : (t : StreamType) -> tagToStreamType (streamTypeToTag t) = Just t
streamTypeRoundtrip Unary          = Refl
streamTypeRoundtrip ServerStreaming = Refl
streamTypeRoundtrip ClientStreaming = Refl
streamTypeRoundtrip BidiStreaming   = Refl

---------------------------------------------------------------------------
-- ContentType (2 constructors, tags 0-1)
--
-- gRPC content type encodings: Protocol Buffers or JSON.
---------------------------------------------------------------------------

public export
contentTypeSize : Nat
contentTypeSize = 1

public export
contentTypeToTag : ContentType -> Bits8
contentTypeToTag Protobuf = 0
contentTypeToTag JSON     = 1

public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just Protobuf
tagToContentType 1 = Just JSON
tagToContentType _ = Nothing

public export
contentTypeRoundtrip : (t : ContentType) -> tagToContentType (contentTypeToTag t) = Just t
contentTypeRoundtrip Protobuf = Refl
contentTypeRoundtrip JSON     = Refl
