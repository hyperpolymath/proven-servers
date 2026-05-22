// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDot protocol bindings.

open ProvenDot

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Connecting))
  assert(sessionStateFromTag(1) == Some(Handshaking))
  assert(sessionStateFromTag(2) == Some(Established))
  assert(sessionStateFromTag(3) == Some(Closing))
  assert(sessionStateFromTag(4) == Some(Closed))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Connecting) == 0)
  assert(sessionStateToTag(Handshaking) == 1)
  assert(sessionStateToTag(Established) == 2)
  assert(sessionStateToTag(Closing) == 3)
  assert(sessionStateToTag(Closed) == 4)
}

let test_paddingStrategy_roundtrip = () => {
  assert(paddingStrategyFromTag(0) == Some(NoPadding))
  assert(paddingStrategyFromTag(1) == Some(BlockPadding))
  assert(paddingStrategyFromTag(2) == Some(RandomPadding))
  assert(paddingStrategyFromTag(3) == None)
}

let test_paddingStrategy_toTag = () => {
  assert(paddingStrategyToTag(NoPadding) == 0)
  assert(paddingStrategyToTag(BlockPadding) == 1)
  assert(paddingStrategyToTag(RandomPadding) == 2)
}

let test_errorReason_roundtrip = () => {
  assert(errorReasonFromTag(0) == Some(HandshakeFailed))
  assert(errorReasonFromTag(1) == Some(CertificateInvalid))
  assert(errorReasonFromTag(2) == Some(Timeout))
  assert(errorReasonFromTag(3) == Some(UpstreamError))
  assert(errorReasonFromTag(4) == None)
}

let test_errorReason_toTag = () => {
  assert(errorReasonToTag(HandshakeFailed) == 0)
  assert(errorReasonToTag(CertificateInvalid) == 1)
  assert(errorReasonToTag(Timeout) == 2)
  assert(errorReasonToTag(UpstreamError) == 3)
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
test_sessionState_roundtrip()
test_sessionState_toTag()
test_paddingStrategy_roundtrip()
test_paddingStrategy_toTag()
test_errorReason_roundtrip()
test_errorReason_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
