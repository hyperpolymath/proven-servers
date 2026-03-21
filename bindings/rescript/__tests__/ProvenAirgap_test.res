// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenAirgap protocol bindings.

open ProvenAirgap

let test_transferDirection_roundtrip = () => {
  assert(transferDirectionFromTag(0) == Some(Import))
  assert(transferDirectionFromTag(1) == Some(Export))
  assert(transferDirectionFromTag(2) == None)
}

let test_transferDirection_toTag = () => {
  assert(transferDirectionToTag(Import) == 0)
  assert(transferDirectionToTag(Export) == 1)
}

let test_mediaType_roundtrip = () => {
  assert(mediaTypeFromTag(0) == Some(Usb))
  assert(mediaTypeFromTag(1) == Some(OpticalDisc))
  assert(mediaTypeFromTag(2) == Some(TapeCartridge))
  assert(mediaTypeFromTag(3) == Some(DiodeLink))
  assert(mediaTypeFromTag(4) == None)
}

let test_mediaType_toTag = () => {
  assert(mediaTypeToTag(Usb) == 0)
  assert(mediaTypeToTag(OpticalDisc) == 1)
  assert(mediaTypeToTag(TapeCartridge) == 2)
  assert(mediaTypeToTag(DiodeLink) == 3)
}

let test_scanResult_roundtrip = () => {
  assert(scanResultFromTag(0) == Some(Clean))
  assert(scanResultFromTag(1) == Some(Suspicious))
  assert(scanResultFromTag(2) == Some(Malicious))
  assert(scanResultFromTag(3) == Some(Unscannable))
  assert(scanResultFromTag(4) == None)
}

let test_scanResult_toTag = () => {
  assert(scanResultToTag(Clean) == 0)
  assert(scanResultToTag(Suspicious) == 1)
  assert(scanResultToTag(Malicious) == 2)
  assert(scanResultToTag(Unscannable) == 3)
}

let test_transferState_roundtrip = () => {
  assert(transferStateFromTag(0) == Some(Pending))
  assert(transferStateFromTag(1) == Some(Scanning))
  assert(transferStateFromTag(2) == Some(Approved))
  assert(transferStateFromTag(3) == Some(Rejected))
  assert(transferStateFromTag(4) == Some(InProgress))
  assert(transferStateFromTag(5) == Some(Complete))
  assert(transferStateFromTag(6) == Some(Failed))
  assert(transferStateFromTag(7) == None)
}

let test_transferState_toTag = () => {
  assert(transferStateToTag(Pending) == 0)
  assert(transferStateToTag(Scanning) == 1)
  assert(transferStateToTag(Approved) == 2)
  assert(transferStateToTag(Rejected) == 3)
  assert(transferStateToTag(InProgress) == 4)
  assert(transferStateToTag(Complete) == 5)
  assert(transferStateToTag(Failed) == 6)
}

let test_validationCheck_roundtrip = () => {
  assert(validationCheckFromTag(0) == Some(HashVerify))
  assert(validationCheckFromTag(1) == Some(SignatureVerify))
  assert(validationCheckFromTag(2) == Some(FormatCheck))
  assert(validationCheckFromTag(3) == Some(ContentInspection))
  assert(validationCheckFromTag(4) == Some(MalwareScan))
  assert(validationCheckFromTag(5) == None)
}

let test_validationCheck_toTag = () => {
  assert(validationCheckToTag(HashVerify) == 0)
  assert(validationCheckToTag(SignatureVerify) == 1)
  assert(validationCheckToTag(FormatCheck) == 2)
  assert(validationCheckToTag(ContentInspection) == 3)
  assert(validationCheckToTag(MalwareScan) == 4)
}

// Run all tests
test_transferDirection_roundtrip()
test_transferDirection_toTag()
test_mediaType_roundtrip()
test_mediaType_toTag()
test_scanResult_roundtrip()
test_scanResult_toTag()
test_transferState_roundtrip()
test_transferState_toTag()
test_validationCheck_roundtrip()
test_validationCheck_toTag()
