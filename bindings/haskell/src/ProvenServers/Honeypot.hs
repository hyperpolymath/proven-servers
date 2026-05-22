-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Honeypot types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Honeypot
  (
    ServiceEmulation(..)
  , serviceEmulationToTag
  , serviceEmulationFromTag
  , InteractionLevel(..)
  , interactionLevelToTag
  , interactionLevelFromTag
  , HoneypotAlertSeverity(..)
  , honeypotAlertSeverityToTag
  , honeypotAlertSeverityFromTag
  , AttackerAction(..)
  , attackerActionToTag
  , attackerActionFromTag
  , ServerState(..)
  , serverStateToTag
  , serverStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ServiceEmulation
-- ---------------------------------------------------------------------------

-- | Emulated service types.
--
-- Tags 0-6 (7 constructors).
data ServiceEmulation
  = Ssh  -- ^ SSH (tag 0).
  | Http  -- ^ HTTP (tag 1).
  | Ftp  -- ^ FTP (tag 2).
  | Smtp  -- ^ SMTP (tag 3).
  | Telnet  -- ^ Telnet (tag 4).
  | Mysql  -- ^ MySQL (tag 5).
  | Rdp  -- ^ RDP (tag 6).
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

-- | Honeypot interaction levels.
--
-- Tags 0-2 (3 constructors).
data InteractionLevel
  = Low  -- ^ Low (tag 0).
  | Medium  -- ^ Medium (tag 1).
  | High  -- ^ High (tag 2).
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

-- | Honeypot alert severity levels.
--
-- Tags 0-4 (5 constructors).
data HoneypotAlertSeverity
  = Info  -- ^ Info (tag 0).
  | AsLow  -- ^ Low (tag 1).
  | AsMedium  -- ^ Medium (tag 2).
  | AsHigh  -- ^ High (tag 3).
  | Critical  -- ^ Critical (tag 4).
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

-- | Observed attacker actions.
--
-- Tags 0-5 (6 constructors).
data AttackerAction
  = Scan  -- ^ Scan (tag 0).
  | BruteForce  -- ^ BruteForce (tag 1).
  | Exploit  -- ^ Exploit (tag 2).
  | Payload  -- ^ Payload (tag 3).
  | Lateral  -- ^ Lateral (tag 4).
  | Exfiltration  -- ^ Exfiltration (tag 5).
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

-- | Honeypot server states.
--
-- Tags 0-3 (4 constructors).
data ServerState
  = Idle  -- ^ Idle (tag 0).
  | Deployed  -- ^ Deployed (tag 1).
  | Engaged  -- ^ Engaged (tag 2).
  | Shutdown  -- ^ Shutdown (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ServerState' to its ABI tag value.
serverStateToTag :: ServerState -> Word8
serverStateToTag = fromIntegral . fromEnum

-- | Decode a 'ServerState' from its ABI tag value.
serverStateFromTag :: Word8 -> Maybe ServerState
serverStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ServerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
