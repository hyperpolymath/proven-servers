-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NETCONF types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Netconf
  (
    netconfPort
  , NetconfOperation(..)
  , netconfOperationToTag
  , netconfOperationFromTag
  , Datastore(..)
  , datastoreToTag
  , datastoreFromTag
  , EditOperation(..)
  , editOperationToTag
  , editOperationFromTag
  , NetconfErrorType(..)
  , netconfErrorTypeToTag
  , netconfErrorTypeFromTag
  , ErrorSeverity(..)
  , errorSeverityToTag
  , errorSeverityFromTag
  , NetconfState(..)
  , netconfStateToTag
  , netconfStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard NETCONF SSH port.
netconfPort :: Word16
netconfPort = 830

-- ---------------------------------------------------------------------------
-- NetconfOperation
-- ---------------------------------------------------------------------------

-- | Standard NETCONF SSH port.
--
-- Tags 0-11 (12 constructors).
data NetconfOperation
  = Get  -- ^ Get (tag 0).
  | GetConfig  -- ^ GetConfig (tag 1).
  | EditConfig  -- ^ EditConfig (tag 2).
  | CopyConfig  -- ^ CopyConfig (tag 3).
  | DeleteConfig  -- ^ DeleteConfig (tag 4).
  | Lock  -- ^ Lock (tag 5).
  | Unlock  -- ^ Unlock (tag 6).
  | CloseSession  -- ^ CloseSession (tag 7).
  | KillSession  -- ^ KillSession (tag 8).
  | Commit  -- ^ Commit (tag 9).
  | Validate  -- ^ Validate (tag 10).
  | DiscardChanges  -- ^ DiscardChanges (tag 11).
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

-- | NETCONF datastores.
--
-- Tags 0-2 (3 constructors).
data Datastore
  = Running  -- ^ Running (tag 0).
  | Startup  -- ^ Startup (tag 1).
  | Candidate  -- ^ Candidate (tag 2).
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

-- | NETCONF edit operations.
--
-- Tags 0-4 (5 constructors).
data EditOperation
  = Merge  -- ^ Merge (tag 0).
  | Replace  -- ^ Replace (tag 1).
  | Create  -- ^ Create (tag 2).
  | Delete  -- ^ Delete (tag 3).
  | Remove  -- ^ Remove (tag 4).
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

-- | NETCONF error types.
--
-- Tags 0-3 (4 constructors).
data NetconfErrorType
  = Transport  -- ^ Transport (tag 0).
  | Rpc  -- ^ RPC (tag 1).
  | Protocol  -- ^ Protocol (tag 2).
  | Application  -- ^ Application (tag 3).
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

-- | NETCONF error severity.
--
-- Tags 0-1 (2 constructors).
data ErrorSeverity
  = Error  -- ^ Error (tag 0).
  | Warning  -- ^ Warning (tag 1).
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

-- | NETCONF session states.
--
-- Tags 0-5 (6 constructors).
data NetconfState
  = Idle  -- ^ Idle (tag 0).
  | Connected  -- ^ Connected (tag 1).
  | Locked  -- ^ Locked (tag 2).
  | Editing  -- ^ Editing (tag 3).
  | Closing  -- ^ Closing (tag 4).
  | Terminated  -- ^ Terminated (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NetconfState' to its ABI tag value.
netconfStateToTag :: NetconfState -> Word8
netconfStateToTag = fromIntegral . fromEnum

-- | Decode a 'NetconfState' from its ABI tag value.
netconfStateFromTag :: Word8 -> Maybe NetconfState
netconfStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NetconfState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
