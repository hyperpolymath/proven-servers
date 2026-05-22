// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenLpd protocol bindings.

open ProvenLpd

let test_commandCode_roundtrip = () => {
  assert(commandCodeFromTag(1) == Some(PrintJob))
  assert(commandCodeFromTag(2) == Some(ReceiveJob))
  assert(commandCodeFromTag(3) == Some(ShortQueue))
  assert(commandCodeFromTag(4) == Some(LongQueue))
  assert(commandCodeFromTag(5) == Some(RemoveJobs))
  assert(commandCodeFromTag(6) == None)
}

let test_commandCode_toTag = () => {
  assert(commandCodeToTag(PrintJob) == 1)
  assert(commandCodeToTag(ReceiveJob) == 2)
  assert(commandCodeToTag(ShortQueue) == 3)
  assert(commandCodeToTag(LongQueue) == 4)
  assert(commandCodeToTag(RemoveJobs) == 5)
}

let test_subCommandCode_roundtrip = () => {
  assert(subCommandCodeFromTag(1) == Some(AbortJob))
  assert(subCommandCodeFromTag(2) == Some(ControlFile))
  assert(subCommandCodeFromTag(3) == Some(DataFile))
  assert(subCommandCodeFromTag(4) == None)
}

let test_subCommandCode_toTag = () => {
  assert(subCommandCodeToTag(AbortJob) == 1)
  assert(subCommandCodeToTag(ControlFile) == 2)
  assert(subCommandCodeToTag(DataFile) == 3)
}

let test_jobStatus_roundtrip = () => {
  assert(jobStatusFromTag(0) == Some(Pending))
  assert(jobStatusFromTag(1) == Some(Printing))
  assert(jobStatusFromTag(2) == Some(Complete))
  assert(jobStatusFromTag(3) == Some(Failed))
  assert(jobStatusFromTag(4) == None)
}

let test_jobStatus_toTag = () => {
  assert(jobStatusToTag(Pending) == 0)
  assert(jobStatusToTag(Printing) == 1)
  assert(jobStatusToTag(Complete) == 2)
  assert(jobStatusToTag(Failed) == 3)
}

// Run all tests
test_commandCode_roundtrip()
test_commandCode_toTag()
test_subCommandCode_roundtrip()
test_subCommandCode_toTag()
test_jobStatus_roundtrip()
test_jobStatus_toTag()
