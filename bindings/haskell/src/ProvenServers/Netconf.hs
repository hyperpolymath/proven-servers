-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NETCONF protocol types for proven-servers.
--
-- NETCONF types (RFC 6241), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Netconf
  ( -- * ADT types matching Idris2 ABI
      NetconfOperation(..)
    , Datastore(..)
    , EditOperation(..)
    , NetconfErrorType(..)
    , ErrorSeverity(..)
    , NetconfState(..)
    , netconfOperationToTag
    , netconfOperationFromTag
    , datastoreToTag
    , datastoreFromTag
    , editOperationToTag
    , editOperationFromTag
    , netconfErrorTypeToTag
    , netconfErrorTypeFromTag
    , errorSeverityToTag
    , errorSeverityFromTag
    , netconfStateToTag
    , netconfStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- NetconfOperation
-- ---------------------------------------------------------------------------

-- | NetconfOperation type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data NetconfOperation
  = Get  -- ^ Tag 0.
  | GetConfig  -- ^ Tag 1.
  | EditConfig  -- ^ Tag 2.
  | CopyConfig  -- ^ Tag 3.
  | DeleteConfig  -- ^ Tag 4.
  | Lock  -- ^ Tag 5.
  | Unlock  -- ^ Tag 6.
  | CloseSession  -- ^ Tag 7.
  | KillSession  -- ^ Tag 8.
  | Commit  -- ^ Tag 9.
  | Validate  -- ^ Tag 10.
  | DiscardChanges  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetconfOperation' to its ABI tag value.
netconfOperationToTag :: NetconfOperation -> Word8
netconfOperationToTag = fromIntegral . fromEnum

-- | Decode a 'NetconfOperation' from its ABI tag value.
netconfOperationFromTag :: Word8 -> Maybe NetconfOperation
netconfOperationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetconfOperation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Datastore
-- ---------------------------------------------------------------------------

-- | Datastore type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Datastore
  = Running  -- ^ Tag 0.
  | Startup  -- ^ Tag 1.
  | Candidate  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Datastore' to its ABI tag value.
datastoreToTag :: Datastore -> Word8
datastoreToTag = fromIntegral . fromEnum

-- | Decode a 'Datastore' from its ABI tag value.
datastoreFromTag :: Word8 -> Maybe Datastore
datastoreFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Datastore)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EditOperation
-- ---------------------------------------------------------------------------

-- | EditOperation type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data EditOperation
  = Merge  -- ^ Tag 0.
  | Replace  -- ^ Tag 1.
  | Create  -- ^ Tag 2.
  | Delete  -- ^ Tag 3.
  | Remove  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EditOperation' to its ABI tag value.
editOperationToTag :: EditOperation -> Word8
editOperationToTag = fromIntegral . fromEnum

-- | Decode a 'EditOperation' from its ABI tag value.
editOperationFromTag :: Word8 -> Maybe EditOperation
editOperationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EditOperation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NetconfErrorType
-- ---------------------------------------------------------------------------

-- | NetconfErrorType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data NetconfErrorType
  = Transport  -- ^ Tag 0.
  | Rpc  -- ^ Tag 1.
  | Protocol  -- ^ Tag 2.
  | Application  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetconfErrorType' to its ABI tag value.
netconfErrorTypeToTag :: NetconfErrorType -> Word8
netconfErrorTypeToTag = fromIntegral . fromEnum

-- | Decode a 'NetconfErrorType' from its ABI tag value.
netconfErrorTypeFromTag :: Word8 -> Maybe NetconfErrorType
netconfErrorTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetconfErrorType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorSeverity
-- ---------------------------------------------------------------------------

-- | ErrorSeverity type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ErrorSeverity
  = Error  -- ^ Tag 0.
  | Warning  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorSeverity' to its ABI tag value.
errorSeverityToTag :: ErrorSeverity -> Word8
errorSeverityToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorSeverity' from its ABI tag value.
errorSeverityFromTag :: Word8 -> Maybe ErrorSeverity
errorSeverityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorSeverity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NetconfState
-- ---------------------------------------------------------------------------

-- | NetconfState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NetconfState
  = Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | Locked  -- ^ Tag 2.
  | Editing  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  | Terminated  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetconfState' to its ABI tag value.
netconfStateToTag :: NetconfState -> Word8
netconfStateToTag = fromIntegral . fromEnum

-- | Decode a 'NetconfState' from its ABI tag value.
netconfStateFromTag :: Word8 -> Maybe NetconfState
netconfStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetconfState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
