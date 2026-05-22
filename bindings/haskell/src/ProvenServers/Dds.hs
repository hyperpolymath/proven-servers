-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DDS types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Dds
  (
    ddsDiscoveryPort
  , ReliabilityKind(..)
  , reliabilityKindToTag
  , reliabilityKindFromTag
  , DurabilityKind(..)
  , durabilityKindToTag
  , durabilityKindFromTag
  , HistoryKind(..)
  , historyKindToTag
  , historyKindFromTag
  , OwnershipKind(..)
  , ownershipKindToTag
  , ownershipKindFromTag
  , EntityType(..)
  , entityTypeToTag
  , entityTypeFromTag
  , ParticipantState(..)
  , participantStateToTag
  , participantStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard DDS discovery port.
ddsDiscoveryPort :: Word16
ddsDiscoveryPort = 7400

-- ---------------------------------------------------------------------------
-- ReliabilityKind
-- ---------------------------------------------------------------------------

-- | Standard DDS discovery port.
--
-- Tags 0-1 (2 constructors).
data ReliabilityKind
  = BestEffort  -- ^ BestEffort (tag 0).
  | Reliable  -- ^ Reliable (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReliabilityKind' to its ABI tag value.
reliabilityKindToTag :: ReliabilityKind -> Word8
reliabilityKindToTag = fromIntegral . fromEnum

-- | Decode a 'ReliabilityKind' from its ABI tag value.
reliabilityKindFromTag :: Word8 -> Maybe ReliabilityKind
reliabilityKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReliabilityKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DurabilityKind
-- ---------------------------------------------------------------------------

-- | DDS durability QoS.
--
-- Tags 0-3 (3 constructors).
data DurabilityKind
  = TransientLocal  -- ^ Transient-local durability (tag 1).
  | Transient  -- ^ Transient durability (tag 2).
  | Persistent  -- ^ Persistent durability (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DurabilityKind' to its ABI tag value.
durabilityKindToTag :: DurabilityKind -> Word8
durabilityKindToTag = fromIntegral . fromEnum

-- | Decode a 'DurabilityKind' from its ABI tag value.
durabilityKindFromTag :: Word8 -> Maybe DurabilityKind
durabilityKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DurabilityKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HistoryKind
-- ---------------------------------------------------------------------------

-- | DDS history QoS.
--
-- Tags 0-1 (2 constructors).
data HistoryKind
  = KeepLast  -- ^ KeepLast (tag 0).
  | KeepAll  -- ^ KeepAll (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HistoryKind' to its ABI tag value.
historyKindToTag :: HistoryKind -> Word8
historyKindToTag = fromIntegral . fromEnum

-- | Decode a 'HistoryKind' from its ABI tag value.
historyKindFromTag :: Word8 -> Maybe HistoryKind
historyKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HistoryKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OwnershipKind
-- ---------------------------------------------------------------------------

-- | DDS ownership QoS.
--
-- Tags 0-1 (2 constructors).
data OwnershipKind
  = Shared  -- ^ Shared (tag 0).
  | Exclusive  -- ^ Exclusive (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OwnershipKind' to its ABI tag value.
ownershipKindToTag :: OwnershipKind -> Word8
ownershipKindToTag = fromIntegral . fromEnum

-- | Decode a 'OwnershipKind' from its ABI tag value.
ownershipKindFromTag :: Word8 -> Maybe OwnershipKind
ownershipKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OwnershipKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EntityType
-- ---------------------------------------------------------------------------

-- | DDS entity types.
--
-- Tags 0-5 (6 constructors).
data EntityType
  = Participant  -- ^ Participant (tag 0).
  | Publisher  -- ^ Publisher (tag 1).
  | Subscriber  -- ^ Subscriber (tag 2).
  | Topic  -- ^ Topic (tag 3).
  | DataWriter  -- ^ DataWriter (tag 4).
  | DataReader  -- ^ DataReader (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EntityType' to its ABI tag value.
entityTypeToTag :: EntityType -> Word8
entityTypeToTag = fromIntegral . fromEnum

-- | Decode a 'EntityType' from its ABI tag value.
entityTypeFromTag :: Word8 -> Maybe EntityType
entityTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EntityType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ParticipantState
-- ---------------------------------------------------------------------------

-- | DDS participant states.
--
-- Tags 0-4 (5 constructors).
data ParticipantState
  = Idle  -- ^ Idle (tag 0).
  | Joined  -- ^ Joined (tag 1).
  | Publishing  -- ^ Publishing (tag 2).
  | Subscribing  -- ^ Subscribing (tag 3).
  | Leaving  -- ^ Leaving (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ParticipantState' to its ABI tag value.
participantStateToTag :: ParticipantState -> Word8
participantStateToTag = fromIntegral . fromEnum

-- | Decode a 'ParticipantState' from its ABI tag value.
participantStateFromTag :: Word8 -> Maybe ParticipantState
participantStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ParticipantState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
