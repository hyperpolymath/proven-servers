-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Container protocol types for proven-servers.
--
-- Container runtime types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Container
  ( -- * ADT types matching Idris2 ABI
      ContainerState(..)
    , ContainerOperation(..)
    , NetworkMode(..)
    , VolumeType(..)
    , RestartPolicy(..)
    , HealthStatus(..)
    , containerStateToTag
    , containerStateFromTag
    , containerOperationToTag
    , containerOperationFromTag
    , networkModeToTag
    , networkModeFromTag
    , volumeTypeToTag
    , volumeTypeFromTag
    , restartPolicyToTag
    , restartPolicyFromTag
    , healthStatusToTag
    , healthStatusFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ContainerState
-- ---------------------------------------------------------------------------

-- | ContainerState type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data ContainerState
  = Creating  -- ^ Tag 0.
  | Running  -- ^ Tag 1.
  | Paused  -- ^ Tag 2.
  | Restarting  -- ^ Tag 3.
  | Stopped  -- ^ Tag 4.
  | Removing  -- ^ Tag 5.
  | Dead  -- ^ Tag 6.
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

-- | ContainerOperation type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data ContainerOperation
  = Create  -- ^ Tag 0.
  | Start  -- ^ Tag 1.
  | Stop  -- ^ Tag 2.
  | Restart  -- ^ Tag 3.
  | Pause  -- ^ Tag 4.
  | Unpause  -- ^ Tag 5.
  | Kill  -- ^ Tag 6.
  | Remove  -- ^ Tag 7.
  | Exec  -- ^ Tag 8.
  | Logs  -- ^ Tag 9.
  | Inspect  -- ^ Tag 10.
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

-- | NetworkMode type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data NetworkMode
  = Bridge  -- ^ Tag 0.
  | Host  -- ^ Tag 1.
  | None  -- ^ Tag 2.
  | Overlay  -- ^ Tag 3.
  | Macvlan  -- ^ Tag 4.
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

-- | VolumeType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data VolumeType
  = Bind  -- ^ Tag 0.
  | Named  -- ^ Tag 1.
  | Tmpfs  -- ^ Tag 2.
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

-- | RestartPolicy type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data RestartPolicy
  = No  -- ^ Tag 0.
  | Always  -- ^ Tag 1.
  | OnFailure  -- ^ Tag 2.
  | UnlessStopped  -- ^ Tag 3.
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

-- | HealthStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HealthStatus
  = Starting  -- ^ Tag 0.
  | Healthy  -- ^ Tag 1.
  | Unhealthy  -- ^ Tag 2.
  | NoCheck  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HealthStatus' to its ABI tag value.
healthStatusToTag :: HealthStatus -> Word8
healthStatusToTag = fromIntegral . fromEnum

-- | Decode a 'HealthStatus' from its ABI tag value.
healthStatusFromTag :: Word8 -> Maybe HealthStatus
healthStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HealthStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
