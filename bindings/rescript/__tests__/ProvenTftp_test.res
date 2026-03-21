// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenTftp protocol bindings.

open ProvenTftp

let test_opcode_roundtrip = () => {
  assert(opcodeFromTag(0) == Some(Rrq))
  assert(opcodeFromTag(1) == Some(Wrq))
  assert(opcodeFromTag(2) == Some(Data))
  assert(opcodeFromTag(3) == Some(Ack))
  assert(opcodeFromTag(4) == Some(Error))
  assert(opcodeFromTag(5) == None)
}

let test_opcode_toTag = () => {
  assert(opcodeToTag(Rrq) == 0)
  assert(opcodeToTag(Wrq) == 1)
  assert(opcodeToTag(Data) == 2)
  assert(opcodeToTag(Ack) == 3)
  assert(opcodeToTag(Error) == 4)
}

let test_transferMode_roundtrip = () => {
  assert(transferModeFromTag(0) == Some(NetAscii))
  assert(transferModeFromTag(1) == Some(Octet))
  assert(transferModeFromTag(2) == Some(Mail))
  assert(transferModeFromTag(3) == None)
}

let test_transferMode_toTag = () => {
  assert(transferModeToTag(NetAscii) == 0)
  assert(transferModeToTag(Octet) == 1)
  assert(transferModeToTag(Mail) == 2)
}

let test_tftpError_roundtrip = () => {
  assert(tftpErrorFromTag(0) == Some(NotDefined))
  assert(tftpErrorFromTag(1) == Some(FileNotFound))
  assert(tftpErrorFromTag(2) == Some(AccessViolation))
  assert(tftpErrorFromTag(3) == Some(DiskFull))
  assert(tftpErrorFromTag(4) == Some(IllegalOperation))
  assert(tftpErrorFromTag(5) == Some(UnknownTid))
  assert(tftpErrorFromTag(6) == Some(FileExists))
  assert(tftpErrorFromTag(7) == Some(NoSuchUser))
  assert(tftpErrorFromTag(8) == None)
}

let test_tftpError_toTag = () => {
  assert(tftpErrorToTag(NotDefined) == 0)
  assert(tftpErrorToTag(FileNotFound) == 1)
  assert(tftpErrorToTag(AccessViolation) == 2)
  assert(tftpErrorToTag(DiskFull) == 3)
  assert(tftpErrorToTag(IllegalOperation) == 4)
  assert(tftpErrorToTag(UnknownTid) == 5)
  assert(tftpErrorToTag(FileExists) == 6)
  assert(tftpErrorToTag(NoSuchUser) == 7)
}

let test_transferState_roundtrip = () => {
  assert(transferStateFromTag(0) == Some(Idle))
  assert(transferStateFromTag(1) == Some(Reading))
  assert(transferStateFromTag(2) == Some(Writing))
  assert(transferStateFromTag(3) == Some(InError))
  assert(transferStateFromTag(4) == Some(Complete))
  assert(transferStateFromTag(5) == None)
}

let test_transferState_toTag = () => {
  assert(transferStateToTag(Idle) == 0)
  assert(transferStateToTag(Reading) == 1)
  assert(transferStateToTag(Writing) == 2)
  assert(transferStateToTag(InError) == 3)
  assert(transferStateToTag(Complete) == 4)
}

// Run all tests
test_opcode_roundtrip()
test_opcode_toTag()
test_transferMode_roundtrip()
test_transferMode_toTag()
test_tftpError_roundtrip()
test_tftpError_toTag()
test_transferState_roundtrip()
test_transferState_toTag()
