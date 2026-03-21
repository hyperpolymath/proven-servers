//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Backup protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `BackupABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// BackupType
// ===========================================================================

/// Backup types.
/// 
/// Matches `BackupType` in `BackupABI.Types`.
pub type BackupType {
  /// Full (tag 0).
  Full
  /// Incremental (tag 1).
  Incremental
  /// Differential (tag 2).
  Differential
  /// Snapshot (tag 3).
  Snapshot
  /// Mirror (tag 4).
  Mirror
}

/// Convert a `BackupType` to its C-ABI tag value.
pub fn backup_type_to_int(value: BackupType) -> Int {
  case value {
    Full -> 0
    Incremental -> 1
    Differential -> 2
    Snapshot -> 3
    Mirror -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn backup_type_from_int(tag: Int) -> Result(BackupType, Nil) {
  case tag {
    0 -> Ok(Full)
    1 -> Ok(Incremental)
    2 -> Ok(Differential)
    3 -> Ok(Snapshot)
    4 -> Ok(Mirror)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ScheduleFreq
// ===========================================================================

/// Backup schedule frequencies.
/// 
/// Matches `ScheduleFreq` in `BackupABI.Types`.
pub type ScheduleFreq {
  /// Hourly (tag 0).
  Hourly
  /// Daily (tag 1).
  Daily
  /// Weekly (tag 2).
  Weekly
  /// Monthly (tag 3).
  Monthly
  /// OnDemand (tag 4).
  OnDemand
}

/// Convert a `ScheduleFreq` to its C-ABI tag value.
pub fn schedule_freq_to_int(value: ScheduleFreq) -> Int {
  case value {
    Hourly -> 0
    Daily -> 1
    Weekly -> 2
    Monthly -> 3
    OnDemand -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn schedule_freq_from_int(tag: Int) -> Result(ScheduleFreq, Nil) {
  case tag {
    0 -> Ok(Hourly)
    1 -> Ok(Daily)
    2 -> Ok(Weekly)
    3 -> Ok(Monthly)
    4 -> Ok(OnDemand)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CompressionAlg
// ===========================================================================

/// Backup compression algorithms.
/// 
/// Matches `CompressionAlg` in `BackupABI.Types`.
pub type CompressionAlg {
  /// None (tag 0).
  CompressionAlgNone
  /// Gzip (tag 1).
  Gzip
  /// Zstd (tag 2).
  Zstd
  /// LZ4 (tag 3).
  Lz4
  /// XZ (tag 4).
  Xz
}

/// Convert a `CompressionAlg` to its C-ABI tag value.
pub fn compression_alg_to_int(value: CompressionAlg) -> Int {
  case value {
    CompressionAlgNone -> 0
    Gzip -> 1
    Zstd -> 2
    Lz4 -> 3
    Xz -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn compression_alg_from_int(tag: Int) -> Result(CompressionAlg, Nil) {
  case tag {
    0 -> Ok(CompressionAlgNone)
    1 -> Ok(Gzip)
    2 -> Ok(Zstd)
    3 -> Ok(Lz4)
    4 -> Ok(Xz)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EncryptionAlg
// ===========================================================================

/// Backup encryption algorithms.
/// 
/// Matches `EncryptionAlg` in `BackupABI.Types`.
pub type EncryptionAlg {
  /// NoEncryption (tag 0).
  NoEncryption
  /// AES-256-GCM (tag 1).
  Aes256Gcm
  /// ChaCha20Poly1305 (tag 2).
  ChaCha20Poly1305
}

/// Convert a `EncryptionAlg` to its C-ABI tag value.
pub fn encryption_alg_to_int(value: EncryptionAlg) -> Int {
  case value {
    NoEncryption -> 0
    Aes256Gcm -> 1
    ChaCha20Poly1305 -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn encryption_alg_from_int(tag: Int) -> Result(EncryptionAlg, Nil) {
  case tag {
    0 -> Ok(NoEncryption)
    1 -> Ok(Aes256Gcm)
    2 -> Ok(ChaCha20Poly1305)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// BackupState
// ===========================================================================

/// Backup job states.
/// 
/// Matches `BackupState` in `BackupABI.Types`.
pub type BackupState {
  /// Idle (tag 0).
  Idle
  /// Running (tag 1).
  Running
  /// Verifying (tag 2).
  Verifying
  /// Complete (tag 3).
  Complete
  /// Failed (tag 4).
  Failed
  /// Cancelled (tag 5).
  Cancelled
}

/// Convert a `BackupState` to its C-ABI tag value.
pub fn backup_state_to_int(value: BackupState) -> Int {
  case value {
    Idle -> 0
    Running -> 1
    Verifying -> 2
    Complete -> 3
    Failed -> 4
    Cancelled -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn backup_state_from_int(tag: Int) -> Result(BackupState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Running)
    2 -> Ok(Verifying)
    3 -> Ok(Complete)
    4 -> Ok(Failed)
    5 -> Ok(Cancelled)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RetentionPolicy
// ===========================================================================

/// Backup retention policies.
/// 
/// Matches `RetentionPolicy` in `BackupABI.Types`.
pub type RetentionPolicy {
  /// KeepAll (tag 0).
  KeepAll
  /// KeepLast (tag 1).
  KeepLast
  /// KeepDaily (tag 2).
  KeepDaily
  /// KeepWeekly (tag 3).
  KeepWeekly
  /// KeepMonthly (tag 4).
  KeepMonthly
}

/// Convert a `RetentionPolicy` to its C-ABI tag value.
pub fn retention_policy_to_int(value: RetentionPolicy) -> Int {
  case value {
    KeepAll -> 0
    KeepLast -> 1
    KeepDaily -> 2
    KeepWeekly -> 3
    KeepMonthly -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn retention_policy_from_int(tag: Int) -> Result(RetentionPolicy, Nil) {
  case tag {
    0 -> Ok(KeepAll)
    1 -> Ok(KeepLast)
    2 -> Ok(KeepDaily)
    3 -> Ok(KeepWeekly)
    4 -> Ok(KeepMonthly)
    _ -> Error(Nil)
  }
}

