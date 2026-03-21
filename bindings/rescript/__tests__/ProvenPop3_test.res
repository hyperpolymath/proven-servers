// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenPop3 protocol bindings.

open ProvenPop3

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(User))
  assert(commandFromTag(1) == Some(Pass))
  assert(commandFromTag(2) == Some(Stat))
  assert(commandFromTag(3) == Some(List))
  assert(commandFromTag(4) == Some(Retr))
  assert(commandFromTag(5) == Some(Dele))
  assert(commandFromTag(6) == Some(Noop))
  assert(commandFromTag(7) == Some(Rset))
  assert(commandFromTag(8) == Some(Quit))
  assert(commandFromTag(9) == Some(Top))
  assert(commandFromTag(10) == Some(Uidl))
  assert(commandFromTag(11) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(User) == 0)
  assert(commandToTag(Pass) == 1)
  assert(commandToTag(Stat) == 2)
  assert(commandToTag(List) == 3)
  assert(commandToTag(Retr) == 4)
  assert(commandToTag(Dele) == 5)
  assert(commandToTag(Noop) == 6)
  assert(commandToTag(Rset) == 7)
  assert(commandToTag(Quit) == 8)
  assert(commandToTag(Top) == 9)
  assert(commandToTag(Uidl) == 10)
}

let test_state_roundtrip = () => {
  assert(stateFromTag(0) == Some(Authorization))
  assert(stateFromTag(1) == Some(Transaction))
  assert(stateFromTag(2) == Some(Update))
  assert(stateFromTag(3) == None)
}

let test_state_toTag = () => {
  assert(stateToTag(Authorization) == 0)
  assert(stateToTag(Transaction) == 1)
  assert(stateToTag(Update) == 2)
}

let test_response_roundtrip = () => {
  assert(responseFromTag(0) == Some(Ok))
  assert(responseFromTag(1) == Some(Err))
  assert(responseFromTag(2) == None)
}

let test_response_toTag = () => {
  assert(responseToTag(Ok) == 0)
  assert(responseToTag(Err) == 1)
}

let test_pop3Error_roundtrip = () => {
  assert(pop3ErrorFromTag(0) == Some(Ok))
  assert(pop3ErrorFromTag(1) == Some(InvalidSlot))
  assert(pop3ErrorFromTag(2) == Some(NotActive))
  assert(pop3ErrorFromTag(3) == Some(InvalidTransition))
  assert(pop3ErrorFromTag(4) == Some(InvalidCommand))
  assert(pop3ErrorFromTag(5) == Some(AuthFailed))
  assert(pop3ErrorFromTag(6) == None)
}

let test_pop3Error_toTag = () => {
  assert(pop3ErrorToTag(Ok) == 0)
  assert(pop3ErrorToTag(InvalidSlot) == 1)
  assert(pop3ErrorToTag(NotActive) == 2)
  assert(pop3ErrorToTag(InvalidTransition) == 3)
  assert(pop3ErrorToTag(InvalidCommand) == 4)
  assert(pop3ErrorToTag(AuthFailed) == 5)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_state_roundtrip()
test_state_toTag()
test_response_roundtrip()
test_response_toTag()
test_pop3Error_roundtrip()
test_pop3Error_toTag()
