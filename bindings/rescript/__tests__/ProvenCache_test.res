// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCache protocol bindings.

open ProvenCache

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Get))
  assert(commandFromTag(1) == Some(Set))
  assert(commandFromTag(2) == Some(Delete))
  assert(commandFromTag(3) == Some(Exists))
  assert(commandFromTag(4) == Some(Expire))
  assert(commandFromTag(5) == Some(Ttl))
  assert(commandFromTag(6) == Some(Keys))
  assert(commandFromTag(7) == Some(Flush))
  assert(commandFromTag(8) == Some(Incr))
  assert(commandFromTag(9) == Some(Decr))
  assert(commandFromTag(10) == Some(Append))
  assert(commandFromTag(11) == Some(Prepend))
  assert(commandFromTag(12) == Some(Cas))
  assert(commandFromTag(13) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Get) == 0)
  assert(commandToTag(Set) == 1)
  assert(commandToTag(Delete) == 2)
  assert(commandToTag(Exists) == 3)
  assert(commandToTag(Expire) == 4)
  assert(commandToTag(Ttl) == 5)
  assert(commandToTag(Keys) == 6)
  assert(commandToTag(Flush) == 7)
  assert(commandToTag(Incr) == 8)
  assert(commandToTag(Decr) == 9)
  assert(commandToTag(Append) == 10)
  assert(commandToTag(Prepend) == 11)
  assert(commandToTag(Cas) == 12)
}

let test_evictionPolicy_roundtrip = () => {
  assert(evictionPolicyFromTag(0) == Some(Lru))
  assert(evictionPolicyFromTag(1) == Some(Lfu))
  assert(evictionPolicyFromTag(2) == Some(Random))
  assert(evictionPolicyFromTag(3) == Some(EvictTtl))
  assert(evictionPolicyFromTag(4) == Some(NoEviction))
  assert(evictionPolicyFromTag(5) == None)
}

let test_evictionPolicy_toTag = () => {
  assert(evictionPolicyToTag(Lru) == 0)
  assert(evictionPolicyToTag(Lfu) == 1)
  assert(evictionPolicyToTag(Random) == 2)
  assert(evictionPolicyToTag(EvictTtl) == 3)
  assert(evictionPolicyToTag(NoEviction) == 4)
}

let test_dataType_roundtrip = () => {
  assert(dataTypeFromTag(0) == Some(StringVal))
  assert(dataTypeFromTag(1) == Some(IntVal))
  assert(dataTypeFromTag(2) == Some(ListVal))
  assert(dataTypeFromTag(3) == Some(SetVal))
  assert(dataTypeFromTag(4) == Some(HashVal))
  assert(dataTypeFromTag(5) == None)
}

let test_dataType_toTag = () => {
  assert(dataTypeToTag(StringVal) == 0)
  assert(dataTypeToTag(IntVal) == 1)
  assert(dataTypeToTag(ListVal) == 2)
  assert(dataTypeToTag(SetVal) == 3)
  assert(dataTypeToTag(HashVal) == 4)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(NotFound))
  assert(errorCodeFromTag(1) == Some(TypeMismatch))
  assert(errorCodeFromTag(2) == Some(OutOfMemory))
  assert(errorCodeFromTag(3) == Some(KeyTooLong))
  assert(errorCodeFromTag(4) == Some(ValueTooLarge))
  assert(errorCodeFromTag(5) == Some(CasConflict))
  assert(errorCodeFromTag(6) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(NotFound) == 0)
  assert(errorCodeToTag(TypeMismatch) == 1)
  assert(errorCodeToTag(OutOfMemory) == 2)
  assert(errorCodeToTag(KeyTooLong) == 3)
  assert(errorCodeToTag(ValueTooLarge) == 4)
  assert(errorCodeToTag(CasConflict) == 5)
}

let test_replicationMode_roundtrip = () => {
  assert(replicationModeFromTag(0) == Some(None))
  assert(replicationModeFromTag(1) == Some(Primary))
  assert(replicationModeFromTag(2) == Some(Replica))
  assert(replicationModeFromTag(3) == Some(Sentinel))
  assert(replicationModeFromTag(4) == None)
}

let test_replicationMode_toTag = () => {
  assert(replicationModeToTag(None) == 0)
  assert(replicationModeToTag(Primary) == 1)
  assert(replicationModeToTag(Replica) == 2)
  assert(replicationModeToTag(Sentinel) == 3)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_evictionPolicy_roundtrip()
test_evictionPolicy_toTag()
test_dataType_roundtrip()
test_dataType_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_replicationMode_roundtrip()
test_replicationMode_toTag()
