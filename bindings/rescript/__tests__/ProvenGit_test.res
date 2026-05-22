// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenGit protocol bindings.

open ProvenGit

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(UploadPack))
  assert(commandFromTag(1) == Some(ReceivePack))
  assert(commandFromTag(2) == Some(UploadArchive))
  assert(commandFromTag(3) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(UploadPack) == 0)
  assert(commandToTag(ReceivePack) == 1)
  assert(commandToTag(UploadArchive) == 2)
}

let test_packetType_roundtrip = () => {
  assert(packetTypeFromTag(0) == Some(Flush))
  assert(packetTypeFromTag(1) == Some(Delimiter))
  assert(packetTypeFromTag(2) == Some(ResponseEnd))
  assert(packetTypeFromTag(3) == Some(Data))
  assert(packetTypeFromTag(4) == Some(PktError))
  assert(packetTypeFromTag(5) == Some(SidebandData))
  assert(packetTypeFromTag(6) == Some(SidebandProgress))
  assert(packetTypeFromTag(7) == Some(SidebandError))
  assert(packetTypeFromTag(8) == None)
}

let test_packetType_toTag = () => {
  assert(packetTypeToTag(Flush) == 0)
  assert(packetTypeToTag(Delimiter) == 1)
  assert(packetTypeToTag(ResponseEnd) == 2)
  assert(packetTypeToTag(Data) == 3)
  assert(packetTypeToTag(PktError) == 4)
  assert(packetTypeToTag(SidebandData) == 5)
  assert(packetTypeToTag(SidebandProgress) == 6)
  assert(packetTypeToTag(SidebandError) == 7)
}

let test_refType_roundtrip = () => {
  assert(refTypeFromTag(0) == Some(Branch))
  assert(refTypeFromTag(1) == Some(Tag))
  assert(refTypeFromTag(2) == Some(Head))
  assert(refTypeFromTag(3) == Some(Remote))
  assert(refTypeFromTag(4) == Some(GitNote))
  assert(refTypeFromTag(5) == None)
}

let test_refType_toTag = () => {
  assert(refTypeToTag(Branch) == 0)
  assert(refTypeToTag(Tag) == 1)
  assert(refTypeToTag(Head) == 2)
  assert(refTypeToTag(Remote) == 3)
  assert(refTypeToTag(GitNote) == 4)
}

let test_capability_roundtrip = () => {
  assert(capabilityFromTag(0) == Some(MultiAck))
  assert(capabilityFromTag(1) == Some(ThinPack))
  assert(capabilityFromTag(2) == Some(SideBand64k))
  assert(capabilityFromTag(3) == Some(OfsDelta))
  assert(capabilityFromTag(4) == Some(Shallow))
  assert(capabilityFromTag(5) == Some(DeepenSince))
  assert(capabilityFromTag(6) == Some(DeepenNot))
  assert(capabilityFromTag(7) == Some(FilterSpec))
  assert(capabilityFromTag(8) == Some(ObjectFormat))
  assert(capabilityFromTag(9) == None)
}

let test_capability_toTag = () => {
  assert(capabilityToTag(MultiAck) == 0)
  assert(capabilityToTag(ThinPack) == 1)
  assert(capabilityToTag(SideBand64k) == 2)
  assert(capabilityToTag(OfsDelta) == 3)
  assert(capabilityToTag(Shallow) == 4)
  assert(capabilityToTag(DeepenSince) == 5)
  assert(capabilityToTag(DeepenNot) == 6)
  assert(capabilityToTag(FilterSpec) == 7)
  assert(capabilityToTag(ObjectFormat) == 8)
}

let test_hookResult_roundtrip = () => {
  assert(hookResultFromTag(0) == Some(Accept))
  assert(hookResultFromTag(1) == Some(Reject))
  assert(hookResultFromTag(2) == None)
}

let test_hookResult_toTag = () => {
  assert(hookResultToTag(Accept) == 0)
  assert(hookResultToTag(Reject) == 1)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Discovery))
  assert(serverStateFromTag(2) == Some(Negotiating))
  assert(serverStateFromTag(3) == Some(Transfer))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Discovery) == 1)
  assert(serverStateToTag(Negotiating) == 2)
  assert(serverStateToTag(Transfer) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_packetType_roundtrip()
test_packetType_toTag()
test_refType_roundtrip()
test_refType_toTag()
test_capability_roundtrip()
test_capability_toTag()
test_hookResult_roundtrip()
test_hookResult_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
