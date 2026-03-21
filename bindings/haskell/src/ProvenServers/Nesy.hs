-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NeSy protocol types for proven-servers.
--
-- Neurosymbolic AI types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Nesy
  ( -- * ADT types matching Idris2 ABI
      ReasoningMode(..)
    , ProofStatus(..)
    , ConstraintKind(..)
    , NeuralBackend(..)
    , Confidence(..)
    , DriftKind(..)
    , NeSyState(..)
    , reasoningModeToTag
    , reasoningModeFromTag
    , proofStatusToTag
    , proofStatusFromTag
    , constraintKindToTag
    , constraintKindFromTag
    , neuralBackendToTag
    , neuralBackendFromTag
    , confidenceToTag
    , confidenceFromTag
    , driftKindToTag
    , driftKindFromTag
    , neSyStateToTag
    , neSyStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ReasoningMode
-- ---------------------------------------------------------------------------

-- | ReasoningMode type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ReasoningMode
  = Symbolic  -- ^ Tag 0.
  | Neural  -- ^ Tag 1.
  | SymToNeural  -- ^ Tag 2.
  | NeuralToSym  -- ^ Tag 3.
  | Ensemble  -- ^ Tag 4.
  | Cascade  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ReasoningMode' to its ABI tag value.
reasoningModeToTag :: ReasoningMode -> Word8
reasoningModeToTag = fromIntegral . fromEnum

-- | Decode a 'ReasoningMode' from its ABI tag value.
reasoningModeFromTag :: Word8 -> Maybe ReasoningMode
reasoningModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ReasoningMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ProofStatus
-- ---------------------------------------------------------------------------

-- | ProofStatus type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ProofStatus
  = Pending  -- ^ Tag 0.
  | Attempting  -- ^ Tag 1.
  | Proved  -- ^ Tag 2.
  | Failed  -- ^ Tag 3.
  | Assumed  -- ^ Tag 4.
  | Vacuous  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ProofStatus' to its ABI tag value.
proofStatusToTag :: ProofStatus -> Word8
proofStatusToTag = fromIntegral . fromEnum

-- | Decode a 'ProofStatus' from its ABI tag value.
proofStatusFromTag :: Word8 -> Maybe ProofStatus
proofStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ProofStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConstraintKind
-- ---------------------------------------------------------------------------

-- | ConstraintKind type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data ConstraintKind
  = TypeEquality  -- ^ Tag 0.
  | Subtype  -- ^ Tag 1.
  | Linearity  -- ^ Tag 2.
  | Termination  -- ^ Tag 3.
  | Totality  -- ^ Tag 4.
  | Invariant  -- ^ Tag 5.
  | Refinement  -- ^ Tag 6.
  | DependentIndex  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConstraintKind' to its ABI tag value.
constraintKindToTag :: ConstraintKind -> Word8
constraintKindToTag = fromIntegral . fromEnum

-- | Decode a 'ConstraintKind' from its ABI tag value.
constraintKindFromTag :: Word8 -> Maybe ConstraintKind
constraintKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConstraintKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NeuralBackend
-- ---------------------------------------------------------------------------

-- | NeuralBackend type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NeuralBackend
  = LocalModel  -- ^ Tag 0.
  | Claude  -- ^ Tag 1.
  | Gemini  -- ^ Tag 2.
  | Mistral  -- ^ Tag 3.
  | Gpt  -- ^ Tag 4.
  | CustomNeural  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeuralBackend' to its ABI tag value.
neuralBackendToTag :: NeuralBackend -> Word8
neuralBackendToTag = fromIntegral . fromEnum

-- | Decode a 'NeuralBackend' from its ABI tag value.
neuralBackendFromTag :: Word8 -> Maybe NeuralBackend
neuralBackendFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeuralBackend)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Confidence
-- ---------------------------------------------------------------------------

-- | Confidence type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Confidence
  = Verified  -- ^ Tag 0.
  | HighNeural  -- ^ Tag 1.
  | MediumNeural  -- ^ Tag 2.
  | LowNeural  -- ^ Tag 3.
  | Unknown  -- ^ Tag 4.
  | Contradicted  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Confidence' to its ABI tag value.
confidenceToTag :: Confidence -> Word8
confidenceToTag = fromIntegral . fromEnum

-- | Decode a 'Confidence' from its ABI tag value.
confidenceFromTag :: Word8 -> Maybe Confidence
confidenceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Confidence)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DriftKind
-- ---------------------------------------------------------------------------

-- | DriftKind type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data DriftKind
  = NoDrift  -- ^ Tag 0.
  | SemanticDrift  -- ^ Tag 1.
  | ConfidenceDrift  -- ^ Tag 2.
  | FactualDrift  -- ^ Tag 3.
  | TemporalDrift  -- ^ Tag 4.
  | CatastrophicDrift  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DriftKind' to its ABI tag value.
driftKindToTag :: DriftKind -> Word8
driftKindToTag = fromIntegral . fromEnum

-- | Decode a 'DriftKind' from its ABI tag value.
driftKindFromTag :: Word8 -> Maybe DriftKind
driftKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DriftKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NeSyState
-- ---------------------------------------------------------------------------

-- | NeSyState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NeSyState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Reasoning  -- ^ Tag 2.
  | Verifying  -- ^ Tag 3.
  | Drift  -- ^ Tag 4.
  | Shutdown  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeSyState' to its ABI tag value.
neSyStateToTag :: NeSyState -> Word8
neSyStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeSyState' from its ABI tag value.
neSyStateFromTag :: Word8 -> Maybe NeSyState
neSyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeSyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
