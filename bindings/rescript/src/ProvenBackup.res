// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module BackupABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// BackupType (tags 0-4)
// ===========================================================================

/// Backup types.
type backupType =
  | @as(0) Full
  | @as(1) Incremental
  | @as(2) Differential
  | @as(3) Snapshot
  | @as(4) Mirror

/// Decode from the C-ABI tag value.
let backupTypeFromTag = (tag: int): option<backupType> =>
  switch tag {
  | 0 => Some(Full)
  | 1 => Some(Incremental)
  | 2 => Some(Differential)
  | 3 => Some(Snapshot)
  | 4 => Some(Mirror)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let backupTypeToTag = (v: backupType): int =>
  switch v {
  | Full => 0
  | Incremental => 1
  | Differential => 2
  | Snapshot => 3
  | Mirror => 4
  }

// ===========================================================================
// ScheduleFreq (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type scheduleFreq =
  | @as(0) Hourly
  | @as(1) Daily
  | @as(2) Weekly
  | @as(3) Monthly
  | @as(4) OnDemand

/// Decode from the C-ABI tag value.
let scheduleFreqFromTag = (tag: int): option<scheduleFreq> =>
  switch tag {
  | 0 => Some(Hourly)
  | 1 => Some(Daily)
  | 2 => Some(Weekly)
  | 3 => Some(Monthly)
  | 4 => Some(OnDemand)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let scheduleFreqToTag = (v: scheduleFreq): int =>
  switch v {
  | Hourly => 0
  | Daily => 1
  | Weekly => 2
  | Monthly => 3
  | OnDemand => 4
  }

// ===========================================================================
// CompressionAlg (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type compressionAlg =
  | @as(0) None
  | @as(1) Gzip
  | @as(2) Zstd
  | @as(3) Lz4
  | @as(4) Xz

/// Decode from the C-ABI tag value.
let compressionAlgFromTag = (tag: int): option<compressionAlg> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(Gzip)
  | 2 => Some(Zstd)
  | 3 => Some(Lz4)
  | 4 => Some(Xz)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let compressionAlgToTag = (v: compressionAlg): int =>
  switch v {
  | None => 0
  | Gzip => 1
  | Zstd => 2
  | Lz4 => 3
  | Xz => 4
  }

// ===========================================================================
// EncryptionAlg (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type encryptionAlg =
  | @as(0) NoEncryption
  | @as(1) Aes256Gcm
  | @as(2) ChaCha20Poly1305

/// Decode from the C-ABI tag value.
let encryptionAlgFromTag = (tag: int): option<encryptionAlg> =>
  switch tag {
  | 0 => Some(NoEncryption)
  | 1 => Some(Aes256Gcm)
  | 2 => Some(ChaCha20Poly1305)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let encryptionAlgToTag = (v: encryptionAlg): int =>
  switch v {
  | NoEncryption => 0
  | Aes256Gcm => 1
  | ChaCha20Poly1305 => 2
  }

// ===========================================================================
// BackupState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type backupState =
  | @as(0) Idle
  | @as(1) Running
  | @as(2) Verifying
  | @as(3) Complete
  | @as(4) Failed
  | @as(5) Cancelled

/// Decode from the C-ABI tag value.
let backupStateFromTag = (tag: int): option<backupState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Running)
  | 2 => Some(Verifying)
  | 3 => Some(Complete)
  | 4 => Some(Failed)
  | 5 => Some(Cancelled)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let backupStateToTag = (v: backupState): int =>
  switch v {
  | Idle => 0
  | Running => 1
  | Verifying => 2
  | Complete => 3
  | Failed => 4
  | Cancelled => 5
  }

// ===========================================================================
// RetentionPolicy (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type retentionPolicy =
  | @as(0) KeepAll
  | @as(1) KeepLast
  | @as(2) KeepDaily
  | @as(3) KeepWeekly
  | @as(4) KeepMonthly

/// Decode from the C-ABI tag value.
let retentionPolicyFromTag = (tag: int): option<retentionPolicy> =>
  switch tag {
  | 0 => Some(KeepAll)
  | 1 => Some(KeepLast)
  | 2 => Some(KeepDaily)
  | 3 => Some(KeepWeekly)
  | 4 => Some(KeepMonthly)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let retentionPolicyToTag = (v: retentionPolicy): int =>
  switch v {
  | KeepAll => 0
  | KeepLast => 1
  | KeepDaily => 2
  | KeepWeekly => 3
  | KeepMonthly => 4
  }

