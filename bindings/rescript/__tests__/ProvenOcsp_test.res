// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenOcsp protocol bindings.

open ProvenOcsp

let test_certStatus_roundtrip = () => {
  assert(certStatusFromTag(0) == Some(Good))
  assert(certStatusFromTag(1) == Some(Revoked))
  assert(certStatusFromTag(2) == Some(Unknown))
  assert(certStatusFromTag(3) == None)
}

let test_certStatus_toTag = () => {
  assert(certStatusToTag(Good) == 0)
  assert(certStatusToTag(Revoked) == 1)
  assert(certStatusToTag(Unknown) == 2)
}

let test_responseStatus_roundtrip = () => {
  assert(responseStatusFromTag(0) == Some(Successful))
  assert(responseStatusFromTag(1) == Some(MalformedRequest))
  assert(responseStatusFromTag(2) == Some(InternalError))
  assert(responseStatusFromTag(3) == Some(TryLater))
  assert(responseStatusFromTag(4) == Some(SigRequired))
  assert(responseStatusFromTag(5) == Some(Unauthorized))
  assert(responseStatusFromTag(6) == None)
}

let test_responseStatus_toTag = () => {
  assert(responseStatusToTag(Successful) == 0)
  assert(responseStatusToTag(MalformedRequest) == 1)
  assert(responseStatusToTag(InternalError) == 2)
  assert(responseStatusToTag(TryLater) == 3)
  assert(responseStatusToTag(SigRequired) == 4)
  assert(responseStatusToTag(Unauthorized) == 5)
}

let test_hashAlgorithm_roundtrip = () => {
  assert(hashAlgorithmFromTag(0) == Some(Sha1))
  assert(hashAlgorithmFromTag(1) == Some(Sha256))
  assert(hashAlgorithmFromTag(2) == Some(Sha384))
  assert(hashAlgorithmFromTag(3) == Some(Sha512))
  assert(hashAlgorithmFromTag(4) == None)
}

let test_hashAlgorithm_toTag = () => {
  assert(hashAlgorithmToTag(Sha1) == 0)
  assert(hashAlgorithmToTag(Sha256) == 1)
  assert(hashAlgorithmToTag(Sha384) == 2)
  assert(hashAlgorithmToTag(Sha512) == 3)
}

let test_responderState_roundtrip = () => {
  assert(responderStateFromTag(0) == Some(Idle))
  assert(responderStateFromTag(1) == Some(Ready))
  assert(responderStateFromTag(2) == Some(Processing))
  assert(responderStateFromTag(3) == Some(Signing))
  assert(responderStateFromTag(4) == Some(Closing))
  assert(responderStateFromTag(5) == None)
}

let test_responderState_toTag = () => {
  assert(responderStateToTag(Idle) == 0)
  assert(responderStateToTag(Ready) == 1)
  assert(responderStateToTag(Processing) == 2)
  assert(responderStateToTag(Signing) == 3)
  assert(responderStateToTag(Closing) == 4)
}

// Run all tests
test_certStatus_roundtrip()
test_certStatus_toTag()
test_responseStatus_roundtrip()
test_responseStatus_toTag()
test_hashAlgorithm_roundtrip()
test_hashAlgorithm_toTag()
test_responderState_roundtrip()
test_responderState_toTag()
