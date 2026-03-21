// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenVoip protocol bindings.

open ProvenVoip

let test_method_roundtrip = () => {
  assert(methodFromTag(0) == Some(Invite))
  assert(methodFromTag(1) == Some(Ack))
  assert(methodFromTag(2) == Some(Bye))
  assert(methodFromTag(3) == Some(Cancel))
  assert(methodFromTag(4) == Some(Register))
  assert(methodFromTag(5) == Some(Options))
  assert(methodFromTag(6) == Some(Info))
  assert(methodFromTag(7) == Some(Update))
  assert(methodFromTag(8) == Some(Subscribe))
  assert(methodFromTag(9) == Some(Notify))
  assert(methodFromTag(10) == Some(Refer))
  assert(methodFromTag(11) == Some(Message))
  assert(methodFromTag(12) == Some(Prack))
  assert(methodFromTag(13) == None)
}

let test_method_toTag = () => {
  assert(methodToTag(Invite) == 0)
  assert(methodToTag(Ack) == 1)
  assert(methodToTag(Bye) == 2)
  assert(methodToTag(Cancel) == 3)
  assert(methodToTag(Register) == 4)
  assert(methodToTag(Options) == 5)
  assert(methodToTag(Info) == 6)
  assert(methodToTag(Update) == 7)
  assert(methodToTag(Subscribe) == 8)
  assert(methodToTag(Notify) == 9)
  assert(methodToTag(Refer) == 10)
  assert(methodToTag(Message) == 11)
  assert(methodToTag(Prack) == 12)
}

let test_responseCode_roundtrip = () => {
  assert(responseCodeFromTag(0) == Some(Trying))
  assert(responseCodeFromTag(1) == Some(Ringing))
  assert(responseCodeFromTag(2) == Some(SessionProgress))
  assert(responseCodeFromTag(3) == Some(Ok))
  assert(responseCodeFromTag(4) == Some(MultipleChoices))
  assert(responseCodeFromTag(5) == Some(MovedPermanently))
  assert(responseCodeFromTag(6) == Some(MovedTemporarily))
  assert(responseCodeFromTag(7) == Some(BadRequest))
  assert(responseCodeFromTag(8) == Some(Unauthorized))
  assert(responseCodeFromTag(9) == Some(Forbidden))
  assert(responseCodeFromTag(10) == Some(NotFound))
  assert(responseCodeFromTag(11) == Some(MethodNotAllowed))
  assert(responseCodeFromTag(12) == Some(RequestTimeout))
  assert(responseCodeFromTag(13) == Some(BusyHere))
  assert(responseCodeFromTag(14) == Some(Decline))
  assert(responseCodeFromTag(15) == Some(ServerInternalError))
  assert(responseCodeFromTag(16) == Some(ServiceUnavailable))
  assert(responseCodeFromTag(17) == None)
}

let test_responseCode_toTag = () => {
  assert(responseCodeToTag(Trying) == 0)
  assert(responseCodeToTag(Ringing) == 1)
  assert(responseCodeToTag(SessionProgress) == 2)
  assert(responseCodeToTag(Ok) == 3)
  assert(responseCodeToTag(MultipleChoices) == 4)
  assert(responseCodeToTag(MovedPermanently) == 5)
  assert(responseCodeToTag(MovedTemporarily) == 6)
  assert(responseCodeToTag(BadRequest) == 7)
  assert(responseCodeToTag(Unauthorized) == 8)
  assert(responseCodeToTag(Forbidden) == 9)
  assert(responseCodeToTag(NotFound) == 10)
  assert(responseCodeToTag(MethodNotAllowed) == 11)
  assert(responseCodeToTag(RequestTimeout) == 12)
  assert(responseCodeToTag(BusyHere) == 13)
  assert(responseCodeToTag(Decline) == 14)
  assert(responseCodeToTag(ServerInternalError) == 15)
  assert(responseCodeToTag(ServiceUnavailable) == 16)
}

let test_dialogState_roundtrip = () => {
  assert(dialogStateFromTag(0) == Some(Early))
  assert(dialogStateFromTag(1) == Some(Confirmed))
  assert(dialogStateFromTag(2) == Some(Terminated))
  assert(dialogStateFromTag(3) == None)
}

let test_dialogState_toTag = () => {
  assert(dialogStateToTag(Early) == 0)
  assert(dialogStateToTag(Confirmed) == 1)
  assert(dialogStateToTag(Terminated) == 2)
}

// Run all tests
test_method_roundtrip()
test_method_toTag()
test_responseCode_roundtrip()
test_responseCode_toTag()
test_dialogState_roundtrip()
test_dialogState_toTag()
