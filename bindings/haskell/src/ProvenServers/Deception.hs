-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Deception protocol types for proven-servers.
--
-- Cyber deception platform types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Deception
  ( -- * ADT types matching Idris2 ABI
      DecoyType(..)
    , TriggerEvent(..)
    , AlertPriority(..)
    , DecoyState(..)
    , ResponseAction(..)
    , ServerState(..)
    , decoyTypeToTag
    , decoyTypeFromTag
    , triggerEventToTag
    , triggerEventFromTag
    , alertPriorityToTag
    , alertPriorityFromTag
    , decoyStateToTag
    , decoyStateFromTag
    , responseActionToTag
    , responseActionFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- DecoyType
-- ---------------------------------------------------------------------------

-- | DecoyType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data DecoyType
  = Service  -- ^ Tag 0.
  | Credential  -- ^ Tag 1.
  | File  -- ^ Tag 2.
  | Network  -- ^ Tag 3.
  | Token  -- ^ Tag 4.
  | Breadcrumb  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DecoyType' to its ABI tag value.
decoyTypeToTag :: DecoyType -> Word8
decoyTypeToTag = fromIntegral . fromEnum

-- | Decode a 'DecoyType' from its ABI tag value.
decoyTypeFromTag :: Word8 -> Maybe DecoyType
decoyTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DecoyType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TriggerEvent
-- ---------------------------------------------------------------------------

-- | TriggerEvent type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data TriggerEvent
  = Access  -- ^ Tag 0.
  | Login  -- ^ Tag 1.
  | Read  -- ^ Tag 2.
  | Write  -- ^ Tag 3.
  | Execute  -- ^ Tag 4.
  | Scan  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TriggerEvent' to its ABI tag value.
triggerEventToTag :: TriggerEvent -> Word8
triggerEventToTag = fromIntegral . fromEnum

-- | Decode a 'TriggerEvent' from its ABI tag value.
triggerEventFromTag :: Word8 -> Maybe TriggerEvent
triggerEventFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TriggerEvent)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AlertPriority
-- ---------------------------------------------------------------------------

-- | AlertPriority type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AlertPriority
  = Low  -- ^ Tag 0.
  | Medium  -- ^ Tag 1.
  | High  -- ^ Tag 2.
  | Critical  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AlertPriority' to its ABI tag value.
alertPriorityToTag :: AlertPriority -> Word8
alertPriorityToTag = fromIntegral . fromEnum

-- | Decode a 'AlertPriority' from its ABI tag value.
alertPriorityFromTag :: Word8 -> Maybe AlertPriority
alertPriorityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AlertPriority)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DecoyState
-- ---------------------------------------------------------------------------

-- | DecoyState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data DecoyState
  = Active  -- ^ Tag 0.
  | Triggered  -- ^ Tag 1.
  | Disabled  -- ^ Tag 2.
  | Expired  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DecoyState' to its ABI tag value.
decoyStateToTag :: DecoyState -> Word8
decoyStateToTag = fromIntegral . fromEnum

-- | Decode a 'DecoyState' from its ABI tag value.
decoyStateFromTag :: Word8 -> Maybe DecoyState
decoyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DecoyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResponseAction
-- ---------------------------------------------------------------------------

-- | ResponseAction type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ResponseAction
  = Alert  -- ^ Tag 0.
  | Redirect  -- ^ Tag 1.
  | Delay  -- ^ Tag 2.
  | Fingerprint  -- ^ Tag 3.
  | Isolate  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResponseAction' to its ABI tag value.
responseActionToTag :: ResponseAction -> Word8
responseActionToTag = fromIntegral . fromEnum

-- | Decode a 'ResponseAction' from its ABI tag value.
responseActionFromTag :: Word8 -> Maybe ResponseAction
responseActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResponseAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Configured  -- ^ Tag 1.
  | Monitoring  -- ^ Tag 2.
  | Responding  -- ^ Tag 3.
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
