// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenContainer protocol bindings.

open ProvenContainer

let test_containerState_roundtrip = () => {
  assert(containerStateFromTag(0) == Some(Creating))
  assert(containerStateFromTag(1) == Some(Running))
  assert(containerStateFromTag(2) == Some(Paused))
  assert(containerStateFromTag(3) == Some(Restarting))
  assert(containerStateFromTag(4) == Some(Stopped))
  assert(containerStateFromTag(5) == Some(Removing))
  assert(containerStateFromTag(6) == Some(Dead))
  assert(containerStateFromTag(7) == None)
}

let test_containerState_toTag = () => {
  assert(containerStateToTag(Creating) == 0)
  assert(containerStateToTag(Running) == 1)
  assert(containerStateToTag(Paused) == 2)
  assert(containerStateToTag(Restarting) == 3)
  assert(containerStateToTag(Stopped) == 4)
  assert(containerStateToTag(Removing) == 5)
  assert(containerStateToTag(Dead) == 6)
}

let test_containerOperation_roundtrip = () => {
  assert(containerOperationFromTag(0) == Some(Create))
  assert(containerOperationFromTag(1) == Some(Start))
  assert(containerOperationFromTag(2) == Some(Stop))
  assert(containerOperationFromTag(3) == Some(Restart))
  assert(containerOperationFromTag(4) == Some(Pause))
  assert(containerOperationFromTag(5) == Some(Unpause))
  assert(containerOperationFromTag(6) == Some(Kill))
  assert(containerOperationFromTag(7) == Some(Remove))
  assert(containerOperationFromTag(8) == Some(Exec))
  assert(containerOperationFromTag(9) == Some(Logs))
  assert(containerOperationFromTag(10) == Some(Inspect))
  assert(containerOperationFromTag(11) == None)
}

let test_containerOperation_toTag = () => {
  assert(containerOperationToTag(Create) == 0)
  assert(containerOperationToTag(Start) == 1)
  assert(containerOperationToTag(Stop) == 2)
  assert(containerOperationToTag(Restart) == 3)
  assert(containerOperationToTag(Pause) == 4)
  assert(containerOperationToTag(Unpause) == 5)
  assert(containerOperationToTag(Kill) == 6)
  assert(containerOperationToTag(Remove) == 7)
  assert(containerOperationToTag(Exec) == 8)
  assert(containerOperationToTag(Logs) == 9)
  assert(containerOperationToTag(Inspect) == 10)
}

let test_networkMode_roundtrip = () => {
  assert(networkModeFromTag(0) == Some(Bridge))
  assert(networkModeFromTag(1) == Some(Host))
  assert(networkModeFromTag(2) == Some(None))
  assert(networkModeFromTag(3) == Some(Overlay))
  assert(networkModeFromTag(4) == Some(Macvlan))
  assert(networkModeFromTag(5) == None)
}

let test_networkMode_toTag = () => {
  assert(networkModeToTag(Bridge) == 0)
  assert(networkModeToTag(Host) == 1)
  assert(networkModeToTag(None) == 2)
  assert(networkModeToTag(Overlay) == 3)
  assert(networkModeToTag(Macvlan) == 4)
}

let test_volumeType_roundtrip = () => {
  assert(volumeTypeFromTag(0) == Some(Bind))
  assert(volumeTypeFromTag(1) == Some(Named))
  assert(volumeTypeFromTag(2) == Some(Tmpfs))
  assert(volumeTypeFromTag(3) == None)
}

let test_volumeType_toTag = () => {
  assert(volumeTypeToTag(Bind) == 0)
  assert(volumeTypeToTag(Named) == 1)
  assert(volumeTypeToTag(Tmpfs) == 2)
}

let test_restartPolicy_roundtrip = () => {
  assert(restartPolicyFromTag(0) == Some(No))
  assert(restartPolicyFromTag(1) == Some(Always))
  assert(restartPolicyFromTag(2) == Some(OnFailure))
  assert(restartPolicyFromTag(3) == Some(UnlessStopped))
  assert(restartPolicyFromTag(4) == None)
}

let test_restartPolicy_toTag = () => {
  assert(restartPolicyToTag(No) == 0)
  assert(restartPolicyToTag(Always) == 1)
  assert(restartPolicyToTag(OnFailure) == 2)
  assert(restartPolicyToTag(UnlessStopped) == 3)
}

let test_healthStatus_roundtrip = () => {
  assert(healthStatusFromTag(0) == Some(Starting))
  assert(healthStatusFromTag(1) == Some(Healthy))
  assert(healthStatusFromTag(2) == Some(Unhealthy))
  assert(healthStatusFromTag(3) == Some(NoCheck))
  assert(healthStatusFromTag(4) == None)
}

let test_healthStatus_toTag = () => {
  assert(healthStatusToTag(Starting) == 0)
  assert(healthStatusToTag(Healthy) == 1)
  assert(healthStatusToTag(Unhealthy) == 2)
  assert(healthStatusToTag(NoCheck) == 3)
}

// Run all tests
test_containerState_roundtrip()
test_containerState_toTag()
test_containerOperation_roundtrip()
test_containerOperation_toTag()
test_networkMode_roundtrip()
test_networkMode_toTag()
test_volumeType_roundtrip()
test_volumeType_toTag()
test_restartPolicy_roundtrip()
test_restartPolicy_toTag()
test_healthStatus_roundtrip()
test_healthStatus_toTag()
