-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Neurosym protocol types for proven-servers.
--
-- Neurosymbolic engine types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Neurosym
  ( -- * ADT types matching Idris2 ABI
      InferenceMode(..)
    , SymbolicOp(..)
    , NeuralOp(..)
    , FusionStrategy(..)
    , ConfidenceLevel(..)
    , KnowledgeType(..)
    , NeurosymState(..)
    , inferenceModeToTag
    , inferenceModeFromTag
    , symbolicOpToTag
    , symbolicOpFromTag
    , neuralOpToTag
    , neuralOpFromTag
    , fusionStrategyToTag
    , fusionStrategyFromTag
    , confidenceLevelToTag
    , confidenceLevelFromTag
    , knowledgeTypeToTag
    , knowledgeTypeFromTag
    , neurosymStateToTag
    , neurosymStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- InferenceMode
-- ---------------------------------------------------------------------------

-- | InferenceMode type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data InferenceMode
  = Neural  -- ^ Tag 0.
  | Symbolic  -- ^ Tag 1.
  | Hybrid  -- ^ Tag 2.
  | Cascade  -- ^ Tag 3.
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

-- | SymbolicOp type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SymbolicOp
  = Unify  -- ^ Tag 0.
  | Resolve  -- ^ Tag 1.
  | Rewrite  -- ^ Tag 2.
  | Prove  -- ^ Tag 3.
  | Search  -- ^ Tag 4.
  | Constrain  -- ^ Tag 5.
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

-- | NeuralOp type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NeuralOp
  = Embed  -- ^ Tag 0.
  | Classify  -- ^ Tag 1.
  | Generate  -- ^ Tag 2.
  | Attend  -- ^ Tag 3.
  | Retrieve  -- ^ Tag 4.
  | Finetune  -- ^ Tag 5.
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

-- | FusionStrategy type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data FusionStrategy
  = NeuralThenSymbolic  -- ^ Tag 0.
  | SymbolicThenNeural  -- ^ Tag 1.
  | Parallel  -- ^ Tag 2.
  | Iterative  -- ^ Tag 3.
  | Gated  -- ^ Tag 4.
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

-- | ConfidenceLevel type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ConfidenceLevel
  = Proven  -- ^ Tag 0.
  | HighConfidence  -- ^ Tag 1.
  | Moderate  -- ^ Tag 2.
  | LowConfidence  -- ^ Tag 3.
  | Uncertain  -- ^ Tag 4.
  | Contradicted  -- ^ Tag 5.
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

-- | KnowledgeType type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data KnowledgeType
  = Axiom  -- ^ Tag 0.
  | Learned  -- ^ Tag 1.
  | Inferred  -- ^ Tag 2.
  | Grounded  -- ^ Tag 3.
  | Hypothetical  -- ^ Tag 4.
  | Retracted  -- ^ Tag 5.
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

-- | NeurosymState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NeurosymState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Inferring  -- ^ Tag 2.
  | Reasoning  -- ^ Tag 3.
  | Fusing  -- ^ Tag 4.
  | Shutdown  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NeurosymState' to its ABI tag value.
neurosymStateToTag :: NeurosymState -> Word8
neurosymStateToTag = fromIntegral . fromEnum

-- | Decode a 'NeurosymState' from its ABI tag value.
neurosymStateFromTag :: Word8 -> Maybe NeurosymState
neurosymStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NeurosymState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
