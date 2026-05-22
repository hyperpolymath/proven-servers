// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenTelnet protocol bindings.

open ProvenTelnet

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Se))
  assert(commandFromTag(1) == Some(Nop))
  assert(commandFromTag(2) == Some(DataMark))
  assert(commandFromTag(3) == Some(Break))
  assert(commandFromTag(4) == Some(InterruptProcess))
  assert(commandFromTag(5) == Some(AbortOutput))
  assert(commandFromTag(6) == Some(AreYouThere))
  assert(commandFromTag(7) == Some(EraseChar))
  assert(commandFromTag(8) == Some(EraseLine))
  assert(commandFromTag(9) == Some(GoAhead))
  assert(commandFromTag(10) == Some(Sb))
  assert(commandFromTag(11) == Some(Will))
  assert(commandFromTag(12) == Some(Wont))
  assert(commandFromTag(13) == Some(Do))
  assert(commandFromTag(14) == Some(Dont))
  assert(commandFromTag(15) == Some(Iac))
  assert(commandFromTag(16) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Se) == 0)
  assert(commandToTag(Nop) == 1)
  assert(commandToTag(DataMark) == 2)
  assert(commandToTag(Break) == 3)
  assert(commandToTag(InterruptProcess) == 4)
  assert(commandToTag(AbortOutput) == 5)
  assert(commandToTag(AreYouThere) == 6)
  assert(commandToTag(EraseChar) == 7)
  assert(commandToTag(EraseLine) == 8)
  assert(commandToTag(GoAhead) == 9)
  assert(commandToTag(Sb) == 10)
  assert(commandToTag(Will) == 11)
  assert(commandToTag(Wont) == 12)
  assert(commandToTag(Do) == 13)
  assert(commandToTag(Dont) == 14)
  assert(commandToTag(Iac) == 15)
}

let test_telnetOption_roundtrip = () => {
  assert(telnetOptionFromTag(0) == Some(Echo))
  assert(telnetOptionFromTag(1) == Some(SuppressGoAhead))
  assert(telnetOptionFromTag(2) == Some(Status))
  assert(telnetOptionFromTag(3) == Some(TimingMark))
  assert(telnetOptionFromTag(4) == Some(TerminalType))
  assert(telnetOptionFromTag(5) == Some(WindowSize))
  assert(telnetOptionFromTag(6) == Some(TerminalSpeed))
  assert(telnetOptionFromTag(7) == Some(RemoteFlowControl))
  assert(telnetOptionFromTag(8) == Some(Linemode))
  assert(telnetOptionFromTag(9) == Some(Environment))
  assert(telnetOptionFromTag(10) == None)
}

let test_telnetOption_toTag = () => {
  assert(telnetOptionToTag(Echo) == 0)
  assert(telnetOptionToTag(SuppressGoAhead) == 1)
  assert(telnetOptionToTag(Status) == 2)
  assert(telnetOptionToTag(TimingMark) == 3)
  assert(telnetOptionToTag(TerminalType) == 4)
  assert(telnetOptionToTag(WindowSize) == 5)
  assert(telnetOptionToTag(TerminalSpeed) == 6)
  assert(telnetOptionToTag(RemoteFlowControl) == 7)
  assert(telnetOptionToTag(Linemode) == 8)
  assert(telnetOptionToTag(Environment) == 9)
}

let test_negotiationState_roundtrip = () => {
  assert(negotiationStateFromTag(0) == Some(Inactive))
  assert(negotiationStateFromTag(1) == Some(WillSent))
  assert(negotiationStateFromTag(2) == Some(DoSent))
  assert(negotiationStateFromTag(3) == Some(Active))
  assert(negotiationStateFromTag(4) == None)
}

let test_negotiationState_toTag = () => {
  assert(negotiationStateToTag(Inactive) == 0)
  assert(negotiationStateToTag(WillSent) == 1)
  assert(negotiationStateToTag(DoSent) == 2)
  assert(negotiationStateToTag(Active) == 3)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Negotiating))
  assert(sessionStateFromTag(2) == Some(Active))
  assert(sessionStateFromTag(3) == Some(Subneg))
  assert(sessionStateFromTag(4) == Some(Closing))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Negotiating) == 1)
  assert(sessionStateToTag(Active) == 2)
  assert(sessionStateToTag(Subneg) == 3)
  assert(sessionStateToTag(Closing) == 4)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_telnetOption_roundtrip()
test_telnetOption_toTag()
test_negotiationState_roundtrip()
test_negotiationState_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
