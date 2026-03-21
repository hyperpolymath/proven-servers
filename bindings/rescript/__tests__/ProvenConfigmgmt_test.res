// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenConfigmgmt protocol bindings.

open ProvenConfigmgmt

let test_resourceType_roundtrip = () => {
  assert(resourceTypeFromTag(0) == Some(File))
  assert(resourceTypeFromTag(1) == Some(Package))
  assert(resourceTypeFromTag(2) == Some(Service))
  assert(resourceTypeFromTag(3) == Some(User))
  assert(resourceTypeFromTag(4) == Some(Group))
  assert(resourceTypeFromTag(5) == Some(Cron))
  assert(resourceTypeFromTag(6) == Some(Mount))
  assert(resourceTypeFromTag(7) == Some(Firewall))
  assert(resourceTypeFromTag(8) == Some(Registry))
  assert(resourceTypeFromTag(9) == None)
}

let test_resourceType_toTag = () => {
  assert(resourceTypeToTag(File) == 0)
  assert(resourceTypeToTag(Package) == 1)
  assert(resourceTypeToTag(Service) == 2)
  assert(resourceTypeToTag(User) == 3)
  assert(resourceTypeToTag(Group) == 4)
  assert(resourceTypeToTag(Cron) == 5)
  assert(resourceTypeToTag(Mount) == 6)
  assert(resourceTypeToTag(Firewall) == 7)
  assert(resourceTypeToTag(Registry) == 8)
}

let test_resourceState_roundtrip = () => {
  assert(resourceStateFromTag(0) == Some(Present))
  assert(resourceStateFromTag(1) == Some(Absent))
  assert(resourceStateFromTag(2) == Some(Running))
  assert(resourceStateFromTag(3) == Some(Stopped))
  assert(resourceStateFromTag(4) == Some(Enabled))
  assert(resourceStateFromTag(5) == Some(Disabled))
  assert(resourceStateFromTag(6) == None)
}

let test_resourceState_toTag = () => {
  assert(resourceStateToTag(Present) == 0)
  assert(resourceStateToTag(Absent) == 1)
  assert(resourceStateToTag(Running) == 2)
  assert(resourceStateToTag(Stopped) == 3)
  assert(resourceStateToTag(Enabled) == 4)
  assert(resourceStateToTag(Disabled) == 5)
}

let test_changeAction_roundtrip = () => {
  assert(changeActionFromTag(0) == Some(Create))
  assert(changeActionFromTag(1) == Some(Modify))
  assert(changeActionFromTag(2) == Some(Delete))
  assert(changeActionFromTag(3) == Some(Restart))
  assert(changeActionFromTag(4) == Some(Reload))
  assert(changeActionFromTag(5) == Some(Skip))
  assert(changeActionFromTag(6) == None)
}

let test_changeAction_toTag = () => {
  assert(changeActionToTag(Create) == 0)
  assert(changeActionToTag(Modify) == 1)
  assert(changeActionToTag(Delete) == 2)
  assert(changeActionToTag(Restart) == 3)
  assert(changeActionToTag(Reload) == 4)
  assert(changeActionToTag(Skip) == 5)
}

let test_driftStatus_roundtrip = () => {
  assert(driftStatusFromTag(0) == Some(InSync))
  assert(driftStatusFromTag(1) == Some(Drifted))
  assert(driftStatusFromTag(2) == Some(DUnknown))
  assert(driftStatusFromTag(3) == Some(Unmanaged))
  assert(driftStatusFromTag(4) == None)
}

let test_driftStatus_toTag = () => {
  assert(driftStatusToTag(InSync) == 0)
  assert(driftStatusToTag(Drifted) == 1)
  assert(driftStatusToTag(DUnknown) == 2)
  assert(driftStatusToTag(Unmanaged) == 3)
}

let test_applyMode_roundtrip = () => {
  assert(applyModeFromTag(0) == Some(Enforce))
  assert(applyModeFromTag(1) == Some(DryRun))
  assert(applyModeFromTag(2) == Some(Audit))
  assert(applyModeFromTag(3) == None)
}

let test_applyMode_toTag = () => {
  assert(applyModeToTag(Enforce) == 0)
  assert(applyModeToTag(DryRun) == 1)
  assert(applyModeToTag(Audit) == 2)
}

// Run all tests
test_resourceType_roundtrip()
test_resourceType_toTag()
test_resourceState_roundtrip()
test_resourceState_toTag()
test_changeAction_roundtrip()
test_changeAction_toTag()
test_driftStatus_roundtrip()
test_driftStatus_toTag()
test_applyMode_roundtrip()
test_applyMode_toTag()
