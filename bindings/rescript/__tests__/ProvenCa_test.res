// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCa protocol bindings.

open ProvenCa

let test_certType_roundtrip = () => {
  assert(certTypeFromTag(0) == Some(Root))
  assert(certTypeFromTag(1) == Some(Intermediate))
  assert(certTypeFromTag(2) == Some(EndEntity))
  assert(certTypeFromTag(3) == Some(CrossSigned))
  assert(certTypeFromTag(4) == Some(CodeSigning))
  assert(certTypeFromTag(5) == Some(EmailProtection))
  assert(certTypeFromTag(6) == Some(OcspSigning))
  assert(certTypeFromTag(7) == None)
}

let test_certType_toTag = () => {
  assert(certTypeToTag(Root) == 0)
  assert(certTypeToTag(Intermediate) == 1)
  assert(certTypeToTag(EndEntity) == 2)
  assert(certTypeToTag(CrossSigned) == 3)
  assert(certTypeToTag(CodeSigning) == 4)
  assert(certTypeToTag(EmailProtection) == 5)
  assert(certTypeToTag(OcspSigning) == 6)
}

let test_keyAlgorithm_roundtrip = () => {
  assert(keyAlgorithmFromTag(0) == Some(Rsa2048))
  assert(keyAlgorithmFromTag(1) == Some(Rsa4096))
  assert(keyAlgorithmFromTag(2) == Some(EcdsaP256))
  assert(keyAlgorithmFromTag(3) == Some(EcdsaP384))
  assert(keyAlgorithmFromTag(4) == Some(Ed25519))
  assert(keyAlgorithmFromTag(5) == Some(Ed448))
  assert(keyAlgorithmFromTag(6) == None)
}

let test_keyAlgorithm_toTag = () => {
  assert(keyAlgorithmToTag(Rsa2048) == 0)
  assert(keyAlgorithmToTag(Rsa4096) == 1)
  assert(keyAlgorithmToTag(EcdsaP256) == 2)
  assert(keyAlgorithmToTag(EcdsaP384) == 3)
  assert(keyAlgorithmToTag(Ed25519) == 4)
  assert(keyAlgorithmToTag(Ed448) == 5)
}

let test_signatureAlgorithm_roundtrip = () => {
  assert(signatureAlgorithmFromTag(0) == Some(Sha256WithRsa))
  assert(signatureAlgorithmFromTag(1) == Some(Sha384WithRsa))
  assert(signatureAlgorithmFromTag(2) == Some(Sha512WithRsa))
  assert(signatureAlgorithmFromTag(3) == Some(Sha256WithEcdsa))
  assert(signatureAlgorithmFromTag(4) == Some(Sha384WithEcdsa))
  assert(signatureAlgorithmFromTag(5) == Some(PureEd25519))
  assert(signatureAlgorithmFromTag(6) == Some(PureEd448))
  assert(signatureAlgorithmFromTag(7) == None)
}

let test_signatureAlgorithm_toTag = () => {
  assert(signatureAlgorithmToTag(Sha256WithRsa) == 0)
  assert(signatureAlgorithmToTag(Sha384WithRsa) == 1)
  assert(signatureAlgorithmToTag(Sha512WithRsa) == 2)
  assert(signatureAlgorithmToTag(Sha256WithEcdsa) == 3)
  assert(signatureAlgorithmToTag(Sha384WithEcdsa) == 4)
  assert(signatureAlgorithmToTag(PureEd25519) == 5)
  assert(signatureAlgorithmToTag(PureEd448) == 6)
}

let test_certState_roundtrip = () => {
  assert(certStateFromTag(0) == Some(Pending))
  assert(certStateFromTag(1) == Some(Active))
  assert(certStateFromTag(2) == Some(Revoked))
  assert(certStateFromTag(3) == Some(Expired))
  assert(certStateFromTag(4) == Some(Suspended))
  assert(certStateFromTag(5) == None)
}

let test_certState_toTag = () => {
  assert(certStateToTag(Pending) == 0)
  assert(certStateToTag(Active) == 1)
  assert(certStateToTag(Revoked) == 2)
  assert(certStateToTag(Expired) == 3)
  assert(certStateToTag(Suspended) == 4)
}

let test_revocationReason_roundtrip = () => {
  assert(revocationReasonFromTag(0) == Some(Unspecified))
  assert(revocationReasonFromTag(1) == Some(KeyCompromise))
  assert(revocationReasonFromTag(2) == Some(CaCompromise))
  assert(revocationReasonFromTag(3) == Some(AffiliationChanged))
  assert(revocationReasonFromTag(4) == Some(Superseded))
  assert(revocationReasonFromTag(5) == Some(CessationOfOperation))
  assert(revocationReasonFromTag(6) == Some(CertificateHold))
  assert(revocationReasonFromTag(7) == None)
}

let test_revocationReason_toTag = () => {
  assert(revocationReasonToTag(Unspecified) == 0)
  assert(revocationReasonToTag(KeyCompromise) == 1)
  assert(revocationReasonToTag(CaCompromise) == 2)
  assert(revocationReasonToTag(AffiliationChanged) == 3)
  assert(revocationReasonToTag(Superseded) == 4)
  assert(revocationReasonToTag(CessationOfOperation) == 5)
  assert(revocationReasonToTag(CertificateHold) == 6)
}

let test_crlStatus_roundtrip = () => {
  assert(crlStatusFromTag(0) == Some(Current))
  assert(crlStatusFromTag(1) == Some(CrlExpired))
  assert(crlStatusFromTag(2) == Some(CrlPending))
  assert(crlStatusFromTag(3) == Some(CrlError))
  assert(crlStatusFromTag(4) == None)
}

let test_crlStatus_toTag = () => {
  assert(crlStatusToTag(Current) == 0)
  assert(crlStatusToTag(CrlExpired) == 1)
  assert(crlStatusToTag(CrlPending) == 2)
  assert(crlStatusToTag(CrlError) == 3)
}

let test_ocspStatus_roundtrip = () => {
  assert(ocspStatusFromTag(0) == Some(Good))
  assert(ocspStatusFromTag(1) == Some(OcspRevoked))
  assert(ocspStatusFromTag(2) == Some(Unknown))
  assert(ocspStatusFromTag(3) == Some(Unavailable))
  assert(ocspStatusFromTag(4) == None)
}

let test_ocspStatus_toTag = () => {
  assert(ocspStatusToTag(Good) == 0)
  assert(ocspStatusToTag(OcspRevoked) == 1)
  assert(ocspStatusToTag(Unknown) == 2)
  assert(ocspStatusToTag(Unavailable) == 3)
}

let test_extension_roundtrip = () => {
  assert(extensionFromTag(0) == Some(BasicConstraints))
  assert(extensionFromTag(1) == Some(KeyUsage))
  assert(extensionFromTag(2) == Some(ExtKeyUsage))
  assert(extensionFromTag(3) == Some(SubjectAltName))
  assert(extensionFromTag(4) == Some(AuthorityInfoAccess))
  assert(extensionFromTag(5) == Some(CrlDistributionPoints))
  assert(extensionFromTag(6) == None)
}

let test_extension_toTag = () => {
  assert(extensionToTag(BasicConstraints) == 0)
  assert(extensionToTag(KeyUsage) == 1)
  assert(extensionToTag(ExtKeyUsage) == 2)
  assert(extensionToTag(SubjectAltName) == 3)
  assert(extensionToTag(AuthorityInfoAccess) == 4)
  assert(extensionToTag(CrlDistributionPoints) == 5)
}

let test_keyUsageBit_roundtrip = () => {
  assert(keyUsageBitFromTag(0) == Some(DigitalSignature))
  assert(keyUsageBitFromTag(1) == Some(NonRepudiation))
  assert(keyUsageBitFromTag(2) == Some(KeyEncipherment))
  assert(keyUsageBitFromTag(3) == Some(DataEncipherment))
  assert(keyUsageBitFromTag(4) == Some(KeyAgreement))
  assert(keyUsageBitFromTag(5) == Some(KeyCertSign))
  assert(keyUsageBitFromTag(6) == Some(CrlSign))
  assert(keyUsageBitFromTag(7) == Some(EncipherOnly))
  assert(keyUsageBitFromTag(8) == Some(DecipherOnly))
  assert(keyUsageBitFromTag(9) == None)
}

let test_keyUsageBit_toTag = () => {
  assert(keyUsageBitToTag(DigitalSignature) == 0)
  assert(keyUsageBitToTag(NonRepudiation) == 1)
  assert(keyUsageBitToTag(KeyEncipherment) == 2)
  assert(keyUsageBitToTag(DataEncipherment) == 3)
  assert(keyUsageBitToTag(KeyAgreement) == 4)
  assert(keyUsageBitToTag(KeyCertSign) == 5)
  assert(keyUsageBitToTag(CrlSign) == 6)
  assert(keyUsageBitToTag(EncipherOnly) == 7)
  assert(keyUsageBitToTag(DecipherOnly) == 8)
}

// Run all tests
test_certType_roundtrip()
test_certType_toTag()
test_keyAlgorithm_roundtrip()
test_keyAlgorithm_toTag()
test_signatureAlgorithm_roundtrip()
test_signatureAlgorithm_toTag()
test_certState_roundtrip()
test_certState_toTag()
test_revocationReason_roundtrip()
test_revocationReason_toTag()
test_crlStatus_roundtrip()
test_crlStatus_toTag()
test_ocspStatus_roundtrip()
test_ocspStatus_toTag()
test_extension_roundtrip()
test_extension_toTag()
test_keyUsageBit_roundtrip()
test_keyUsageBit_toTag()
