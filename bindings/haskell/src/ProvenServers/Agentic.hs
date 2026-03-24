-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Agentic AI types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Agentic
  (
    AgentState(..)
  , agentStateToTag
  , agentStateFromTag
  , isActive
  , ToolCall(..)
  , toolCallToTag
  , toolCallFromTag
  , PlanStep(..)
  , planStepToTag
  , planStepFromTag
  , Coordination(..)
  , coordinationToTag
  , coordinationFromTag
  , SafetyCheck(..)
  , safetyCheckToTag
  , safetyCheckFromTag
  , isSafe
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- AgentState
-- ---------------------------------------------------------------------------

-- | AI agent lifecycle states.
--
-- Tags 0-6 (7 constructors).
data AgentState
  = Idle  -- ^ Idle (tag 0).
  | Planning  -- ^ Planning (tag 1).
  | Acting  -- ^ Acting (tag 2).
  | Observing  -- ^ Observing (tag 3).
  | Reflecting  -- ^ Reflecting (tag 4).
  | Blocked  -- ^ Blocked (tag 5).
  | Terminated  -- ^ Terminated (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AgentState' to its ABI tag value.
agentStateToTag :: AgentState -> Word8
agentStateToTag = fromIntegral . fromEnum

-- | Decode a 'AgentState' from its ABI tag value.
agentStateFromTag :: Word8 -> Maybe AgentState
agentStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AgentState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the agent is actively working.
isActive :: AgentState -> Bool
isActive Planning = True
isActive Acting = True
isActive Observing = True
isActive Reflecting = True
isActive _ = False

-- ---------------------------------------------------------------------------
-- ToolCall
-- ---------------------------------------------------------------------------

-- | Agent tool call types.
--
-- Tags 0-5 (6 constructors).
data ToolCall
  = Execute  -- ^ Execute (tag 0).
  | Query  -- ^ Query (tag 1).
  | Transform  -- ^ Transform (tag 2).
  | Communicate  -- ^ Communicate (tag 3).
  | Delegate  -- ^ Delegate (tag 4).
  | Escalate  -- ^ Escalate (tag 5).
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

-- | Agent plan step types.
--
-- Tags 0-6 (7 constructors).
data PlanStep
  = Action  -- ^ Action (tag 0).
  | Condition  -- ^ Condition (tag 1).
  | Loop  -- ^ Loop (tag 2).
  | Branch  -- ^ Branch (tag 3).
  | Parallel  -- ^ Parallel (tag 4).
  | Checkpoint  -- ^ Checkpoint (tag 5).
  | Rollback  -- ^ Rollback (tag 6).
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

-- | Multi-agent coordination modes.
--
-- Tags 0-5 (6 constructors).
data Coordination
  = Solo  -- ^ Solo (tag 0).
  | Collaborative  -- ^ Collaborative (tag 1).
  | Competitive  -- ^ Competitive (tag 2).
  | Hierarchical  -- ^ Hierarchical (tag 3).
  | Swarm  -- ^ Swarm (tag 4).
  | Consensus  -- ^ Consensus (tag 5).
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

-- | Agent safety check results.
--
-- Tags 0-5 (6 constructors).
data SafetyCheck
  = Approved  -- ^ Approved (tag 0).
  | Denied  -- ^ Denied (tag 1).
  | Escalated  -- ^ Escalated (tag 2).
  | Timeout  -- ^ Timeout (tag 3).
  | Sandboxed  -- ^ Sandboxed (tag 4).
  | HumanRequired  -- ^ HumanRequired (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SafetyCheck' to its ABI tag value.
safetyCheckToTag :: SafetyCheck -> Word8
safetyCheckToTag = fromIntegral . fromEnum

-- | Decode a 'SafetyCheck' from its ABI tag value.
safetyCheckFromTag :: Word8 -> Maybe SafetyCheck
safetyCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SafetyCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the action is approved to proceed.
isSafe :: SafetyCheck -> Bool
isSafe Approved = True
isSafe Sandboxed = True
isSafe _ = False
