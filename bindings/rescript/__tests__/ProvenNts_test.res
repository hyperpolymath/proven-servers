// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNts protocol bindings.

open ProvenNts

let test_recordType_roundtrip = () => {
  assert(recordTypeFromTag(0) == Some(EndOfMessage))
  assert(recordTypeFromTag(1) == Some(NextProtocol))
  assert(recordTypeFromTag(2) == Some(Error))
  assert(recordTypeFromTag(3) == Some(Warning))
  assert(recordTypeFromTag(4) == Some(AeadAlgorithm))
  assert(recordTypeFromTag(5) == Some(Cookie))
  assert(recordTypeFromTag(6) == Some(CookiePlaceholder))
  assert(recordTypeFromTag(7) == Some(NtskeServer))
  assert(recordTypeFromTag(8) == Some(NtskePort))
  assert(recordTypeFromTag(9) == None)
}

let test_recordType_toTag = () => {
  assert(recordTypeToTag(EndOfMessage) == 0)
  assert(recordTypeToTag(NextProtocol) == 1)
  assert(recordTypeToTag(Error) == 2)
  assert(recordTypeToTag(Warning) == 3)
  assert(recordTypeToTag(AeadAlgorithm) == 4)
  assert(recordTypeToTag(Cookie) == 5)
  assert(recordTypeToTag(CookiePlaceholder) == 6)
  assert(recordTypeToTag(NtskeServer) == 7)
  assert(recordTypeToTag(NtskePort) == 8)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(UnrecognizedCritical))
  assert(errorCodeFromTag(1) == Some(BadRequest))
  assert(errorCodeFromTag(2) == Some(InternalError))
  assert(errorCodeFromTag(3) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(UnrecognizedCritical) == 0)
  assert(errorCodeToTag(BadRequest) == 1)
  assert(errorCodeToTag(InternalError) == 2)
}

let test_aeadAlgorithm_roundtrip = () => {
  assert(aeadAlgorithmFromTag(0) == Some(AeadAes128Gcm))
  assert(aeadAlgorithmFromTag(1) == Some(AeadAes256Gcm))
  assert(aeadAlgorithmFromTag(2) == Some(AeadAesSivCmac256))
  assert(aeadAlgorithmFromTag(3) == None)
}

let test_aeadAlgorithm_toTag = () => {
  assert(aeadAlgorithmToTag(AeadAes128Gcm) == 0)
  assert(aeadAlgorithmToTag(AeadAes256Gcm) == 1)
  assert(aeadAlgorithmToTag(AeadAesSivCmac256) == 2)
}

let test_handshakeState_roundtrip = () => {
  assert(handshakeStateFromTag(0) == Some(Initial))
  assert(handshakeStateFromTag(1) == Some(Negotiating))
  assert(handshakeStateFromTag(2) == Some(Established))
  assert(handshakeStateFromTag(3) == Some(Failed))
  assert(handshakeStateFromTag(4) == None)
}

let test_handshakeState_toTag = () => {
  assert(handshakeStateToTag(Initial) == 0)
  assert(handshakeStateToTag(Negotiating) == 1)
  assert(handshakeStateToTag(Established) == 2)
  assert(handshakeStateToTag(Failed) == 3)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Handshaking))
  assert(sessionStateFromTag(2) == Some(Negotiating))
  assert(sessionStateFromTag(3) == Some(Established))
  assert(sessionStateFromTag(4) == Some(Closing))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Handshaking) == 1)
  assert(sessionStateToTag(Negotiating) == 2)
  assert(sessionStateToTag(Established) == 3)
  assert(sessionStateToTag(Closing) == 4)
}

// Run all tests
test_recordType_roundtrip()
test_recordType_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_aeadAlgorithm_roundtrip()
test_aeadAlgorithm_toTag()
test_handshakeState_roundtrip()
test_handshakeState_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
