-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Cache protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Cache
  (
    redisPort
  , memcachedPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , isWrite
  , isRead
  , EvictionPolicy(..)
  , evictionPolicyToTag
  , evictionPolicyFromTag
  , mayEvict
  , DataType(..)
  , dataTypeToTag
  , dataTypeFromTag
  , isCollection
  , isScalar
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , isTransient
  , isClientError
  , ReplicationMode(..)
  , replicationModeToTag
  , replicationModeFromTag
  , acceptsWrites
  , servesData
  ) where

import Data.Word (Word16, Word8)

-- | Standard Redis port.
redisPort :: Word16
redisPort = 6379

-- | Standard Memcached port.
memcachedPort :: Word16
memcachedPort = 11211

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard Redis port.
--
-- Tags 0-12 (13 constructors).
data Command
  = Get  -- ^ Retrieve a value by key (tag 0).
  | Set  -- ^ Store a key-value pair (tag 1).
  | Delete  -- ^ Remove a key (tag 2).
  | Exists  -- ^ Check if a key exists (tag 3).
  | Expire  -- ^ Set TTL on a key (tag 4).
  | Ttl  -- ^ Get remaining TTL for a key (tag 5).
  | Keys  -- ^ List keys matching a pattern (tag 6).
  | Flush  -- ^ Remove all keys (tag 7).
  | Incr  -- ^ Atomically increment a numeric value (tag 8).
  | Decr  -- ^ Atomically decrement a numeric value (tag 9).
  | Append  -- ^ Append data to a string value (tag 10).
  | Prepend  -- ^ Prepend data to a string value (tag 11).
  | Cas  -- ^ Compare-and-swap (optimistic locking) (tag 12).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command modifies stored data.
isWrite :: Command -> Bool
isWrite Get = False
isWrite Exists = False
isWrite Ttl = False
isWrite Keys = False
isWrite _ = True

-- | Whether this command is read-only.
isRead :: Command -> Bool
isRead Get = True
isRead Exists = True
isRead Ttl = True
isRead Keys = True
isRead _ = False

-- ---------------------------------------------------------------------------
-- EvictionPolicy
-- ---------------------------------------------------------------------------

-- | Cache eviction policy strategies.
--
-- Tags 0-4 (5 constructors).
data EvictionPolicy
  = Lru  -- ^ Least Recently Used (tag 0).
  | Lfu  -- ^ Least Frequently Used (tag 1).
  | Random  -- ^ Random eviction (tag 2).
  | EvictTtl  -- ^ Evict keys with expiry (TTL-based) (tag 3).
  | NoEviction  -- ^ No eviction — return errors when memory is full (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EvictionPolicy' to its ABI tag value.
evictionPolicyToTag :: EvictionPolicy -> Word8
evictionPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'EvictionPolicy' from its ABI tag value.
evictionPolicyFromTag :: Word8 -> Maybe EvictionPolicy
evictionPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EvictionPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this policy can cause data loss under memory pressure.
mayEvict :: EvictionPolicy -> Bool
mayEvict NoEviction = False
mayEvict _ = True

-- ---------------------------------------------------------------------------
-- DataType
-- ---------------------------------------------------------------------------

-- | Cache stored value types.
--
-- Tags 0-4 (5 constructors).
data DataType
  = StringVal  -- ^ String value (tag 0).
  | IntVal  -- ^ Integer value (tag 1).
  | ListVal  -- ^ List (ordered collection) (tag 2).
  | SetVal  -- ^ Set (unordered unique collection) (tag 3).
  | HashVal  -- ^ Hash map (field-value pairs) (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DataType' to its ABI tag value.
dataTypeToTag :: DataType -> Word8
dataTypeToTag = fromIntegral . fromEnum

-- | Decode a 'DataType' from its ABI tag value.
dataTypeFromTag :: Word8 -> Maybe DataType
dataTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DataType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this type is a collection (list, set, or hash).
isCollection :: DataType -> Bool
isCollection ListVal = True
isCollection SetVal = True
isCollection HashVal = True
isCollection _ = False

-- | Whether this type is a scalar (string or integer).
isScalar :: DataType -> Bool
isScalar StringVal = True
isScalar IntVal = True
isScalar _ = False

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | Cache error codes.
--
-- Tags 0-5 (6 constructors).
data ErrorCode
  = NotFound  -- ^ Key not found in cache (tag 0).
  | TypeMismatch  -- ^ Operation attempted on wrong data type (tag 1).
  | OutOfMemory  -- ^ Cache server is out of memory (tag 2).
  | KeyTooLong  -- ^ Key exceeds maximum length (tag 3).
  | ValueTooLarge  -- ^ Value exceeds maximum size (tag 4).
  | CasConflict  -- ^ Compare-and-swap version conflict (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error is transient (may succeed on retry).
isTransient :: ErrorCode -> Bool
isTransient OutOfMemory = True
isTransient CasConflict = True
isTransient _ = False

-- | Whether this error indicates a client programming error.
isClientError :: ErrorCode -> Bool
isClientError TypeMismatch = True
isClientError KeyTooLong = True
isClientError ValueTooLarge = True
isClientError _ = False

-- ---------------------------------------------------------------------------
-- ReplicationMode
-- ---------------------------------------------------------------------------

-- | Cache replication topology roles.
--
-- Tags 0-3 (4 constructors).
data ReplicationMode
  = None  -- ^ Standalone, no replication (tag 0).
  | Primary  -- ^ Primary (leader) node accepting writes (tag 1).
  | Replica  -- ^ Replica (follower) node serving reads (tag 2).
  | Sentinel  -- ^ Sentinel node monitoring cluster health (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReplicationMode' to its ABI tag value.
replicationModeToTag :: ReplicationMode -> Word8
replicationModeToTag = fromIntegral . fromEnum

-- | Decode a 'ReplicationMode' from its ABI tag value.
replicationModeFromTag :: Word8 -> Maybe ReplicationMode
replicationModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReplicationMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this node accepts write operations.
acceptsWrites :: ReplicationMode -> Bool
acceptsWrites None = True
acceptsWrites Primary = True
acceptsWrites _ = False

-- | Whether this is a data-serving node (not sentinel).
servesData :: ReplicationMode -> Bool
servesData Sentinel = False
servesData _ = True
