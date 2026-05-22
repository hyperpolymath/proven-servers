// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCarddav protocol bindings.

open ProvenCarddav

let test_propertyType_roundtrip = () => {
  assert(propertyTypeFromTag(0) == Some(FnName))
  assert(propertyTypeFromTag(1) == Some(N))
  assert(propertyTypeFromTag(2) == Some(Email))
  assert(propertyTypeFromTag(3) == Some(Tel))
  assert(propertyTypeFromTag(4) == Some(Adr))
  assert(propertyTypeFromTag(5) == Some(Org))
  assert(propertyTypeFromTag(6) == Some(Photo))
  assert(propertyTypeFromTag(7) == Some(Url))
  assert(propertyTypeFromTag(8) == Some(Note))
  assert(propertyTypeFromTag(9) == None)
}

let test_propertyType_toTag = () => {
  assert(propertyTypeToTag(FnName) == 0)
  assert(propertyTypeToTag(N) == 1)
  assert(propertyTypeToTag(Email) == 2)
  assert(propertyTypeToTag(Tel) == 3)
  assert(propertyTypeToTag(Adr) == 4)
  assert(propertyTypeToTag(Org) == 5)
  assert(propertyTypeToTag(Photo) == 6)
  assert(propertyTypeToTag(Url) == 7)
  assert(propertyTypeToTag(Note) == 8)
}

let test_cardMethod_roundtrip = () => {
  assert(cardMethodFromTag(0) == Some(Get))
  assert(cardMethodFromTag(1) == Some(Put))
  assert(cardMethodFromTag(2) == Some(Delete))
  assert(cardMethodFromTag(3) == Some(Propfind))
  assert(cardMethodFromTag(4) == Some(Proppatch))
  assert(cardMethodFromTag(5) == Some(Report))
  assert(cardMethodFromTag(6) == Some(Mkcol))
  assert(cardMethodFromTag(7) == None)
}

let test_cardMethod_toTag = () => {
  assert(cardMethodToTag(Get) == 0)
  assert(cardMethodToTag(Put) == 1)
  assert(cardMethodToTag(Delete) == 2)
  assert(cardMethodToTag(Propfind) == 3)
  assert(cardMethodToTag(Proppatch) == 4)
  assert(cardMethodToTag(Report) == 5)
  assert(cardMethodToTag(Mkcol) == 6)
}

let test_vCardVersion_roundtrip = () => {
  assert(vCardVersionFromTag(0) == Some(Vcard3))
  assert(vCardVersionFromTag(1) == Some(Vcard4))
  assert(vCardVersionFromTag(2) == None)
}

let test_vCardVersion_toTag = () => {
  assert(vCardVersionToTag(Vcard3) == 0)
  assert(vCardVersionToTag(Vcard4) == 1)
}

let test_cardError_roundtrip = () => {
  assert(cardErrorFromTag(0) == Some(ValidAddressData))
  assert(cardErrorFromTag(1) == Some(NoResourceType))
  assert(cardErrorFromTag(2) == Some(MaxResourceSize))
  assert(cardErrorFromTag(3) == Some(UidConflict))
  assert(cardErrorFromTag(4) == Some(SupportedAddressData))
  assert(cardErrorFromTag(5) == Some(PreconditionFailed))
  assert(cardErrorFromTag(6) == None)
}

let test_cardError_toTag = () => {
  assert(cardErrorToTag(ValidAddressData) == 0)
  assert(cardErrorToTag(NoResourceType) == 1)
  assert(cardErrorToTag(MaxResourceSize) == 2)
  assert(cardErrorToTag(UidConflict) == 3)
  assert(cardErrorToTag(SupportedAddressData) == 4)
  assert(cardErrorToTag(PreconditionFailed) == 5)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Bound))
  assert(serverStateFromTag(2) == Some(Serving))
  assert(serverStateFromTag(3) == Some(Shutdown))
  assert(serverStateFromTag(4) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Bound) == 1)
  assert(serverStateToTag(Serving) == 2)
  assert(serverStateToTag(Shutdown) == 3)
}

// Run all tests
test_propertyType_roundtrip()
test_propertyType_toTag()
test_cardMethod_roundtrip()
test_cardMethod_toTag()
test_vCardVersion_roundtrip()
test_vCardVersion_toTag()
test_cardError_roundtrip()
test_cardError_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
