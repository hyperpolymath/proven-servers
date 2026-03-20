-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BackupABI.Types: C-ABI-compatible numeric representations of Backup types.
--
-- Maps every constructor of the core Backup sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/backup.h) and the
-- Zig FFI enums (ffi/zig/src/backup.zig) exactly.
--
-- Types covered:
--   BackupType      (5 constructors, tags 0-4)
--   ScheduleFreq    (5 constructors, tags 0-4)
--   CompressionAlg  (5 constructors, tags 0-4)
--   EncryptionAlg   (3 constructors, tags 0-2)
--   BackupState     (6 constructors, tags 0-5)
--   RetentionPolicy (5 constructors, tags 0-4)

module BackupABI.Types

import Backup.Types

%default total

---------------------------------------------------------------------------
-- BackupType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
backupTypeSize : Nat
backupTypeSize = 1

||| Encode a BackupType to its ABI tag value.
public export
backupTypeToTag : BackupType -> Bits8
backupTypeToTag Full         = 0
backupTypeToTag Incremental  = 1
backupTypeToTag Differential = 2
backupTypeToTag Snapshot     = 3
backupTypeToTag Mirror       = 4

||| Decode an ABI tag to a BackupType.
public export
tagToBackupType : Bits8 -> Maybe BackupType
tagToBackupType 0 = Just Full
tagToBackupType 1 = Just Incremental
tagToBackupType 2 = Just Differential
tagToBackupType 3 = Just Snapshot
tagToBackupType 4 = Just Mirror
tagToBackupType _ = Nothing

||| Roundtrip proof: decoding an encoded BackupType yields the original.
public export
backupTypeRoundtrip : (b : BackupType) -> tagToBackupType (backupTypeToTag b) = Just b
backupTypeRoundtrip Full         = Refl
backupTypeRoundtrip Incremental  = Refl
backupTypeRoundtrip Differential = Refl
backupTypeRoundtrip Snapshot     = Refl
backupTypeRoundtrip Mirror       = Refl

---------------------------------------------------------------------------
-- ScheduleFreq (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
scheduleFreqSize : Nat
scheduleFreqSize = 1

||| Encode a ScheduleFreq to its ABI tag value.
public export
scheduleFreqToTag : ScheduleFreq -> Bits8
scheduleFreqToTag Hourly   = 0
scheduleFreqToTag Daily    = 1
scheduleFreqToTag Weekly   = 2
scheduleFreqToTag Monthly  = 3
scheduleFreqToTag OnDemand = 4

||| Decode an ABI tag to a ScheduleFreq.
public export
tagToScheduleFreq : Bits8 -> Maybe ScheduleFreq
tagToScheduleFreq 0 = Just Hourly
tagToScheduleFreq 1 = Just Daily
tagToScheduleFreq 2 = Just Weekly
tagToScheduleFreq 3 = Just Monthly
tagToScheduleFreq 4 = Just OnDemand
tagToScheduleFreq _ = Nothing

||| Roundtrip proof: decoding an encoded ScheduleFreq yields the original.
public export
scheduleFreqRoundtrip : (f : ScheduleFreq) -> tagToScheduleFreq (scheduleFreqToTag f) = Just f
scheduleFreqRoundtrip Hourly   = Refl
scheduleFreqRoundtrip Daily    = Refl
scheduleFreqRoundtrip Weekly   = Refl
scheduleFreqRoundtrip Monthly  = Refl
scheduleFreqRoundtrip OnDemand = Refl

---------------------------------------------------------------------------
-- CompressionAlg (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
compressionAlgSize : Nat
compressionAlgSize = 1

||| Encode a CompressionAlg to its ABI tag value.
public export
compressionAlgToTag : CompressionAlg -> Bits8
compressionAlgToTag None = 0
compressionAlgToTag Gzip = 1
compressionAlgToTag Zstd = 2
compressionAlgToTag LZ4  = 3
compressionAlgToTag XZ   = 4

||| Decode an ABI tag to a CompressionAlg.
public export
tagToCompressionAlg : Bits8 -> Maybe CompressionAlg
tagToCompressionAlg 0 = Just None
tagToCompressionAlg 1 = Just Gzip
tagToCompressionAlg 2 = Just Zstd
tagToCompressionAlg 3 = Just LZ4
tagToCompressionAlg 4 = Just XZ
tagToCompressionAlg _ = Nothing

||| Roundtrip proof: decoding an encoded CompressionAlg yields the original.
public export
compressionAlgRoundtrip : (c : CompressionAlg) -> tagToCompressionAlg (compressionAlgToTag c) = Just c
compressionAlgRoundtrip None = Refl
compressionAlgRoundtrip Gzip = Refl
compressionAlgRoundtrip Zstd = Refl
compressionAlgRoundtrip LZ4  = Refl
compressionAlgRoundtrip XZ   = Refl

---------------------------------------------------------------------------
-- EncryptionAlg (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
encryptionAlgSize : Nat
encryptionAlgSize = 1

||| Encode an EncryptionAlg to its ABI tag value.
public export
encryptionAlgToTag : EncryptionAlg -> Bits8
encryptionAlgToTag NoEncryption     = 0
encryptionAlgToTag AES256GCM        = 1
encryptionAlgToTag ChaCha20Poly1305 = 2

||| Decode an ABI tag to an EncryptionAlg.
public export
tagToEncryptionAlg : Bits8 -> Maybe EncryptionAlg
tagToEncryptionAlg 0 = Just NoEncryption
tagToEncryptionAlg 1 = Just AES256GCM
tagToEncryptionAlg 2 = Just ChaCha20Poly1305
tagToEncryptionAlg _ = Nothing

||| Roundtrip proof: decoding an encoded EncryptionAlg yields the original.
public export
encryptionAlgRoundtrip : (e : EncryptionAlg) -> tagToEncryptionAlg (encryptionAlgToTag e) = Just e
encryptionAlgRoundtrip NoEncryption     = Refl
encryptionAlgRoundtrip AES256GCM        = Refl
encryptionAlgRoundtrip ChaCha20Poly1305 = Refl

---------------------------------------------------------------------------
-- BackupState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
backupStateSize : Nat
backupStateSize = 1

||| Encode a BackupState to its ABI tag value.
public export
backupStateToTag : BackupState -> Bits8
backupStateToTag Idle      = 0
backupStateToTag Running   = 1
backupStateToTag Verifying = 2
backupStateToTag Complete  = 3
backupStateToTag Failed    = 4
backupStateToTag Cancelled = 5

||| Decode an ABI tag to a BackupState.
public export
tagToBackupState : Bits8 -> Maybe BackupState
tagToBackupState 0 = Just Idle
tagToBackupState 1 = Just Running
tagToBackupState 2 = Just Verifying
tagToBackupState 3 = Just Complete
tagToBackupState 4 = Just Failed
tagToBackupState 5 = Just Cancelled
tagToBackupState _ = Nothing

||| Roundtrip proof: decoding an encoded BackupState yields the original.
public export
backupStateRoundtrip : (s : BackupState) -> tagToBackupState (backupStateToTag s) = Just s
backupStateRoundtrip Idle      = Refl
backupStateRoundtrip Running   = Refl
backupStateRoundtrip Verifying = Refl
backupStateRoundtrip Complete  = Refl
backupStateRoundtrip Failed    = Refl
backupStateRoundtrip Cancelled = Refl

---------------------------------------------------------------------------
-- RetentionPolicy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
retentionPolicySize : Nat
retentionPolicySize = 1

||| Encode a RetentionPolicy to its ABI tag value.
public export
retentionPolicyToTag : RetentionPolicy -> Bits8
retentionPolicyToTag KeepAll     = 0
retentionPolicyToTag KeepLast    = 1
retentionPolicyToTag KeepDaily   = 2
retentionPolicyToTag KeepWeekly  = 3
retentionPolicyToTag KeepMonthly = 4

||| Decode an ABI tag to a RetentionPolicy.
public export
tagToRetentionPolicy : Bits8 -> Maybe RetentionPolicy
tagToRetentionPolicy 0 = Just KeepAll
tagToRetentionPolicy 1 = Just KeepLast
tagToRetentionPolicy 2 = Just KeepDaily
tagToRetentionPolicy 3 = Just KeepWeekly
tagToRetentionPolicy 4 = Just KeepMonthly
tagToRetentionPolicy _ = Nothing

||| Roundtrip proof: decoding an encoded RetentionPolicy yields the original.
public export
retentionPolicyRoundtrip : (p : RetentionPolicy) -> tagToRetentionPolicy (retentionPolicyToTag p) = Just p
retentionPolicyRoundtrip KeepAll     = Refl
retentionPolicyRoundtrip KeepLast    = Refl
retentionPolicyRoundtrip KeepDaily   = Refl
retentionPolicyRoundtrip KeepWeekly  = Refl
retentionPolicyRoundtrip KeepMonthly = Refl
