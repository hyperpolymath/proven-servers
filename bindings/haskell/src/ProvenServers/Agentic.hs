-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Agentic AI protocol types for proven-servers.
--
-- Agentic AI orchestration types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Agentic
  ( -- * ADT types matching Idris2 ABI
      AgentState(..)
    , ToolCall(..)
    , PlanStep(..)
    , Coordination(..)
    , SafetyCheck(..)
    , agentStateToTag
    , agentStateFromTag
    , toolCallToTag
    , toolCallFromTag
    , planStepToTag
    , planStepFromTag
    , coordinationToTag
    , coordinationFromTag
    , safetyCheckToTag
    , safetyCheckFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AgentState
-- ---------------------------------------------------------------------------

-- | AgentState type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data AgentState
  = Idle  -- ^ Tag 0.
  | Planning  -- ^ Tag 1.
  | Acting  -- ^ Tag 2.
  | Observing  -- ^ Tag 3.
  | Reflecting  -- ^ Tag 4.
  | Blocked  -- ^ Tag 5.
  | Terminated  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AgentState' to its ABI tag value.
agentStateToTag :: AgentState -> Word8
agentStateToTag = fromIntegral . fromEnum

-- | Decode a 'AgentState' from its ABI tag value.
agentStateFromTag :: Word8 -> Maybe AgentState
agentStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AgentState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ToolCall
-- ---------------------------------------------------------------------------

-- | ToolCall type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ToolCall
  = Execute  -- ^ Tag 0.
  | Query  -- ^ Tag 1.
  | Transform  -- ^ Tag 2.
  | Communicate  -- ^ Tag 3.
  | Delegate  -- ^ Tag 4.
  | Escalate  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ToolCall' to its ABI tag value.
toolCallToTag :: ToolCall -> Word8
toolCallToTag = fromIntegral . fromEnum

-- | Decode a 'ToolCall' from its ABI tag value.
toolCallFromTag :: Word8 -> Maybe ToolCall
toolCallFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ToolCall)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PlanStep
-- ---------------------------------------------------------------------------

-- | PlanStep type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data PlanStep
  = Action  -- ^ Tag 0.
  | Condition  -- ^ Tag 1.
  | Loop  -- ^ Tag 2.
  | Branch  -- ^ Tag 3.
  | Parallel  -- ^ Tag 4.
  | Checkpoint  -- ^ Tag 5.
  | Rollback  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PlanStep' to its ABI tag value.
planStepToTag :: PlanStep -> Word8
planStepToTag = fromIntegral . fromEnum

-- | Decode a 'PlanStep' from its ABI tag value.
planStepFromTag :: Word8 -> Maybe PlanStep
planStepFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PlanStep)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Coordination
-- ---------------------------------------------------------------------------

-- | Coordination type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Coordination
  = Solo  -- ^ Tag 0.
  | Collaborative  -- ^ Tag 1.
  | Competitive  -- ^ Tag 2.
  | Hierarchical  -- ^ Tag 3.
  | Swarm  -- ^ Tag 4.
  | Consensus  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Coordination' to its ABI tag value.
coordinationToTag :: Coordination -> Word8
coordinationToTag = fromIntegral . fromEnum

-- | Decode a 'Coordination' from its ABI tag value.
coordinationFromTag :: Word8 -> Maybe Coordination
coordinationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Coordination)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SafetyCheck
-- ---------------------------------------------------------------------------

-- | SafetyCheck type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SafetyCheck
  = Approved  -- ^ Tag 0.
  | Denied  -- ^ Tag 1.
  | Escalated  -- ^ Tag 2.
  | Timeout  -- ^ Tag 3.
  | Sandboxed  -- ^ Tag 4.
  | HumanRequired  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SafetyCheck' to its ABI tag value.
safetyCheckToTag :: SafetyCheck -> Word8
safetyCheckToTag = fromIntegral . fromEnum

-- | Decode a 'SafetyCheck' from its ABI tag value.
safetyCheckFromTag :: Word8 -> Maybe SafetyCheck
safetyCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SafetyCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
