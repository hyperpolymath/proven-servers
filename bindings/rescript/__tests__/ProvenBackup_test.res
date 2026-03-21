// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenBackup protocol bindings.

open ProvenBackup

let test_backupType_roundtrip = () => {
  assert(backupTypeFromTag(0) == Some(Full))
  assert(backupTypeFromTag(1) == Some(Incremental))
  assert(backupTypeFromTag(2) == Some(Differential))
  assert(backupTypeFromTag(3) == Some(Snapshot))
  assert(backupTypeFromTag(4) == Some(Mirror))
  assert(backupTypeFromTag(5) == None)
}

let test_backupType_toTag = () => {
  assert(backupTypeToTag(Full) == 0)
  assert(backupTypeToTag(Incremental) == 1)
  assert(backupTypeToTag(Differential) == 2)
  assert(backupTypeToTag(Snapshot) == 3)
  assert(backupTypeToTag(Mirror) == 4)
}

let test_scheduleFreq_roundtrip = () => {
  assert(scheduleFreqFromTag(0) == Some(Hourly))
  assert(scheduleFreqFromTag(1) == Some(Daily))
  assert(scheduleFreqFromTag(2) == Some(Weekly))
  assert(scheduleFreqFromTag(3) == Some(Monthly))
  assert(scheduleFreqFromTag(4) == Some(OnDemand))
  assert(scheduleFreqFromTag(5) == None)
}

let test_scheduleFreq_toTag = () => {
  assert(scheduleFreqToTag(Hourly) == 0)
  assert(scheduleFreqToTag(Daily) == 1)
  assert(scheduleFreqToTag(Weekly) == 2)
  assert(scheduleFreqToTag(Monthly) == 3)
  assert(scheduleFreqToTag(OnDemand) == 4)
}

let test_compressionAlg_roundtrip = () => {
  assert(compressionAlgFromTag(0) == Some(None))
  assert(compressionAlgFromTag(1) == Some(Gzip))
  assert(compressionAlgFromTag(2) == Some(Zstd))
  assert(compressionAlgFromTag(3) == Some(Lz4))
  assert(compressionAlgFromTag(4) == Some(Xz))
  assert(compressionAlgFromTag(5) == None)
}

let test_compressionAlg_toTag = () => {
  assert(compressionAlgToTag(None) == 0)
  assert(compressionAlgToTag(Gzip) == 1)
  assert(compressionAlgToTag(Zstd) == 2)
  assert(compressionAlgToTag(Lz4) == 3)
  assert(compressionAlgToTag(Xz) == 4)
}

let test_encryptionAlg_roundtrip = () => {
  assert(encryptionAlgFromTag(0) == Some(NoEncryption))
  assert(encryptionAlgFromTag(1) == Some(Aes256Gcm))
  assert(encryptionAlgFromTag(2) == Some(ChaCha20Poly1305))
  assert(encryptionAlgFromTag(3) == None)
}

let test_encryptionAlg_toTag = () => {
  assert(encryptionAlgToTag(NoEncryption) == 0)
  assert(encryptionAlgToTag(Aes256Gcm) == 1)
  assert(encryptionAlgToTag(ChaCha20Poly1305) == 2)
}

let test_backupState_roundtrip = () => {
  assert(backupStateFromTag(0) == Some(Idle))
  assert(backupStateFromTag(1) == Some(Running))
  assert(backupStateFromTag(2) == Some(Verifying))
  assert(backupStateFromTag(3) == Some(Complete))
  assert(backupStateFromTag(4) == Some(Failed))
  assert(backupStateFromTag(5) == Some(Cancelled))
  assert(backupStateFromTag(6) == None)
}

let test_backupState_toTag = () => {
  assert(backupStateToTag(Idle) == 0)
  assert(backupStateToTag(Running) == 1)
  assert(backupStateToTag(Verifying) == 2)
  assert(backupStateToTag(Complete) == 3)
  assert(backupStateToTag(Failed) == 4)
  assert(backupStateToTag(Cancelled) == 5)
}

let test_retentionPolicy_roundtrip = () => {
  assert(retentionPolicyFromTag(0) == Some(KeepAll))
  assert(retentionPolicyFromTag(1) == Some(KeepLast))
  assert(retentionPolicyFromTag(2) == Some(KeepDaily))
  assert(retentionPolicyFromTag(3) == Some(KeepWeekly))
  assert(retentionPolicyFromTag(4) == Some(KeepMonthly))
  assert(retentionPolicyFromTag(5) == None)
}

let test_retentionPolicy_toTag = () => {
  assert(retentionPolicyToTag(KeepAll) == 0)
  assert(retentionPolicyToTag(KeepLast) == 1)
  assert(retentionPolicyToTag(KeepDaily) == 2)
  assert(retentionPolicyToTag(KeepWeekly) == 3)
  assert(retentionPolicyToTag(KeepMonthly) == 4)
}

// Run all tests
test_backupType_roundtrip()
test_backupType_toTag()
test_scheduleFreq_roundtrip()
test_scheduleFreq_toTag()
test_compressionAlg_roundtrip()
test_compressionAlg_toTag()
test_encryptionAlg_roundtrip()
test_encryptionAlg_toTag()
test_backupState_roundtrip()
test_backupState_toTag()
test_retentionPolicy_roundtrip()
test_retentionPolicy_toTag()
