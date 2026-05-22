// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenKms protocol bindings.

open ProvenKms

let test_objectType_roundtrip = () => {
  assert(objectTypeFromTag(0) == Some(SymmetricKey))
  assert(objectTypeFromTag(1) == Some(PublicKey))
  assert(objectTypeFromTag(2) == Some(PrivateKey))
  assert(objectTypeFromTag(3) == Some(SecretData))
  assert(objectTypeFromTag(4) == Some(Certificate))
  assert(objectTypeFromTag(5) == Some(OpaqueData))
  assert(objectTypeFromTag(6) == None)
}

let test_objectType_toTag = () => {
  assert(objectTypeToTag(SymmetricKey) == 0)
  assert(objectTypeToTag(PublicKey) == 1)
  assert(objectTypeToTag(PrivateKey) == 2)
  assert(objectTypeToTag(SecretData) == 3)
  assert(objectTypeToTag(Certificate) == 4)
  assert(objectTypeToTag(OpaqueData) == 5)
}

let test_operation_roundtrip = () => {
  assert(operationFromTag(0) == Some(Create))
  assert(operationFromTag(1) == Some(Get))
  assert(operationFromTag(2) == Some(Activate))
  assert(operationFromTag(3) == Some(Revoke))
  assert(operationFromTag(4) == Some(Destroy))
  assert(operationFromTag(5) == Some(Locate))
  assert(operationFromTag(6) == Some(Register))
  assert(operationFromTag(7) == Some(Rekey))
  assert(operationFromTag(8) == Some(Encrypt))
  assert(operationFromTag(9) == Some(Decrypt))
  assert(operationFromTag(10) == Some(Sign))
  assert(operationFromTag(11) == Some(Verify))
  assert(operationFromTag(12) == Some(Wrap))
  assert(operationFromTag(13) == Some(Unwrap))
  assert(operationFromTag(14) == Some(Mac))
  assert(operationFromTag(15) == None)
}

let test_operation_toTag = () => {
  assert(operationToTag(Create) == 0)
  assert(operationToTag(Get) == 1)
  assert(operationToTag(Activate) == 2)
  assert(operationToTag(Revoke) == 3)
  assert(operationToTag(Destroy) == 4)
  assert(operationToTag(Locate) == 5)
  assert(operationToTag(Register) == 6)
  assert(operationToTag(Rekey) == 7)
  assert(operationToTag(Encrypt) == 8)
  assert(operationToTag(Decrypt) == 9)
  assert(operationToTag(Sign) == 10)
  assert(operationToTag(Verify) == 11)
  assert(operationToTag(Wrap) == 12)
  assert(operationToTag(Unwrap) == 13)
  assert(operationToTag(Mac) == 14)
}

let test_keyState_roundtrip = () => {
  assert(keyStateFromTag(0) == Some(PreActive))
  assert(keyStateFromTag(1) == Some(Active))
  assert(keyStateFromTag(2) == Some(Deactivated))
  assert(keyStateFromTag(3) == Some(Compromised))
  assert(keyStateFromTag(4) == Some(Destroyed))
  assert(keyStateFromTag(5) == Some(DestroyedCompromised))
  assert(keyStateFromTag(6) == None)
}

let test_keyState_toTag = () => {
  assert(keyStateToTag(PreActive) == 0)
  assert(keyStateToTag(Active) == 1)
  assert(keyStateToTag(Deactivated) == 2)
  assert(keyStateToTag(Compromised) == 3)
  assert(keyStateToTag(Destroyed) == 4)
  assert(keyStateToTag(DestroyedCompromised) == 5)
}

let test_kmsAlgorithm_roundtrip = () => {
  assert(kmsAlgorithmFromTag(0) == Some(Aes128))
  assert(kmsAlgorithmFromTag(1) == Some(Aes256))
  assert(kmsAlgorithmFromTag(2) == Some(Rsa2048))
  assert(kmsAlgorithmFromTag(3) == Some(Rsa4096))
  assert(kmsAlgorithmFromTag(4) == Some(EcdsaP256))
  assert(kmsAlgorithmFromTag(5) == Some(EcdsaP384))
  assert(kmsAlgorithmFromTag(6) == Some(Ed25519))
  assert(kmsAlgorithmFromTag(7) == Some(Chacha20Poly1305))
  assert(kmsAlgorithmFromTag(8) == Some(HmacSha256))
  assert(kmsAlgorithmFromTag(9) == None)
}

let test_kmsAlgorithm_toTag = () => {
  assert(kmsAlgorithmToTag(Aes128) == 0)
  assert(kmsAlgorithmToTag(Aes256) == 1)
  assert(kmsAlgorithmToTag(Rsa2048) == 2)
  assert(kmsAlgorithmToTag(Rsa4096) == 3)
  assert(kmsAlgorithmToTag(EcdsaP256) == 4)
  assert(kmsAlgorithmToTag(EcdsaP384) == 5)
  assert(kmsAlgorithmToTag(Ed25519) == 6)
  assert(kmsAlgorithmToTag(Chacha20Poly1305) == 7)
  assert(kmsAlgorithmToTag(HmacSha256) == 8)
}

// Run all tests
test_objectType_roundtrip()
test_objectType_toTag()
test_operation_roundtrip()
test_operation_toTag()
test_keyState_roundtrip()
test_keyState_toTag()
test_kmsAlgorithm_roundtrip()
test_kmsAlgorithm_toTag()
