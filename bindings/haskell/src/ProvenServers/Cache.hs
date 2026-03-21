-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Cache protocol types for proven-servers.
--
-- Cache (Redis/Memcached) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Cache
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , EvictionPolicy(..)
    , DataType(..)
    , ErrorCode(..)
    , ReplicationMode(..)
    , commandToTag
    , commandFromTag
    , evictionPolicyToTag
    , evictionPolicyFromTag
    , dataTypeToTag
    , dataTypeFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , replicationModeToTag
    , replicationModeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-12 (13 constructors).
data Command
  = Get  -- ^ Tag 0.
  | Set  -- ^ Tag 1.
  | Delete  -- ^ Tag 2.
  | Exists  -- ^ Tag 3.
  | Expire  -- ^ Tag 4.
  | Ttl  -- ^ Tag 5.
  | Keys  -- ^ Tag 6.
  | Flush  -- ^ Tag 7.
  | Incr  -- ^ Tag 8.
  | Decr  -- ^ Tag 9.
  | Append  -- ^ Tag 10.
  | Prepend  -- ^ Tag 11.
  | Cas  -- ^ Tag 12.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EvictionPolicy
-- ---------------------------------------------------------------------------

-- | EvictionPolicy type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data EvictionPolicy
  = Lru  -- ^ Tag 0.
  | Lfu  -- ^ Tag 1.
  | Random  -- ^ Tag 2.
  | EvictTtl  -- ^ Tag 3.
  | NoEviction  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EvictionPolicy' to its ABI tag value.
evictionPolicyToTag :: EvictionPolicy -> Word8
evictionPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'EvictionPolicy' from its ABI tag value.
evictionPolicyFromTag :: Word8 -> Maybe EvictionPolicy
evictionPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EvictionPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DataType
-- ---------------------------------------------------------------------------

-- | DataType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data DataType
  = StringVal  -- ^ Tag 0.
  | IntVal  -- ^ Tag 1.
  | ListVal  -- ^ Tag 2.
  | SetVal  -- ^ Tag 3.
  | HashVal  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DataType' to its ABI tag value.
dataTypeToTag :: DataType -> Word8
dataTypeToTag = fromIntegral . fromEnum

-- | Decode a 'DataType' from its ABI tag value.
dataTypeFromTag :: Word8 -> Maybe DataType
dataTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DataType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ErrorCode
  = NotFound  -- ^ Tag 0.
  | TypeMismatch  -- ^ Tag 1.
  | OutOfMemory  -- ^ Tag 2.
  | KeyTooLong  -- ^ Tag 3.
  | ValueTooLarge  -- ^ Tag 4.
  | CasConflict  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ReplicationMode
-- ---------------------------------------------------------------------------

-- | ReplicationMode type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ReplicationMode
  = None  -- ^ Tag 0.
  | Primary  -- ^ Tag 1.
  | Replica  -- ^ Tag 2.
  | Sentinel  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplicationMode' to its ABI tag value.
replicationModeToTag :: ReplicationMode -> Word8
replicationModeToTag = fromIntegral . fromEnum

-- | Decode a 'ReplicationMode' from its ABI tag value.
replicationModeFromTag :: Word8 -> Maybe ReplicationMode
replicationModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplicationMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
