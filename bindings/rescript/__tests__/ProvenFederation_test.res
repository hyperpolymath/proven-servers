// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenFederation protocol bindings.

open ProvenFederation

let test_activityType_roundtrip = () => {
  assert(activityTypeFromTag(0) == Some(Create))
  assert(activityTypeFromTag(1) == Some(Update))
  assert(activityTypeFromTag(2) == Some(Delete))
  assert(activityTypeFromTag(3) == Some(Follow))
  assert(activityTypeFromTag(4) == Some(Accept))
  assert(activityTypeFromTag(5) == Some(Reject))
  assert(activityTypeFromTag(6) == Some(Announce))
  assert(activityTypeFromTag(7) == Some(Like))
  assert(activityTypeFromTag(8) == Some(Undo))
  assert(activityTypeFromTag(9) == Some(Block))
  assert(activityTypeFromTag(10) == Some(Flag))
  assert(activityTypeFromTag(11) == None)
}

let test_activityType_toTag = () => {
  assert(activityTypeToTag(Create) == 0)
  assert(activityTypeToTag(Update) == 1)
  assert(activityTypeToTag(Delete) == 2)
  assert(activityTypeToTag(Follow) == 3)
  assert(activityTypeToTag(Accept) == 4)
  assert(activityTypeToTag(Reject) == 5)
  assert(activityTypeToTag(Announce) == 6)
  assert(activityTypeToTag(Like) == 7)
  assert(activityTypeToTag(Undo) == 8)
  assert(activityTypeToTag(Block) == 9)
  assert(activityTypeToTag(Flag) == 10)
}

let test_actorType_roundtrip = () => {
  assert(actorTypeFromTag(0) == Some(Person))
  assert(actorTypeFromTag(1) == Some(Service))
  assert(actorTypeFromTag(2) == Some(Application))
  assert(actorTypeFromTag(3) == Some(Group))
  assert(actorTypeFromTag(4) == Some(Organization))
  assert(actorTypeFromTag(5) == None)
}

let test_actorType_toTag = () => {
  assert(actorTypeToTag(Person) == 0)
  assert(actorTypeToTag(Service) == 1)
  assert(actorTypeToTag(Application) == 2)
  assert(actorTypeToTag(Group) == 3)
  assert(actorTypeToTag(Organization) == 4)
}

let test_deliveryStatus_roundtrip = () => {
  assert(deliveryStatusFromTag(0) == Some(Pending))
  assert(deliveryStatusFromTag(1) == Some(Delivered))
  assert(deliveryStatusFromTag(2) == Some(Failed))
  assert(deliveryStatusFromTag(3) == Some(Rejected))
  assert(deliveryStatusFromTag(4) == Some(Deferred))
  assert(deliveryStatusFromTag(5) == None)
}

let test_deliveryStatus_toTag = () => {
  assert(deliveryStatusToTag(Pending) == 0)
  assert(deliveryStatusToTag(Delivered) == 1)
  assert(deliveryStatusToTag(Failed) == 2)
  assert(deliveryStatusToTag(Rejected) == 3)
  assert(deliveryStatusToTag(Deferred) == 4)
}

let test_trustLevel_roundtrip = () => {
  assert(trustLevelFromTag(0) == Some(SelfSigned))
  assert(trustLevelFromTag(1) == Some(PeerVerified))
  assert(trustLevelFromTag(2) == Some(FederationTrusted))
  assert(trustLevelFromTag(3) == Some(Revoked))
  assert(trustLevelFromTag(4) == Some(Unknown))
  assert(trustLevelFromTag(5) == None)
}

let test_trustLevel_toTag = () => {
  assert(trustLevelToTag(SelfSigned) == 0)
  assert(trustLevelToTag(PeerVerified) == 1)
  assert(trustLevelToTag(FederationTrusted) == 2)
  assert(trustLevelToTag(Revoked) == 3)
  assert(trustLevelToTag(Unknown) == 4)
}

let test_objectType_roundtrip = () => {
  assert(objectTypeFromTag(0) == Some(Note))
  assert(objectTypeFromTag(1) == Some(Article))
  assert(objectTypeFromTag(2) == Some(Image))
  assert(objectTypeFromTag(3) == Some(Video))
  assert(objectTypeFromTag(4) == Some(Audio))
  assert(objectTypeFromTag(5) == Some(Document))
  assert(objectTypeFromTag(6) == Some(Event))
  assert(objectTypeFromTag(7) == Some(Collection))
  assert(objectTypeFromTag(8) == Some(OrderedCollection))
  assert(objectTypeFromTag(9) == None)
}

let test_objectType_toTag = () => {
  assert(objectTypeToTag(Note) == 0)
  assert(objectTypeToTag(Article) == 1)
  assert(objectTypeToTag(Image) == 2)
  assert(objectTypeToTag(Video) == 3)
  assert(objectTypeToTag(Audio) == 4)
  assert(objectTypeToTag(Document) == 5)
  assert(objectTypeToTag(Event) == 6)
  assert(objectTypeToTag(Collection) == 7)
  assert(objectTypeToTag(OrderedCollection) == 8)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Active))
  assert(serverStateFromTag(2) == Some(Processing))
  assert(serverStateFromTag(3) == Some(Delivering))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Active) == 1)
  assert(serverStateToTag(Processing) == 2)
  assert(serverStateToTag(Delivering) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_activityType_roundtrip()
test_activityType_toTag()
test_actorType_roundtrip()
test_actorType_toTag()
test_deliveryStatus_roundtrip()
test_deliveryStatus_toTag()
test_trustLevel_roundtrip()
test_trustLevel_toTag()
test_objectType_roundtrip()
test_objectType_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
