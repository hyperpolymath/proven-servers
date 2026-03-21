-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | DDS protocol types for proven-servers.
--
-- DDS (Data Distribution Service) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Dds
  ( -- * ADT types matching Idris2 ABI
      ReliabilityKind(..)
    , DurabilityKind(..)
    , HistoryKind(..)
    , OwnershipKind(..)
    , EntityType(..)
    , ParticipantState(..)
    , reliabilityKindToTag
    , reliabilityKindFromTag
    , durabilityKindToTag
    , durabilityKindFromTag
    , historyKindToTag
    , historyKindFromTag
    , ownershipKindToTag
    , ownershipKindFromTag
    , entityTypeToTag
    , entityTypeFromTag
    , participantStateToTag
    , participantStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ReliabilityKind
-- ---------------------------------------------------------------------------

-- | ReliabilityKind type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ReliabilityKind
  = BestEffort  -- ^ Tag 0.
  | Reliable  -- ^ Tag 1.
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

-- | DurabilityKind type matching the Idris2 ABI.
--
-- Tags 1-3 (3 constructors).
data DurabilityKind
  = TransientLocal  -- ^ Tag 1.
  | Transient  -- ^ Tag 2.
  | Persistent  -- ^ Tag 3.
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

-- | HistoryKind type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data HistoryKind
  = KeepLast  -- ^ Tag 0.
  | KeepAll  -- ^ Tag 1.
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

-- | OwnershipKind type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data OwnershipKind
  = Shared  -- ^ Tag 0.
  | Exclusive  -- ^ Tag 1.
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

-- | EntityType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data EntityType
  = Participant  -- ^ Tag 0.
  | Publisher  -- ^ Tag 1.
  | Subscriber  -- ^ Tag 2.
  | Topic  -- ^ Tag 3.
  | DataWriter  -- ^ Tag 4.
  | DataReader  -- ^ Tag 5.
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

-- | ParticipantState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ParticipantState
  = Idle  -- ^ Tag 0.
  | Joined  -- ^ Tag 1.
  | Publishing  -- ^ Tag 2.
  | Subscribing  -- ^ Tag 3.
  | Leaving  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ParticipantState' to its ABI tag value.
participantStateToTag :: ParticipantState -> Word8
participantStateToTag = fromIntegral . fromEnum

-- | Decode a 'ParticipantState' from its ABI tag value.
participantStateFromTag :: Word8 -> Maybe ParticipantState
participantStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ParticipantState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
