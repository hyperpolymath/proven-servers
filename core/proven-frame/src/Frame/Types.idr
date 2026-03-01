-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Frame.Types: Core type definitions for framing strategies.
-- Closed sum types representing how protocols turn raw byte streams into
-- discrete messages — delimiters, length encodings, frame states, and errors.

module Frame.Types

%default total

---------------------------------------------------------------------------
-- Frame strategy — how the byte stream is divided into messages.
---------------------------------------------------------------------------

||| The strategy used to delimit messages within a byte stream.
public export
data FrameStrategy : Type where
  ||| Messages separated by a delimiter character or sequence.
  LineDelimited : FrameStrategy
  ||| Messages prefixed with their length.
  LengthPrefixed : FrameStrategy
  ||| HTTP-style framing (headers + content-length or chunked).
  HTTPFrame : FrameStrategy
  ||| All messages are the same fixed size.
  FixedSize : FrameStrategy
  ||| HTTP chunked transfer encoding.
  ChunkEncoded : FrameStrategy
  ||| No framing — raw bytes passed through as-is.
  RawBytes : FrameStrategy
  ||| Type-Length-Value framing.
  TLVFrame : FrameStrategy

public export
Show FrameStrategy where
  show LineDelimited  = "LineDelimited"
  show LengthPrefixed = "LengthPrefixed"
  show HTTPFrame      = "HTTPFrame"
  show FixedSize      = "FixedSize"
  show ChunkEncoded   = "ChunkEncoded"
  show RawBytes       = "RawBytes"
  show TLVFrame       = "TLVFrame"

---------------------------------------------------------------------------
-- Delimiter — the character or sequence that separates messages.
---------------------------------------------------------------------------

||| The delimiter used between line-delimited messages.
public export
data Delimiter : Type where
  ||| Carriage return + line feed (\r\n).
  CRLF   : Delimiter
  ||| Line feed only (\n).
  LF     : Delimiter
  ||| Null byte (\0).
  Null   : Delimiter
  ||| A custom delimiter byte or sequence.
  Custom : Delimiter

public export
Show Delimiter where
  show CRLF   = "CRLF"
  show LF     = "LF"
  show Null   = "Null"
  show Custom = "Custom"

---------------------------------------------------------------------------
-- Length encoding — how the length prefix is encoded.
---------------------------------------------------------------------------

||| The encoding used for length-prefixed frame headers.
public export
data LengthEncoding : Type where
  ||| 16-bit big-endian length.
  BigEndian16    : LengthEncoding
  ||| 32-bit big-endian length.
  BigEndian32    : LengthEncoding
  ||| 16-bit little-endian length.
  LittleEndian16 : LengthEncoding
  ||| 32-bit little-endian length.
  LittleEndian32 : LengthEncoding
  ||| Variable-length integer encoding.
  Varint         : LengthEncoding

public export
Show LengthEncoding where
  show BigEndian16    = "BigEndian16"
  show BigEndian32    = "BigEndian32"
  show LittleEndian16 = "LittleEndian16"
  show LittleEndian32 = "LittleEndian32"
  show Varint         = "Varint"

---------------------------------------------------------------------------
-- Frame error — errors that can occur during framing.
---------------------------------------------------------------------------

||| Errors that can occur when framing or deframing a byte stream.
public export
data FrameError : Type where
  ||| Not enough data to complete the frame.
  Incomplete       : FrameError
  ||| The frame exceeds the maximum allowed size.
  Oversized        : FrameError
  ||| The delimiter is invalid or missing.
  InvalidDelimiter : FrameError
  ||| The length prefix is invalid.
  InvalidLength    : FrameError
  ||| The frame header is malformed.
  MalformedHeader  : FrameError
  ||| An encoding error occurred in the payload.
  EncodingError    : FrameError

public export
Show FrameError where
  show Incomplete       = "Incomplete"
  show Oversized        = "Oversized"
  show InvalidDelimiter = "InvalidDelimiter"
  show InvalidLength    = "InvalidLength"
  show MalformedHeader  = "MalformedHeader"
  show EncodingError    = "EncodingError"

---------------------------------------------------------------------------
-- Frame state — the state of the framing state machine.
---------------------------------------------------------------------------

||| The current state of frame parsing.
public export
data FrameState : Type where
  ||| Waiting for frame header / delimiter / length prefix.
  AwaitingHeader  : FrameState
  ||| Header received, waiting for payload data.
  AwaitingPayload : FrameState
  ||| A complete frame has been assembled.
  Complete        : FrameState
  ||| Framing has failed irrecoverably.
  Failed          : FrameState

public export
Show FrameState where
  show AwaitingHeader  = "AwaitingHeader"
  show AwaitingPayload = "AwaitingPayload"
  show Complete        = "Complete"
  show Failed          = "Failed"
