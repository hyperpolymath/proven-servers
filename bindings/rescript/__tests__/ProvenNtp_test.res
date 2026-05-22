// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNtp protocol bindings.

open ProvenNtp

let test_leapIndicator_roundtrip = () => {
  assert(leapIndicatorFromTag(0) == Some(NoWarning))
  assert(leapIndicatorFromTag(1) == Some(LastMinute61))
  assert(leapIndicatorFromTag(2) == Some(LastMinute59))
  assert(leapIndicatorFromTag(3) == Some(Unsynchronised))
  assert(leapIndicatorFromTag(4) == None)
}

let test_leapIndicator_toTag = () => {
  assert(leapIndicatorToTag(NoWarning) == 0)
  assert(leapIndicatorToTag(LastMinute61) == 1)
  assert(leapIndicatorToTag(LastMinute59) == 2)
  assert(leapIndicatorToTag(Unsynchronised) == 3)
}

let test_ntpMode_roundtrip = () => {
  assert(ntpModeFromTag(0) == Some(Reserved))
  assert(ntpModeFromTag(1) == Some(SymmetricActive))
  assert(ntpModeFromTag(2) == Some(SymmetricPassive))
  assert(ntpModeFromTag(3) == Some(Client))
  assert(ntpModeFromTag(4) == Some(Server))
  assert(ntpModeFromTag(5) == Some(Broadcast))
  assert(ntpModeFromTag(6) == Some(ControlMessage))
  assert(ntpModeFromTag(7) == Some(Private))
  assert(ntpModeFromTag(8) == None)
}

let test_ntpMode_toTag = () => {
  assert(ntpModeToTag(Reserved) == 0)
  assert(ntpModeToTag(SymmetricActive) == 1)
  assert(ntpModeToTag(SymmetricPassive) == 2)
  assert(ntpModeToTag(Client) == 3)
  assert(ntpModeToTag(Server) == 4)
  assert(ntpModeToTag(Broadcast) == 5)
  assert(ntpModeToTag(ControlMessage) == 6)
  assert(ntpModeToTag(Private) == 7)
}

let test_exchangeState_roundtrip = () => {
  assert(exchangeStateFromTag(0) == Some(Idle))
  assert(exchangeStateFromTag(1) == Some(RequestReceived))
  assert(exchangeStateFromTag(2) == Some(TimestampCalculated))
  assert(exchangeStateFromTag(3) == Some(ResponseSent))
  assert(exchangeStateFromTag(4) == None)
}

let test_exchangeState_toTag = () => {
  assert(exchangeStateToTag(Idle) == 0)
  assert(exchangeStateToTag(RequestReceived) == 1)
  assert(exchangeStateToTag(TimestampCalculated) == 2)
  assert(exchangeStateToTag(ResponseSent) == 3)
}

let test_clockDisciplineState_roundtrip = () => {
  assert(clockDisciplineStateFromTag(0) == Some(Unset))
  assert(clockDisciplineStateFromTag(1) == Some(Spike))
  assert(clockDisciplineStateFromTag(2) == Some(Freq))
  assert(clockDisciplineStateFromTag(3) == Some(Sync))
  assert(clockDisciplineStateFromTag(4) == Some(Panic))
  assert(clockDisciplineStateFromTag(5) == None)
}

let test_clockDisciplineState_toTag = () => {
  assert(clockDisciplineStateToTag(Unset) == 0)
  assert(clockDisciplineStateToTag(Spike) == 1)
  assert(clockDisciplineStateToTag(Freq) == 2)
  assert(clockDisciplineStateToTag(Sync) == 3)
  assert(clockDisciplineStateToTag(Panic) == 4)
}

let test_kissCode_roundtrip = () => {
  assert(kissCodeFromTag(0) == Some(Deny))
  assert(kissCodeFromTag(1) == Some(Rstr))
  assert(kissCodeFromTag(2) == Some(Rate))
  assert(kissCodeFromTag(3) == Some(Other))
  assert(kissCodeFromTag(4) == None)
}

let test_kissCode_toTag = () => {
  assert(kissCodeToTag(Deny) == 0)
  assert(kissCodeToTag(Rstr) == 1)
  assert(kissCodeToTag(Rate) == 2)
  assert(kissCodeToTag(Other) == 3)
}

let test_ntpError_roundtrip = () => {
  assert(ntpErrorFromTag(0) == Some(Ok))
  assert(ntpErrorFromTag(1) == Some(InvalidSlot))
  assert(ntpErrorFromTag(2) == Some(NotActive))
  assert(ntpErrorFromTag(3) == Some(InvalidPacket))
  assert(ntpErrorFromTag(4) == Some(KissOfDeath))
  assert(ntpErrorFromTag(5) == Some(StratumTooHigh))
  assert(ntpErrorFromTag(6) == None)
}

let test_ntpError_toTag = () => {
  assert(ntpErrorToTag(Ok) == 0)
  assert(ntpErrorToTag(InvalidSlot) == 1)
  assert(ntpErrorToTag(NotActive) == 2)
  assert(ntpErrorToTag(InvalidPacket) == 3)
  assert(ntpErrorToTag(KissOfDeath) == 4)
  assert(ntpErrorToTag(StratumTooHigh) == 5)
}

// Run all tests
test_leapIndicator_roundtrip()
test_leapIndicator_toTag()
test_ntpMode_roundtrip()
test_ntpMode_toTag()
test_exchangeState_roundtrip()
test_exchangeState_toTag()
test_clockDisciplineState_roundtrip()
test_clockDisciplineState_toTag()
test_kissCode_roundtrip()
test_kissCode_toTag()
test_ntpError_roundtrip()
test_ntpError_toTag()
