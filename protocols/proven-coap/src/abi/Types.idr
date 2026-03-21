-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CoapABI.Types: C-ABI-compatible numeric representations of Coap types.
--
-- Maps every constructor of the core Coap sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/coap.zig) exactly.
--
-- Types covered:
--   Method                    (4 constructors, tags 0-3)
--   MessageType               (4 constructors, tags 0-3)
--   ContentFormat             (7 constructors, tags 0-6)
--   ResponseClass             (5 constructors, tags 0-4)
--   SessionState              (5 constructors, tags 0-4)

module CoapABI.Types

%default total

---------------------------------------------------------------------------
-- Method (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
methodSize : Nat
methodSize = 1

||| Method sum type for ABI encoding.
public export
data Method : Type where
  Get : Method
  Post : Method
  Put : Method
  Delete : Method

||| Encode a Method to its ABI tag value.
public export
methodToTag : Method -> Bits8
methodToTag Get = 0
methodToTag Post = 1
methodToTag Put = 2
methodToTag Delete = 3

||| Decode an ABI tag to a Method.
public export
tagToMethod : Bits8 -> Maybe Method
tagToMethod 0 = Just Get
tagToMethod 1 = Just Post
tagToMethod 2 = Just Put
tagToMethod 3 = Just Delete
tagToMethod _ = Nothing

||| Roundtrip proof: decoding an encoded Method yields the original.
public export
methodRoundtrip : (x : Method) -> tagToMethod (methodToTag x) = Just x
methodRoundtrip Get = Refl
methodRoundtrip Post = Refl
methodRoundtrip Put = Refl
methodRoundtrip Delete = Refl

---------------------------------------------------------------------------
-- MessageType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
message_typeSize : Nat
message_typeSize = 1

||| MessageType sum type for ABI encoding.
public export
data MessageType : Type where
  Confirmable : MessageType
  NonConfirmable : MessageType
  Acknowledgement : MessageType
  Reset : MessageType

||| Encode a MessageType to its ABI tag value.
public export
message_typeToTag : MessageType -> Bits8
message_typeToTag Confirmable = 0
message_typeToTag NonConfirmable = 1
message_typeToTag Acknowledgement = 2
message_typeToTag Reset = 3

||| Decode an ABI tag to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Confirmable
tagToMessageType 1 = Just NonConfirmable
tagToMessageType 2 = Just Acknowledgement
tagToMessageType 3 = Just Reset
tagToMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
message_typeRoundtrip : (x : MessageType) -> tagToMessageType (message_typeToTag x) = Just x
message_typeRoundtrip Confirmable = Refl
message_typeRoundtrip NonConfirmable = Refl
message_typeRoundtrip Acknowledgement = Refl
message_typeRoundtrip Reset = Refl

---------------------------------------------------------------------------
-- ContentFormat (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
content_formatSize : Nat
content_formatSize = 1

||| ContentFormat sum type for ABI encoding.
public export
data ContentFormat : Type where
  TextPlain : ContentFormat
  LinkFormat : ContentFormat
  Xml : ContentFormat
  OctetStream : ContentFormat
  Exi : ContentFormat
  Json : ContentFormat
  Cbor : ContentFormat

||| Encode a ContentFormat to its ABI tag value.
public export
content_formatToTag : ContentFormat -> Bits8
content_formatToTag TextPlain = 0
content_formatToTag LinkFormat = 1
content_formatToTag Xml = 2
content_formatToTag OctetStream = 3
content_formatToTag Exi = 4
content_formatToTag Json = 5
content_formatToTag Cbor = 6

||| Decode an ABI tag to a ContentFormat.
public export
tagToContentFormat : Bits8 -> Maybe ContentFormat
tagToContentFormat 0 = Just TextPlain
tagToContentFormat 1 = Just LinkFormat
tagToContentFormat 2 = Just Xml
tagToContentFormat 3 = Just OctetStream
tagToContentFormat 4 = Just Exi
tagToContentFormat 5 = Just Json
tagToContentFormat 6 = Just Cbor
tagToContentFormat _ = Nothing

||| Roundtrip proof: decoding an encoded ContentFormat yields the original.
public export
content_formatRoundtrip : (x : ContentFormat) -> tagToContentFormat (content_formatToTag x) = Just x
content_formatRoundtrip TextPlain = Refl
content_formatRoundtrip LinkFormat = Refl
content_formatRoundtrip Xml = Refl
content_formatRoundtrip OctetStream = Refl
content_formatRoundtrip Exi = Refl
content_formatRoundtrip Json = Refl
content_formatRoundtrip Cbor = Refl

---------------------------------------------------------------------------
-- ResponseClass (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
response_classSize : Nat
response_classSize = 1

||| ResponseClass sum type for ABI encoding.
public export
data ResponseClass : Type where
  Success : ResponseClass
  ClientError : ResponseClass
  ServerError : ResponseClass
  Signaling : ResponseClass
  Empty : ResponseClass

||| Encode a ResponseClass to its ABI tag value.
public export
response_classToTag : ResponseClass -> Bits8
response_classToTag Success = 0
response_classToTag ClientError = 1
response_classToTag ServerError = 2
response_classToTag Signaling = 3
response_classToTag Empty = 4

||| Decode an ABI tag to a ResponseClass.
public export
tagToResponseClass : Bits8 -> Maybe ResponseClass
tagToResponseClass 0 = Just Success
tagToResponseClass 1 = Just ClientError
tagToResponseClass 2 = Just ServerError
tagToResponseClass 3 = Just Signaling
tagToResponseClass 4 = Just Empty
tagToResponseClass _ = Nothing

||| Roundtrip proof: decoding an encoded ResponseClass yields the original.
public export
response_classRoundtrip : (x : ResponseClass) -> tagToResponseClass (response_classToTag x) = Just x
response_classRoundtrip Success = Refl
response_classRoundtrip ClientError = Refl
response_classRoundtrip ServerError = Refl
response_classRoundtrip Signaling = Refl
response_classRoundtrip Empty = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Idle : SessionState
  Bound : SessionState
  Serving : SessionState
  Observing : SessionState
  Shutdown : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Idle = 0
session_stateToTag Bound = 1
session_stateToTag Serving = 2
session_stateToTag Observing = 3
session_stateToTag Shutdown = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just Bound
tagToSessionState 2 = Just Serving
tagToSessionState 3 = Just Observing
tagToSessionState 4 = Just Shutdown
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Idle = Refl
session_stateRoundtrip Bound = Refl
session_stateRoundtrip Serving = Refl
session_stateRoundtrip Observing = Refl
session_stateRoundtrip Shutdown = Refl
