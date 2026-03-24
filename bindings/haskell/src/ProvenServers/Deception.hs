-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Deception Platform types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Deception
  (
    DecoyType(..)
  , decoyTypeToTag
  , decoyTypeFromTag
  , TriggerEvent(..)
  , triggerEventToTag
  , triggerEventFromTag
  , AlertPriority(..)
  , alertPriorityToTag
  , alertPriorityFromTag
  , DecoyState(..)
  , decoyStateToTag
  , decoyStateFromTag
  , ResponseAction(..)
  , responseActionToTag
  , responseActionFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- DecoyType
-- ---------------------------------------------------------------------------

-- | Deception decoy types.
--
-- Tags 0-5 (6 constructors).
data DecoyType
  = Service  -- ^ Service (tag 0).
  | Credential  -- ^ Credential (tag 1).
  | File  -- ^ File (tag 2).
  | Network  -- ^ Network (tag 3).
  | Token  -- ^ Token (tag 4).
  | Breadcrumb  -- ^ Breadcrumb (tag 5).
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

-- | Decoy trigger events.
--
-- Tags 0-5 (6 constructors).
data TriggerEvent
  = Access  -- ^ Access (tag 0).
  | Login  -- ^ Login (tag 1).
  | Read  -- ^ Read (tag 2).
  | Write  -- ^ Write (tag 3).
  | Execute  -- ^ Execute (tag 4).
  | Scan  -- ^ Scan (tag 5).
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

-- | Deception alert priority.
--
-- Tags 0-3 (4 constructors).
data AlertPriority
  = Low  -- ^ Low (tag 0).
  | Medium  -- ^ Medium (tag 1).
  | High  -- ^ High (tag 2).
  | Critical  -- ^ Critical (tag 3).
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

-- | Decoy lifecycle states.
--
-- Tags 0-3 (4 constructors).
data DecoyState
  = Active  -- ^ Active (tag 0).
  | Triggered  -- ^ Triggered (tag 1).
  | Disabled  -- ^ Disabled (tag 2).
  | Expired  -- ^ Expired (tag 3).
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

-- | Deception response actions.
--
-- Tags 0-4 (5 constructors).
data ResponseAction
  = Alert  -- ^ Alert (tag 0).
  | Redirect  -- ^ Redirect (tag 1).
  | Delay  -- ^ Delay (tag 2).
  | Fingerprint  -- ^ Fingerprint (tag 3).
  | Isolate  -- ^ Isolate (tag 4).
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

-- | Deception server states.
--
-- Tags 0-4 (5 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Configured  -- ^ Configured (tag 1).
  | Monitoring  -- ^ Monitoring (tag 2).
  | Responding  -- ^ Responding (tag 3).
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
