-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Backup Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Backup
  (
    BackupType(..)
  , backupTypeToTag
  , backupTypeFromTag
  , ScheduleFreq(..)
  , scheduleFreqToTag
  , scheduleFreqFromTag
  , CompressionAlg(..)
  , compressionAlgToTag
  , compressionAlgFromTag
  , EncryptionAlg(..)
  , encryptionAlgToTag
  , encryptionAlgFromTag
  , BackupState(..)
  , backupStateToTag
  , backupStateFromTag
  , RetentionPolicy(..)
  , retentionPolicyToTag
  , retentionPolicyFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- BackupType
-- ---------------------------------------------------------------------------

-- | Backup types.
--
-- Tags 0-4 (5 constructors).
data BackupType
  = Full  -- ^ Full (tag 0).
  | Incremental  -- ^ Incremental (tag 1).
  | Differential  -- ^ Differential (tag 2).
  | Snapshot  -- ^ Snapshot (tag 3).
  | Mirror  -- ^ Mirror (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BackupType' to its ABI tag value.
backupTypeToTag :: BackupType -> Word8
backupTypeToTag = fromIntegral . fromEnum

-- | Decode a 'BackupType' from its ABI tag value.
backupTypeFromTag :: Word8 -> Maybe BackupType
backupTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BackupType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ScheduleFreq
-- ---------------------------------------------------------------------------

-- | Backup schedule frequencies.
--
-- Tags 0-4 (5 constructors).
data ScheduleFreq
  = Hourly  -- ^ Hourly (tag 0).
  | Daily  -- ^ Daily (tag 1).
  | Weekly  -- ^ Weekly (tag 2).
  | Monthly  -- ^ Monthly (tag 3).
  | OnDemand  -- ^ OnDemand (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ScheduleFreq' to its ABI tag value.
scheduleFreqToTag :: ScheduleFreq -> Word8
scheduleFreqToTag = fromIntegral . fromEnum

-- | Decode a 'ScheduleFreq' from its ABI tag value.
scheduleFreqFromTag :: Word8 -> Maybe ScheduleFreq
scheduleFreqFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ScheduleFreq)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CompressionAlg
-- ---------------------------------------------------------------------------

-- | Backup compression algorithms.
--
-- Tags 0-4 (5 constructors).
data CompressionAlg
  = None  -- ^ None (tag 0).
  | Gzip  -- ^ Gzip (tag 1).
  | Zstd  -- ^ Zstd (tag 2).
  | Lz4  -- ^ LZ4 (tag 3).
  | Xz  -- ^ XZ (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CompressionAlg' to its ABI tag value.
compressionAlgToTag :: CompressionAlg -> Word8
compressionAlgToTag = fromIntegral . fromEnum

-- | Decode a 'CompressionAlg' from its ABI tag value.
compressionAlgFromTag :: Word8 -> Maybe CompressionAlg
compressionAlgFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CompressionAlg)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EncryptionAlg
-- ---------------------------------------------------------------------------

-- | Backup encryption algorithms.
--
-- Tags 0-2 (3 constructors).
data EncryptionAlg
  = NoEncryption  -- ^ NoEncryption (tag 0).
  | Aes256Gcm  -- ^ AES-256-GCM (tag 1).
  | ChaCha20Poly1305  -- ^ ChaCha20Poly1305 (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncryptionAlg' to its ABI tag value.
encryptionAlgToTag :: EncryptionAlg -> Word8
encryptionAlgToTag = fromIntegral . fromEnum

-- | Decode a 'EncryptionAlg' from its ABI tag value.
encryptionAlgFromTag :: Word8 -> Maybe EncryptionAlg
encryptionAlgFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncryptionAlg)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BackupState
-- ---------------------------------------------------------------------------

-- | Backup job states.
--
-- Tags 0-5 (6 constructors).
data BackupState
  = Idle  -- ^ Idle (tag 0).
  | Running  -- ^ Running (tag 1).
  | Verifying  -- ^ Verifying (tag 2).
  | Complete  -- ^ Complete (tag 3).
  | Failed  -- ^ Failed (tag 4).
  | Cancelled  -- ^ Cancelled (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BackupState' to its ABI tag value.
backupStateToTag :: BackupState -> Word8
backupStateToTag = fromIntegral . fromEnum

-- | Decode a 'BackupState' from its ABI tag value.
backupStateFromTag :: Word8 -> Maybe BackupState
backupStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BackupState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RetentionPolicy
-- ---------------------------------------------------------------------------

-- | Backup retention policies.
--
-- Tags 0-4 (5 constructors).
data RetentionPolicy
  = KeepAll  -- ^ KeepAll (tag 0).
  | KeepLast  -- ^ KeepLast (tag 1).
  | KeepDaily  -- ^ KeepDaily (tag 2).
  | KeepWeekly  -- ^ KeepWeekly (tag 3).
  | KeepMonthly  -- ^ KeepMonthly (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RetentionPolicy' to its ABI tag value.
retentionPolicyToTag :: RetentionPolicy -> Word8
retentionPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'RetentionPolicy' from its ABI tag value.
retentionPolicyFromTag :: Word8 -> Maybe RetentionPolicy
retentionPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RetentionPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
