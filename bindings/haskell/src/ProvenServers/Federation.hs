-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Federation protocol types for proven-servers.
--
-- ActivityPub/federation types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Federation
  ( -- * ADT types matching Idris2 ABI
      ActivityType(..)
    , ActorType(..)
    , DeliveryStatus(..)
    , TrustLevel(..)
    , ObjectType(..)
    , ServerState(..)
    , activityTypeToTag
    , activityTypeFromTag
    , actorTypeToTag
    , actorTypeFromTag
    , deliveryStatusToTag
    , deliveryStatusFromTag
    , trustLevelToTag
    , trustLevelFromTag
    , objectTypeToTag
    , objectTypeFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ActivityType
-- ---------------------------------------------------------------------------

-- | ActivityType type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data ActivityType
  = Create  -- ^ Tag 0.
  | Update  -- ^ Tag 1.
  | Delete  -- ^ Tag 2.
  | Follow  -- ^ Tag 3.
  | Accept  -- ^ Tag 4.
  | Reject  -- ^ Tag 5.
  | Announce  -- ^ Tag 6.
  | Like  -- ^ Tag 7.
  | Undo  -- ^ Tag 8.
  | Block  -- ^ Tag 9.
  | Flag  -- ^ Tag 10.
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

-- | ActorType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ActorType
  = Person  -- ^ Tag 0.
  | Service  -- ^ Tag 1.
  | Application  -- ^ Tag 2.
  | Group  -- ^ Tag 3.
  | Organization  -- ^ Tag 4.
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

-- | DeliveryStatus type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data DeliveryStatus
  = Pending  -- ^ Tag 0.
  | Delivered  -- ^ Tag 1.
  | Failed  -- ^ Tag 2.
  | Rejected  -- ^ Tag 3.
  | Deferred  -- ^ Tag 4.
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

-- | TrustLevel type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data TrustLevel
  = SelfSigned  -- ^ Tag 0.
  | PeerVerified  -- ^ Tag 1.
  | FederationTrusted  -- ^ Tag 2.
  | Revoked  -- ^ Tag 3.
  | Unknown  -- ^ Tag 4.
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

-- | ObjectType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data ObjectType
  = Note  -- ^ Tag 0.
  | Article  -- ^ Tag 1.
  | Image  -- ^ Tag 2.
  | Video  -- ^ Tag 3.
  | Audio  -- ^ Tag 4.
  | Document  -- ^ Tag 5.
  | Event  -- ^ Tag 6.
  | Collection  -- ^ Tag 7.
  | OrderedCollection  -- ^ Tag 8.
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

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Active  -- ^ Tag 1.
  | Processing  -- ^ Tag 2.
  | Delivering  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
