-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | File Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Fileserver
  (
    FileOperation(..)
  , fileOperationToTag
  , fileOperationFromTag
  , FileType(..)
  , fileTypeToTag
  , fileTypeFromTag
  , FilePermission(..)
  , filePermissionToTag
  , filePermissionFromTag
  , LockType(..)
  , lockTypeToTag
  , lockTypeFromTag
  , FileErrorCode(..)
  , fileErrorCodeToTag
  , fileErrorCodeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- FileOperation
-- ---------------------------------------------------------------------------

-- | File server operations.
--
-- Tags 0-9 (10 constructors).
data FileOperation
  = Read  -- ^ Read (tag 0).
  | Write  -- ^ Write (tag 1).
  | Create  -- ^ Create (tag 2).
  | Delete  -- ^ Delete (tag 3).
  | Rename  -- ^ Rename (tag 4).
  | List  -- ^ List (tag 5).
  | Stat  -- ^ Stat (tag 6).
  | Lock  -- ^ Lock (tag 7).
  | Unlock  -- ^ Unlock (tag 8).
  | Watch  -- ^ Watch (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FileOperation' to its ABI tag value.
fileOperationToTag :: FileOperation -> Word8
fileOperationToTag = fromIntegral . fromEnum

-- | Decode a 'FileOperation' from its ABI tag value.
fileOperationFromTag :: Word8 -> Maybe FileOperation
fileOperationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FileOperation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FileType
-- ---------------------------------------------------------------------------

-- | File types.
--
-- Tags 0-6 (7 constructors).
data FileType
  = Regular  -- ^ Regular (tag 0).
  | Directory  -- ^ Directory (tag 1).
  | Symlink  -- ^ Symlink (tag 2).
  | BlockDevice  -- ^ BlockDevice (tag 3).
  | CharDevice  -- ^ CharDevice (tag 4).
  | Fifo  -- ^ FIFO (tag 5).
  | Socket  -- ^ Socket (tag 6).
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
-- FilePermission
-- ---------------------------------------------------------------------------

-- | POSIX file permissions.
--
-- Tags 0-8 (9 constructors).
data FilePermission
  = OwnerRead  -- ^ OwnerRead (tag 0).
  | OwnerWrite  -- ^ OwnerWrite (tag 1).
  | OwnerExecute  -- ^ OwnerExecute (tag 2).
  | GroupRead  -- ^ GroupRead (tag 3).
  | GroupWrite  -- ^ GroupWrite (tag 4).
  | GroupExecute  -- ^ GroupExecute (tag 5).
  | OtherRead  -- ^ OtherRead (tag 6).
  | OtherWrite  -- ^ OtherWrite (tag 7).
  | OtherExecute  -- ^ OtherExecute (tag 8).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FilePermission' to its ABI tag value.
filePermissionToTag :: FilePermission -> Word8
filePermissionToTag = fromIntegral . fromEnum

-- | Decode a 'FilePermission' from its ABI tag value.
filePermissionFromTag :: Word8 -> Maybe FilePermission
filePermissionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FilePermission)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LockType
-- ---------------------------------------------------------------------------

-- | File lock types.
--
-- Tags 0-3 (4 constructors).
data LockType
  = Shared  -- ^ Shared (tag 0).
  | Exclusive  -- ^ Exclusive (tag 1).
  | Advisory  -- ^ Advisory (tag 2).
  | Mandatory  -- ^ Mandatory (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LockType' to its ABI tag value.
lockTypeToTag :: LockType -> Word8
lockTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LockType' from its ABI tag value.
lockTypeFromTag :: Word8 -> Maybe LockType
lockTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LockType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- FileErrorCode
-- ---------------------------------------------------------------------------

-- | File server error codes.
--
-- Tags 0-9 (10 constructors).
data FileErrorCode
  = NotFound  -- ^ NotFound (tag 0).
  | PermissionDenied  -- ^ PermissionDenied (tag 1).
  | AlreadyExists  -- ^ AlreadyExists (tag 2).
  | NotEmpty  -- ^ NotEmpty (tag 3).
  | IsDirectory  -- ^ IsDirectory (tag 4).
  | NotDirectory  -- ^ NotDirectory (tag 5).
  | NoSpace  -- ^ NoSpace (tag 6).
  | ReadOnly  -- ^ ReadOnly (tag 7).
  | Locked  -- ^ Locked (tag 8).
  | IoError  -- ^ I/O error (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FileErrorCode' to its ABI tag value.
fileErrorCodeToTag :: FileErrorCode -> Word8
fileErrorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'FileErrorCode' from its ABI tag value.
fileErrorCodeFromTag :: Word8 -> Maybe FileErrorCode
fileErrorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FileErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | File server session states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Connected  -- ^ Connected (tag 1).
  | Operating  -- ^ Operating (tag 2).
  | FsLocked  -- ^ Locked (tag 3).
  | Disconnecting  -- ^ Disconnecting (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
