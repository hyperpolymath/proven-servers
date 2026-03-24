-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | BFD types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Bfd
  (
    bfdPort
  , BfdState(..)
  , bfdStateToTag
  , bfdStateFromTag
  , Diagnostic(..)
  , diagnosticToTag
  , diagnosticFromTag
  , SessionMode(..)
  , sessionModeToTag
  , sessionModeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard BFD port.
bfdPort :: Word16
bfdPort = 3784

-- ---------------------------------------------------------------------------
-- BfdState
-- ---------------------------------------------------------------------------

-- | Standard BFD port.
--
-- Tags 0-3 (4 constructors).
data BfdState
  = AdminDown  -- ^ AdminDown (tag 0).
  | Down  -- ^ Down (tag 1).
  | Init  -- ^ Init (tag 2).
  | Up  -- ^ Up (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BfdState' to its ABI tag value.
bfdStateToTag :: BfdState -> Word8
bfdStateToTag = fromIntegral . fromEnum

-- | Decode a 'BfdState' from its ABI tag value.
bfdStateFromTag :: Word8 -> Maybe BfdState
bfdStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BfdState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Diagnostic
-- ---------------------------------------------------------------------------

-- | BFD diagnostic codes (RFC 5880 Section 4.1).
--
-- Tags 0-8 (9 constructors).
data Diagnostic
  = NoDiagnostic  -- ^ NoDiagnostic (tag 0).
  | ControlDetectionTimeExpired  -- ^ ControlDetectionTimeExpired (tag 1).
  | EchoFunctionFailed  -- ^ EchoFunctionFailed (tag 2).
  | NeighborSignaledSessionDown  -- ^ NeighborSignaledSessionDown (tag 3).
  | ForwardingPlaneReset  -- ^ ForwardingPlaneReset (tag 4).
  | PathDown  -- ^ PathDown (tag 5).
  | ConcatenatedPathDown  -- ^ ConcatenatedPathDown (tag 6).
  | AdministrativelyDown  -- ^ AdministrativelyDown (tag 7).
  | ReverseConcatenatedPathDown  -- ^ ReverseConcatenatedPathDown (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Diagnostic' to its ABI tag value.
diagnosticToTag :: Diagnostic -> Word8
diagnosticToTag = fromIntegral . fromEnum

-- | Decode a 'Diagnostic' from its ABI tag value.
diagnosticFromTag :: Word8 -> Maybe Diagnostic
diagnosticFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Diagnostic)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionMode
-- ---------------------------------------------------------------------------

-- | BFD session modes.
--
-- Tags 0-1 (2 constructors).
data SessionMode
  = AsyncMode  -- ^ AsyncMode (tag 0).
  | DemandMode  -- ^ DemandMode (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionMode' to its ABI tag value.
sessionModeToTag :: SessionMode -> Word8
sessionModeToTag = fromIntegral . fromEnum

-- | Decode a 'SessionMode' from its ABI tag value.
sessionModeFromTag :: Word8 -> Maybe SessionMode
sessionModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | BFD session lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | SsDown  -- ^ Down (tag 1).
  | Negotiating  -- ^ Negotiating (tag 2).
  | Established  -- ^ Established (tag 3).
  | Teardown  -- ^ Teardown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
