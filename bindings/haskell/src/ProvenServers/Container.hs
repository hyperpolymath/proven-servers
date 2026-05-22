-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Container Runtime types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Container
  (
    ContainerState(..)
  , containerStateToTag
  , containerStateFromTag
  , ContainerOperation(..)
  , containerOperationToTag
  , containerOperationFromTag
  , NetworkMode(..)
  , networkModeToTag
  , networkModeFromTag
  , VolumeType(..)
  , volumeTypeToTag
  , volumeTypeFromTag
  , RestartPolicy(..)
  , restartPolicyToTag
  , restartPolicyFromTag
  , HealthStatus(..)
  , healthStatusToTag
  , healthStatusFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ContainerState
-- ---------------------------------------------------------------------------

-- | Container lifecycle states.
--
-- Tags 0-6 (7 constructors).
data ContainerState
  = Creating  -- ^ Creating (tag 0).
  | Running  -- ^ Running (tag 1).
  | Paused  -- ^ Paused (tag 2).
  | Restarting  -- ^ Restarting (tag 3).
  | Stopped  -- ^ Stopped (tag 4).
  | Removing  -- ^ Removing (tag 5).
  | Dead  -- ^ Dead (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContainerState' to its ABI tag value.
containerStateToTag :: ContainerState -> Word8
containerStateToTag = fromIntegral . fromEnum

-- | Decode a 'ContainerState' from its ABI tag value.
containerStateFromTag :: Word8 -> Maybe ContainerState
containerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContainerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ContainerOperation
-- ---------------------------------------------------------------------------

-- | Container operations.
--
-- Tags 0-10 (11 constructors).
data ContainerOperation
  = Create  -- ^ Create (tag 0).
  | Start  -- ^ Start (tag 1).
  | Stop  -- ^ Stop (tag 2).
  | Restart  -- ^ Restart (tag 3).
  | Pause  -- ^ Pause (tag 4).
  | Unpause  -- ^ Unpause (tag 5).
  | Kill  -- ^ Kill (tag 6).
  | Remove  -- ^ Remove (tag 7).
  | Exec  -- ^ Exec (tag 8).
  | Logs  -- ^ Logs (tag 9).
  | Inspect  -- ^ Inspect (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContainerOperation' to its ABI tag value.
containerOperationToTag :: ContainerOperation -> Word8
containerOperationToTag = fromIntegral . fromEnum

-- | Decode a 'ContainerOperation' from its ABI tag value.
containerOperationFromTag :: Word8 -> Maybe ContainerOperation
containerOperationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContainerOperation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NetworkMode
-- ---------------------------------------------------------------------------

-- | Container network modes.
--
-- Tags 0-4 (5 constructors).
data NetworkMode
  = Bridge  -- ^ Bridge (tag 0).
  | Host  -- ^ Host (tag 1).
  | None  -- ^ None (tag 2).
  | Overlay  -- ^ Overlay (tag 3).
  | Macvlan  -- ^ Macvlan (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetworkMode' to its ABI tag value.
networkModeToTag :: NetworkMode -> Word8
networkModeToTag = fromIntegral . fromEnum

-- | Decode a 'NetworkMode' from its ABI tag value.
networkModeFromTag :: Word8 -> Maybe NetworkMode
networkModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetworkMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- VolumeType
-- ---------------------------------------------------------------------------

-- | Container volume types.
--
-- Tags 0-2 (3 constructors).
data VolumeType
  = Bind  -- ^ Bind (tag 0).
  | Named  -- ^ Named (tag 1).
  | Tmpfs  -- ^ Tmpfs (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VolumeType' to its ABI tag value.
volumeTypeToTag :: VolumeType -> Word8
volumeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'VolumeType' from its ABI tag value.
volumeTypeFromTag :: Word8 -> Maybe VolumeType
volumeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VolumeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- RestartPolicy
-- ---------------------------------------------------------------------------

-- | Container restart policies.
--
-- Tags 0-3 (4 constructors).
data RestartPolicy
  = No  -- ^ No (tag 0).
  | Always  -- ^ Always (tag 1).
  | OnFailure  -- ^ OnFailure (tag 2).
  | UnlessStopped  -- ^ UnlessStopped (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'RestartPolicy' to its ABI tag value.
restartPolicyToTag :: RestartPolicy -> Word8
restartPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'RestartPolicy' from its ABI tag value.
restartPolicyFromTag :: Word8 -> Maybe RestartPolicy
restartPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: RestartPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HealthStatus
-- ---------------------------------------------------------------------------

-- | Container health check status.
--
-- Tags 0-3 (4 constructors).
data HealthStatus
  = Starting  -- ^ Starting (tag 0).
  | Healthy  -- ^ Healthy (tag 1).
  | Unhealthy  -- ^ Unhealthy (tag 2).
  | NoCheck  -- ^ NoCheck (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HealthStatus' to its ABI tag value.
healthStatusToTag :: HealthStatus -> Word8
healthStatusToTag = fromIntegral . fromEnum

-- | Decode a 'HealthStatus' from its ABI tag value.
healthStatusFromTag :: Word8 -> Maybe HealthStatus
healthStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HealthStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
