// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDds protocol bindings.

open ProvenDds

let test_reliabilityKind_roundtrip = () => {
  assert(reliabilityKindFromTag(0) == Some(BestEffort))
  assert(reliabilityKindFromTag(1) == Some(Reliable))
  assert(reliabilityKindFromTag(2) == None)
}

let test_reliabilityKind_toTag = () => {
  assert(reliabilityKindToTag(BestEffort) == 0)
  assert(reliabilityKindToTag(Reliable) == 1)
}

let test_durabilityKind_roundtrip = () => {
  assert(durabilityKindFromTag(1) == Some(TransientLocal))
  assert(durabilityKindFromTag(2) == Some(Transient))
  assert(durabilityKindFromTag(3) == Some(Persistent))
  assert(durabilityKindFromTag(4) == None)
}

let test_durabilityKind_toTag = () => {
  assert(durabilityKindToTag(TransientLocal) == 1)
  assert(durabilityKindToTag(Transient) == 2)
  assert(durabilityKindToTag(Persistent) == 3)
}

let test_historyKind_roundtrip = () => {
  assert(historyKindFromTag(0) == Some(KeepLast))
  assert(historyKindFromTag(1) == Some(KeepAll))
  assert(historyKindFromTag(2) == None)
}

let test_historyKind_toTag = () => {
  assert(historyKindToTag(KeepLast) == 0)
  assert(historyKindToTag(KeepAll) == 1)
}

let test_ownershipKind_roundtrip = () => {
  assert(ownershipKindFromTag(0) == Some(Shared))
  assert(ownershipKindFromTag(1) == Some(Exclusive))
  assert(ownershipKindFromTag(2) == None)
}

let test_ownershipKind_toTag = () => {
  assert(ownershipKindToTag(Shared) == 0)
  assert(ownershipKindToTag(Exclusive) == 1)
}

let test_entityType_roundtrip = () => {
  assert(entityTypeFromTag(0) == Some(Participant))
  assert(entityTypeFromTag(1) == Some(Publisher))
  assert(entityTypeFromTag(2) == Some(Subscriber))
  assert(entityTypeFromTag(3) == Some(Topic))
  assert(entityTypeFromTag(4) == Some(DataWriter))
  assert(entityTypeFromTag(5) == Some(DataReader))
  assert(entityTypeFromTag(6) == None)
}

let test_entityType_toTag = () => {
  assert(entityTypeToTag(Participant) == 0)
  assert(entityTypeToTag(Publisher) == 1)
  assert(entityTypeToTag(Subscriber) == 2)
  assert(entityTypeToTag(Topic) == 3)
  assert(entityTypeToTag(DataWriter) == 4)
  assert(entityTypeToTag(DataReader) == 5)
}

let test_participantState_roundtrip = () => {
  assert(participantStateFromTag(0) == Some(Idle))
  assert(participantStateFromTag(1) == Some(Joined))
  assert(participantStateFromTag(2) == Some(Publishing))
  assert(participantStateFromTag(3) == Some(Subscribing))
  assert(participantStateFromTag(4) == Some(Leaving))
  assert(participantStateFromTag(5) == None)
}

let test_participantState_toTag = () => {
  assert(participantStateToTag(Idle) == 0)
  assert(participantStateToTag(Joined) == 1)
  assert(participantStateToTag(Publishing) == 2)
  assert(participantStateToTag(Subscribing) == 3)
  assert(participantStateToTag(Leaving) == 4)
}

// Run all tests
test_reliabilityKind_roundtrip()
test_reliabilityKind_toTag()
test_durabilityKind_roundtrip()
test_durabilityKind_toTag()
test_historyKind_roundtrip()
test_historyKind_toTag()
test_ownershipKind_roundtrip()
test_ownershipKind_toTag()
test_entityType_roundtrip()
test_entityType_toTag()
test_participantState_roundtrip()
test_participantState_toTag()
