// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenKerberos protocol bindings.

open ProvenKerberos

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(AsReq))
  assert(messageTypeFromTag(1) == Some(AsRep))
  assert(messageTypeFromTag(2) == Some(TgsReq))
  assert(messageTypeFromTag(3) == Some(TgsRep))
  assert(messageTypeFromTag(4) == Some(ApReq))
  assert(messageTypeFromTag(5) == Some(ApRep))
  assert(messageTypeFromTag(6) == Some(KrbError))
  assert(messageTypeFromTag(7) == Some(KrbSafe))
  assert(messageTypeFromTag(8) == Some(KrbPriv))
  assert(messageTypeFromTag(9) == Some(KrbCred))
  assert(messageTypeFromTag(10) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(AsReq) == 0)
  assert(messageTypeToTag(AsRep) == 1)
  assert(messageTypeToTag(TgsReq) == 2)
  assert(messageTypeToTag(TgsRep) == 3)
  assert(messageTypeToTag(ApReq) == 4)
  assert(messageTypeToTag(ApRep) == 5)
  assert(messageTypeToTag(KrbError) == 6)
  assert(messageTypeToTag(KrbSafe) == 7)
  assert(messageTypeToTag(KrbPriv) == 8)
  assert(messageTypeToTag(KrbCred) == 9)
}

let test_encryptionType_roundtrip = () => {
  assert(encryptionTypeFromTag(0) == Some(Aes256CtsHmacSha1))
  assert(encryptionTypeFromTag(1) == Some(Aes128CtsHmacSha1))
  assert(encryptionTypeFromTag(2) == Some(Aes256CtsHmacSha384))
  assert(encryptionTypeFromTag(3) == Some(Rc4Hmac))
  assert(encryptionTypeFromTag(4) == Some(Des3CbcSha1))
  assert(encryptionTypeFromTag(5) == None)
}

let test_encryptionType_toTag = () => {
  assert(encryptionTypeToTag(Aes256CtsHmacSha1) == 0)
  assert(encryptionTypeToTag(Aes128CtsHmacSha1) == 1)
  assert(encryptionTypeToTag(Aes256CtsHmacSha384) == 2)
  assert(encryptionTypeToTag(Rc4Hmac) == 3)
  assert(encryptionTypeToTag(Des3CbcSha1) == 4)
}

let test_principalType_roundtrip = () => {
  assert(principalTypeFromTag(0) == Some(NtUnknown))
  assert(principalTypeFromTag(1) == Some(NtPrincipal))
  assert(principalTypeFromTag(2) == Some(NtSrvInst))
  assert(principalTypeFromTag(3) == Some(NtSrvHst))
  assert(principalTypeFromTag(4) == Some(NtUid))
  assert(principalTypeFromTag(5) == Some(NtX500))
  assert(principalTypeFromTag(6) == Some(NtEnterprise))
  assert(principalTypeFromTag(7) == None)
}

let test_principalType_toTag = () => {
  assert(principalTypeToTag(NtUnknown) == 0)
  assert(principalTypeToTag(NtPrincipal) == 1)
  assert(principalTypeToTag(NtSrvInst) == 2)
  assert(principalTypeToTag(NtSrvHst) == 3)
  assert(principalTypeToTag(NtUid) == 4)
  assert(principalTypeToTag(NtX500) == 5)
  assert(principalTypeToTag(NtEnterprise) == 6)
}

let test_ticketFlag_roundtrip = () => {
  assert(ticketFlagFromTag(0) == Some(Forwardable))
  assert(ticketFlagFromTag(1) == Some(Forwarded))
  assert(ticketFlagFromTag(2) == Some(Proxiable))
  assert(ticketFlagFromTag(3) == Some(Proxy))
  assert(ticketFlagFromTag(4) == Some(Renewable))
  assert(ticketFlagFromTag(5) == Some(PreAuthent))
  assert(ticketFlagFromTag(6) == Some(HwAuthent))
  assert(ticketFlagFromTag(7) == None)
}

let test_ticketFlag_toTag = () => {
  assert(ticketFlagToTag(Forwardable) == 0)
  assert(ticketFlagToTag(Forwarded) == 1)
  assert(ticketFlagToTag(Proxiable) == 2)
  assert(ticketFlagToTag(Proxy) == 3)
  assert(ticketFlagToTag(Renewable) == 4)
  assert(ticketFlagToTag(PreAuthent) == 5)
  assert(ticketFlagToTag(HwAuthent) == 6)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(KdcErrNone))
  assert(errorCodeFromTag(1) == Some(KdcErrNameExp))
  assert(errorCodeFromTag(2) == Some(KdcErrServiceExp))
  assert(errorCodeFromTag(3) == Some(KdcErrBadPvno))
  assert(errorCodeFromTag(4) == Some(KdcErrCOldMastKvno))
  assert(errorCodeFromTag(5) == Some(KdcErrSOldMastKvno))
  assert(errorCodeFromTag(6) == Some(KdcErrCPrincipalUnknown))
  assert(errorCodeFromTag(7) == Some(KdcErrSPrincipalUnknown))
  assert(errorCodeFromTag(8) == Some(KdcErrPreauthFailed))
  assert(errorCodeFromTag(9) == Some(KdcErrPreauthRequired))
  assert(errorCodeFromTag(10) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(KdcErrNone) == 0)
  assert(errorCodeToTag(KdcErrNameExp) == 1)
  assert(errorCodeToTag(KdcErrServiceExp) == 2)
  assert(errorCodeToTag(KdcErrBadPvno) == 3)
  assert(errorCodeToTag(KdcErrCOldMastKvno) == 4)
  assert(errorCodeToTag(KdcErrSOldMastKvno) == 5)
  assert(errorCodeToTag(KdcErrCPrincipalUnknown) == 6)
  assert(errorCodeToTag(KdcErrSPrincipalUnknown) == 7)
  assert(errorCodeToTag(KdcErrPreauthFailed) == 8)
  assert(errorCodeToTag(KdcErrPreauthRequired) == 9)
}

let test_authState_roundtrip = () => {
  assert(authStateFromTag(0) == Some(Initial))
  assert(authStateFromTag(1) == Some(TgtObtained))
  assert(authStateFromTag(2) == Some(ServiceTicketObtained))
  assert(authStateFromTag(3) == Some(Authenticated))
  assert(authStateFromTag(4) == Some(AuthFailed))
  assert(authStateFromTag(5) == None)
}

let test_authState_toTag = () => {
  assert(authStateToTag(Initial) == 0)
  assert(authStateToTag(TgtObtained) == 1)
  assert(authStateToTag(ServiceTicketObtained) == 2)
  assert(authStateToTag(Authenticated) == 3)
  assert(authStateToTag(AuthFailed) == 4)
}

let test_encStrength_roundtrip = () => {
  assert(encStrengthFromTag(0) == Some(Strong))
  assert(encStrengthFromTag(1) == Some(Medium))
  assert(encStrengthFromTag(2) == Some(Weak))
  assert(encStrengthFromTag(3) == None)
}

let test_encStrength_toTag = () => {
  assert(encStrengthToTag(Strong) == 0)
  assert(encStrengthToTag(Medium) == 1)
  assert(encStrengthToTag(Weak) == 2)
}

let test_preAuthType_roundtrip = () => {
  assert(preAuthTypeFromTag(0) == Some(PaEncTimestamp))
  assert(preAuthTypeFromTag(1) == Some(PaEtypeInfo2))
  assert(preAuthTypeFromTag(2) == Some(PaFxFast))
  assert(preAuthTypeFromTag(3) == Some(PaFxCookie))
  assert(preAuthTypeFromTag(4) == None)
}

let test_preAuthType_toTag = () => {
  assert(preAuthTypeToTag(PaEncTimestamp) == 0)
  assert(preAuthTypeToTag(PaEtypeInfo2) == 1)
  assert(preAuthTypeToTag(PaFxFast) == 2)
  assert(preAuthTypeToTag(PaFxCookie) == 3)
}

let test_negotiationState_roundtrip = () => {
  assert(negotiationStateFromTag(0) == Some(NegIdle))
  assert(negotiationStateFromTag(1) == Some(Proposed))
  assert(negotiationStateFromTag(2) == Some(Selected))
  assert(negotiationStateFromTag(3) == Some(NegFailed))
  assert(negotiationStateFromTag(4) == None)
}

let test_negotiationState_toTag = () => {
  assert(negotiationStateToTag(NegIdle) == 0)
  assert(negotiationStateToTag(Proposed) == 1)
  assert(negotiationStateToTag(Selected) == 2)
  assert(negotiationStateToTag(NegFailed) == 3)
}

// Run all tests
test_messageType_roundtrip()
test_messageType_toTag()
test_encryptionType_roundtrip()
test_encryptionType_toTag()
test_principalType_roundtrip()
test_principalType_toTag()
test_ticketFlag_roundtrip()
test_ticketFlag_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_authState_roundtrip()
test_authState_toTag()
test_encStrength_roundtrip()
test_encStrength_toTag()
test_preAuthType_roundtrip()
test_preAuthType_toTag()
test_negotiationState_roundtrip()
test_negotiationState_toTag()
