-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Config Mgmt protocol types for proven-servers.
--
-- Configuration management types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Configmgmt
  ( -- * ADT types matching Idris2 ABI
      ResourceType(..)
    , ResourceState(..)
    , ChangeAction(..)
    , DriftStatus(..)
    , ApplyMode(..)
    , resourceTypeToTag
    , resourceTypeFromTag
    , resourceStateToTag
    , resourceStateFromTag
    , changeActionToTag
    , changeActionFromTag
    , driftStatusToTag
    , driftStatusFromTag
    , applyModeToTag
    , applyModeFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ResourceType
-- ---------------------------------------------------------------------------

-- | ResourceType type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data ResourceType
  = File  -- ^ Tag 0.
  | Package  -- ^ Tag 1.
  | Service  -- ^ Tag 2.
  | User  -- ^ Tag 3.
  | Group  -- ^ Tag 4.
  | Cron  -- ^ Tag 5.
  | Mount  -- ^ Tag 6.
  | Firewall  -- ^ Tag 7.
  | Registry  -- ^ Tag 8.
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

-- | ResourceState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ResourceState
  = Present  -- ^ Tag 0.
  | Absent  -- ^ Tag 1.
  | Running  -- ^ Tag 2.
  | Stopped  -- ^ Tag 3.
  | Enabled  -- ^ Tag 4.
  | Disabled  -- ^ Tag 5.
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

-- | ChangeAction type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ChangeAction
  = Create  -- ^ Tag 0.
  | Modify  -- ^ Tag 1.
  | Delete  -- ^ Tag 2.
  | Restart  -- ^ Tag 3.
  | Reload  -- ^ Tag 4.
  | Skip  -- ^ Tag 5.
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

-- | DriftStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data DriftStatus
  = InSync  -- ^ Tag 0.
  | Drifted  -- ^ Tag 1.
  | DUnknown  -- ^ Tag 2.
  | Unmanaged  -- ^ Tag 3.
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

-- | ApplyMode type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data ApplyMode
  = Enforce  -- ^ Tag 0.
  | DryRun  -- ^ Tag 1.
  | Audit  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ApplyMode' to its ABI tag value.
applyModeToTag :: ApplyMode -> Word8
applyModeToTag = fromIntegral . fromEnum

-- | Decode a 'ApplyMode' from its ABI tag value.
applyModeFromTag :: Word8 -> Maybe ApplyMode
applyModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ApplyMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
