-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CardDAV Core Protocol Types (RFC 6352)
--
-- Defines vCard property types, request methods, address book operations,
-- and error conditions as closed sum types with Show/Eq instances.
-- All constructors map to RFC 6352 and vCard (RFC 6350) sections.

module CardDAV.Types

%default total

-- ============================================================================
-- vCard Property Types (RFC 6350 Section 6)
-- ============================================================================

||| Core vCard property types supported by CardDAV.
public export
data PropertyType : Type where
  ||| FN: formatted name of the contact.
  PropFN     : PropertyType
  ||| N: structured name components.
  PropN      : PropertyType
  ||| EMAIL: email address.
  PropEmail  : PropertyType
  ||| TEL: telephone number.
  PropTel    : PropertyType
  ||| ADR: delivery address.
  PropAdr    : PropertyType
  ||| ORG: organization name.
  PropOrg    : PropertyType
  ||| PHOTO: contact photograph.
  PropPhoto  : PropertyType
  ||| URL: associated URL.
  PropUrl    : PropertyType
  ||| NOTE: supplemental text.
  PropNote   : PropertyType

public export
Eq PropertyType where
  PropFN    == PropFN    = True
  PropN     == PropN     = True
  PropEmail == PropEmail = True
  PropTel   == PropTel   = True
  PropAdr   == PropAdr   = True
  PropOrg   == PropOrg   = True
  PropPhoto == PropPhoto = True
  PropUrl   == PropUrl   = True
  PropNote  == PropNote  = True
  _         == _         = False

public export
Show PropertyType where
  show PropFN    = "FN"
  show PropN     = "N"
  show PropEmail = "EMAIL"
  show PropTel   = "TEL"
  show PropAdr   = "ADR"
  show PropOrg   = "ORG"
  show PropPhoto = "PHOTO"
  show PropUrl   = "URL"
  show PropNote  = "NOTE"

-- ============================================================================
-- CardDAV Request Methods (RFC 6352 Section 6)
-- ============================================================================

||| CardDAV/WebDAV methods relevant to address book operations.
public export
data CardMethod : Type where
  ||| GET: retrieve a vCard resource.
  CardGet            : CardMethod
  ||| PUT: create or update a vCard resource.
  CardPut            : CardMethod
  ||| DELETE: remove a vCard resource.
  CardDelete         : CardMethod
  ||| PROPFIND: retrieve properties.
  CardPropfind       : CardMethod
  ||| PROPPATCH: modify properties.
  CardProppatch      : CardMethod
  ||| REPORT: execute a CardDAV report (e.g., addressbook-query).
  CardReport         : CardMethod
  ||| MKCOL: create address book collection (with DAV:resourcetype).
  CardMkcol          : CardMethod

public export
Eq CardMethod where
  CardGet       == CardGet       = True
  CardPut       == CardPut       = True
  CardDelete    == CardDelete    = True
  CardPropfind  == CardPropfind  = True
  CardProppatch == CardProppatch = True
  CardReport    == CardReport    = True
  CardMkcol     == CardMkcol     = True
  _             == _             = False

public export
Show CardMethod where
  show CardGet       = "GET"
  show CardPut       = "PUT"
  show CardDelete    = "DELETE"
  show CardPropfind  = "PROPFIND"
  show CardProppatch = "PROPPATCH"
  show CardReport    = "REPORT"
  show CardMkcol     = "MKCOL"

-- ============================================================================
-- vCard Version (RFC 6350)
-- ============================================================================

||| Supported vCard versions.
public export
data VCardVersion : Type where
  ||| vCard 3.0 (RFC 2426) — legacy but widely supported.
  VCard3 : VCardVersion
  ||| vCard 4.0 (RFC 6350) — current standard.
  VCard4 : VCardVersion

public export
Eq VCardVersion where
  VCard3 == VCard3 = True
  VCard4 == VCard4 = True
  _      == _      = False

public export
Show VCardVersion where
  show VCard3 = "3.0"
  show VCard4 = "4.0"

-- ============================================================================
-- CardDAV Error Conditions (RFC 6352 Section 6.3)
-- ============================================================================

||| CardDAV-specific error conditions.
public export
data CardError : Type where
  ||| Valid vCard data required but not provided.
  ValidAddressData    : CardError
  ||| Address book collection cannot contain another collection.
  NoResourceType      : CardError
  ||| Maximum resource size exceeded.
  MaxResourceSize     : CardError
  ||| UID conflict (duplicate UID in address book).
  UIDConflict         : CardError
  ||| Supported address data type mismatch.
  SupportedAddressData : CardError
  ||| Precondition failed (If-Match / If-None-Match).
  PreconditionFailed  : CardError

public export
Eq CardError where
  ValidAddressData     == ValidAddressData     = True
  NoResourceType       == NoResourceType       = True
  MaxResourceSize      == MaxResourceSize      = True
  UIDConflict          == UIDConflict          = True
  SupportedAddressData == SupportedAddressData = True
  PreconditionFailed   == PreconditionFailed   = True
  _                    == _                    = False

public export
Show CardError where
  show ValidAddressData     = "valid-address-data"
  show NoResourceType       = "no-resource-type"
  show MaxResourceSize      = "max-resource-size"
  show UIDConflict          = "uid-conflict"
  show SupportedAddressData = "supported-address-data"
  show PreconditionFailed   = "precondition-failed"
