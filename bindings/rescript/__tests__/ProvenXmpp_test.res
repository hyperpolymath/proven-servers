// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenXmpp protocol bindings.

open ProvenXmpp

let test_stanzaType_roundtrip = () => {
  assert(stanzaTypeFromTag(0) == Some(Message))
  assert(stanzaTypeFromTag(1) == Some(Presence))
  assert(stanzaTypeFromTag(2) == Some(Iq))
  assert(stanzaTypeFromTag(3) == None)
}

let test_stanzaType_toTag = () => {
  assert(stanzaTypeToTag(Message) == 0)
  assert(stanzaTypeToTag(Presence) == 1)
  assert(stanzaTypeToTag(Iq) == 2)
}

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(Chat))
  assert(messageTypeFromTag(1) == Some(Error))
  assert(messageTypeFromTag(2) == Some(Groupchat))
  assert(messageTypeFromTag(3) == Some(Headline))
  assert(messageTypeFromTag(4) == Some(Normal))
  assert(messageTypeFromTag(5) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(Chat) == 0)
  assert(messageTypeToTag(Error) == 1)
  assert(messageTypeToTag(Groupchat) == 2)
  assert(messageTypeToTag(Headline) == 3)
  assert(messageTypeToTag(Normal) == 4)
}

let test_presenceType_roundtrip = () => {
  assert(presenceTypeFromTag(0) == Some(Available))
  assert(presenceTypeFromTag(1) == Some(Away))
  assert(presenceTypeFromTag(2) == Some(Dnd))
  assert(presenceTypeFromTag(3) == Some(Xa))
  assert(presenceTypeFromTag(4) == Some(Unavailable))
  assert(presenceTypeFromTag(5) == None)
}

let test_presenceType_toTag = () => {
  assert(presenceTypeToTag(Available) == 0)
  assert(presenceTypeToTag(Away) == 1)
  assert(presenceTypeToTag(Dnd) == 2)
  assert(presenceTypeToTag(Xa) == 3)
  assert(presenceTypeToTag(Unavailable) == 4)
}

let test_iqType_roundtrip = () => {
  assert(iqTypeFromTag(0) == Some(Get))
  assert(iqTypeFromTag(1) == Some(Set))
  assert(iqTypeFromTag(2) == Some(Result))
  assert(iqTypeFromTag(3) == Some(Error))
  assert(iqTypeFromTag(4) == None)
}

let test_iqType_toTag = () => {
  assert(iqTypeToTag(Get) == 0)
  assert(iqTypeToTag(Set) == 1)
  assert(iqTypeToTag(Result) == 2)
  assert(iqTypeToTag(Error) == 3)
}

let test_streamError_roundtrip = () => {
  assert(streamErrorFromTag(0) == Some(BadFormat))
  assert(streamErrorFromTag(1) == Some(Conflict))
  assert(streamErrorFromTag(2) == Some(ConnectionTimeout))
  assert(streamErrorFromTag(3) == Some(HostGone))
  assert(streamErrorFromTag(4) == Some(HostUnknown))
  assert(streamErrorFromTag(5) == Some(NotAuthorized))
  assert(streamErrorFromTag(6) == Some(PolicyViolation))
  assert(streamErrorFromTag(7) == Some(ResourceConstraint))
  assert(streamErrorFromTag(8) == Some(SystemShutdown))
  assert(streamErrorFromTag(9) == None)
}

let test_streamError_toTag = () => {
  assert(streamErrorToTag(BadFormat) == 0)
  assert(streamErrorToTag(Conflict) == 1)
  assert(streamErrorToTag(ConnectionTimeout) == 2)
  assert(streamErrorToTag(HostGone) == 3)
  assert(streamErrorToTag(HostUnknown) == 4)
  assert(streamErrorToTag(NotAuthorized) == 5)
  assert(streamErrorToTag(PolicyViolation) == 6)
  assert(streamErrorToTag(ResourceConstraint) == 7)
  assert(streamErrorToTag(SystemShutdown) == 8)
}

// Run all tests
test_stanzaType_roundtrip()
test_stanzaType_toTag()
test_messageType_roundtrip()
test_messageType_toTag()
test_presenceType_roundtrip()
test_presenceType_toTag()
test_iqType_roundtrip()
test_iqType_toTag()
test_streamError_roundtrip()
test_streamError_toTag()
