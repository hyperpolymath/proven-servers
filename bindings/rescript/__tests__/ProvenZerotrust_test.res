// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenZerotrust protocol bindings.

open ProvenZerotrust

let test_policyType_roundtrip = () => {
  assert(policyTypeFromTag(0) == Some(AlwaysVerify))
  assert(policyTypeFromTag(1) == Some(NeverTrust))
  assert(policyTypeFromTag(2) == Some(LeastPrivilege))
  assert(policyTypeFromTag(3) == Some(MicroSegmentation))
  assert(policyTypeFromTag(4) == None)
}

let test_policyType_toTag = () => {
  assert(policyTypeToTag(AlwaysVerify) == 0)
  assert(policyTypeToTag(NeverTrust) == 1)
  assert(policyTypeToTag(LeastPrivilege) == 2)
  assert(policyTypeToTag(MicroSegmentation) == 3)
}

let test_identityConfidence_roundtrip = () => {
  assert(identityConfidenceFromTag(0) == Some(Unverified))
  assert(identityConfidenceFromTag(1) == Some(BasicAuth))
  assert(identityConfidenceFromTag(2) == Some(MfaVerified))
  assert(identityConfidenceFromTag(3) == Some(StrongAuth))
  assert(identityConfidenceFromTag(4) == Some(ContinuousAuth))
  assert(identityConfidenceFromTag(5) == None)
}

let test_identityConfidence_toTag = () => {
  assert(identityConfidenceToTag(Unverified) == 0)
  assert(identityConfidenceToTag(BasicAuth) == 1)
  assert(identityConfidenceToTag(MfaVerified) == 2)
  assert(identityConfidenceToTag(StrongAuth) == 3)
  assert(identityConfidenceToTag(ContinuousAuth) == 4)
}

let test_deviceTrustScore_roundtrip = () => {
  assert(deviceTrustScoreFromTag(0) == Some(DeviceUnknown))
  assert(deviceTrustScoreFromTag(1) == Some(DevicePartial))
  assert(deviceTrustScoreFromTag(2) == Some(DeviceCompliant))
  assert(deviceTrustScoreFromTag(3) == Some(DeviceManaged))
  assert(deviceTrustScoreFromTag(4) == Some(DeviceHardened))
  assert(deviceTrustScoreFromTag(5) == None)
}

let test_deviceTrustScore_toTag = () => {
  assert(deviceTrustScoreToTag(DeviceUnknown) == 0)
  assert(deviceTrustScoreToTag(DevicePartial) == 1)
  assert(deviceTrustScoreToTag(DeviceCompliant) == 2)
  assert(deviceTrustScoreToTag(DeviceManaged) == 3)
  assert(deviceTrustScoreToTag(DeviceHardened) == 4)
}

let test_accessDecision_roundtrip = () => {
  assert(accessDecisionFromTag(0) == Some(Allow))
  assert(accessDecisionFromTag(1) == Some(Deny))
  assert(accessDecisionFromTag(2) == Some(Challenge))
  assert(accessDecisionFromTag(3) == Some(StepUp))
  assert(accessDecisionFromTag(4) == None)
}

let test_accessDecision_toTag = () => {
  assert(accessDecisionToTag(Allow) == 0)
  assert(accessDecisionToTag(Deny) == 1)
  assert(accessDecisionToTag(Challenge) == 2)
  assert(accessDecisionToTag(StepUp) == 3)
}

let test_contextSignalKind_roundtrip = () => {
  assert(contextSignalKindFromTag(0) == Some(Location))
  assert(contextSignalKindFromTag(1) == Some(Time))
  assert(contextSignalKindFromTag(2) == Some(Device))
  assert(contextSignalKindFromTag(3) == Some(Behavior))
  assert(contextSignalKindFromTag(4) == Some(Network))
  assert(contextSignalKindFromTag(5) == None)
}

let test_contextSignalKind_toTag = () => {
  assert(contextSignalKindToTag(Location) == 0)
  assert(contextSignalKindToTag(Time) == 1)
  assert(contextSignalKindToTag(Device) == 2)
  assert(contextSignalKindToTag(Behavior) == 3)
  assert(contextSignalKindToTag(Network) == 4)
}

let test_authFactor_roundtrip = () => {
  assert(authFactorFromTag(0) == Some(Certificate))
  assert(authFactorFromTag(1) == Some(Token))
  assert(authFactorFromTag(2) == Some(Biometric))
  assert(authFactorFromTag(3) == Some(Fido2))
  assert(authFactorFromTag(4) == Some(Totp))
  assert(authFactorFromTag(5) == Some(Push))
  assert(authFactorFromTag(6) == None)
}

let test_authFactor_toTag = () => {
  assert(authFactorToTag(Certificate) == 0)
  assert(authFactorToTag(Token) == 1)
  assert(authFactorToTag(Biometric) == 2)
  assert(authFactorToTag(Fido2) == 3)
  assert(authFactorToTag(Totp) == 4)
  assert(authFactorToTag(Push) == 5)
}

// Run all tests
test_policyType_roundtrip()
test_policyType_toTag()
test_identityConfidence_roundtrip()
test_identityConfidence_toTag()
test_deviceTrustScore_roundtrip()
test_deviceTrustScore_toTag()
test_accessDecision_roundtrip()
test_accessDecision_toTag()
test_contextSignalKind_roundtrip()
test_contextSignalKind_toTag()
test_authFactor_roundtrip()
test_authFactor_toTag()
