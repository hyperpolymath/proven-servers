-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NeSy types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Nesy
  (
    ReasoningMode(..)
  , reasoningModeToTag
  , reasoningModeFromTag
  , ProofStatus(..)
  , proofStatusToTag
  , proofStatusFromTag
  , ConstraintKind(..)
  , constraintKindToTag
  , constraintKindFromTag
  , NeuralBackend(..)
  , neuralBackendToTag
  , neuralBackendFromTag
  , Confidence(..)
  , confidenceToTag
  , confidenceFromTag
  , DriftKind(..)
  , driftKindToTag
  , driftKindFromTag
  , NeSyState(..)
  , neSyStateToTag
  , neSyStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ReasoningMode
-- ---------------------------------------------------------------------------

-- | Neurosymbolic reasoning modes.
--
-- Tags 0-5 (6 constructors).
data ReasoningMode
  = Symbolic  -- ^ Symbolic (tag 0).
  | Neural  -- ^ Neural (tag 1).
  | SymToNeural  -- ^ SymToNeural (tag 2).
  | NeuralToSym  -- ^ NeuralToSym (tag 3).
  | Ensemble  -- ^ Ensemble (tag 4).
  | Cascade  -- ^ Cascade (tag 5).
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

-- | Proof verification status.
--
-- Tags 0-5 (6 constructors).
data ProofStatus
  = Pending  -- ^ Pending (tag 0).
  | Attempting  -- ^ Attempting (tag 1).
  | Proved  -- ^ Proved (tag 2).
  | Failed  -- ^ Failed (tag 3).
  | Assumed  -- ^ Assumed (tag 4).
  | Vacuous  -- ^ Vacuous (tag 5).
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

-- | Type constraint kinds.
--
-- Tags 0-7 (8 constructors).
data ConstraintKind
  = TypeEquality  -- ^ TypeEquality (tag 0).
  | Subtype  -- ^ Subtype (tag 1).
  | Linearity  -- ^ Linearity (tag 2).
  | Termination  -- ^ Termination (tag 3).
  | Totality  -- ^ Totality (tag 4).
  | Invariant  -- ^ Invariant (tag 5).
  | Refinement  -- ^ Refinement (tag 6).
  | DependentIndex  -- ^ DependentIndex (tag 7).
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

-- | Neural inference backend providers.
--
-- Tags 0-5 (6 constructors).
data NeuralBackend
  = LocalModel  -- ^ LocalModel (tag 0).
  | Claude  -- ^ Claude (tag 1).
  | Gemini  -- ^ Gemini (tag 2).
  | Mistral  -- ^ Mistral (tag 3).
  | Gpt  -- ^ GPT (tag 4).
  | CustomNeural  -- ^ CustomNeural (tag 5).
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

-- | Inference confidence levels.
--
-- Tags 0-5 (6 constructors).
data Confidence
  = Verified  -- ^ Verified (tag 0).
  | HighNeural  -- ^ HighNeural (tag 1).
  | MediumNeural  -- ^ MediumNeural (tag 2).
  | LowNeural  -- ^ LowNeural (tag 3).
  | Unknown  -- ^ Unknown (tag 4).
  | Contradicted  -- ^ Contradicted (tag 5).
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

-- | Knowledge drift types.
--
-- Tags 0-5 (6 constructors).
data DriftKind
  = NoDrift  -- ^ NoDrift (tag 0).
  | SemanticDrift  -- ^ SemanticDrift (tag 1).
  | ConfidenceDrift  -- ^ ConfidenceDrift (tag 2).
  | FactualDrift  -- ^ FactualDrift (tag 3).
  | TemporalDrift  -- ^ TemporalDrift (tag 4).
  | CatastrophicDrift  -- ^ CatastrophicDrift (tag 5).
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

-- | NeSy engine states.
--
-- Tags 0-5 (6 constructors).
data NeSyState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | Reasoning  -- ^ Reasoning (tag 2).
  | Verifying  -- ^ Verifying (tag 3).
  | Drift  -- ^ Drift (tag 4).
  | Shutdown  -- ^ Shutdown (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeSyState' to its ABI tag value.
neSyStateToTag :: NeSyState -> Word8
neSyStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeSyState' from its ABI tag value.
neSyStateFromTag :: Word8 -> Maybe NeSyState
neSyStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeSyState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
