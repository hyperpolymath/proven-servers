-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SemwebABI.Types: C-ABI-compatible numeric representations of semantic web types.
--
-- Maps every constructor of the core semweb sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/semweb.zig) exactly.
--
-- Types covered:
--   Format             (6 constructors, tags 0-5)
--   ResourceType       (5 constructors, tags 0-4)
--   HTTPMethod         (5 constructors, tags 0-4)
--   ContentNegotiation (4 constructors, tags 0-3)
--   ErrorCode          (5 constructors, tags 0-4)

module SemwebABI.Types

import Semweb.Types

%default total

---------------------------------------------------------------------------
-- Format (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
formatSize : Nat
formatSize = 1

||| Encode a Format to its ABI tag value.
public export
formatToTag : Format -> Bits8
formatToTag RDFxml   = 0
formatToTag Turtle   = 1
formatToTag NTriples = 2
formatToTag NQuads   = 3
formatToTag JSONLD   = 4
formatToTag Trig     = 5

||| Decode an ABI tag value to a Format.
public export
tagToFormat : Bits8 -> Maybe Format
tagToFormat 0 = Just RDFxml
tagToFormat 1 = Just Turtle
tagToFormat 2 = Just NTriples
tagToFormat 3 = Just NQuads
tagToFormat 4 = Just JSONLD
tagToFormat 5 = Just Trig
tagToFormat _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
formatRoundtrip : (f : Format) -> tagToFormat (formatToTag f) = Just f
formatRoundtrip RDFxml   = Refl
formatRoundtrip Turtle   = Refl
formatRoundtrip NTriples = Refl
formatRoundtrip NQuads   = Refl
formatRoundtrip JSONLD   = Refl
formatRoundtrip Trig     = Refl

---------------------------------------------------------------------------
-- ResourceType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
resourceTypeSize : Nat
resourceTypeSize = 1

||| Encode a ResourceType to its ABI tag value.
public export
resourceTypeToTag : ResourceType -> Bits8
resourceTypeToTag Class      = 0
resourceTypeToTag Property   = 1
resourceTypeToTag Individual = 2
resourceTypeToTag Ontology   = 3
resourceTypeToTag NamedGraph = 4

||| Decode an ABI tag value to a ResourceType.
public export
tagToResourceType : Bits8 -> Maybe ResourceType
tagToResourceType 0 = Just Class
tagToResourceType 1 = Just Property
tagToResourceType 2 = Just Individual
tagToResourceType 3 = Just Ontology
tagToResourceType 4 = Just NamedGraph
tagToResourceType _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
resourceTypeRoundtrip : (r : ResourceType) -> tagToResourceType (resourceTypeToTag r) = Just r
resourceTypeRoundtrip Class      = Refl
resourceTypeRoundtrip Property   = Refl
resourceTypeRoundtrip Individual = Refl
resourceTypeRoundtrip Ontology   = Refl
resourceTypeRoundtrip NamedGraph = Refl

---------------------------------------------------------------------------
-- HTTPMethod (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
httpMethodSize : Nat
httpMethodSize = 1

||| Encode an HTTPMethod to its ABI tag value.
public export
httpMethodToTag : HTTPMethod -> Bits8
httpMethodToTag Get    = 0
httpMethodToTag Post   = 1
httpMethodToTag Put    = 2
httpMethodToTag Patch  = 3
httpMethodToTag Delete = 4

||| Decode an ABI tag value to an HTTPMethod.
public export
tagToHTTPMethod : Bits8 -> Maybe HTTPMethod
tagToHTTPMethod 0 = Just Get
tagToHTTPMethod 1 = Just Post
tagToHTTPMethod 2 = Just Put
tagToHTTPMethod 3 = Just Patch
tagToHTTPMethod 4 = Just Delete
tagToHTTPMethod _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
httpMethodRoundtrip : (m : HTTPMethod) -> tagToHTTPMethod (httpMethodToTag m) = Just m
httpMethodRoundtrip Get    = Refl
httpMethodRoundtrip Post   = Refl
httpMethodRoundtrip Put    = Refl
httpMethodRoundtrip Patch  = Refl
httpMethodRoundtrip Delete = Refl

---------------------------------------------------------------------------
-- ContentNegotiation (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
contentNegotiationSize : Nat
contentNegotiationSize = 1

||| Encode a ContentNegotiation to its ABI tag value.
public export
contentNegotiationToTag : ContentNegotiation -> Bits8
contentNegotiationToTag NegRDFxml = 0
contentNegotiationToTag NegTurtle = 1
contentNegotiationToTag NegJSONLD = 2
contentNegotiationToTag NegHTML   = 3

||| Decode an ABI tag value to a ContentNegotiation.
public export
tagToContentNegotiation : Bits8 -> Maybe ContentNegotiation
tagToContentNegotiation 0 = Just NegRDFxml
tagToContentNegotiation 1 = Just NegTurtle
tagToContentNegotiation 2 = Just NegJSONLD
tagToContentNegotiation 3 = Just NegHTML
tagToContentNegotiation _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
contentNegotiationRoundtrip : (c : ContentNegotiation) -> tagToContentNegotiation (contentNegotiationToTag c) = Just c
contentNegotiationRoundtrip NegRDFxml = Refl
contentNegotiationRoundtrip NegTurtle = Refl
contentNegotiationRoundtrip NegJSONLD = Refl
contentNegotiationRoundtrip NegHTML   = Refl

---------------------------------------------------------------------------
-- ErrorCode (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorCodeSize : Nat
errorCodeSize = 1

||| Encode an ErrorCode to its ABI tag value.
public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag NotFound           = 0
errorCodeToTag InvalidURI         = 1
errorCodeToTag MalformedRDF       = 2
errorCodeToTag UnsupportedFormat  = 3
errorCodeToTag ConflictingTriples = 4

||| Decode an ABI tag value to an ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just NotFound
tagToErrorCode 1 = Just InvalidURI
tagToErrorCode 2 = Just MalformedRDF
tagToErrorCode 3 = Just UnsupportedFormat
tagToErrorCode 4 = Just ConflictingTriples
tagToErrorCode _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip NotFound           = Refl
errorCodeRoundtrip InvalidURI         = Refl
errorCodeRoundtrip MalformedRDF       = Refl
errorCodeRoundtrip UnsupportedFormat  = Refl
errorCodeRoundtrip ConflictingTriples = Refl
