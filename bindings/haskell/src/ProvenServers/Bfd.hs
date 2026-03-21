-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | BFD protocol types for proven-servers.
--
-- BFD (Bidirectional Forwarding Detection, RFC 5880) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Bfd
  ( -- * ADT types matching Idris2 ABI
      BfdState(..)
    , Diagnostic(..)
    , SessionMode(..)
    , SessionState(..)
    , bfdStateToTag
    , bfdStateFromTag
    , diagnosticToTag
    , diagnosticFromTag
    , sessionModeToTag
    , sessionModeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- BfdState
-- ---------------------------------------------------------------------------

-- | BfdState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data BfdState
  = AdminDown  -- ^ Tag 0.
  | Down  -- ^ Tag 1.
  | Init  -- ^ Tag 2.
  | Up  -- ^ Tag 3.
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

-- | Diagnostic type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data Diagnostic
  = NoDiagnostic  -- ^ Tag 0.
  | ControlDetectionTimeExpired  -- ^ Tag 1.
  | EchoFunctionFailed  -- ^ Tag 2.
  | NeighborSignaledSessionDown  -- ^ Tag 3.
  | ForwardingPlaneReset  -- ^ Tag 4.
  | PathDown  -- ^ Tag 5.
  | ConcatenatedPathDown  -- ^ Tag 6.
  | AdministrativelyDown  -- ^ Tag 7.
  | ReverseConcatenatedPathDown  -- ^ Tag 8.
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

-- | SessionMode type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data SessionMode
  = AsyncMode  -- ^ Tag 0.
  | DemandMode  -- ^ Tag 1.
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

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | SsDown  -- ^ Tag 1.
  | Negotiating  -- ^ Tag 2.
  | Established  -- ^ Tag 3.
  | Teardown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
