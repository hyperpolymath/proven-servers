// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenOspf protocol bindings.

open ProvenOspf

let test_packetType_roundtrip = () => {
  assert(packetTypeFromTag(0) == Some(Hello))
  assert(packetTypeFromTag(1) == Some(DatabaseDescription))
  assert(packetTypeFromTag(2) == Some(LinkStateRequest))
  assert(packetTypeFromTag(3) == Some(LinkStateUpdate))
  assert(packetTypeFromTag(4) == Some(LinkStateAck))
  assert(packetTypeFromTag(5) == None)
}

let test_packetType_toTag = () => {
  assert(packetTypeToTag(Hello) == 0)
  assert(packetTypeToTag(DatabaseDescription) == 1)
  assert(packetTypeToTag(LinkStateRequest) == 2)
  assert(packetTypeToTag(LinkStateUpdate) == 3)
  assert(packetTypeToTag(LinkStateAck) == 4)
}

let test_neighborState_roundtrip = () => {
  assert(neighborStateFromTag(0) == Some(Down))
  assert(neighborStateFromTag(1) == Some(Attempt))
  assert(neighborStateFromTag(2) == Some(Init))
  assert(neighborStateFromTag(3) == Some(TwoWay))
  assert(neighborStateFromTag(4) == Some(ExStart))
  assert(neighborStateFromTag(5) == Some(Exchange))
  assert(neighborStateFromTag(6) == Some(Loading))
  assert(neighborStateFromTag(7) == Some(Full))
  assert(neighborStateFromTag(8) == None)
}

let test_neighborState_toTag = () => {
  assert(neighborStateToTag(Down) == 0)
  assert(neighborStateToTag(Attempt) == 1)
  assert(neighborStateToTag(Init) == 2)
  assert(neighborStateToTag(TwoWay) == 3)
  assert(neighborStateToTag(ExStart) == 4)
  assert(neighborStateToTag(Exchange) == 5)
  assert(neighborStateToTag(Loading) == 6)
  assert(neighborStateToTag(Full) == 7)
}

let test_lsaType_roundtrip = () => {
  assert(lsaTypeFromTag(0) == Some(RouterLsa))
  assert(lsaTypeFromTag(1) == Some(NetworkLsa))
  assert(lsaTypeFromTag(2) == Some(SummaryLsa))
  assert(lsaTypeFromTag(3) == Some(AsbrSummaryLsa))
  assert(lsaTypeFromTag(4) == Some(AsExternalLsa))
  assert(lsaTypeFromTag(5) == None)
}

let test_lsaType_toTag = () => {
  assert(lsaTypeToTag(RouterLsa) == 0)
  assert(lsaTypeToTag(NetworkLsa) == 1)
  assert(lsaTypeToTag(SummaryLsa) == 2)
  assert(lsaTypeToTag(AsbrSummaryLsa) == 3)
  assert(lsaTypeToTag(AsExternalLsa) == 4)
}

let test_areaType_roundtrip = () => {
  assert(areaTypeFromTag(0) == Some(Normal))
  assert(areaTypeFromTag(1) == Some(Stub))
  assert(areaTypeFromTag(2) == Some(TotallyStub))
  assert(areaTypeFromTag(3) == Some(Nssa))
  assert(areaTypeFromTag(4) == None)
}

let test_areaType_toTag = () => {
  assert(areaTypeToTag(Normal) == 0)
  assert(areaTypeToTag(Stub) == 1)
  assert(areaTypeToTag(TotallyStub) == 2)
  assert(areaTypeToTag(Nssa) == 3)
}

let test_ospfError_roundtrip = () => {
  assert(ospfErrorFromTag(0) == Some(Ok))
  assert(ospfErrorFromTag(1) == Some(InvalidSlot))
  assert(ospfErrorFromTag(2) == Some(NotActive))
  assert(ospfErrorFromTag(3) == Some(InvalidTransition))
  assert(ospfErrorFromTag(4) == Some(InvalidPacket))
  assert(ospfErrorFromTag(5) == Some(AreaError))
  assert(ospfErrorFromTag(6) == Some(FloodLimit))
  assert(ospfErrorFromTag(7) == None)
}

let test_ospfError_toTag = () => {
  assert(ospfErrorToTag(Ok) == 0)
  assert(ospfErrorToTag(InvalidSlot) == 1)
  assert(ospfErrorToTag(NotActive) == 2)
  assert(ospfErrorToTag(InvalidTransition) == 3)
  assert(ospfErrorToTag(InvalidPacket) == 4)
  assert(ospfErrorToTag(AreaError) == 5)
  assert(ospfErrorToTag(FloodLimit) == 6)
}

// Run all tests
test_packetType_roundtrip()
test_packetType_toTag()
test_neighborState_roundtrip()
test_neighborState_toTag()
test_lsaType_roundtrip()
test_lsaType_toTag()
test_areaType_roundtrip()
test_areaType_toTag()
test_ospfError_roundtrip()
test_ospfError_toTag()
