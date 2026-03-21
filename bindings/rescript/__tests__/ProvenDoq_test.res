// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDoq protocol bindings.

open ProvenDoq

let test_streamType_roundtrip = () => {
  assert(streamTypeFromTag(0) == Some(Unidirectional))
  assert(streamTypeFromTag(1) == Some(Bidirectional))
  assert(streamTypeFromTag(2) == None)
}

let test_streamType_toTag = () => {
  assert(streamTypeToTag(Unidirectional) == 0)
  assert(streamTypeToTag(Bidirectional) == 1)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(NoError))
  assert(errorCodeFromTag(1) == Some(InternalError))
  assert(errorCodeFromTag(2) == Some(ExcessiveLoad))
  assert(errorCodeFromTag(3) == Some(ProtocolError))
  assert(errorCodeFromTag(4) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(NoError) == 0)
  assert(errorCodeToTag(InternalError) == 1)
  assert(errorCodeToTag(ExcessiveLoad) == 2)
  assert(errorCodeToTag(ProtocolError) == 3)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Initial))
  assert(sessionStateFromTag(1) == Some(Handshaking))
  assert(sessionStateFromTag(2) == Some(Ready))
  assert(sessionStateFromTag(3) == Some(Draining))
  assert(sessionStateFromTag(4) == Some(Closed))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Initial) == 0)
  assert(sessionStateToTag(Handshaking) == 1)
  assert(sessionStateToTag(Ready) == 2)
  assert(sessionStateToTag(Draining) == 3)
  assert(sessionStateToTag(Closed) == 4)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Bound))
  assert(serverStateFromTag(2) == Some(Listening))
  assert(serverStateFromTag(3) == Some(Processing))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Bound) == 1)
  assert(serverStateToTag(Listening) == 2)
  assert(serverStateToTag(Processing) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_streamType_roundtrip()
test_streamType_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
