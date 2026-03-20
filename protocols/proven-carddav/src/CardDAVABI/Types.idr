-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CardDAVABI.Types: C-ABI-compatible numeric representations of CardDAV types.
--
-- Maps every constructor of the core CardDAV sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/carddav.h) and the
-- Zig FFI enums (ffi/zig/src/carddav.zig) exactly.
--
-- Types covered:
--   PropertyType  (9 constructors, tags 0-8)
--   CardMethod    (7 constructors, tags 0-6)
--   VCardVersion  (2 constructors, tags 0-1)
--   CardError     (6 constructors, tags 0-5)
--   ServerState   (4 constructors, tags 0-3)

module CardDAVABI.Types

import CardDAV.Types

%default total

---------------------------------------------------------------------------
-- PropertyType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
propertyTypeToTag : PropertyType -> Bits8
propertyTypeToTag PropFN    = 0
propertyTypeToTag PropN     = 1
propertyTypeToTag PropEmail = 2
propertyTypeToTag PropTel   = 3
propertyTypeToTag PropAdr   = 4
propertyTypeToTag PropOrg   = 5
propertyTypeToTag PropPhoto = 6
propertyTypeToTag PropUrl   = 7
propertyTypeToTag PropNote  = 8

public export
tagToPropertyType : Bits8 -> Maybe PropertyType
tagToPropertyType 0 = Just PropFN
tagToPropertyType 1 = Just PropN
tagToPropertyType 2 = Just PropEmail
tagToPropertyType 3 = Just PropTel
tagToPropertyType 4 = Just PropAdr
tagToPropertyType 5 = Just PropOrg
tagToPropertyType 6 = Just PropPhoto
tagToPropertyType 7 = Just PropUrl
tagToPropertyType 8 = Just PropNote
tagToPropertyType _ = Nothing

public export
propertyTypeRoundtrip : (p : PropertyType) -> tagToPropertyType (propertyTypeToTag p) = Just p
propertyTypeRoundtrip PropFN    = Refl
propertyTypeRoundtrip PropN     = Refl
propertyTypeRoundtrip PropEmail = Refl
propertyTypeRoundtrip PropTel   = Refl
propertyTypeRoundtrip PropAdr   = Refl
propertyTypeRoundtrip PropOrg   = Refl
propertyTypeRoundtrip PropPhoto = Refl
propertyTypeRoundtrip PropUrl   = Refl
propertyTypeRoundtrip PropNote  = Refl

---------------------------------------------------------------------------
-- CardMethod (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
cardMethodToTag : CardMethod -> Bits8
cardMethodToTag CardGet       = 0
cardMethodToTag CardPut       = 1
cardMethodToTag CardDelete    = 2
cardMethodToTag CardPropfind  = 3
cardMethodToTag CardProppatch = 4
cardMethodToTag CardReport    = 5
cardMethodToTag CardMkcol     = 6

public export
tagToCardMethod : Bits8 -> Maybe CardMethod
tagToCardMethod 0 = Just CardGet
tagToCardMethod 1 = Just CardPut
tagToCardMethod 2 = Just CardDelete
tagToCardMethod 3 = Just CardPropfind
tagToCardMethod 4 = Just CardProppatch
tagToCardMethod 5 = Just CardReport
tagToCardMethod 6 = Just CardMkcol
tagToCardMethod _ = Nothing

public export
cardMethodRoundtrip : (m : CardMethod) -> tagToCardMethod (cardMethodToTag m) = Just m
cardMethodRoundtrip CardGet       = Refl
cardMethodRoundtrip CardPut       = Refl
cardMethodRoundtrip CardDelete    = Refl
cardMethodRoundtrip CardPropfind  = Refl
cardMethodRoundtrip CardProppatch = Refl
cardMethodRoundtrip CardReport    = Refl
cardMethodRoundtrip CardMkcol     = Refl

---------------------------------------------------------------------------
-- VCardVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
vcardVersionToTag : VCardVersion -> Bits8
vcardVersionToTag VCard3 = 0
vcardVersionToTag VCard4 = 1

public export
tagToVCardVersion : Bits8 -> Maybe VCardVersion
tagToVCardVersion 0 = Just VCard3
tagToVCardVersion 1 = Just VCard4
tagToVCardVersion _ = Nothing

public export
vcardVersionRoundtrip : (v : VCardVersion) -> tagToVCardVersion (vcardVersionToTag v) = Just v
vcardVersionRoundtrip VCard3 = Refl
vcardVersionRoundtrip VCard4 = Refl

---------------------------------------------------------------------------
-- CardError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
cardErrorToTag : CardError -> Bits8
cardErrorToTag ValidAddressData     = 0
cardErrorToTag NoResourceType       = 1
cardErrorToTag MaxResourceSize      = 2
cardErrorToTag UIDConflict          = 3
cardErrorToTag SupportedAddressData = 4
cardErrorToTag PreconditionFailed   = 5

public export
tagToCardError : Bits8 -> Maybe CardError
tagToCardError 0 = Just ValidAddressData
tagToCardError 1 = Just NoResourceType
tagToCardError 2 = Just MaxResourceSize
tagToCardError 3 = Just UIDConflict
tagToCardError 4 = Just SupportedAddressData
tagToCardError 5 = Just PreconditionFailed
tagToCardError _ = Nothing

public export
cardErrorRoundtrip : (e : CardError) -> tagToCardError (cardErrorToTag e) = Just e
cardErrorRoundtrip ValidAddressData     = Refl
cardErrorRoundtrip NoResourceType       = Refl
cardErrorRoundtrip MaxResourceSize      = Refl
cardErrorRoundtrip UIDConflict          = Refl
cardErrorRoundtrip SupportedAddressData = Refl
cardErrorRoundtrip PreconditionFailed   = Refl

---------------------------------------------------------------------------
-- ServerState (4 constructors, tags 0-3)
-- CardDAV server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| CardDAV server lifecycle states.
public export
data ServerState : Type where
  ||| No server bound. Initial and terminal state.
  SSIdle     : ServerState
  ||| Server bound to HTTP port, ready to accept requests.
  SSBound    : ServerState
  ||| Actively serving address books (at least one address book exists).
  SSServing  : ServerState
  ||| Shutting down (draining in-flight requests).
  SSShutdown : ServerState

public export
Eq ServerState where
  SSIdle     == SSIdle     = True
  SSBound    == SSBound    = True
  SSServing  == SSServing  = True
  SSShutdown == SSShutdown = True
  _          == _          = False

public export
Show ServerState where
  show SSIdle     = "Idle"
  show SSBound    = "Bound"
  show SSServing  = "Serving"
  show SSShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SSIdle     = 0
serverStateToTag SSBound    = 1
serverStateToTag SSServing  = 2
serverStateToTag SSShutdown = 3

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SSIdle
tagToServerState 1 = Just SSBound
tagToServerState 2 = Just SSServing
tagToServerState 3 = Just SSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SSIdle     = Refl
serverStateRoundtrip SSBound    = Refl
serverStateRoundtrip SSServing  = Refl
serverStateRoundtrip SSShutdown = Refl
