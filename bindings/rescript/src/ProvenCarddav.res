// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV types for the proven-servers ABI.
//
// Mirrors the Idris2 module CarddavABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard CardDAV HTTPS port.
let carddavPort = 443

// ===========================================================================
// PropertyType (tags 0-8)
// ===========================================================================

/// Standard CardDAV HTTPS port.
type propertyType =
  | @as(0) FnName
  | @as(1) N
  | @as(2) Email
  | @as(3) Tel
  | @as(4) Adr
  | @as(5) Org
  | @as(6) Photo
  | @as(7) Url
  | @as(8) Note

/// Decode from the C-ABI tag value.
let propertyTypeFromTag = (tag: int): option<propertyType> =>
  switch tag {
  | 0 => Some(FnName)
  | 1 => Some(N)
  | 2 => Some(Email)
  | 3 => Some(Tel)
  | 4 => Some(Adr)
  | 5 => Some(Org)
  | 6 => Some(Photo)
  | 7 => Some(Url)
  | 8 => Some(Note)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let propertyTypeToTag = (v: propertyType): int =>
  switch v {
  | FnName => 0
  | N => 1
  | Email => 2
  | Tel => 3
  | Adr => 4
  | Org => 5
  | Photo => 6
  | Url => 7
  | Note => 8
  }

// ===========================================================================
// CardMethod (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type cardMethod =
  | @as(0) Get
  | @as(1) Put
  | @as(2) Delete
  | @as(3) Propfind
  | @as(4) Proppatch
  | @as(5) Report
  | @as(6) Mkcol

/// Decode from the C-ABI tag value.
let cardMethodFromTag = (tag: int): option<cardMethod> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Put)
  | 2 => Some(Delete)
  | 3 => Some(Propfind)
  | 4 => Some(Proppatch)
  | 5 => Some(Report)
  | 6 => Some(Mkcol)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let cardMethodToTag = (v: cardMethod): int =>
  switch v {
  | Get => 0
  | Put => 1
  | Delete => 2
  | Propfind => 3
  | Proppatch => 4
  | Report => 5
  | Mkcol => 6
  }

// ===========================================================================
// VCardVersion (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type vCardVersion =
  | @as(0) Vcard3
  | @as(1) Vcard4

/// Decode from the C-ABI tag value.
let vCardVersionFromTag = (tag: int): option<vCardVersion> =>
  switch tag {
  | 0 => Some(Vcard3)
  | 1 => Some(Vcard4)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let vCardVersionToTag = (v: vCardVersion): int =>
  switch v {
  | Vcard3 => 0
  | Vcard4 => 1
  }

// ===========================================================================
// CardError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type cardError =
  | @as(0) ValidAddressData
  | @as(1) NoResourceType
  | @as(2) MaxResourceSize
  | @as(3) UidConflict
  | @as(4) SupportedAddressData
  | @as(5) PreconditionFailed

/// Decode from the C-ABI tag value.
let cardErrorFromTag = (tag: int): option<cardError> =>
  switch tag {
  | 0 => Some(ValidAddressData)
  | 1 => Some(NoResourceType)
  | 2 => Some(MaxResourceSize)
  | 3 => Some(UidConflict)
  | 4 => Some(SupportedAddressData)
  | 5 => Some(PreconditionFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let cardErrorToTag = (v: cardError): int =>
  switch v {
  | ValidAddressData => 0
  | NoResourceType => 1
  | MaxResourceSize => 2
  | UidConflict => 3
  | SupportedAddressData => 4
  | PreconditionFailed => 5
  }

// ===========================================================================
// ServerState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Bound
  | @as(2) Serving
  | @as(3) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Bound)
  | 2 => Some(Serving)
  | 3 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Bound => 1
  | Serving => 2
  | Shutdown => 3
  }

