-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Configuration Management types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Configmgmt
  (
    ResourceType(..)
  , resourceTypeToTag
  , resourceTypeFromTag
  , ResourceState(..)
  , resourceStateToTag
  , resourceStateFromTag
  , ChangeAction(..)
  , changeActionToTag
  , changeActionFromTag
  , DriftStatus(..)
  , driftStatusToTag
  , driftStatusFromTag
  , ApplyMode(..)
  , applyModeToTag
  , applyModeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ResourceType
-- ---------------------------------------------------------------------------

-- | Managed resource types.
--
-- Tags 0-8 (9 constructors).
data ResourceType
  = File  -- ^ File (tag 0).
  | Package  -- ^ Package (tag 1).
  | Service  -- ^ Service (tag 2).
  | User  -- ^ User (tag 3).
  | Group  -- ^ Group (tag 4).
  | Cron  -- ^ Cron (tag 5).
  | Mount  -- ^ Mount (tag 6).
  | Firewall  -- ^ Firewall (tag 7).
  | Registry  -- ^ Registry (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResourceType' to its ABI tag value.
resourceTypeToTag :: ResourceType -> Word8
resourceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ResourceType' from its ABI tag value.
resourceTypeFromTag :: Word8 -> Maybe ResourceType
resourceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResourceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResourceState
-- ---------------------------------------------------------------------------

-- | Desired resource states.
--
-- Tags 0-5 (6 constructors).
data ResourceState
  = Present  -- ^ Present (tag 0).
  | Absent  -- ^ Absent (tag 1).
  | Running  -- ^ Running (tag 2).
  | Stopped  -- ^ Stopped (tag 3).
  | Enabled  -- ^ Enabled (tag 4).
  | Disabled  -- ^ Disabled (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResourceState' to its ABI tag value.
resourceStateToTag :: ResourceState -> Word8
resourceStateToTag = fromIntegral . fromEnum

-- | Decode a 'ResourceState' from its ABI tag value.
resourceStateFromTag :: Word8 -> Maybe ResourceState
resourceStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResourceState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChangeAction
-- ---------------------------------------------------------------------------

-- | Configuration change actions.
--
-- Tags 0-5 (6 constructors).
data ChangeAction
  = Create  -- ^ Create (tag 0).
  | Modify  -- ^ Modify (tag 1).
  | Delete  -- ^ Delete (tag 2).
  | Restart  -- ^ Restart (tag 3).
  | Reload  -- ^ Reload (tag 4).
  | Skip  -- ^ Skip (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChangeAction' to its ABI tag value.
changeActionToTag :: ChangeAction -> Word8
changeActionToTag = fromIntegral . fromEnum

-- | Decode a 'ChangeAction' from its ABI tag value.
changeActionFromTag :: Word8 -> Maybe ChangeAction
changeActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChangeAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DriftStatus
-- ---------------------------------------------------------------------------

-- | Configuration drift status.
--
-- Tags 0-3 (4 constructors).
data DriftStatus
  = InSync  -- ^ InSync (tag 0).
  | Drifted  -- ^ Drifted (tag 1).
  | DUnknown  -- ^ Unknown (tag 2).
  | Unmanaged  -- ^ Unmanaged (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DriftStatus' to its ABI tag value.
driftStatusToTag :: DriftStatus -> Word8
driftStatusToTag = fromIntegral . fromEnum

-- | Decode a 'DriftStatus' from its ABI tag value.
driftStatusFromTag :: Word8 -> Maybe DriftStatus
driftStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DriftStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ApplyMode
-- ---------------------------------------------------------------------------

-- | Configuration apply modes.
--
-- Tags 0-2 (3 constructors).
data ApplyMode
  = Enforce  -- ^ Enforce (tag 0).
  | DryRun  -- ^ DryRun (tag 1).
  | Audit  -- ^ Audit (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ApplyMode' to its ABI tag value.
applyModeToTag :: ApplyMode -> Word8
applyModeToTag = fromIntegral . fromEnum

-- | Decode a 'ApplyMode' from its ABI tag value.
applyModeFromTag :: Word8 -> Maybe ApplyMode
applyModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ApplyMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
