// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenVpn protocol bindings.

open ProvenVpn

let test_tunnelType_roundtrip = () => {
  assert(tunnelTypeFromTag(0) == Some(Ipsec))
  assert(tunnelTypeFromTag(1) == Some(Wireguard))
  assert(tunnelTypeFromTag(2) == Some(Openvpn))
  assert(tunnelTypeFromTag(3) == Some(L2tp))
  assert(tunnelTypeFromTag(4) == None)
}

let test_tunnelType_toTag = () => {
  assert(tunnelTypeToTag(Ipsec) == 0)
  assert(tunnelTypeToTag(Wireguard) == 1)
  assert(tunnelTypeToTag(Openvpn) == 2)
  assert(tunnelTypeToTag(L2tp) == 3)
}

let test_tunnelPhase_roundtrip = () => {
  assert(tunnelPhaseFromTag(0) == Some(Idle))
  assert(tunnelPhaseFromTag(1) == Some(Phase1Init))
  assert(tunnelPhaseFromTag(2) == Some(Phase1Auth))
  assert(tunnelPhaseFromTag(3) == Some(Phase1Done))
  assert(tunnelPhaseFromTag(4) == Some(Phase2Negotiating))
  assert(tunnelPhaseFromTag(5) == Some(Established))
  assert(tunnelPhaseFromTag(6) == Some(Expired))
  assert(tunnelPhaseFromTag(7) == None)
}

let test_tunnelPhase_toTag = () => {
  assert(tunnelPhaseToTag(Idle) == 0)
  assert(tunnelPhaseToTag(Phase1Init) == 1)
  assert(tunnelPhaseToTag(Phase1Auth) == 2)
  assert(tunnelPhaseToTag(Phase1Done) == 3)
  assert(tunnelPhaseToTag(Phase2Negotiating) == 4)
  assert(tunnelPhaseToTag(Established) == 5)
  assert(tunnelPhaseToTag(Expired) == 6)
}

let test_encryptionAlgorithm_roundtrip = () => {
  assert(encryptionAlgorithmFromTag(0) == Some(Aes128Cbc))
  assert(encryptionAlgorithmFromTag(1) == Some(Aes256Cbc))
  assert(encryptionAlgorithmFromTag(2) == Some(Aes128Gcm))
  assert(encryptionAlgorithmFromTag(3) == Some(Aes256Gcm))
  assert(encryptionAlgorithmFromTag(4) == Some(Chacha20Poly1305))
  assert(encryptionAlgorithmFromTag(5) == Some(NullCipher))
  assert(encryptionAlgorithmFromTag(6) == None)
}

let test_encryptionAlgorithm_toTag = () => {
  assert(encryptionAlgorithmToTag(Aes128Cbc) == 0)
  assert(encryptionAlgorithmToTag(Aes256Cbc) == 1)
  assert(encryptionAlgorithmToTag(Aes128Gcm) == 2)
  assert(encryptionAlgorithmToTag(Aes256Gcm) == 3)
  assert(encryptionAlgorithmToTag(Chacha20Poly1305) == 4)
  assert(encryptionAlgorithmToTag(NullCipher) == 5)
}

let test_integrityAlgorithm_roundtrip = () => {
  assert(integrityAlgorithmFromTag(0) == Some(HmacSha1))
  assert(integrityAlgorithmFromTag(1) == Some(HmacSha256))
  assert(integrityAlgorithmFromTag(2) == Some(HmacSha384))
  assert(integrityAlgorithmFromTag(3) == Some(HmacSha512))
  assert(integrityAlgorithmFromTag(4) == Some(NoIntegrity))
  assert(integrityAlgorithmFromTag(5) == None)
}

let test_integrityAlgorithm_toTag = () => {
  assert(integrityAlgorithmToTag(HmacSha1) == 0)
  assert(integrityAlgorithmToTag(HmacSha256) == 1)
  assert(integrityAlgorithmToTag(HmacSha384) == 2)
  assert(integrityAlgorithmToTag(HmacSha512) == 3)
  assert(integrityAlgorithmToTag(NoIntegrity) == 4)
}

let test_dhGroup_roundtrip = () => {
  assert(dhGroupFromTag(0) == Some(Dh14))
  assert(dhGroupFromTag(1) == Some(Ecp256))
  assert(dhGroupFromTag(2) == Some(Ecp384))
  assert(dhGroupFromTag(3) == Some(Curve25519))
  assert(dhGroupFromTag(4) == None)
}

let test_dhGroup_toTag = () => {
  assert(dhGroupToTag(Dh14) == 0)
  assert(dhGroupToTag(Ecp256) == 1)
  assert(dhGroupToTag(Ecp384) == 2)
  assert(dhGroupToTag(Curve25519) == 3)
}

let test_saLifecycle_roundtrip = () => {
  assert(saLifecycleFromTag(0) == Some(None))
  assert(saLifecycleFromTag(1) == Some(Active))
  assert(saLifecycleFromTag(2) == Some(Rekeying))
  assert(saLifecycleFromTag(3) == Some(Expired))
  assert(saLifecycleFromTag(4) == Some(Deleted))
  assert(saLifecycleFromTag(5) == None)
}

let test_saLifecycle_toTag = () => {
  assert(saLifecycleToTag(None) == 0)
  assert(saLifecycleToTag(Active) == 1)
  assert(saLifecycleToTag(Rekeying) == 2)
  assert(saLifecycleToTag(Expired) == 3)
  assert(saLifecycleToTag(Deleted) == 4)
}

let test_ikeVersion_roundtrip = () => {
  assert(ikeVersionFromTag(0) == Some(V1))
  assert(ikeVersionFromTag(1) == Some(V2))
  assert(ikeVersionFromTag(2) == None)
}

let test_ikeVersion_toTag = () => {
  assert(ikeVersionToTag(V1) == 0)
  assert(ikeVersionToTag(V2) == 1)
}

let test_vpnError_roundtrip = () => {
  assert(vpnErrorFromTag(0) == Some(AuthenticationFailed))
  assert(vpnErrorFromTag(1) == Some(NoProposalChosen))
  assert(vpnErrorFromTag(2) == Some(LifetimeExpired))
  assert(vpnErrorFromTag(3) == Some(InvalidSpi))
  assert(vpnErrorFromTag(4) == Some(ReplayDetected))
  assert(vpnErrorFromTag(5) == Some(NegotiationTimeout))
  assert(vpnErrorFromTag(6) == None)
}

let test_vpnError_toTag = () => {
  assert(vpnErrorToTag(AuthenticationFailed) == 0)
  assert(vpnErrorToTag(NoProposalChosen) == 1)
  assert(vpnErrorToTag(LifetimeExpired) == 2)
  assert(vpnErrorToTag(InvalidSpi) == 3)
  assert(vpnErrorToTag(ReplayDetected) == 4)
  assert(vpnErrorToTag(NegotiationTimeout) == 5)
}

// Run all tests
test_tunnelType_roundtrip()
test_tunnelType_toTag()
test_tunnelPhase_roundtrip()
test_tunnelPhase_toTag()
test_encryptionAlgorithm_roundtrip()
test_encryptionAlgorithm_toTag()
test_integrityAlgorithm_roundtrip()
test_integrityAlgorithm_toTag()
test_dhGroup_roundtrip()
test_dhGroup_toTag()
test_saLifecycle_roundtrip()
test_saLifecycle_toTag()
test_ikeVersion_roundtrip()
test_ikeVersion_toTag()
test_vpnError_roundtrip()
test_vpnError_toTag()
