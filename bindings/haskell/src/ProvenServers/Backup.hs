-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Backup protocol types for proven-servers.
--
-- Backup/restore server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Backup
  ( -- * ADT types matching Idris2 ABI
      BackupType(..)
    , ScheduleFreq(..)
    , CompressionAlg(..)
    , EncryptionAlg(..)
    , BackupState(..)
    , RetentionPolicy(..)
    , backupTypeToTag
    , backupTypeFromTag
    , scheduleFreqToTag
    , scheduleFreqFromTag
    , compressionAlgToTag
    , compressionAlgFromTag
    , encryptionAlgToTag
    , encryptionAlgFromTag
    , backupStateToTag
    , backupStateFromTag
    , retentionPolicyToTag
    , retentionPolicyFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- BackupType
-- ---------------------------------------------------------------------------

-- | BackupType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data BackupType
  = Full  -- ^ Tag 0.
  | Incremental  -- ^ Tag 1.
  | Differential  -- ^ Tag 2.
  | Snapshot  -- ^ Tag 3.
  | Mirror  -- ^ Tag 4.
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

-- | ScheduleFreq type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ScheduleFreq
  = Hourly  -- ^ Tag 0.
  | Daily  -- ^ Tag 1.
  | Weekly  -- ^ Tag 2.
  | Monthly  -- ^ Tag 3.
  | OnDemand  -- ^ Tag 4.
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

-- | CompressionAlg type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data CompressionAlg
  = None  -- ^ Tag 0.
  | Gzip  -- ^ Tag 1.
  | Zstd  -- ^ Tag 2.
  | Lz4  -- ^ Tag 3.
  | Xz  -- ^ Tag 4.
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

-- | EncryptionAlg type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data EncryptionAlg
  = NoEncryption  -- ^ Tag 0.
  | Aes256Gcm  -- ^ Tag 1.
  | ChaCha20Poly1305  -- ^ Tag 2.
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

-- | BackupState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data BackupState
  = Idle  -- ^ Tag 0.
  | Running  -- ^ Tag 1.
  | Verifying  -- ^ Tag 2.
  | Complete  -- ^ Tag 3.
  | Failed  -- ^ Tag 4.
  | Cancelled  -- ^ Tag 5.
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

-- | RetentionPolicy type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data RetentionPolicy
  = KeepAll  -- ^ Tag 0.
  | KeepLast  -- ^ Tag 1.
  | KeepDaily  -- ^ Tag 2.
  | KeepWeekly  -- ^ Tag 3.
  | KeepMonthly  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RetentionPolicy' to its ABI tag value.
retentionPolicyToTag :: RetentionPolicy -> Word8
retentionPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'RetentionPolicy' from its ABI tag value.
retentionPolicyFromTag :: Word8 -> Maybe RetentionPolicy
retentionPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RetentionPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
