-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DohABI.Types: C-ABI-compatible numeric representations of Doh types.
--
-- Maps every constructor of the core Doh sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/doh.zig) exactly.
--
-- Types covered:
--   ContentType               (2 constructors, tags 0-1)
--   RequestMethod             (2 constructors, tags 0-1)
--   WireFormat                (2 constructors, tags 0-1)
--   ErrorReason               (5 constructors, tags 0-4)
--   SessionState              (5 constructors, tags 0-4)

module DohABI.Types

%default total

---------------------------------------------------------------------------
-- ContentType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
content_typeSize : Nat
content_typeSize = 1

||| ContentType sum type for ABI encoding.
public export
data ContentType : Type where
  DnsMessage : ContentType
  DnsJson : ContentType

||| Encode a ContentType to its ABI tag value.
public export
content_typeToTag : ContentType -> Bits8
content_typeToTag DnsMessage = 0
content_typeToTag DnsJson = 1

||| Decode an ABI tag to a ContentType.
public export
tagToContentType : Bits8 -> Maybe ContentType
tagToContentType 0 = Just DnsMessage
tagToContentType 1 = Just DnsJson
tagToContentType _ = Nothing

||| Roundtrip proof: decoding an encoded ContentType yields the original.
public export
content_typeRoundtrip : (x : ContentType) -> tagToContentType (content_typeToTag x) = Just x
content_typeRoundtrip DnsMessage = Refl
content_typeRoundtrip DnsJson = Refl

---------------------------------------------------------------------------
-- RequestMethod (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
request_methodSize : Nat
request_methodSize = 1

||| RequestMethod sum type for ABI encoding.
public export
data RequestMethod : Type where
  Get : RequestMethod
  Post : RequestMethod

||| Encode a RequestMethod to its ABI tag value.
public export
request_methodToTag : RequestMethod -> Bits8
request_methodToTag Get = 0
request_methodToTag Post = 1

||| Decode an ABI tag to a RequestMethod.
public export
tagToRequestMethod : Bits8 -> Maybe RequestMethod
tagToRequestMethod 0 = Just Get
tagToRequestMethod 1 = Just Post
tagToRequestMethod _ = Nothing

||| Roundtrip proof: decoding an encoded RequestMethod yields the original.
public export
request_methodRoundtrip : (x : RequestMethod) -> tagToRequestMethod (request_methodToTag x) = Just x
request_methodRoundtrip Get = Refl
request_methodRoundtrip Post = Refl

---------------------------------------------------------------------------
-- WireFormat (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
wire_formatSize : Nat
wire_formatSize = 1

||| WireFormat sum type for ABI encoding.
public export
data WireFormat : Type where
  Binary : WireFormat
  Json : WireFormat

||| Encode a WireFormat to its ABI tag value.
public export
wire_formatToTag : WireFormat -> Bits8
wire_formatToTag Binary = 0
wire_formatToTag Json = 1

||| Decode an ABI tag to a WireFormat.
public export
tagToWireFormat : Bits8 -> Maybe WireFormat
tagToWireFormat 0 = Just Binary
tagToWireFormat 1 = Just Json
tagToWireFormat _ = Nothing

||| Roundtrip proof: decoding an encoded WireFormat yields the original.
public export
wire_formatRoundtrip : (x : WireFormat) -> tagToWireFormat (wire_formatToTag x) = Just x
wire_formatRoundtrip Binary = Refl
wire_formatRoundtrip Json = Refl

---------------------------------------------------------------------------
-- ErrorReason (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
error_reasonSize : Nat
error_reasonSize = 1

||| ErrorReason sum type for ABI encoding.
public export
data ErrorReason : Type where
  BadContentType : ErrorReason
  BadMethod : ErrorReason
  PayloadTooLarge : ErrorReason
  UpstreamTimeout : ErrorReason
  UpstreamError : ErrorReason

||| Encode a ErrorReason to its ABI tag value.
public export
error_reasonToTag : ErrorReason -> Bits8
error_reasonToTag BadContentType = 0
error_reasonToTag BadMethod = 1
error_reasonToTag PayloadTooLarge = 2
error_reasonToTag UpstreamTimeout = 3
error_reasonToTag UpstreamError = 4

||| Decode an ABI tag to a ErrorReason.
public export
tagToErrorReason : Bits8 -> Maybe ErrorReason
tagToErrorReason 0 = Just BadContentType
tagToErrorReason 1 = Just BadMethod
tagToErrorReason 2 = Just PayloadTooLarge
tagToErrorReason 3 = Just UpstreamTimeout
tagToErrorReason 4 = Just UpstreamError
tagToErrorReason _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorReason yields the original.
public export
error_reasonRoundtrip : (x : ErrorReason) -> tagToErrorReason (error_reasonToTag x) = Just x
error_reasonRoundtrip BadContentType = Refl
error_reasonRoundtrip BadMethod = Refl
error_reasonRoundtrip PayloadTooLarge = Refl
error_reasonRoundtrip UpstreamTimeout = Refl
error_reasonRoundtrip UpstreamError = Refl

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
  Resolving : SessionState
  Shutdown : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Idle = 0
session_stateToTag Bound = 1
session_stateToTag Serving = 2
session_stateToTag Resolving = 3
session_stateToTag Shutdown = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just Bound
tagToSessionState 2 = Just Serving
tagToSessionState 3 = Just Resolving
tagToSessionState 4 = Just Shutdown
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Idle = Refl
session_stateRoundtrip Bound = Refl
session_stateRoundtrip Serving = Refl
session_stateRoundtrip Resolving = Refl
session_stateRoundtrip Shutdown = Refl
