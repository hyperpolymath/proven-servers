-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SparqlABI.Types: C-ABI-compatible numeric representations of SPARQL types.
--
-- Maps every constructor of the core SPARQL sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/sparql.h) and the
-- Zig FFI enums (ffi/zig/src/sparql.zig) exactly.
--
-- Types covered:
--   QueryType    (4 constructors, tags 0-3)
--   UpdateType   (6 constructors, tags 0-5)
--   ResultFormat (4 constructors, tags 0-3)
--   ErrorType    (5 constructors, tags 0-4)

module SparqlABI.Types

import Sparql.Types

%default total

---------------------------------------------------------------------------
-- QueryType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
queryTypeSize : Nat
queryTypeSize = 1

||| Encode a QueryType to its ABI tag value.
public export
queryTypeToTag : QueryType -> Bits8
queryTypeToTag Select    = 0
queryTypeToTag Construct = 1
queryTypeToTag Ask       = 2
queryTypeToTag Describe  = 3

||| Decode an ABI tag to a QueryType.
public export
tagToQueryType : Bits8 -> Maybe QueryType
tagToQueryType 0 = Just Select
tagToQueryType 1 = Just Construct
tagToQueryType 2 = Just Ask
tagToQueryType 3 = Just Describe
tagToQueryType _ = Nothing

||| Roundtrip proof: decoding an encoded QueryType yields the original.
public export
queryTypeRoundtrip : (q : QueryType) -> tagToQueryType (queryTypeToTag q) = Just q
queryTypeRoundtrip Select    = Refl
queryTypeRoundtrip Construct = Refl
queryTypeRoundtrip Ask       = Refl
queryTypeRoundtrip Describe  = Refl

---------------------------------------------------------------------------
-- UpdateType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
updateTypeSize : Nat
updateTypeSize = 1

||| Encode an UpdateType to its ABI tag value.
public export
updateTypeToTag : UpdateType -> Bits8
updateTypeToTag Insert = 0
updateTypeToTag Delete = 1
updateTypeToTag Load   = 2
updateTypeToTag Clear  = 3
updateTypeToTag Create = 4
updateTypeToTag Drop   = 5

||| Decode an ABI tag to an UpdateType.
public export
tagToUpdateType : Bits8 -> Maybe UpdateType
tagToUpdateType 0 = Just Insert
tagToUpdateType 1 = Just Delete
tagToUpdateType 2 = Just Load
tagToUpdateType 3 = Just Clear
tagToUpdateType 4 = Just Create
tagToUpdateType 5 = Just Drop
tagToUpdateType _ = Nothing

||| Roundtrip proof: decoding an encoded UpdateType yields the original.
public export
updateTypeRoundtrip : (u : UpdateType) -> tagToUpdateType (updateTypeToTag u) = Just u
updateTypeRoundtrip Insert = Refl
updateTypeRoundtrip Delete = Refl
updateTypeRoundtrip Load   = Refl
updateTypeRoundtrip Clear  = Refl
updateTypeRoundtrip Create = Refl
updateTypeRoundtrip Drop   = Refl

---------------------------------------------------------------------------
-- ResultFormat (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
resultFormatSize : Nat
resultFormatSize = 1

||| Encode a ResultFormat to its ABI tag value.
public export
resultFormatToTag : ResultFormat -> Bits8
resultFormatToTag XML  = 0
resultFormatToTag JSON = 1
resultFormatToTag CSV  = 2
resultFormatToTag TSV  = 3

||| Decode an ABI tag to a ResultFormat.
public export
tagToResultFormat : Bits8 -> Maybe ResultFormat
tagToResultFormat 0 = Just XML
tagToResultFormat 1 = Just JSON
tagToResultFormat 2 = Just CSV
tagToResultFormat 3 = Just TSV
tagToResultFormat _ = Nothing

||| Roundtrip proof: decoding an encoded ResultFormat yields the original.
public export
resultFormatRoundtrip : (r : ResultFormat) -> tagToResultFormat (resultFormatToTag r) = Just r
resultFormatRoundtrip XML  = Refl
resultFormatRoundtrip JSON = Refl
resultFormatRoundtrip CSV  = Refl
resultFormatRoundtrip TSV  = Refl

---------------------------------------------------------------------------
-- ErrorType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorTypeSize : Nat
errorTypeSize = 1

||| Encode an ErrorType to its ABI tag value.
public export
errorTypeToTag : ErrorType -> Bits8
errorTypeToTag ParseError      = 0
errorTypeToTag QueryTimeout    = 1
errorTypeToTag ResultsTooLarge = 2
errorTypeToTag UnknownGraph    = 3
errorTypeToTag AccessDenied    = 4

||| Decode an ABI tag to an ErrorType.
public export
tagToErrorType : Bits8 -> Maybe ErrorType
tagToErrorType 0 = Just ParseError
tagToErrorType 1 = Just QueryTimeout
tagToErrorType 2 = Just ResultsTooLarge
tagToErrorType 3 = Just UnknownGraph
tagToErrorType 4 = Just AccessDenied
tagToErrorType _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorType yields the original.
public export
errorTypeRoundtrip : (e : ErrorType) -> tagToErrorType (errorTypeToTag e) = Just e
errorTypeRoundtrip ParseError      = Refl
errorTypeRoundtrip QueryTimeout    = Refl
errorTypeRoundtrip ResultsTooLarge = Refl
errorTypeRoundtrip UnknownGraph    = Refl
errorTypeRoundtrip AccessDenied    = Refl
