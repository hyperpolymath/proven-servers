-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Federation types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Federation
  (
    ActivityType(..)
  , activityTypeToTag
  , activityTypeFromTag
  , ActorType(..)
  , actorTypeToTag
  , actorTypeFromTag
  , DeliveryStatus(..)
  , deliveryStatusToTag
  , deliveryStatusFromTag
  , TrustLevel(..)
  , trustLevelToTag
  , trustLevelFromTag
  , ObjectType(..)
  , objectTypeToTag
  , objectTypeFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ActivityType
-- ---------------------------------------------------------------------------

-- | ActivityPub activity types.
--
-- Tags 0-10 (11 constructors).
data ActivityType
  = Create  -- ^ Create (tag 0).
  | Update  -- ^ Update (tag 1).
  | Delete  -- ^ Delete (tag 2).
  | Follow  -- ^ Follow (tag 3).
  | Accept  -- ^ Accept (tag 4).
  | Reject  -- ^ Reject (tag 5).
  | Announce  -- ^ Announce (tag 6).
  | Like  -- ^ Like (tag 7).
  | Undo  -- ^ Undo (tag 8).
  | Block  -- ^ Block (tag 9).
  | Flag  -- ^ Flag (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ActivityType' to its ABI tag value.
activityTypeToTag :: ActivityType -> Word8
activityTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ActivityType' from its ABI tag value.
activityTypeFromTag :: Word8 -> Maybe ActivityType
activityTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ActivityType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ActorType
-- ---------------------------------------------------------------------------

-- | ActivityPub actor types.
--
-- Tags 0-4 (5 constructors).
data ActorType
  = Person  -- ^ Person (tag 0).
  | Service  -- ^ Service (tag 1).
  | Application  -- ^ Application (tag 2).
  | Group  -- ^ Group (tag 3).
  | Organization  -- ^ Organization (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ActorType' to its ABI tag value.
actorTypeToTag :: ActorType -> Word8
actorTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ActorType' from its ABI tag value.
actorTypeFromTag :: Word8 -> Maybe ActorType
actorTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ActorType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DeliveryStatus
-- ---------------------------------------------------------------------------

-- | Federation delivery statuses.
--
-- Tags 0-4 (5 constructors).
data DeliveryStatus
  = Pending  -- ^ Pending (tag 0).
  | Delivered  -- ^ Delivered (tag 1).
  | Failed  -- ^ Failed (tag 2).
  | Rejected  -- ^ Rejected (tag 3).
  | Deferred  -- ^ Deferred (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DeliveryStatus' to its ABI tag value.
deliveryStatusToTag :: DeliveryStatus -> Word8
deliveryStatusToTag = fromIntegral . fromEnum

-- | Decode a 'DeliveryStatus' from its ABI tag value.
deliveryStatusFromTag :: Word8 -> Maybe DeliveryStatus
deliveryStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DeliveryStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TrustLevel
-- ---------------------------------------------------------------------------

-- | Federation trust levels.
--
-- Tags 0-4 (5 constructors).
data TrustLevel
  = SelfSigned  -- ^ SelfSigned (tag 0).
  | PeerVerified  -- ^ PeerVerified (tag 1).
  | FederationTrusted  -- ^ FederationTrusted (tag 2).
  | Revoked  -- ^ Revoked (tag 3).
  | Unknown  -- ^ Unknown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TrustLevel' to its ABI tag value.
trustLevelToTag :: TrustLevel -> Word8
trustLevelToTag = fromIntegral . fromEnum

-- | Decode a 'TrustLevel' from its ABI tag value.
trustLevelFromTag :: Word8 -> Maybe TrustLevel
trustLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TrustLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ObjectType
-- ---------------------------------------------------------------------------

-- | ActivityPub object types.
--
-- Tags 0-8 (9 constructors).
data ObjectType
  = Note  -- ^ Note (tag 0).
  | Article  -- ^ Article (tag 1).
  | Image  -- ^ Image (tag 2).
  | Video  -- ^ Video (tag 3).
  | Audio  -- ^ Audio (tag 4).
  | Document  -- ^ Document (tag 5).
  | Event  -- ^ Event (tag 6).
  | Collection  -- ^ Collection (tag 7).
  | OrderedCollection  -- ^ OrderedCollection (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ObjectType' to its ABI tag value.
objectTypeToTag :: ObjectType -> Word8
objectTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ObjectType' from its ABI tag value.
objectTypeFromTag :: Word8 -> Maybe ObjectType
objectTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ObjectType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | Federation server states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Active  -- ^ Active (tag 1).
  | Processing  -- ^ Processing (tag 2).
  | Delivering  -- ^ Delivering (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
