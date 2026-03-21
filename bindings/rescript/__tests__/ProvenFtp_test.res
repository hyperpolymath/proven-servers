// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenFtp protocol bindings.

open ProvenFtp

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Connected))
  assert(sessionStateFromTag(1) == Some(UserOk))
  assert(sessionStateFromTag(2) == Some(Authenticated))
  assert(sessionStateFromTag(3) == Some(Renaming))
  assert(sessionStateFromTag(4) == Some(Quit))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Connected) == 0)
  assert(sessionStateToTag(UserOk) == 1)
  assert(sessionStateToTag(Authenticated) == 2)
  assert(sessionStateToTag(Renaming) == 3)
  assert(sessionStateToTag(Quit) == 4)
}

let test_transferType_roundtrip = () => {
  assert(transferTypeFromTag(0) == Some(Ascii))
  assert(transferTypeFromTag(1) == Some(Binary))
  assert(transferTypeFromTag(2) == None)
}

let test_transferType_toTag = () => {
  assert(transferTypeToTag(Ascii) == 0)
  assert(transferTypeToTag(Binary) == 1)
}

let test_dataMode_roundtrip = () => {
  assert(dataModeFromTag(0) == Some(Active))
  assert(dataModeFromTag(1) == Some(Passive))
  assert(dataModeFromTag(2) == None)
}

let test_dataMode_toTag = () => {
  assert(dataModeToTag(Active) == 0)
  assert(dataModeToTag(Passive) == 1)
}

let test_transferState_roundtrip = () => {
  assert(transferStateFromTag(0) == Some(Idle))
  assert(transferStateFromTag(1) == Some(InProgress))
  assert(transferStateFromTag(2) == Some(Completed))
  assert(transferStateFromTag(3) == Some(Aborted))
  assert(transferStateFromTag(4) == None)
}

let test_transferState_toTag = () => {
  assert(transferStateToTag(Idle) == 0)
  assert(transferStateToTag(InProgress) == 1)
  assert(transferStateToTag(Completed) == 2)
  assert(transferStateToTag(Aborted) == 3)
}

let test_replyCategory_roundtrip = () => {
  assert(replyCategoryFromTag(0) == Some(Preliminary))
  assert(replyCategoryFromTag(1) == Some(Completion))
  assert(replyCategoryFromTag(2) == Some(Intermediate))
  assert(replyCategoryFromTag(3) == Some(TransientNeg))
  assert(replyCategoryFromTag(4) == Some(PermanentNeg))
  assert(replyCategoryFromTag(5) == None)
}

let test_replyCategory_toTag = () => {
  assert(replyCategoryToTag(Preliminary) == 0)
  assert(replyCategoryToTag(Completion) == 1)
  assert(replyCategoryToTag(Intermediate) == 2)
  assert(replyCategoryToTag(TransientNeg) == 3)
  assert(replyCategoryToTag(PermanentNeg) == 4)
}

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(User))
  assert(commandFromTag(1) == Some(Pass))
  assert(commandFromTag(2) == Some(Acct))
  assert(commandFromTag(3) == Some(Cwd))
  assert(commandFromTag(4) == Some(Cdup))
  assert(commandFromTag(5) == Some(Quit))
  assert(commandFromTag(6) == Some(Pasv))
  assert(commandFromTag(7) == Some(Port))
  assert(commandFromTag(8) == Some(TypeCmd))
  assert(commandFromTag(9) == Some(Retr))
  assert(commandFromTag(10) == Some(Stor))
  assert(commandFromTag(11) == Some(Dele))
  assert(commandFromTag(12) == Some(Rmd))
  assert(commandFromTag(13) == Some(Mkd))
  assert(commandFromTag(14) == Some(Pwd))
  assert(commandFromTag(15) == Some(List))
  assert(commandFromTag(16) == Some(Nlst))
  assert(commandFromTag(17) == Some(Syst))
  assert(commandFromTag(18) == Some(Stat))
  assert(commandFromTag(19) == Some(Noop))
  assert(commandFromTag(20) == Some(Rnfr))
  assert(commandFromTag(21) == Some(Rnto))
  assert(commandFromTag(22) == Some(Size))
  assert(commandFromTag(23) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(User) == 0)
  assert(commandToTag(Pass) == 1)
  assert(commandToTag(Acct) == 2)
  assert(commandToTag(Cwd) == 3)
  assert(commandToTag(Cdup) == 4)
  assert(commandToTag(Quit) == 5)
  assert(commandToTag(Pasv) == 6)
  assert(commandToTag(Port) == 7)
  assert(commandToTag(TypeCmd) == 8)
  assert(commandToTag(Retr) == 9)
  assert(commandToTag(Stor) == 10)
  assert(commandToTag(Dele) == 11)
  assert(commandToTag(Rmd) == 12)
  assert(commandToTag(Mkd) == 13)
  assert(commandToTag(Pwd) == 14)
  assert(commandToTag(List) == 15)
  assert(commandToTag(Nlst) == 16)
  assert(commandToTag(Syst) == 17)
  assert(commandToTag(Stat) == 18)
  assert(commandToTag(Noop) == 19)
  assert(commandToTag(Rnfr) == 20)
  assert(commandToTag(Rnto) == 21)
  assert(commandToTag(Size) == 22)
}

// Run all tests
test_sessionState_roundtrip()
test_sessionState_toTag()
test_transferType_roundtrip()
test_transferType_toTag()
test_dataMode_roundtrip()
test_dataMode_toTag()
test_transferState_roundtrip()
test_transferState_toTag()
test_replyCategory_roundtrip()
test_replyCategory_toTag()
test_command_roundtrip()
test_command_toTag()
