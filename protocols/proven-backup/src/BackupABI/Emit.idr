-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BackupABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into backup_abi_gen.zig for the comptime guard.

module BackupABI.Emit

import Backup.Types
import BackupABI.Types
import BackupABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "TYPE" "FULL"         (backupTypeToTag Full)
  , line "TYPE" "INCREMENTAL"  (backupTypeToTag Incremental)
  , line "TYPE" "DIFFERENTIAL" (backupTypeToTag Differential)
  , line "TYPE" "SNAPSHOT"     (backupTypeToTag Snapshot)
  , line "TYPE" "MIRROR"       (backupTypeToTag Mirror)
  , line "FREQ" "HOURLY"    (scheduleFreqToTag Hourly)
  , line "FREQ" "DAILY"     (scheduleFreqToTag Daily)
  , line "FREQ" "WEEKLY"    (scheduleFreqToTag Weekly)
  , line "FREQ" "MONTHLY"   (scheduleFreqToTag Monthly)
  , line "FREQ" "ON_DEMAND" (scheduleFreqToTag OnDemand)
  , line "COMP" "NONE" (compressionAlgToTag None)
  , line "COMP" "GZIP" (compressionAlgToTag Gzip)
  , line "COMP" "ZSTD" (compressionAlgToTag Zstd)
  , line "COMP" "LZ4"  (compressionAlgToTag LZ4)
  , line "COMP" "XZ"   (compressionAlgToTag XZ)
  , line "ENC" "NO_ENCRYPTION"   (encryptionAlgToTag NoEncryption)
  , line "ENC" "AES256GCM"       (encryptionAlgToTag AES256GCM)
  , line "ENC" "CHACHA20POLY1305" (encryptionAlgToTag ChaCha20Poly1305)
  , line "STATE" "IDLE"      (backupStateToTag Idle)
  , line "STATE" "RUNNING"   (backupStateToTag Running)
  , line "STATE" "VERIFYING" (backupStateToTag Verifying)
  , line "STATE" "COMPLETE"  (backupStateToTag Complete)
  , line "STATE" "FAILED"    (backupStateToTag Failed)
  , line "STATE" "CANCELLED" (backupStateToTag Cancelled)
  , line "RET" "KEEP_ALL"     (retentionPolicyToTag KeepAll)
  , line "RET" "KEEP_LAST"    (retentionPolicyToTag KeepLast)
  , line "RET" "KEEP_DAILY"   (retentionPolicyToTag KeepDaily)
  , line "RET" "KEEP_WEEKLY"  (retentionPolicyToTag KeepWeekly)
  , line "RET" "KEEP_MONTHLY" (retentionPolicyToTag KeepMonthly)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
