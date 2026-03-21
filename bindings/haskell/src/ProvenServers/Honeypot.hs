-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Honeypot protocol types for proven-servers.
--
-- Honeypot/deception types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Honeypot
  ( -- * ADT types matching Idris2 ABI
      ServiceEmulation(..)
    , InteractionLevel(..)
    , HoneypotAlertSeverity(..)
    , AttackerAction(..)
    , ServerState(..)
    , serviceEmulationToTag
    , serviceEmulationFromTag
    , interactionLevelToTag
    , interactionLevelFromTag
    , honeypotAlertSeverityToTag
    , honeypotAlertSeverityFromTag
    , attackerActionToTag
    , attackerActionFromTag
    , serverStateToTag
    , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ServiceEmulation
-- ---------------------------------------------------------------------------

-- | ServiceEmulation type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data ServiceEmulation
  = Ssh  -- ^ Tag 0.
  | Http  -- ^ Tag 1.
  | Ftp  -- ^ Tag 2.
  | Smtp  -- ^ Tag 3.
  | Telnet  -- ^ Tag 4.
  | Mysql  -- ^ Tag 5.
  | Rdp  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServiceEmulation' to its ABI tag value.
serviceEmulationToTag :: ServiceEmulation -> Word8
serviceEmulationToTag = fromIntegral . fromEnum

-- | Decode a 'ServiceEmulation' from its ABI tag value.
serviceEmulationFromTag :: Word8 -> Maybe ServiceEmulation
serviceEmulationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServiceEmulation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- InteractionLevel
-- ---------------------------------------------------------------------------

-- | InteractionLevel type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data InteractionLevel
  = Low  -- ^ Tag 0.
  | Medium  -- ^ Tag 1.
  | High  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'InteractionLevel' to its ABI tag value.
interactionLevelToTag :: InteractionLevel -> Word8
interactionLevelToTag = fromIntegral . fromEnum

-- | Decode a 'InteractionLevel' from its ABI tag value.
interactionLevelFromTag :: Word8 -> Maybe InteractionLevel
interactionLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: InteractionLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HoneypotAlertSeverity
-- ---------------------------------------------------------------------------

-- | HoneypotAlertSeverity type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data HoneypotAlertSeverity
  = Info  -- ^ Tag 0.
  | AsLow  -- ^ Tag 1.
  | AsMedium  -- ^ Tag 2.
  | AsHigh  -- ^ Tag 3.
  | Critical  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HoneypotAlertSeverity' to its ABI tag value.
honeypotAlertSeverityToTag :: HoneypotAlertSeverity -> Word8
honeypotAlertSeverityToTag = fromIntegral . fromEnum

-- | Decode a 'HoneypotAlertSeverity' from its ABI tag value.
honeypotAlertSeverityFromTag :: Word8 -> Maybe HoneypotAlertSeverity
honeypotAlertSeverityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HoneypotAlertSeverity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AttackerAction
-- ---------------------------------------------------------------------------

-- | AttackerAction type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data AttackerAction
  = Scan  -- ^ Tag 0.
  | BruteForce  -- ^ Tag 1.
  | Exploit  -- ^ Tag 2.
  | Payload  -- ^ Tag 3.
  | Lateral  -- ^ Tag 4.
  | Exfiltration  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AttackerAction' to its ABI tag value.
attackerActionToTag :: AttackerAction -> Word8
attackerActionToTag = fromIntegral . fromEnum

-- | Decode a 'AttackerAction' from its ABI tag value.
attackerActionFromTag :: Word8 -> Maybe AttackerAction
attackerActionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AttackerAction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ServerState
-- ---------------------------------------------------------------------------

-- | ServerState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ServerState
  = Idle  -- ^ Tag 0.
  | Deployed  -- ^ Tag 1.
  | Engaged  -- ^ Tag 2.
  | Shutdown  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
