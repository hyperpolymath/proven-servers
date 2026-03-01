-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Wire.Types: Core type definitions for verified serialisation/deserialisation.
-- Closed sum types representing the boundary between typed Idris values and
-- raw bytes on the wire — endianness, wire types, encode/decode errors, codecs.

module Wire.Types

%default total

---------------------------------------------------------------------------
-- Endianness — byte order for multi-byte values.
---------------------------------------------------------------------------

||| Byte order for multi-byte wire values.
public export
data Endianness : Type where
  ||| Most significant byte first.
  BigEndian    : Endianness
  ||| Least significant byte first.
  LittleEndian : Endianness
  ||| Network byte order (big-endian by convention).
  NetworkOrder : Endianness
  ||| Host-native byte order.
  HostOrder    : Endianness

public export
Show Endianness where
  show BigEndian    = "BigEndian"
  show LittleEndian = "LittleEndian"
  show NetworkOrder = "NetworkOrder"
  show HostOrder    = "HostOrder"

---------------------------------------------------------------------------
-- Wire type — the primitive types that can appear on the wire.
---------------------------------------------------------------------------

||| Primitive types that can be encoded/decoded on the wire.
public export
data WireType : Type where
  ||| Unsigned 8-bit integer.
  UInt8      : WireType
  ||| Unsigned 16-bit integer.
  UInt16     : WireType
  ||| Unsigned 32-bit integer.
  UInt32     : WireType
  ||| Unsigned 64-bit integer.
  UInt64     : WireType
  ||| Signed 8-bit integer.
  Int8       : WireType
  ||| Signed 16-bit integer.
  Int16      : WireType
  ||| Signed 32-bit integer.
  Int32      : WireType
  ||| Signed 64-bit integer.
  Int64      : WireType
  ||| IEEE 754 single-precision float.
  Float32    : WireType
  ||| IEEE 754 double-precision float.
  Float64    : WireType
  ||| Boolean value.
  Bool       : WireType
  ||| UTF-8 encoded string.
  UTF8String : WireType
  ||| Raw byte sequence.
  Bytes      : WireType
  ||| Optional (nullable) value.
  Optional   : WireType
  ||| Ordered sequence of values.
  Sequence   : WireType
  ||| Named record of fields.
  Record     : WireType

public export
Show WireType where
  show UInt8      = "UInt8"
  show UInt16     = "UInt16"
  show UInt32     = "UInt32"
  show UInt64     = "UInt64"
  show Int8       = "Int8"
  show Int16      = "Int16"
  show Int32      = "Int32"
  show Int64      = "Int64"
  show Float32    = "Float32"
  show Float64    = "Float64"
  show Bool       = "Bool"
  show UTF8String = "UTF8String"
  show Bytes      = "Bytes"
  show Optional   = "Optional"
  show Sequence   = "Sequence"
  show Record     = "Record"

---------------------------------------------------------------------------
-- Encode error — errors during serialisation.
---------------------------------------------------------------------------

||| Errors that can occur during serialisation (encoding).
public export
data EncodeError : Type where
  ||| Value exceeds the maximum for its wire type.
  Overflow     : EncodeError
  ||| Value is below the minimum for its wire type.
  Underflow    : EncodeError
  ||| String contains invalid UTF-8 sequences.
  InvalidUTF8  : EncodeError
  ||| The output buffer is full.
  BufferFull   : EncodeError
  ||| A required field is missing from the record.
  FieldMissing : EncodeError
  ||| The value type does not match the expected wire type.
  TypeMismatch : EncodeError

public export
Show EncodeError where
  show Overflow     = "Overflow"
  show Underflow    = "Underflow"
  show InvalidUTF8  = "InvalidUTF8"
  show BufferFull   = "BufferFull"
  show FieldMissing = "FieldMissing"
  show TypeMismatch = "TypeMismatch"

---------------------------------------------------------------------------
-- Decode error — errors during deserialisation.
---------------------------------------------------------------------------

||| Errors that can occur during deserialisation (decoding).
public export
data DecodeError : Type where
  ||| Unexpected end of input before value was fully read.
  UnexpectedEOF    : DecodeError
  ||| An unrecognised type tag was encountered.
  InvalidTag       : DecodeError
  ||| The declared length is invalid or inconsistent.
  InvalidLength    : DecodeError
  ||| The data is structurally malformed.
  MalformedData    : DecodeError
  ||| The wire format version is not supported.
  UnsupportedVersion : DecodeError
  ||| The checksum does not match the data.
  ChecksumMismatch : DecodeError

public export
Show DecodeError where
  show UnexpectedEOF      = "UnexpectedEOF"
  show InvalidTag         = "InvalidTag"
  show InvalidLength      = "InvalidLength"
  show MalformedData      = "MalformedData"
  show UnsupportedVersion = "UnsupportedVersion"
  show ChecksumMismatch   = "ChecksumMismatch"

---------------------------------------------------------------------------
-- Codec — the direction of a wire encoding operation.
---------------------------------------------------------------------------

||| The direction of a wire encoding operation.
public export
data Codec : Type where
  ||| Serialise a value to bytes.
  Encode   : Codec
  ||| Deserialise bytes to a value.
  Decode   : Codec
  ||| Verify that encode then decode is the identity (roundtrip).
  Roundtrip : Codec

public export
Show Codec where
  show Encode   = "Encode"
  show Decode   = "Decode"
  show Roundtrip = "Roundtrip"
