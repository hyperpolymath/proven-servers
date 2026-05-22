// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSnmp protocol bindings.

open ProvenSnmp

let test_version_roundtrip = () => {
  assert(versionFromTag(0) == Some(V1))
  assert(versionFromTag(1) == Some(V2c))
  assert(versionFromTag(2) == Some(V3))
  assert(versionFromTag(3) == None)
}

let test_version_toTag = () => {
  assert(versionToTag(V1) == 0)
  assert(versionToTag(V2c) == 1)
  assert(versionToTag(V3) == 2)
}

let test_pduType_roundtrip = () => {
  assert(pduTypeFromTag(0) == Some(GetRequest))
  assert(pduTypeFromTag(1) == Some(GetNextRequest))
  assert(pduTypeFromTag(2) == Some(GetResponse))
  assert(pduTypeFromTag(3) == Some(SetRequest))
  assert(pduTypeFromTag(4) == Some(GetBulkRequest))
  assert(pduTypeFromTag(5) == Some(InformRequest))
  assert(pduTypeFromTag(6) == Some(SnmpV2Trap))
  assert(pduTypeFromTag(7) == None)
}

let test_pduType_toTag = () => {
  assert(pduTypeToTag(GetRequest) == 0)
  assert(pduTypeToTag(GetNextRequest) == 1)
  assert(pduTypeToTag(GetResponse) == 2)
  assert(pduTypeToTag(SetRequest) == 3)
  assert(pduTypeToTag(GetBulkRequest) == 4)
  assert(pduTypeToTag(InformRequest) == 5)
  assert(pduTypeToTag(SnmpV2Trap) == 6)
}

let test_errorStatus_roundtrip = () => {
  assert(errorStatusFromTag(0) == Some(NoError))
  assert(errorStatusFromTag(1) == Some(TooBig))
  assert(errorStatusFromTag(2) == Some(NoSuchName))
  assert(errorStatusFromTag(3) == Some(BadValue))
  assert(errorStatusFromTag(4) == Some(ReadOnly))
  assert(errorStatusFromTag(5) == Some(GenErr))
  assert(errorStatusFromTag(6) == Some(NoAccess))
  assert(errorStatusFromTag(7) == Some(WrongType))
  assert(errorStatusFromTag(8) == Some(WrongLength))
  assert(errorStatusFromTag(9) == Some(WrongValue))
  assert(errorStatusFromTag(10) == Some(NoCreation))
  assert(errorStatusFromTag(11) == Some(InconsistentValue))
  assert(errorStatusFromTag(12) == Some(ResourceUnavailable))
  assert(errorStatusFromTag(13) == Some(CommitFailed))
  assert(errorStatusFromTag(14) == Some(UndoFailed))
  assert(errorStatusFromTag(15) == Some(AuthorizationError))
  assert(errorStatusFromTag(16) == None)
}

let test_errorStatus_toTag = () => {
  assert(errorStatusToTag(NoError) == 0)
  assert(errorStatusToTag(TooBig) == 1)
  assert(errorStatusToTag(NoSuchName) == 2)
  assert(errorStatusToTag(BadValue) == 3)
  assert(errorStatusToTag(ReadOnly) == 4)
  assert(errorStatusToTag(GenErr) == 5)
  assert(errorStatusToTag(NoAccess) == 6)
  assert(errorStatusToTag(WrongType) == 7)
  assert(errorStatusToTag(WrongLength) == 8)
  assert(errorStatusToTag(WrongValue) == 9)
  assert(errorStatusToTag(NoCreation) == 10)
  assert(errorStatusToTag(InconsistentValue) == 11)
  assert(errorStatusToTag(ResourceUnavailable) == 12)
  assert(errorStatusToTag(CommitFailed) == 13)
  assert(errorStatusToTag(UndoFailed) == 14)
  assert(errorStatusToTag(AuthorizationError) == 15)
}

// Run all tests
test_version_roundtrip()
test_version_toTag()
test_pduType_roundtrip()
test_pduType_toTag()
test_errorStatus_roundtrip()
test_errorStatus_toTag()
