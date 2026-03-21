// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCtlog protocol bindings.

open ProvenCtlog

let test_logEntryType_roundtrip = () => {
  assert(logEntryTypeFromTag(0) == Some(X509Entry))
  assert(logEntryTypeFromTag(1) == Some(PrecertEntry))
  assert(logEntryTypeFromTag(2) == None)
}

let test_logEntryType_toTag = () => {
  assert(logEntryTypeToTag(X509Entry) == 0)
  assert(logEntryTypeToTag(PrecertEntry) == 1)
}

let test_signatureType_roundtrip = () => {
  assert(signatureTypeFromTag(0) == Some(CertificateTimestamp))
  assert(signatureTypeFromTag(1) == Some(TreeHash))
  assert(signatureTypeFromTag(2) == None)
}

let test_signatureType_toTag = () => {
  assert(signatureTypeToTag(CertificateTimestamp) == 0)
  assert(signatureTypeToTag(TreeHash) == 1)
}

let test_merkleLeafType_roundtrip = () => {
  assert(merkleLeafTypeFromTag(0) == Some(TimestampedEntry))
  assert(merkleLeafTypeFromTag(1) == None)
}

let test_merkleLeafType_toTag = () => {
  assert(merkleLeafTypeToTag(TimestampedEntry) == 0)
}

let test_submissionStatus_roundtrip = () => {
  assert(submissionStatusFromTag(0) == Some(Accepted))
  assert(submissionStatusFromTag(1) == Some(Duplicate))
  assert(submissionStatusFromTag(2) == Some(RateLimited))
  assert(submissionStatusFromTag(3) == Some(Rejected))
  assert(submissionStatusFromTag(4) == Some(InvalidChain))
  assert(submissionStatusFromTag(5) == Some(UnknownAnchor))
  assert(submissionStatusFromTag(6) == None)
}

let test_submissionStatus_toTag = () => {
  assert(submissionStatusToTag(Accepted) == 0)
  assert(submissionStatusToTag(Duplicate) == 1)
  assert(submissionStatusToTag(RateLimited) == 2)
  assert(submissionStatusToTag(Rejected) == 3)
  assert(submissionStatusToTag(InvalidChain) == 4)
  assert(submissionStatusToTag(UnknownAnchor) == 5)
}

let test_verificationResult_roundtrip = () => {
  assert(verificationResultFromTag(0) == Some(ValidProof))
  assert(verificationResultFromTag(1) == Some(InvalidProof))
  assert(verificationResultFromTag(2) == Some(InconsistentTree))
  assert(verificationResultFromTag(3) == Some(StaleSth))
  assert(verificationResultFromTag(4) == None)
}

let test_verificationResult_toTag = () => {
  assert(verificationResultToTag(ValidProof) == 0)
  assert(verificationResultToTag(InvalidProof) == 1)
  assert(verificationResultToTag(InconsistentTree) == 2)
  assert(verificationResultToTag(StaleSth) == 3)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Active))
  assert(serverStateFromTag(2) == Some(Merging))
  assert(serverStateFromTag(3) == Some(Signing))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Active) == 1)
  assert(serverStateToTag(Merging) == 2)
  assert(serverStateToTag(Signing) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_logEntryType_roundtrip()
test_logEntryType_toTag()
test_signatureType_roundtrip()
test_signatureType_toTag()
test_merkleLeafType_roundtrip()
test_merkleLeafType_toTag()
test_submissionStatus_roundtrip()
test_submissionStatus_toTag()
test_verificationResult_roundtrip()
test_verificationResult_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
