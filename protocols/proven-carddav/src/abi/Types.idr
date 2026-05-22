-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CarddavABI.Types: C-ABI-compatible numeric representations of Carddav types.
--
-- Maps every constructor of the core Carddav sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/carddav.zig) exactly.
--
-- Types covered:
--   PropertyType              (9 constructors, tags 0-8)
--   CardMethod                (7 constructors, tags 0-6)
--   VCardVersion              (2 constructors, tags 0-1)
--   CardError                 (6 constructors, tags 0-5)
--   ServerState               (4 constructors, tags 0-3)

module CarddavABI.Types

%default total

---------------------------------------------------------------------------
-- PropertyType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
property_typeSize : Nat
property_typeSize = 1

||| PropertyType sum type for ABI encoding.
public export
data PropertyType : Type where
  FnName : PropertyType
  N : PropertyType
  Email : PropertyType
  Tel : PropertyType
  Adr : PropertyType
  Org : PropertyType
  Photo : PropertyType
  Url : PropertyType
  Note : PropertyType

||| Encode a PropertyType to its ABI tag value.
public export
property_typeToTag : PropertyType -> Bits8
property_typeToTag FnName = 0
property_typeToTag N = 1
property_typeToTag Email = 2
property_typeToTag Tel = 3
property_typeToTag Adr = 4
property_typeToTag Org = 5
property_typeToTag Photo = 6
property_typeToTag Url = 7
property_typeToTag Note = 8

||| Decode an ABI tag to a PropertyType.
public export
tagToPropertyType : Bits8 -> Maybe PropertyType
tagToPropertyType 0 = Just FnName
tagToPropertyType 1 = Just N
tagToPropertyType 2 = Just Email
tagToPropertyType 3 = Just Tel
tagToPropertyType 4 = Just Adr
tagToPropertyType 5 = Just Org
tagToPropertyType 6 = Just Photo
tagToPropertyType 7 = Just Url
tagToPropertyType 8 = Just Note
tagToPropertyType _ = Nothing

||| Roundtrip proof: decoding an encoded PropertyType yields the original.
public export
property_typeRoundtrip : (x : PropertyType) -> tagToPropertyType (property_typeToTag x) = Just x
property_typeRoundtrip FnName = Refl
property_typeRoundtrip N = Refl
property_typeRoundtrip Email = Refl
property_typeRoundtrip Tel = Refl
property_typeRoundtrip Adr = Refl
property_typeRoundtrip Org = Refl
property_typeRoundtrip Photo = Refl
property_typeRoundtrip Url = Refl
property_typeRoundtrip Note = Refl

---------------------------------------------------------------------------
-- CardMethod (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
card_methodSize : Nat
card_methodSize = 1

||| CardMethod sum type for ABI encoding.
public export
data CardMethod : Type where
  Get : CardMethod
  Put : CardMethod
  Delete : CardMethod
  Propfind : CardMethod
  Proppatch : CardMethod
  Report : CardMethod
  Mkcol : CardMethod

||| Encode a CardMethod to its ABI tag value.
public export
card_methodToTag : CardMethod -> Bits8
card_methodToTag Get = 0
card_methodToTag Put = 1
card_methodToTag Delete = 2
card_methodToTag Propfind = 3
card_methodToTag Proppatch = 4
card_methodToTag Report = 5
card_methodToTag Mkcol = 6

||| Decode an ABI tag to a CardMethod.
public export
tagToCardMethod : Bits8 -> Maybe CardMethod
tagToCardMethod 0 = Just Get
tagToCardMethod 1 = Just Put
tagToCardMethod 2 = Just Delete
tagToCardMethod 3 = Just Propfind
tagToCardMethod 4 = Just Proppatch
tagToCardMethod 5 = Just Report
tagToCardMethod 6 = Just Mkcol
tagToCardMethod _ = Nothing

||| Roundtrip proof: decoding an encoded CardMethod yields the original.
public export
card_methodRoundtrip : (x : CardMethod) -> tagToCardMethod (card_methodToTag x) = Just x
card_methodRoundtrip Get = Refl
card_methodRoundtrip Put = Refl
card_methodRoundtrip Delete = Refl
card_methodRoundtrip Propfind = Refl
card_methodRoundtrip Proppatch = Refl
card_methodRoundtrip Report = Refl
card_methodRoundtrip Mkcol = Refl

---------------------------------------------------------------------------
-- VCardVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
v_card_versionSize : Nat
v_card_versionSize = 1

||| VCardVersion sum type for ABI encoding.
public export
data VCardVersion : Type where
  Vcard3 : VCardVersion
  Vcard4 : VCardVersion

||| Encode a VCardVersion to its ABI tag value.
public export
v_card_versionToTag : VCardVersion -> Bits8
v_card_versionToTag Vcard3 = 0
v_card_versionToTag Vcard4 = 1

||| Decode an ABI tag to a VCardVersion.
public export
tagToVCardVersion : Bits8 -> Maybe VCardVersion
tagToVCardVersion 0 = Just Vcard3
tagToVCardVersion 1 = Just Vcard4
tagToVCardVersion _ = Nothing

||| Roundtrip proof: decoding an encoded VCardVersion yields the original.
public export
v_card_versionRoundtrip : (x : VCardVersion) -> tagToVCardVersion (v_card_versionToTag x) = Just x
v_card_versionRoundtrip Vcard3 = Refl
v_card_versionRoundtrip Vcard4 = Refl

---------------------------------------------------------------------------
-- CardError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
card_errorSize : Nat
card_errorSize = 1

||| CardError sum type for ABI encoding.
public export
data CardError : Type where
  ValidAddressData : CardError
  NoResourceType : CardError
  MaxResourceSize : CardError
  UidConflict : CardError
  SupportedAddressData : CardError
  PreconditionFailed : CardError

||| Encode a CardError to its ABI tag value.
public export
card_errorToTag : CardError -> Bits8
card_errorToTag ValidAddressData = 0
card_errorToTag NoResourceType = 1
card_errorToTag MaxResourceSize = 2
card_errorToTag UidConflict = 3
card_errorToTag SupportedAddressData = 4
card_errorToTag PreconditionFailed = 5

||| Decode an ABI tag to a CardError.
public export
tagToCardError : Bits8 -> Maybe CardError
tagToCardError 0 = Just ValidAddressData
tagToCardError 1 = Just NoResourceType
tagToCardError 2 = Just MaxResourceSize
tagToCardError 3 = Just UidConflict
tagToCardError 4 = Just SupportedAddressData
tagToCardError 5 = Just PreconditionFailed
tagToCardError _ = Nothing

||| Roundtrip proof: decoding an encoded CardError yields the original.
public export
card_errorRoundtrip : (x : CardError) -> tagToCardError (card_errorToTag x) = Just x
card_errorRoundtrip ValidAddressData = Refl
card_errorRoundtrip NoResourceType = Refl
card_errorRoundtrip MaxResourceSize = Refl
card_errorRoundtrip UidConflict = Refl
card_errorRoundtrip SupportedAddressData = Refl
card_errorRoundtrip PreconditionFailed = Refl

---------------------------------------------------------------------------
-- ServerState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
server_stateSize : Nat
server_stateSize = 1

||| ServerState sum type for ABI encoding.
public export
data ServerState : Type where
  Idle : ServerState
  Bound : ServerState
  Serving : ServerState
  Shutdown : ServerState

||| Encode a ServerState to its ABI tag value.
public export
server_stateToTag : ServerState -> Bits8
server_stateToTag Idle = 0
server_stateToTag Bound = 1
server_stateToTag Serving = 2
server_stateToTag Shutdown = 3

||| Decode an ABI tag to a ServerState.
public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just Idle
tagToServerState 1 = Just Bound
tagToServerState 2 = Just Serving
tagToServerState 3 = Just Shutdown
tagToServerState _ = Nothing

||| Roundtrip proof: decoding an encoded ServerState yields the original.
public export
server_stateRoundtrip : (x : ServerState) -> tagToServerState (server_stateToTag x) = Just x
server_stateRoundtrip Idle = Refl
server_stateRoundtrip Bound = Refl
server_stateRoundtrip Serving = Refl
server_stateRoundtrip Shutdown = Refl
