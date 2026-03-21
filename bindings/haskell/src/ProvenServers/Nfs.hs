-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NFS protocol types for proven-servers.
--
-- NFS (Network File System) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Nfs
  ( -- * ADT types matching Idris2 ABI
      Operation(..)
    , FileType(..)
    , Status(..)
    , NfsState(..)
    , operationToTag
    , operationFromTag
    , fileTypeToTag
    , fileTypeFromTag
    , statusToTag
    , statusFromTag
    , nfsStateToTag
    , nfsStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Operation type matching the Idris2 ABI.
--
-- Tags 0-14 (15 constructors).
data Operation
  = Operation_Access  -- ^ Tag 0.
  | Close  -- ^ Tag 1.
  | Commit  -- ^ Tag 2.
  | Create  -- ^ Tag 3.
  | GetAttr  -- ^ Tag 4.
  | Operation_Link  -- ^ Tag 5.
  | Lock  -- ^ Tag 6.
  | Lookup  -- ^ Tag 7.
  | Open  -- ^ Tag 8.
  | Read  -- ^ Tag 9.
  | ReadDir  -- ^ Tag 10.
  | Remove  -- ^ Tag 11.
  | Rename  -- ^ Tag 12.
  | SetAttr  -- ^ Tag 13.
  | Write  -- ^ Tag 14.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FileType
-- ---------------------------------------------------------------------------

-- | FileType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data FileType
  = Regular  -- ^ Tag 0.
  | Directory  -- ^ Tag 1.
  | BlockDevice  -- ^ Tag 2.
  | CharDevice  -- ^ Tag 3.
  | FileType_Link  -- ^ Tag 4.
  | Socket  -- ^ Tag 5.
  | Fifo  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FileType' to its ABI tag value.
fileTypeToTag :: FileType -> Word8
fileTypeToTag = fromIntegral . fromEnum

-- | Decode a 'FileType' from its ABI tag value.
fileTypeFromTag :: Word8 -> Maybe FileType
fileTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FileType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------

-- | Status type matching the Idris2 ABI.
--
-- Tags 0-13 (14 constructors).
data Status
  = Ok  -- ^ Tag 0.
  | Perm  -- ^ Tag 1.
  | NoEnt  -- ^ Tag 2.
  | Io  -- ^ Tag 3.
  | NxIo  -- ^ Tag 4.
  | Status_Access  -- ^ Tag 5.
  | Exist  -- ^ Tag 6.
  | NotDir  -- ^ Tag 7.
  | IsDir  -- ^ Tag 8.
  | FBig  -- ^ Tag 9.
  | NoSpc  -- ^ Tag 10.
  | ROfs  -- ^ Tag 11.
  | NotEmpty  -- ^ Tag 12.
  | Stale  -- ^ Tag 13.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Status' to its ABI tag value.
statusToTag :: Status -> Word8
statusToTag = fromIntegral . fromEnum

-- | Decode a 'Status' from its ABI tag value.
statusFromTag :: Word8 -> Maybe Status
statusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Status)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NfsState
-- ---------------------------------------------------------------------------

-- | NfsState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data NfsState
  = Idle  -- ^ Tag 0.
  | Mounted  -- ^ Tag 1.
  | FileOpen  -- ^ Tag 2.
  | Locked  -- ^ Tag 3.
  | Busy  -- ^ Tag 4.
  | Unmounting  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NfsState' to its ABI tag value.
nfsStateToTag :: NfsState -> Word8
nfsStateToTag = fromIntegral . fromEnum

-- | Decode a 'NfsState' from its ABI tag value.
nfsStateFromTag :: Word8 -> Maybe NfsState
nfsStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NfsState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
