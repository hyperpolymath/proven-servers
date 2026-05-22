// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSandbox protocol bindings.

open ProvenSandbox

let test_executionPolicy_roundtrip = () => {
  assert(executionPolicyFromTag(0) == Some(Unrestricted))
  assert(executionPolicyFromTag(1) == Some(ReadOnly))
  assert(executionPolicyFromTag(2) == Some(NetworkDenied))
  assert(executionPolicyFromTag(3) == Some(Isolated))
  assert(executionPolicyFromTag(4) == Some(Ephemeral))
  assert(executionPolicyFromTag(5) == None)
}

let test_executionPolicy_toTag = () => {
  assert(executionPolicyToTag(Unrestricted) == 0)
  assert(executionPolicyToTag(ReadOnly) == 1)
  assert(executionPolicyToTag(NetworkDenied) == 2)
  assert(executionPolicyToTag(Isolated) == 3)
  assert(executionPolicyToTag(Ephemeral) == 4)
}

let test_resourceLimit_roundtrip = () => {
  assert(resourceLimitFromTag(0) == Some(CpuTime))
  assert(resourceLimitFromTag(1) == Some(Memory))
  assert(resourceLimitFromTag(2) == Some(DiskIo))
  assert(resourceLimitFromTag(3) == Some(NetworkIo))
  assert(resourceLimitFromTag(4) == Some(FileDescriptors))
  assert(resourceLimitFromTag(5) == Some(Processes))
  assert(resourceLimitFromTag(6) == None)
}

let test_resourceLimit_toTag = () => {
  assert(resourceLimitToTag(CpuTime) == 0)
  assert(resourceLimitToTag(Memory) == 1)
  assert(resourceLimitToTag(DiskIo) == 2)
  assert(resourceLimitToTag(NetworkIo) == 3)
  assert(resourceLimitToTag(FileDescriptors) == 4)
  assert(resourceLimitToTag(Processes) == 5)
}

let test_sandboxState_roundtrip = () => {
  assert(sandboxStateFromTag(0) == Some(Creating))
  assert(sandboxStateFromTag(1) == Some(Ready))
  assert(sandboxStateFromTag(2) == Some(Running))
  assert(sandboxStateFromTag(3) == Some(Suspended))
  assert(sandboxStateFromTag(4) == Some(Terminated))
  assert(sandboxStateFromTag(5) == Some(Destroyed))
  assert(sandboxStateFromTag(6) == None)
}

let test_sandboxState_toTag = () => {
  assert(sandboxStateToTag(Creating) == 0)
  assert(sandboxStateToTag(Ready) == 1)
  assert(sandboxStateToTag(Running) == 2)
  assert(sandboxStateToTag(Suspended) == 3)
  assert(sandboxStateToTag(Terminated) == 4)
  assert(sandboxStateToTag(Destroyed) == 5)
}

let test_exitReason_roundtrip = () => {
  assert(exitReasonFromTag(0) == Some(Normal))
  assert(exitReasonFromTag(1) == Some(Timeout))
  assert(exitReasonFromTag(2) == Some(MemoryExceeded))
  assert(exitReasonFromTag(3) == Some(PolicyViolation))
  assert(exitReasonFromTag(4) == Some(Killed))
  assert(exitReasonFromTag(5) == Some(Error))
  assert(exitReasonFromTag(6) == None)
}

let test_exitReason_toTag = () => {
  assert(exitReasonToTag(Normal) == 0)
  assert(exitReasonToTag(Timeout) == 1)
  assert(exitReasonToTag(MemoryExceeded) == 2)
  assert(exitReasonToTag(PolicyViolation) == 3)
  assert(exitReasonToTag(Killed) == 4)
  assert(exitReasonToTag(Error) == 5)
}

let test_syscallPolicy_roundtrip = () => {
  assert(syscallPolicyFromTag(0) == Some(Allow))
  assert(syscallPolicyFromTag(1) == Some(Deny))
  assert(syscallPolicyFromTag(2) == Some(Log))
  assert(syscallPolicyFromTag(3) == Some(Trap))
  assert(syscallPolicyFromTag(4) == None)
}

let test_syscallPolicy_toTag = () => {
  assert(syscallPolicyToTag(Allow) == 0)
  assert(syscallPolicyToTag(Deny) == 1)
  assert(syscallPolicyToTag(Log) == 2)
  assert(syscallPolicyToTag(Trap) == 3)
}

// Run all tests
test_executionPolicy_roundtrip()
test_executionPolicy_toTag()
test_resourceLimit_roundtrip()
test_resourceLimit_toTag()
test_sandboxState_roundtrip()
test_sandboxState_toTag()
test_exitReason_roundtrip()
test_exitReason_toTag()
test_syscallPolicy_roundtrip()
test_syscallPolicy_toTag()
