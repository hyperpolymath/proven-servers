-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WireABI.Layout: C-ABI-compatible numeric representations of wire types.
--
-- Maps every constructor of the five core sum types (Endianness, WireType,
-- EncodeError, DecodeError, Codec) to fixed Bits8 values for C interop.
-- Each type gets a total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/wire.h) and the
-- Zig FFI enums (ffi/zig/src/wire.zig) exactly.

module WireABI.Layout

import Wire.Types

%default total

---------------------------------------------------------------------------
-- Endianness (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
endiannessSize : Nat
endiannessSize = 1

public export
endiannessToTag : Endianness -> Bits8
endiannessToTag BigEndian    = 0
endiannessToTag LittleEndian = 1
endiannessToTag NetworkOrder = 2
endiannessToTag HostOrder    = 3

public export
tagToEndianness : Bits8 -> Maybe Endianness
tagToEndianness 0 = Just BigEndian
tagToEndianness 1 = Just LittleEndian
tagToEndianness 2 = Just NetworkOrder
tagToEndianness 3 = Just HostOrder
tagToEndianness _ = Nothing

public export
endiannessRoundtrip : (e : Endianness) -> tagToEndianness (endiannessToTag e) = Just e
endiannessRoundtrip BigEndian    = Refl
endiannessRoundtrip LittleEndian = Refl
endiannessRoundtrip NetworkOrder = Refl
endiannessRoundtrip HostOrder    = Refl

---------------------------------------------------------------------------
-- WireType (16 constructors, tags 0-15)
---------------------------------------------------------------------------

public export
wireTypeSize : Nat
wireTypeSize = 1

public export
wireTypeToTag : WireType -> Bits8
wireTypeToTag UInt8      = 0
wireTypeToTag UInt16     = 1
wireTypeToTag UInt32     = 2
wireTypeToTag UInt64     = 3
wireTypeToTag Int8       = 4
wireTypeToTag Int16      = 5
wireTypeToTag Int32      = 6
wireTypeToTag Int64      = 7
wireTypeToTag Float32    = 8
wireTypeToTag Float64    = 9
wireTypeToTag Bool       = 10
wireTypeToTag UTF8String = 11
wireTypeToTag Bytes      = 12
wireTypeToTag Optional   = 13
wireTypeToTag Sequence   = 14
wireTypeToTag Record     = 15

public export
tagToWireType : Bits8 -> Maybe WireType
tagToWireType 0  = Just UInt8
tagToWireType 1  = Just UInt16
tagToWireType 2  = Just UInt32
tagToWireType 3  = Just UInt64
tagToWireType 4  = Just Int8
tagToWireType 5  = Just Int16
tagToWireType 6  = Just Int32
tagToWireType 7  = Just Int64
tagToWireType 8  = Just Float32
tagToWireType 9  = Just Float64
tagToWireType 10 = Just Bool
tagToWireType 11 = Just UTF8String
tagToWireType 12 = Just Bytes
tagToWireType 13 = Just Optional
tagToWireType 14 = Just Sequence
tagToWireType 15 = Just Record
tagToWireType _  = Nothing

public export
wireTypeRoundtrip : (w : WireType) -> tagToWireType (wireTypeToTag w) = Just w
wireTypeRoundtrip UInt8      = Refl
wireTypeRoundtrip UInt16     = Refl
wireTypeRoundtrip UInt32     = Refl
wireTypeRoundtrip UInt64     = Refl
wireTypeRoundtrip Int8       = Refl
wireTypeRoundtrip Int16      = Refl
wireTypeRoundtrip Int32      = Refl
wireTypeRoundtrip Int64      = Refl
wireTypeRoundtrip Float32    = Refl
wireTypeRoundtrip Float64    = Refl
wireTypeRoundtrip Bool       = Refl
wireTypeRoundtrip UTF8String = Refl
wireTypeRoundtrip Bytes      = Refl
wireTypeRoundtrip Optional   = Refl
wireTypeRoundtrip Sequence   = Refl
wireTypeRoundtrip Record     = Refl

---------------------------------------------------------------------------
-- WireType byte size lookup
---------------------------------------------------------------------------

||| Fixed byte size of a wire type. Returns 0 for variable-length types
||| (UTF8String, Bytes, Optional, Sequence, Record).
public export
wireTypeByteSize : WireType -> Nat
wireTypeByteSize UInt8      = 1
wireTypeByteSize UInt16     = 2
wireTypeByteSize UInt32     = 4
wireTypeByteSize UInt64     = 8
wireTypeByteSize Int8       = 1
wireTypeByteSize Int16      = 2
wireTypeByteSize Int32      = 4
wireTypeByteSize Int64      = 8
wireTypeByteSize Float32    = 4
wireTypeByteSize Float64    = 8
wireTypeByteSize Bool       = 1
wireTypeByteSize UTF8String = 0
wireTypeByteSize Bytes      = 0
wireTypeByteSize Optional   = 0
wireTypeByteSize Sequence   = 0
wireTypeByteSize Record     = 0

||| Whether a wire type has a fixed size (not variable-length).
public export
isFixedSize : WireType -> Bool
isFixedSize w = wireTypeByteSize w /= 0

---------------------------------------------------------------------------
-- EncodeError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
encodeErrorSize : Nat
encodeErrorSize = 1

public export
encodeErrorToTag : EncodeError -> Bits8
encodeErrorToTag Overflow     = 0
encodeErrorToTag Underflow    = 1
encodeErrorToTag InvalidUTF8  = 2
encodeErrorToTag BufferFull   = 3
encodeErrorToTag FieldMissing = 4
encodeErrorToTag TypeMismatch = 5

public export
tagToEncodeError : Bits8 -> Maybe EncodeError
tagToEncodeError 0 = Just Overflow
tagToEncodeError 1 = Just Underflow
tagToEncodeError 2 = Just InvalidUTF8
tagToEncodeError 3 = Just BufferFull
tagToEncodeError 4 = Just FieldMissing
tagToEncodeError 5 = Just TypeMismatch
tagToEncodeError _ = Nothing

public export
encodeErrorRoundtrip : (e : EncodeError) -> tagToEncodeError (encodeErrorToTag e) = Just e
encodeErrorRoundtrip Overflow     = Refl
encodeErrorRoundtrip Underflow    = Refl
encodeErrorRoundtrip InvalidUTF8  = Refl
encodeErrorRoundtrip BufferFull   = Refl
encodeErrorRoundtrip FieldMissing = Refl
encodeErrorRoundtrip TypeMismatch = Refl

---------------------------------------------------------------------------
-- DecodeError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
decodeErrorSize : Nat
decodeErrorSize = 1

public export
decodeErrorToTag : DecodeError -> Bits8
decodeErrorToTag UnexpectedEOF      = 0
decodeErrorToTag InvalidTag         = 1
decodeErrorToTag InvalidLength      = 2
decodeErrorToTag MalformedData      = 3
decodeErrorToTag UnsupportedVersion = 4
decodeErrorToTag ChecksumMismatch   = 5

public export
tagToDecodeError : Bits8 -> Maybe DecodeError
tagToDecodeError 0 = Just UnexpectedEOF
tagToDecodeError 1 = Just InvalidTag
tagToDecodeError 2 = Just InvalidLength
tagToDecodeError 3 = Just MalformedData
tagToDecodeError 4 = Just UnsupportedVersion
tagToDecodeError 5 = Just ChecksumMismatch
tagToDecodeError _ = Nothing

public export
decodeErrorRoundtrip : (e : DecodeError) -> tagToDecodeError (decodeErrorToTag e) = Just e
decodeErrorRoundtrip UnexpectedEOF      = Refl
decodeErrorRoundtrip InvalidTag         = Refl
decodeErrorRoundtrip InvalidLength      = Refl
decodeErrorRoundtrip MalformedData      = Refl
decodeErrorRoundtrip UnsupportedVersion = Refl
decodeErrorRoundtrip ChecksumMismatch   = Refl

---------------------------------------------------------------------------
-- Codec (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
codecSize : Nat
codecSize = 1

public export
codecToTag : Codec -> Bits8
codecToTag Encode    = 0
codecToTag Decode    = 1
codecToTag Roundtrip = 2

public export
tagToCodec : Bits8 -> Maybe Codec
tagToCodec 0 = Just Encode
tagToCodec 1 = Just Decode
tagToCodec 2 = Just Roundtrip
tagToCodec _ = Nothing

public export
codecRoundtrip : (c : Codec) -> tagToCodec (codecToTag c) = Just c
codecRoundtrip Encode    = Refl
codecRoundtrip Decode    = Refl
codecRoundtrip Roundtrip = Refl
