-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrpcABI.Types: C-ABI-compatible numeric representations of Grpc types.
--
-- Maps every constructor of the core Grpc sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/grpc.zig) exactly.
--
-- Types covered:
--   FrameType                 (9 constructors, tags 0-8)
--   StreamState               (6 constructors, tags 0-5)
--   StatusCode                (17 constructors, tags 0-16)
--   Compression               (5 constructors, tags 0-4)
--   StreamType                (4 constructors, tags 0-3)
--   ContentType               (2 constructors, tags 0-1)

module GrpcABI.Types

%default total

---------------------------------------------------------------------------
-- FrameType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
frame_typeSize : Nat
frame_typeSize = 1

||| FrameType sum type for ABI encoding.
public export
data FrameType : Type where
  Data : FrameType
  Headers : FrameType
  RstStream : FrameType
  Settings : FrameType
  PushPromise : FrameType
  Ping : FrameType
  Goaway : FrameType
  WindowUpdate : FrameType
  Continuation : FrameType

||| Encode a FrameType to its ABI tag value.
public export
frame_typeToTag : FrameType -> Bits8
frame_typeToTag Data = 0
frame_typeToTag Headers = 1
frame_typeToTag RstStream = 2
frame_typeToTag Settings = 3
frame_typeToTag PushPromise = 4
frame_typeToTag Ping = 5
frame_typeToTag Goaway = 6
frame_typeToTag WindowUpdate = 7
frame_typeToTag Continuation = 8

||| Decode an ABI tag to a FrameType.
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

||| Roundtrip proof: decoding an encoded FrameType yields the original.
public export
frame_typeRoundtrip : (x : FrameType) -> tagToFrameType (frame_typeToTag x) = Just x
frame_typeRoundtrip Data = Refl
frame_typeRoundtrip Headers = Refl
frame_typeRoundtrip RstStream = Refl
frame_typeRoundtrip Settings = Refl
frame_typeRoundtrip PushPromise = Refl
frame_typeRoundtrip Ping = Refl
frame_typeRoundtrip Goaway = Refl
frame_typeRoundtrip WindowUpdate = Refl
frame_typeRoundtrip Continuation = Refl

---------------------------------------------------------------------------
-- StreamState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
stream_stateSize : Nat
stream_stateSize = 1

||| StreamState sum type for ABI encoding.
public export
data StreamState : Type where
  Idle : StreamState
  Open : StreamState
  HalfClosedLocal : StreamState
  HalfClosedRemote : StreamState
  Closed : StreamState
  Reserved : StreamState

||| Encode a StreamState to its ABI tag value.
public export
stream_stateToTag : StreamState -> Bits8
stream_stateToTag Idle = 0
stream_stateToTag Open = 1
stream_stateToTag HalfClosedLocal = 2
stream_stateToTag HalfClosedRemote = 3
stream_stateToTag Closed = 4
stream_stateToTag Reserved = 5

||| Decode an ABI tag to a StreamState.
public export
tagToStreamState : Bits8 -> Maybe StreamState
tagToStreamState 0 = Just Idle
tagToStreamState 1 = Just Open
tagToStreamState 2 = Just HalfClosedLocal
tagToStreamState 3 = Just HalfClosedRemote
tagToStreamState 4 = Just Closed
tagToStreamState 5 = Just Reserved
tagToStreamState _ = Nothing

||| Roundtrip proof: decoding an encoded StreamState yields the original.
public export
stream_stateRoundtrip : (x : StreamState) -> tagToStreamState (stream_stateToTag x) = Just x
stream_stateRoundtrip Idle = Refl
stream_stateRoundtrip Open = Refl
stream_stateRoundtrip HalfClosedLocal = Refl
stream_stateRoundtrip HalfClosedRemote = Refl
stream_stateRoundtrip Closed = Refl
stream_stateRoundtrip Reserved = Refl

---------------------------------------------------------------------------
-- StatusCode (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
status_codeSize : Nat
status_codeSize = 1

||| StatusCode sum type for ABI encoding.
public export
data StatusCode : Type where
  Ok : StatusCode
  Cancelled : StatusCode
  Unknown : StatusCode
  InvalidArgument : StatusCode
  DeadlineExceeded : StatusCode
  NotFound : StatusCode
  AlreadyExists : StatusCode
  PermissionDenied : StatusCode
  ResourceExhausted : StatusCode
  FailedPrecondition : StatusCode
  Aborted : StatusCode
  OutOfRange : StatusCode
  Unimplemented : StatusCode
  Internal : StatusCode
  Unavailable : StatusCode
  DataLoss : StatusCode
  Unauthenticated : StatusCode

||| Encode a StatusCode to its ABI tag value.
public export
status_codeToTag : StatusCode -> Bits8
status_codeToTag Ok = 0
status_codeToTag Cancelled = 1
status_codeToTag Unknown = 2
status_codeToTag InvalidArgument = 3
status_codeToTag DeadlineExceeded = 4
status_codeToTag NotFound = 5
status_codeToTag AlreadyExists = 6
status_codeToTag PermissionDenied = 7
status_codeToTag ResourceExhausted = 8
status_codeToTag FailedPrecondition = 9
status_codeToTag Aborted = 10
status_codeToTag OutOfRange = 11
status_codeToTag Unimplemented = 12
status_codeToTag Internal = 13
status_codeToTag Unavailable = 14
status_codeToTag DataLoss = 15
status_codeToTag Unauthenticated = 16

||| Decode an ABI tag to a StatusCode.
public export
tagToStatusCode : Bits8 -> Maybe StatusCode
tagToStatusCode 0 = Just Ok
tagToStatusCode 1 = Just Cancelled
tagToStatusCode 2 = Just Unknown
tagToStatusCode 3 = Just InvalidArgument
tagToStatusCode 4 = Just DeadlineExceeded
tagToStatusCode 5 = Just NotFound
tagToStatusCode 6 = Just AlreadyExists
tagToStatusCode 7 = Just PermissionDenied
tagToStatusCode 8 = Just ResourceExhausted
tagToStatusCode 9 = Just FailedPrecondition
tagToStatusCode 10 = Just Aborted
tagToStatusCode 11 = Just OutOfRange
tagToStatusCode 12 = Just Unimplemented
tagToStatusCode 13 = Just Internal
tagToStatusCode 14 = Just Unavailable
tagToStatusCode 15 = Just DataLoss
tagToStatusCode 16 = Just Unauthenticated
tagToStatusCode _ = Nothing

||| Roundtrip proof: decoding an encoded StatusCode yields the original.
public export
status_codeRoundtrip : (x : StatusCode) -> tagToStatusCode (status_codeToTag x) = Just x
status_codeRoundtrip Ok = Refl
status_codeRoundtrip Cancelled = Refl
status_codeRoundtrip Unknown = Refl
status_codeRoundtrip InvalidArgument = Refl
status_codeRoundtrip DeadlineExceeded = Refl
status_codeRoundtrip NotFound = Refl
status_codeRoundtrip AlreadyExists = Refl
status_codeRoundtrip PermissionDenied = Refl
status_codeRoundtrip ResourceExhausted = Refl
status_codeRoundtrip FailedPrecondition = Refl
status_codeRoundtrip Aborted = Refl
status_codeRoundtrip OutOfRange = Refl
status_codeRoundtrip Unimplemented = Refl
status_codeRoundtrip Internal = Refl
status_codeRoundtrip Unavailable = Refl
status_codeRoundtrip DataLoss = Refl
status_codeRoundtrip Unauthenticated = Refl

---------------------------------------------------------------------------
-- Compression (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
compressionSize : Nat
compressionSize = 1

||| Compression sum type for ABI encoding.
public export
data Compression : Type where
  Identity : Compression
  Gzip : Compression
  Deflate : Compression
  Snappy : Compression
  Zstd : Compression

||| Encode a Compression to its ABI tag value.
public export
compressionToTag : Compression -> Bits8
compressionToTag Identity = 0
compressionToTag Gzip = 1
compressionToTag Deflate = 2
compressionToTag Snappy = 3
compressionToTag Zstd = 4

||| Decode an ABI tag to a Compression.
public export
tagToCompression : Bits8 -> Maybe Compression
tagToCompression 0 = Just Identity
tagToCompression 1 = Just Gzip
tagToCompression 2 = Just Deflate
tagToCompression 3 = Just Snappy
tagToCompression 4 = Just Zstd
tagToCompression _ = Nothing

||| Roundtrip proof: decoding an encoded Compression yields the original.
public export
compressionRoundtrip : (x : Compression) -> tagToCompression (compressionToTag x) = Just x
compressionRoundtrip Identity = Refl
compressionRoundtrip Gzip = Refl
compressionRoundtrip Deflate = Refl
compressionRoundtrip Snappy = Refl
compressionRoundtrip Zstd = Refl

---------------------------------------------------------------------------
-- StreamType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
stream_typeSize : Nat
stream_typeSize = 1

||| StreamType sum type for ABI encoding.
public export
data StreamType : Type where
  Unary : StreamType
  ServerStreaming : StreamType
  ClientStreaming : StreamType
  BidiStreaming : StreamType

||| Encode a StreamType to its ABI tag value.
public export
stream_typeToTag : StreamType -> Bits8
stream_typeToTag Unary = 0
stream_typeToTag ServerStreaming = 1
stream_typeToTag ClientStreaming = 2
stream_typeToTag BidiStreaming = 3

||| Decode an ABI tag to a StreamType.
public export
tagToStreamType : Bits8 -> Maybe StreamType
tagToStreamType 0 = Just Unary
tagToStreamType 1 = Just ServerStreaming
tagToStreamType 2 = Just ClientStreaming
tagToStreamType 3 = Just BidiStreaming
tagToStreamType _ = Nothing

||| Roundtrip proof: decoding an encoded StreamType yields the original.
public export
stream_typeRoundtrip : (x : StreamType) -> tagToStreamType (stream_typeToTag x) = Just x
stream_typeRoundtrip Unary = Refl
stream_typeRoundtrip ServerStreaming = Refl
stream_typeRoundtrip ClientStreaming = Refl
stream_typeRoundtrip BidiStreaming = Refl

---------------------------------------------------------------------------
-- ContentType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
content_typeSize : Nat
content_typeSize = 1

||| ContentType sum type for ABI encoding.
public export
data ContentType : Type where
  Protobuf : ContentType
  Json : ContentType

||| Encode a ContentType to its ABI tag value.
public export
content_typeToTag : ContentType -> Bits8
content_typeToTag Protobuf = 0
content_typeToTag Json = 1

||| Decode an ABI tag to a ContentType.
public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just Protobuf
tagToContentType 1 = Just Json
tagToContentType _ = Nothing

||| Roundtrip proof: decoding an encoded ContentType yields the original.
public export
content_typeRoundtrip : (x : ContentType) -> tagToContentType (content_typeToTag x) = Just x
content_typeRoundtrip Protobuf = Refl
content_typeRoundtrip Json = Refl
