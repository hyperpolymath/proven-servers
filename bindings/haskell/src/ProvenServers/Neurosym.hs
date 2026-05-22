-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Neurosymbolic Engine types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Neurosym
  (
    InferenceMode(..)
  , inferenceModeToTag
  , inferenceModeFromTag
  , SymbolicOp(..)
  , symbolicOpToTag
  , symbolicOpFromTag
  , NeuralOp(..)
  , neuralOpToTag
  , neuralOpFromTag
  , FusionStrategy(..)
  , fusionStrategyToTag
  , fusionStrategyFromTag
  , ConfidenceLevel(..)
  , confidenceLevelToTag
  , confidenceLevelFromTag
  , KnowledgeType(..)
  , knowledgeTypeToTag
  , knowledgeTypeFromTag
  , NeurosymState(..)
  , neurosymStateToTag
  , neurosymStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- InferenceMode
-- ---------------------------------------------------------------------------

-- | Neurosymbolic inference modes.
--
-- Tags 0-3 (4 constructors).
data InferenceMode
  = Neural  -- ^ Neural (tag 0).
  | Symbolic  -- ^ Symbolic (tag 1).
  | Hybrid  -- ^ Hybrid (tag 2).
  | Cascade  -- ^ Cascade (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'InferenceMode' to its ABI tag value.
inferenceModeToTag :: InferenceMode -> Word8
inferenceModeToTag = fromIntegral . fromEnum

-- | Decode a 'InferenceMode' from its ABI tag value.
inferenceModeFromTag :: Word8 -> Maybe InferenceMode
inferenceModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: InferenceMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SymbolicOp
-- ---------------------------------------------------------------------------

-- | Symbolic reasoning operations.
--
-- Tags 0-5 (6 constructors).
data SymbolicOp
  = Unify  -- ^ Unify (tag 0).
  | Resolve  -- ^ Resolve (tag 1).
  | Rewrite  -- ^ Rewrite (tag 2).
  | Prove  -- ^ Prove (tag 3).
  | Search  -- ^ Search (tag 4).
  | Constrain  -- ^ Constrain (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SymbolicOp' to its ABI tag value.
symbolicOpToTag :: SymbolicOp -> Word8
symbolicOpToTag = fromIntegral . fromEnum

-- | Decode a 'SymbolicOp' from its ABI tag value.
symbolicOpFromTag :: Word8 -> Maybe SymbolicOp
symbolicOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SymbolicOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NeuralOp
-- ---------------------------------------------------------------------------

-- | Neural inference operations.
--
-- Tags 0-5 (6 constructors).
data NeuralOp
  = Embed  -- ^ Embed (tag 0).
  | Classify  -- ^ Classify (tag 1).
  | Generate  -- ^ Generate (tag 2).
  | Attend  -- ^ Attend (tag 3).
  | Retrieve  -- ^ Retrieve (tag 4).
  | Finetune  -- ^ Finetune (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeuralOp' to its ABI tag value.
neuralOpToTag :: NeuralOp -> Word8
neuralOpToTag = fromIntegral . fromEnum

-- | Decode a 'NeuralOp' from its ABI tag value.
neuralOpFromTag :: Word8 -> Maybe NeuralOp
neuralOpFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeuralOp)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FusionStrategy
-- ---------------------------------------------------------------------------

-- | Neural-symbolic fusion strategies.
--
-- Tags 0-4 (5 constructors).
data FusionStrategy
  = NeuralThenSymbolic  -- ^ NeuralThenSymbolic (tag 0).
  | SymbolicThenNeural  -- ^ SymbolicThenNeural (tag 1).
  | Parallel  -- ^ Parallel (tag 2).
  | Iterative  -- ^ Iterative (tag 3).
  | Gated  -- ^ Gated (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FusionStrategy' to its ABI tag value.
fusionStrategyToTag :: FusionStrategy -> Word8
fusionStrategyToTag = fromIntegral . fromEnum

-- | Decode a 'FusionStrategy' from its ABI tag value.
fusionStrategyFromTag :: Word8 -> Maybe FusionStrategy
fusionStrategyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FusionStrategy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConfidenceLevel
-- ---------------------------------------------------------------------------

-- | Inference confidence levels.
--
-- Tags 0-5 (6 constructors).
data ConfidenceLevel
  = Proven  -- ^ Proven (tag 0).
  | HighConfidence  -- ^ HighConfidence (tag 1).
  | Moderate  -- ^ Moderate (tag 2).
  | LowConfidence  -- ^ LowConfidence (tag 3).
  | Uncertain  -- ^ Uncertain (tag 4).
  | Contradicted  -- ^ Contradicted (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConfidenceLevel' to its ABI tag value.
confidenceLevelToTag :: ConfidenceLevel -> Word8
confidenceLevelToTag = fromIntegral . fromEnum

-- | Decode a 'ConfidenceLevel' from its ABI tag value.
confidenceLevelFromTag :: Word8 -> Maybe ConfidenceLevel
confidenceLevelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConfidenceLevel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KnowledgeType
-- ---------------------------------------------------------------------------

-- | Knowledge entry types.
--
-- Tags 0-5 (6 constructors).
data KnowledgeType
  = Axiom  -- ^ Axiom (tag 0).
  | Learned  -- ^ Learned (tag 1).
  | Inferred  -- ^ Inferred (tag 2).
  | Grounded  -- ^ Grounded (tag 3).
  | Hypothetical  -- ^ Hypothetical (tag 4).
  | Retracted  -- ^ Retracted (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KnowledgeType' to its ABI tag value.
knowledgeTypeToTag :: KnowledgeType -> Word8
knowledgeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'KnowledgeType' from its ABI tag value.
knowledgeTypeFromTag :: Word8 -> Maybe KnowledgeType
knowledgeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KnowledgeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NeurosymState
-- ---------------------------------------------------------------------------

-- | Neurosymbolic engine states.
--
-- Tags 0-5 (6 constructors).
data NeurosymState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | Inferring  -- ^ Inferring (tag 2).
  | Reasoning  -- ^ Reasoning (tag 3).
  | Fusing  -- ^ Fusing (tag 4).
  | Shutdown  -- ^ Shutdown (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeurosymState' to its ABI tag value.
neurosymStateToTag :: NeurosymState -> Word8
neurosymStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeurosymState' from its ABI tag value.
neurosymStateFromTag :: Word8 -> Maybe NeurosymState
neurosymStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeurosymState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
