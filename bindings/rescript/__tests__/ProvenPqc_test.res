// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenPqc protocol bindings.

open ProvenPqc

let test_pqcAlgorithm_roundtrip = () => {
  assert(pqcAlgorithmFromTag(0) == Some(CrystalsKyber))
  assert(pqcAlgorithmFromTag(1) == Some(CrystalsDilithium))
  assert(pqcAlgorithmFromTag(2) == Some(Falcon))
  assert(pqcAlgorithmFromTag(3) == Some(SphincsPlus))
  assert(pqcAlgorithmFromTag(4) == Some(ClassicMceliece))
  assert(pqcAlgorithmFromTag(5) == Some(Bike))
  assert(pqcAlgorithmFromTag(6) == Some(Hqc))
  assert(pqcAlgorithmFromTag(7) == Some(Frodokem))
  assert(pqcAlgorithmFromTag(8) == None)
}

let test_pqcAlgorithm_toTag = () => {
  assert(pqcAlgorithmToTag(CrystalsKyber) == 0)
  assert(pqcAlgorithmToTag(CrystalsDilithium) == 1)
  assert(pqcAlgorithmToTag(Falcon) == 2)
  assert(pqcAlgorithmToTag(SphincsPlus) == 3)
  assert(pqcAlgorithmToTag(ClassicMceliece) == 4)
  assert(pqcAlgorithmToTag(Bike) == 5)
  assert(pqcAlgorithmToTag(Hqc) == 6)
  assert(pqcAlgorithmToTag(Frodokem) == 7)
}

let test_nistLevel_roundtrip = () => {
  assert(nistLevelFromTag(0) == Some(Nist1))
  assert(nistLevelFromTag(1) == Some(Nist2))
  assert(nistLevelFromTag(2) == Some(Nist3))
  assert(nistLevelFromTag(3) == Some(Nist4))
  assert(nistLevelFromTag(4) == Some(Nist5))
  assert(nistLevelFromTag(5) == None)
}

let test_nistLevel_toTag = () => {
  assert(nistLevelToTag(Nist1) == 0)
  assert(nistLevelToTag(Nist2) == 1)
  assert(nistLevelToTag(Nist3) == 2)
  assert(nistLevelToTag(Nist4) == 3)
  assert(nistLevelToTag(Nist5) == 4)
}

let test_operation_roundtrip = () => {
  assert(operationFromTag(0) == Some(Keygen))
  assert(operationFromTag(1) == Some(Encapsulate))
  assert(operationFromTag(2) == Some(Decapsulate))
  assert(operationFromTag(3) == Some(Sign))
  assert(operationFromTag(4) == Some(Verify))
  assert(operationFromTag(5) == None)
}

let test_operation_toTag = () => {
  assert(operationToTag(Keygen) == 0)
  assert(operationToTag(Encapsulate) == 1)
  assert(operationToTag(Decapsulate) == 2)
  assert(operationToTag(Sign) == 3)
  assert(operationToTag(Verify) == 4)
}

let test_hybridMode_roundtrip = () => {
  assert(hybridModeFromTag(0) == Some(ClassicalOnly))
  assert(hybridModeFromTag(1) == Some(PqcOnly))
  assert(hybridModeFromTag(2) == Some(Hybrid))
  assert(hybridModeFromTag(3) == None)
}

let test_hybridMode_toTag = () => {
  assert(hybridModeToTag(ClassicalOnly) == 0)
  assert(hybridModeToTag(PqcOnly) == 1)
  assert(hybridModeToTag(Hybrid) == 2)
}

let test_algorithmCategory_roundtrip = () => {
  assert(algorithmCategoryFromTag(0) == Some(Kem))
  assert(algorithmCategoryFromTag(1) == Some(Signature))
  assert(algorithmCategoryFromTag(2) == None)
}

let test_algorithmCategory_toTag = () => {
  assert(algorithmCategoryToTag(Kem) == 0)
  assert(algorithmCategoryToTag(Signature) == 1)
}

let test_keyState_roundtrip = () => {
  assert(keyStateFromTag(0) == Some(Empty))
  assert(keyStateFromTag(1) == Some(Generating))
  assert(keyStateFromTag(2) == Some(Generated))
  assert(keyStateFromTag(3) == Some(Active))
  assert(keyStateFromTag(4) == Some(Expired))
  assert(keyStateFromTag(5) == Some(Compromised))
  assert(keyStateFromTag(6) == None)
}

let test_keyState_toTag = () => {
  assert(keyStateToTag(Empty) == 0)
  assert(keyStateToTag(Generating) == 1)
  assert(keyStateToTag(Generated) == 2)
  assert(keyStateToTag(Active) == 3)
  assert(keyStateToTag(Expired) == 4)
  assert(keyStateToTag(Compromised) == 5)
}

// Run all tests
test_pqcAlgorithm_roundtrip()
test_pqcAlgorithm_toTag()
test_nistLevel_roundtrip()
test_nistLevel_toTag()
test_operation_roundtrip()
test_operation_toTag()
test_hybridMode_roundtrip()
test_hybridMode_toTag()
test_algorithmCategory_roundtrip()
test_algorithmCategory_toTag()
test_keyState_roundtrip()
test_keyState_toTag()
