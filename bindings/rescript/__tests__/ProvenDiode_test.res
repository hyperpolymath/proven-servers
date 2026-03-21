// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDiode protocol bindings.

open ProvenDiode

let test_direction_roundtrip = () => {
  assert(directionFromTag(0) == Some(HighToLow))
  assert(directionFromTag(1) == Some(LowToHigh))
  assert(directionFromTag(2) == None)
}

let test_direction_toTag = () => {
  assert(directionToTag(HighToLow) == 0)
  assert(directionToTag(LowToHigh) == 1)
}

let test_diodeProtocol_roundtrip = () => {
  assert(diodeProtocolFromTag(0) == Some(Udp))
  assert(diodeProtocolFromTag(1) == Some(Tcp))
  assert(diodeProtocolFromTag(2) == Some(FileTransfer))
  assert(diodeProtocolFromTag(3) == Some(Syslog))
  assert(diodeProtocolFromTag(4) == Some(Snmp))
  assert(diodeProtocolFromTag(5) == None)
}

let test_diodeProtocol_toTag = () => {
  assert(diodeProtocolToTag(Udp) == 0)
  assert(diodeProtocolToTag(Tcp) == 1)
  assert(diodeProtocolToTag(FileTransfer) == 2)
  assert(diodeProtocolToTag(Syslog) == 3)
  assert(diodeProtocolToTag(Snmp) == 4)
}

let test_transferState_roundtrip = () => {
  assert(transferStateFromTag(0) == Some(Queued))
  assert(transferStateFromTag(1) == Some(Sending))
  assert(transferStateFromTag(2) == Some(Confirming))
  assert(transferStateFromTag(3) == Some(Complete))
  assert(transferStateFromTag(4) == Some(Failed))
  assert(transferStateFromTag(5) == None)
}

let test_transferState_toTag = () => {
  assert(transferStateToTag(Queued) == 0)
  assert(transferStateToTag(Sending) == 1)
  assert(transferStateToTag(Confirming) == 2)
  assert(transferStateToTag(Complete) == 3)
  assert(transferStateToTag(Failed) == 4)
}

let test_validationResult_roundtrip = () => {
  assert(validationResultFromTag(0) == Some(Passed))
  assert(validationResultFromTag(1) == Some(FormatError))
  assert(validationResultFromTag(2) == Some(SizeExceeded))
  assert(validationResultFromTag(3) == Some(PolicyBlocked))
  assert(validationResultFromTag(4) == None)
}

let test_validationResult_toTag = () => {
  assert(validationResultToTag(Passed) == 0)
  assert(validationResultToTag(FormatError) == 1)
  assert(validationResultToTag(SizeExceeded) == 2)
  assert(validationResultToTag(PolicyBlocked) == 3)
}

let test_integrityCheck_roundtrip = () => {
  assert(integrityCheckFromTag(0) == Some(Crc32))
  assert(integrityCheckFromTag(1) == Some(Sha256))
  assert(integrityCheckFromTag(2) == Some(Hmac))
  assert(integrityCheckFromTag(3) == None)
}

let test_integrityCheck_toTag = () => {
  assert(integrityCheckToTag(Crc32) == 0)
  assert(integrityCheckToTag(Sha256) == 1)
  assert(integrityCheckToTag(Hmac) == 2)
}

let test_gatewayState_roundtrip = () => {
  assert(gatewayStateFromTag(0) == Some(Idle))
  assert(gatewayStateFromTag(1) == Some(Configured))
  assert(gatewayStateFromTag(2) == Some(Transferring))
  assert(gatewayStateFromTag(3) == Some(Validating))
  assert(gatewayStateFromTag(4) == Some(Shutdown))
  assert(gatewayStateFromTag(5) == None)
}

let test_gatewayState_toTag = () => {
  assert(gatewayStateToTag(Idle) == 0)
  assert(gatewayStateToTag(Configured) == 1)
  assert(gatewayStateToTag(Transferring) == 2)
  assert(gatewayStateToTag(Validating) == 3)
  assert(gatewayStateToTag(Shutdown) == 4)
}

// Run all tests
test_direction_roundtrip()
test_direction_toTag()
test_diodeProtocol_roundtrip()
test_diodeProtocol_toTag()
test_transferState_roundtrip()
test_transferState_toTag()
test_validationResult_roundtrip()
test_validationResult_toTag()
test_integrityCheck_roundtrip()
test_integrityCheck_toTag()
test_gatewayState_roundtrip()
test_gatewayState_toTag()
