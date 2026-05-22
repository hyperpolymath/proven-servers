-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | NFS (Network File System) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Nfs
  (
    nfsPort
  , Operation(..)
  , operationToTag
  , operationFromTag
  , isWrite
  , isRead
  , FileType(..)
  , fileTypeToTag
  , fileTypeFromTag
  , isRegular
  , isDevice
  , Status(..)
  , statusToTag
  , statusFromTag
  , isOk
  , isAccessError
  , isRetryable
  , NfsState(..)
  , nfsStateToTag
  , nfsStateFromTag
  , isMounted
  ) where

import Data.Word (Word16, Word8)

-- | Standard NFS port (RFC 7530).
nfsPort :: Word16
nfsPort = 2049

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Standard NFS port (RFC 7530).
--
-- Tags 0-14 (15 constructors).
data Operation
  = Access  -- ^ Check access permissions (tag 0).
  | Close  -- ^ Close a stateful file handle (tag 1).
  | Commit  -- ^ Commit cached data to stable storage (tag 2).
  | Create  -- ^ Create a file or directory (tag 3).
  | GetAttr  -- ^ Get file attributes (tag 4).
  | Link  -- ^ Create a hard link (tag 5).
  | Lock  -- ^ Lock a byte range (tag 6).
  | Lookup  -- ^ Look up a name in a directory (tag 7).
  | Open  -- ^ Open a file (tag 8).
  | Read  -- ^ Read file data (tag 9).
  | ReadDir  -- ^ List directory entries (tag 10).
  | Remove  -- ^ Remove a file or directory (tag 11).
  | Rename  -- ^ Rename a file or directory (tag 12).
  | SetAttr  -- ^ Set file attributes (tag 13).
  | Write  -- ^ Write file data (tag 14).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this operation modifies the filesystem.
isWrite :: Operation -> Bool
isWrite Create = True
isWrite Link = True
isWrite Remove = True
isWrite Rename = True
isWrite SetAttr = True
isWrite Write = True
isWrite Commit = True
isWrite _ = False

-- | Whether this operation is read-only.
isRead :: Operation -> Bool
isRead Access = True
isRead GetAttr = True
isRead Lookup = True
isRead Read = True
isRead ReadDir = True
isRead _ = False

-- ---------------------------------------------------------------------------
-- FileType
-- ---------------------------------------------------------------------------

-- | NFS file types (RFC 7530 Section 5.8).
--
-- Tags 0-6 (7 constructors).
data FileType
  = Regular  -- ^ Regular file (tag 0).
  | Directory  -- ^ Directory (tag 1).
  | BlockDevice  -- ^ Block device (tag 2).
  | CharDevice  -- ^ Character device (tag 3).
  | Link  -- ^ Symbolic link (tag 4).
  | Socket  -- ^ Unix domain socket (tag 5).
  | Fifo  -- ^ Named pipe / FIFO (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FileType' to its ABI tag value.
fileTypeToTag :: FileType -> Word8
fileTypeToTag = fromIntegral . fromEnum

-- | Decode a 'FileType' from its ABI tag value.
fileTypeFromTag :: Word8 -> Maybe FileType
fileTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FileType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this file type is a regular data file.
isRegular :: FileType -> Bool
isRegular Regular = True
isRegular _ = False

-- | Whether this file type is a special device node.
isDevice :: FileType -> Bool
isDevice BlockDevice = True
isDevice CharDevice = True
isDevice _ = False

-- ---------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------

-- | NFS status codes (RFC 7530 Section 13).
--
-- Tags 0-13 (14 constructors).
data Status
  = Ok  -- ^ Success (tag 0).
  | Perm  -- ^ Permission denied (tag 1).
  | NoEnt  -- ^ No such file or directory (tag 2).
  | Io  -- ^ I/O error (tag 3).
  | NxIo  -- ^ No such device or address (tag 4).
  | Access  -- ^ Access denied (tag 5).
  | Exist  -- ^ File or directory already exists (tag 6).
  | NotDir  -- ^ Not a directory (tag 7).
  | IsDir  -- ^ Is a directory (tag 8).
  | FBig  -- ^ File too large (tag 9).
  | NoSpc  -- ^ No space left on device (tag 10).
  | ROfs  -- ^ Read-only file system (tag 11).
  | NotEmpty  -- ^ Directory not empty (tag 12).
  | Stale  -- ^ Stale file handle (tag 13).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Status' to its ABI tag value.
statusToTag :: Status -> Word8
statusToTag = fromIntegral . fromEnum

-- | Decode a 'Status' from its ABI tag value.
statusFromTag :: Word8 -> Maybe Status
statusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Status)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this status indicates success.
isOk :: Status -> Bool
isOk Ok = True
isOk _ = False

-- | Whether this error relates to access control.
isAccessError :: Status -> Bool
isAccessError Perm = True
isAccessError Access = True
isAccessError ROfs = True
isAccessError _ = False

-- | Whether this error is likely transient and retryable.
isRetryable :: Status -> Bool
isRetryable Io = True
isRetryable NxIo = True
isRetryable Stale = True
isRetryable _ = False

-- ---------------------------------------------------------------------------
-- NfsState
-- ---------------------------------------------------------------------------

-- | NFS server lifecycle states for the FFI layer.
--
-- Tags 0-5 (6 constructors).
data NfsState
  = Idle  -- ^ Not mounted (tag 0).
  | Mounted  -- ^ Connected to server, mount established (tag 1).
  | FileOpen  -- ^ File handle is open (tag 2).
  | Locked  -- ^ Lock held on a file region (tag 3).
  | Busy  -- ^ I/O in progress (tag 4).
  | Unmounting  -- ^ Unmounting (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NfsState' to its ABI tag value.
nfsStateToTag :: NfsState -> Word8
nfsStateToTag = fromIntegral . fromEnum

-- | Decode a 'NfsState' from its ABI tag value.
nfsStateFromTag :: Word8 -> Maybe NfsState
nfsStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NfsState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the NFS mount is active.
isMounted :: NfsState -> Bool
isMounted Idle = False
isMounted Unmounting = False
isMounted _ = True
