// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenImap protocol bindings.

open ProvenImap

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Login))
  assert(commandFromTag(1) == Some(Logout))
  assert(commandFromTag(2) == Some(Select))
  assert(commandFromTag(3) == Some(Examine))
  assert(commandFromTag(4) == Some(Create))
  assert(commandFromTag(5) == Some(Delete))
  assert(commandFromTag(6) == Some(Rename))
  assert(commandFromTag(7) == Some(List))
  assert(commandFromTag(8) == Some(Fetch))
  assert(commandFromTag(9) == Some(Store))
  assert(commandFromTag(10) == Some(Search))
  assert(commandFromTag(11) == Some(Copy))
  assert(commandFromTag(12) == Some(Noop))
  assert(commandFromTag(13) == Some(Capability))
  assert(commandFromTag(14) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Login) == 0)
  assert(commandToTag(Logout) == 1)
  assert(commandToTag(Select) == 2)
  assert(commandToTag(Examine) == 3)
  assert(commandToTag(Create) == 4)
  assert(commandToTag(Delete) == 5)
  assert(commandToTag(Rename) == 6)
  assert(commandToTag(List) == 7)
  assert(commandToTag(Fetch) == 8)
  assert(commandToTag(Store) == 9)
  assert(commandToTag(Search) == 10)
  assert(commandToTag(Copy) == 11)
  assert(commandToTag(Noop) == 12)
  assert(commandToTag(Capability) == 13)
}

let test_state_roundtrip = () => {
  assert(stateFromTag(0) == Some(NotAuthenticated))
  assert(stateFromTag(1) == Some(Authenticated))
  assert(stateFromTag(2) == Some(Selected))
  assert(stateFromTag(3) == Some(Logout))
  assert(stateFromTag(4) == None)
}

let test_state_toTag = () => {
  assert(stateToTag(NotAuthenticated) == 0)
  assert(stateToTag(Authenticated) == 1)
  assert(stateToTag(Selected) == 2)
  assert(stateToTag(Logout) == 3)
}

let test_flag_roundtrip = () => {
  assert(flagFromTag(0) == Some(Seen))
  assert(flagFromTag(1) == Some(Answered))
  assert(flagFromTag(2) == Some(Flagged))
  assert(flagFromTag(3) == Some(Deleted))
  assert(flagFromTag(4) == Some(Draft))
  assert(flagFromTag(5) == Some(Recent))
  assert(flagFromTag(6) == None)
}

let test_flag_toTag = () => {
  assert(flagToTag(Seen) == 0)
  assert(flagToTag(Answered) == 1)
  assert(flagToTag(Flagged) == 2)
  assert(flagToTag(Deleted) == 3)
  assert(flagToTag(Draft) == 4)
  assert(flagToTag(Recent) == 5)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_state_roundtrip()
test_state_toTag()
test_flag_roundtrip()
test_flag_toTag()
