-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Sandbox protocol types for proven-servers.
--
-- Sandbox/isolation types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Sandbox
  ( -- * ADT types matching Idris2 ABI
      ExecutionPolicy(..)
    , ResourceLimit(..)
    , SandboxState(..)
    , ExitReason(..)
    , SyscallPolicy(..)
    , executionPolicyToTag
    , executionPolicyFromTag
    , resourceLimitToTag
    , resourceLimitFromTag
    , sandboxStateToTag
    , sandboxStateFromTag
    , exitReasonToTag
    , exitReasonFromTag
    , syscallPolicyToTag
    , syscallPolicyFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ExecutionPolicy
-- ---------------------------------------------------------------------------

-- | ExecutionPolicy type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ExecutionPolicy
  = Unrestricted  -- ^ Tag 0.
  | ReadOnly  -- ^ Tag 1.
  | NetworkDenied  -- ^ Tag 2.
  | Isolated  -- ^ Tag 3.
  | Ephemeral  -- ^ Tag 4.
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

-- | ResourceLimit type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ResourceLimit
  = CpuTime  -- ^ Tag 0.
  | Memory  -- ^ Tag 1.
  | DiskIo  -- ^ Tag 2.
  | NetworkIo  -- ^ Tag 3.
  | FileDescriptors  -- ^ Tag 4.
  | Processes  -- ^ Tag 5.
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

-- | SandboxState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data SandboxState
  = Creating  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | Running  -- ^ Tag 2.
  | Suspended  -- ^ Tag 3.
  | Terminated  -- ^ Tag 4.
  | Destroyed  -- ^ Tag 5.
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

-- | ExitReason type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data ExitReason
  = Normal  -- ^ Tag 0.
  | Timeout  -- ^ Tag 1.
  | MemoryExceeded  -- ^ Tag 2.
  | PolicyViolation  -- ^ Tag 3.
  | Killed  -- ^ Tag 4.
  | Error  -- ^ Tag 5.
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

-- | SyscallPolicy type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data SyscallPolicy
  = Allow  -- ^ Tag 0.
  | Deny  -- ^ Tag 1.
  | Log  -- ^ Tag 2.
  | Trap  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SyscallPolicy' to its ABI tag value.
syscallPolicyToTag :: SyscallPolicy -> Word8
syscallPolicyToTag = fromIntegral . fromEnum

-- | Decode a 'SyscallPolicy' from its ABI tag value.
syscallPolicyFromTag :: Word8 -> Maybe SyscallPolicy
syscallPolicyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SyscallPolicy)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
