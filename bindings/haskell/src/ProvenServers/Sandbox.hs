-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Sandbox types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Sandbox
  (
    ExecutionPolicy(..)
  , executionPolicyToTag
  , executionPolicyFromTag
  , ResourceLimit(..)
  , resourceLimitToTag
  , resourceLimitFromTag
  , SandboxState(..)
  , sandboxStateToTag
  , sandboxStateFromTag
  , ExitReason(..)
  , exitReasonToTag
  , exitReasonFromTag
  , SyscallPolicy(..)
  , syscallPolicyToTag
  , syscallPolicyFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ExecutionPolicy
-- ---------------------------------------------------------------------------

-- | Sandbox execution policies.
--
-- Tags 0-4 (5 constructors).
data ExecutionPolicy
  = Unrestricted  -- ^ Unrestricted (tag 0).
  | ReadOnly  -- ^ ReadOnly (tag 1).
  | NetworkDenied  -- ^ NetworkDenied (tag 2).
  | Isolated  -- ^ Isolated (tag 3).
  | Ephemeral  -- ^ Ephemeral (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExecutionPolicy' to its ABI tag value.
executionPolicyToTag :: ExecutionPolicy -> Word8
executionPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'ExecutionPolicy' from its ABI tag value.
executionPolicyFromTag :: Word8 -> Maybe ExecutionPolicy
executionPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExecutionPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ResourceLimit
-- ---------------------------------------------------------------------------

-- | Sandbox resource limits.
--
-- Tags 0-5 (6 constructors).
data ResourceLimit
  = CpuTime  -- ^ CPU time (tag 0).
  | Memory  -- ^ Memory (tag 1).
  | DiskIo  -- ^ Disk I/O (tag 2).
  | NetworkIo  -- ^ Network I/O (tag 3).
  | FileDescriptors  -- ^ FileDescriptors (tag 4).
  | Processes  -- ^ Processes (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ResourceLimit' to its ABI tag value.
resourceLimitToTag :: ResourceLimit -> Word8
resourceLimitToTag = fromIntegral . fromEnum

-- | Decode a 'ResourceLimit' from its ABI tag value.
resourceLimitFromTag :: Word8 -> Maybe ResourceLimit
resourceLimitFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ResourceLimit)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SandboxState
-- ---------------------------------------------------------------------------

-- | Sandbox lifecycle states.
--
-- Tags 0-5 (6 constructors).
data SandboxState
  = Creating  -- ^ Creating (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | Running  -- ^ Running (tag 2).
  | Suspended  -- ^ Suspended (tag 3).
  | Terminated  -- ^ Terminated (tag 4).
  | Destroyed  -- ^ Destroyed (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SandboxState' to its ABI tag value.
sandboxStateToTag :: SandboxState -> Word8
sandboxStateToTag = fromIntegral . fromEnum

-- | Decode a 'SandboxState' from its ABI tag value.
sandboxStateFromTag :: Word8 -> Maybe SandboxState
sandboxStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SandboxState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ExitReason
-- ---------------------------------------------------------------------------

-- | Sandbox exit reasons.
--
-- Tags 0-5 (6 constructors).
data ExitReason
  = Normal  -- ^ Normal (tag 0).
  | Timeout  -- ^ Timeout (tag 1).
  | MemoryExceeded  -- ^ MemoryExceeded (tag 2).
  | PolicyViolation  -- ^ PolicyViolation (tag 3).
  | Killed  -- ^ Killed (tag 4).
  | Error  -- ^ Error (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExitReason' to its ABI tag value.
exitReasonToTag :: ExitReason -> Word8
exitReasonToTag = fromIntegral . fromEnum

-- | Decode a 'ExitReason' from its ABI tag value.
exitReasonFromTag :: Word8 -> Maybe ExitReason
exitReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExitReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SyscallPolicy
-- ---------------------------------------------------------------------------

-- | System call filter policies.
--
-- Tags 0-3 (4 constructors).
data SyscallPolicy
  = Allow  -- ^ Allow (tag 0).
  | Deny  -- ^ Deny (tag 1).
  | Log  -- ^ Log (tag 2).
  | Trap  -- ^ Trap (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SyscallPolicy' to its ABI tag value.
syscallPolicyToTag :: SyscallPolicy -> Word8
syscallPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'SyscallPolicy' from its ABI tag value.
syscallPolicyFromTag :: Word8 -> Maybe SyscallPolicy
syscallPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SyscallPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
