-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FrameABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (FrameStrategy, Delimiter,
-- LengthEncoding, FrameError, FrameState) to a fixed Bits8 value for
-- C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/frame.h) and the
-- Zig FFI enums (ffi/zig/src/frame.zig) exactly.

module FrameABI.Layout

import Frame.Types

%default total

---------------------------------------------------------------------------
-- FrameStrategy (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| C-ABI representation size for FrameStrategy (1 byte).
public export
frameStrategySize : Nat
frameStrategySize = 1

||| Map FrameStrategy to its C-ABI byte value.
|||
||| Tag assignments:
|||   LineDelimited  = 0
|||   LengthPrefixed = 1
|||   HTTPFrame      = 2
|||   FixedSize      = 3
|||   ChunkEncoded   = 4
|||   RawBytes       = 5
|||   TLVFrame       = 6
public export
frameStrategyToTag : FrameStrategy -> Bits8
frameStrategyToTag LineDelimited  = 0
frameStrategyToTag LengthPrefixed = 1
frameStrategyToTag HTTPFrame      = 2
frameStrategyToTag FixedSize      = 3
frameStrategyToTag ChunkEncoded   = 4
frameStrategyToTag RawBytes       = 5
frameStrategyToTag TLVFrame       = 6

||| Recover FrameStrategy from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-6.
public export
tagToFrameStrategy : Bits8 -> Maybe FrameStrategy
tagToFrameStrategy 0 = Just LineDelimited
tagToFrameStrategy 1 = Just LengthPrefixed
tagToFrameStrategy 2 = Just HTTPFrame
tagToFrameStrategy 3 = Just FixedSize
tagToFrameStrategy 4 = Just ChunkEncoded
tagToFrameStrategy 5 = Just RawBytes
tagToFrameStrategy 6 = Just TLVFrame
tagToFrameStrategy _ = Nothing

||| Proof: encoding then decoding FrameStrategy is the identity.
public export
frameStrategyRoundtrip : (s : FrameStrategy) -> tagToFrameStrategy (frameStrategyToTag s) = Just s
frameStrategyRoundtrip LineDelimited  = Refl
frameStrategyRoundtrip LengthPrefixed = Refl
frameStrategyRoundtrip HTTPFrame      = Refl
frameStrategyRoundtrip FixedSize      = Refl
frameStrategyRoundtrip ChunkEncoded   = Refl
frameStrategyRoundtrip RawBytes       = Refl
frameStrategyRoundtrip TLVFrame       = Refl

---------------------------------------------------------------------------
-- Delimiter (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for Delimiter (1 byte).
public export
delimiterSize : Nat
delimiterSize = 1

||| Map Delimiter to its C-ABI byte value.
|||
||| Tag assignments:
|||   CRLF   = 0
|||   LF     = 1
|||   Null   = 2
|||   Custom = 3
public export
delimiterToTag : Delimiter -> Bits8
delimiterToTag CRLF   = 0
delimiterToTag LF     = 1
delimiterToTag Null   = 2
delimiterToTag Custom = 3

||| Recover Delimiter from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToDelimiter : Bits8 -> Maybe Delimiter
tagToDelimiter 0 = Just CRLF
tagToDelimiter 1 = Just LF
tagToDelimiter 2 = Just Null
tagToDelimiter 3 = Just Custom
tagToDelimiter _ = Nothing

||| Proof: encoding then decoding Delimiter is the identity.
public export
delimiterRoundtrip : (d : Delimiter) -> tagToDelimiter (delimiterToTag d) = Just d
delimiterRoundtrip CRLF   = Refl
delimiterRoundtrip LF     = Refl
delimiterRoundtrip Null   = Refl
delimiterRoundtrip Custom = Refl

---------------------------------------------------------------------------
-- LengthEncoding (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for LengthEncoding (1 byte).
public export
lengthEncodingSize : Nat
lengthEncodingSize = 1

||| Map LengthEncoding to its C-ABI byte value.
|||
||| Tag assignments:
|||   BigEndian16    = 0
|||   BigEndian32    = 1
|||   LittleEndian16 = 2
|||   LittleEndian32 = 3
|||   Varint         = 4
public export
lengthEncodingToTag : LengthEncoding -> Bits8
lengthEncodingToTag BigEndian16    = 0
lengthEncodingToTag BigEndian32    = 1
lengthEncodingToTag LittleEndian16 = 2
lengthEncodingToTag LittleEndian32 = 3
lengthEncodingToTag Varint         = 4

||| Recover LengthEncoding from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToLengthEncoding : Bits8 -> Maybe LengthEncoding
tagToLengthEncoding 0 = Just BigEndian16
tagToLengthEncoding 1 = Just BigEndian32
tagToLengthEncoding 2 = Just LittleEndian16
tagToLengthEncoding 3 = Just LittleEndian32
tagToLengthEncoding 4 = Just Varint
tagToLengthEncoding _ = Nothing

||| Proof: encoding then decoding LengthEncoding is the identity.
public export
lengthEncodingRoundtrip : (enc : LengthEncoding) -> tagToLengthEncoding (lengthEncodingToTag enc) = Just enc
lengthEncodingRoundtrip BigEndian16    = Refl
lengthEncodingRoundtrip BigEndian32    = Refl
lengthEncodingRoundtrip LittleEndian16 = Refl
lengthEncodingRoundtrip LittleEndian32 = Refl
lengthEncodingRoundtrip Varint         = Refl

---------------------------------------------------------------------------
-- FrameError (6 constructors, tags 1-6; 0 = no error)
---------------------------------------------------------------------------

||| C-ABI representation size for FrameError (1 byte).
||| Note: tag 0 is reserved for "no error" in the C header (FRAME_ERR_NONE).
||| The Idris2 type has no "None" constructor -- the absence of an error
||| is represented by the absence of a FrameError value.
public export
frameErrorSize : Nat
frameErrorSize = 1

||| Map FrameError to its C-ABI byte value.
|||
||| Tag assignments (tag 0 reserved for FRAME_ERR_NONE):
|||   Incomplete       = 1
|||   Oversized        = 2
|||   InvalidDelimiter = 3
|||   InvalidLength    = 4
|||   MalformedHeader  = 5
|||   EncodingError    = 6
public export
frameErrorToTag : FrameError -> Bits8
frameErrorToTag Incomplete       = 1
frameErrorToTag Oversized        = 2
frameErrorToTag InvalidDelimiter = 3
frameErrorToTag InvalidLength    = 4
frameErrorToTag MalformedHeader  = 5
frameErrorToTag EncodingError    = 6

||| Recover FrameError from its C-ABI byte value.
||| Returns Nothing for tag 0 (no error) and for values > 6.
public export
tagToFrameError : Bits8 -> Maybe FrameError
tagToFrameError 1 = Just Incomplete
tagToFrameError 2 = Just Oversized
tagToFrameError 3 = Just InvalidDelimiter
tagToFrameError 4 = Just InvalidLength
tagToFrameError 5 = Just MalformedHeader
tagToFrameError 6 = Just EncodingError
tagToFrameError _ = Nothing

||| Proof: encoding then decoding FrameError is the identity.
public export
frameErrorRoundtrip : (e : FrameError) -> tagToFrameError (frameErrorToTag e) = Just e
frameErrorRoundtrip Incomplete       = Refl
frameErrorRoundtrip Oversized        = Refl
frameErrorRoundtrip InvalidDelimiter = Refl
frameErrorRoundtrip InvalidLength    = Refl
frameErrorRoundtrip MalformedHeader  = Refl
frameErrorRoundtrip EncodingError    = Refl

---------------------------------------------------------------------------
-- FrameState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for FrameState (1 byte).
public export
frameStateSize : Nat
frameStateSize = 1

||| Map FrameState to its C-ABI byte value.
|||
||| Tag assignments:
|||   AwaitingHeader  = 0
|||   AwaitingPayload = 1
|||   Complete        = 2
|||   Failed          = 3
public export
frameStateToTag : FrameState -> Bits8
frameStateToTag AwaitingHeader  = 0
frameStateToTag AwaitingPayload = 1
frameStateToTag Complete        = 2
frameStateToTag Failed          = 3

||| Recover FrameState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToFrameState : Bits8 -> Maybe FrameState
tagToFrameState 0 = Just AwaitingHeader
tagToFrameState 1 = Just AwaitingPayload
tagToFrameState 2 = Just Complete
tagToFrameState 3 = Just Failed
tagToFrameState _ = Nothing

||| Proof: encoding then decoding FrameState is the identity.
public export
frameStateRoundtrip : (s : FrameState) -> tagToFrameState (frameStateToTag s) = Just s
frameStateRoundtrip AwaitingHeader  = Refl
frameStateRoundtrip AwaitingPayload = Refl
frameStateRoundtrip Complete        = Refl
frameStateRoundtrip Failed          = Refl
