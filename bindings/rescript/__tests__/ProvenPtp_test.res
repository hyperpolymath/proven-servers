// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenPtp protocol bindings.

open ProvenPtp

let test_ptpMessageType_roundtrip = () => {
  assert(ptpMessageTypeFromTag(0) == Some(Sync))
  assert(ptpMessageTypeFromTag(1) == Some(DelayReq))
  assert(ptpMessageTypeFromTag(2) == Some(PdelayReq))
  assert(ptpMessageTypeFromTag(3) == Some(PdelayResp))
  assert(ptpMessageTypeFromTag(4) == Some(FollowUp))
  assert(ptpMessageTypeFromTag(5) == Some(DelayResp))
  assert(ptpMessageTypeFromTag(6) == Some(PdelayRespFollowUp))
  assert(ptpMessageTypeFromTag(7) == Some(Announce))
  assert(ptpMessageTypeFromTag(8) == Some(Signaling))
  assert(ptpMessageTypeFromTag(9) == Some(Management))
  assert(ptpMessageTypeFromTag(10) == None)
}

let test_ptpMessageType_toTag = () => {
  assert(ptpMessageTypeToTag(Sync) == 0)
  assert(ptpMessageTypeToTag(DelayReq) == 1)
  assert(ptpMessageTypeToTag(PdelayReq) == 2)
  assert(ptpMessageTypeToTag(PdelayResp) == 3)
  assert(ptpMessageTypeToTag(FollowUp) == 4)
  assert(ptpMessageTypeToTag(DelayResp) == 5)
  assert(ptpMessageTypeToTag(PdelayRespFollowUp) == 6)
  assert(ptpMessageTypeToTag(Announce) == 7)
  assert(ptpMessageTypeToTag(Signaling) == 8)
  assert(ptpMessageTypeToTag(Management) == 9)
}

let test_clockClass_roundtrip = () => {
  assert(clockClassFromTag(0) == Some(PrimaryClock))
  assert(clockClassFromTag(1) == Some(ApplicationSpecific))
  assert(clockClassFromTag(2) == Some(SlaveOnly))
  assert(clockClassFromTag(3) == Some(DefaultClass))
  assert(clockClassFromTag(4) == None)
}

let test_clockClass_toTag = () => {
  assert(clockClassToTag(PrimaryClock) == 0)
  assert(clockClassToTag(ApplicationSpecific) == 1)
  assert(clockClassToTag(SlaveOnly) == 2)
  assert(clockClassToTag(DefaultClass) == 3)
}

let test_ptpPortState_roundtrip = () => {
  assert(ptpPortStateFromTag(0) == Some(Initializing))
  assert(ptpPortStateFromTag(1) == Some(Faulty))
  assert(ptpPortStateFromTag(2) == Some(Disabled))
  assert(ptpPortStateFromTag(3) == Some(Listening))
  assert(ptpPortStateFromTag(4) == Some(PreMaster))
  assert(ptpPortStateFromTag(5) == Some(Master))
  assert(ptpPortStateFromTag(6) == Some(Passive))
  assert(ptpPortStateFromTag(7) == Some(Uncalibrated))
  assert(ptpPortStateFromTag(8) == Some(Slave))
  assert(ptpPortStateFromTag(9) == None)
}

let test_ptpPortState_toTag = () => {
  assert(ptpPortStateToTag(Initializing) == 0)
  assert(ptpPortStateToTag(Faulty) == 1)
  assert(ptpPortStateToTag(Disabled) == 2)
  assert(ptpPortStateToTag(Listening) == 3)
  assert(ptpPortStateToTag(PreMaster) == 4)
  assert(ptpPortStateToTag(Master) == 5)
  assert(ptpPortStateToTag(Passive) == 6)
  assert(ptpPortStateToTag(Uncalibrated) == 7)
  assert(ptpPortStateToTag(Slave) == 8)
}

let test_delayMechanism_roundtrip = () => {
  assert(delayMechanismFromTag(0) == Some(E2E))
  assert(delayMechanismFromTag(1) == Some(P2P))
  assert(delayMechanismFromTag(2) == Some(DmDisabled))
  assert(delayMechanismFromTag(3) == None)
}

let test_delayMechanism_toTag = () => {
  assert(delayMechanismToTag(E2E) == 0)
  assert(delayMechanismToTag(P2P) == 1)
  assert(delayMechanismToTag(DmDisabled) == 2)
}

// Run all tests
test_ptpMessageType_roundtrip()
test_ptpMessageType_toTag()
test_clockClass_roundtrip()
test_clockClass_toTag()
test_ptpPortState_roundtrip()
test_ptpPortState_toTag()
test_delayMechanism_roundtrip()
test_delayMechanism_toTag()
