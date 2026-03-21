-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | File Server protocol types for proven-servers.
--
-- File server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Fileserver
  ( -- * ADT types matching Idris2 ABI
      FileOperation(..)
    , FileType(..)
    , FilePermission(..)
    , LockType(..)
    , FileErrorCode(..)
    , SessionState(..)
    , fileOperationToTag
    , fileOperationFromTag
    , fileTypeToTag
    , fileTypeFromTag
    , filePermissionToTag
    , filePermissionFromTag
    , lockTypeToTag
    , lockTypeFromTag
    , fileErrorCodeToTag
    , fileErrorCodeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- FileOperation
-- ---------------------------------------------------------------------------

-- | FileOperation type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data FileOperation
  = Read  -- ^ Tag 0.
  | Write  -- ^ Tag 1.
  | Create  -- ^ Tag 2.
  | Delete  -- ^ Tag 3.
  | Rename  -- ^ Tag 4.
  | List  -- ^ Tag 5.
  | Stat  -- ^ Tag 6.
  | Lock  -- ^ Tag 7.
  | Unlock  -- ^ Tag 8.
  | Watch  -- ^ Tag 9.
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

-- | FileType type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data FileType
  = Regular  -- ^ Tag 0.
  | Directory  -- ^ Tag 1.
  | Symlink  -- ^ Tag 2.
  | BlockDevice  -- ^ Tag 3.
  | CharDevice  -- ^ Tag 4.
  | Fifo  -- ^ Tag 5.
  | Socket  -- ^ Tag 6.
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

-- | FilePermission type matching the Idris2 ABI.
--
-- Tags 0-8 (9 constructors).
data FilePermission
  = OwnerRead  -- ^ Tag 0.
  | OwnerWrite  -- ^ Tag 1.
  | OwnerExecute  -- ^ Tag 2.
  | GroupRead  -- ^ Tag 3.
  | GroupWrite  -- ^ Tag 4.
  | GroupExecute  -- ^ Tag 5.
  | OtherRead  -- ^ Tag 6.
  | OtherWrite  -- ^ Tag 7.
  | OtherExecute  -- ^ Tag 8.
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

-- | LockType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data LockType
  = Shared  -- ^ Tag 0.
  | Exclusive  -- ^ Tag 1.
  | Advisory  -- ^ Tag 2.
  | Mandatory  -- ^ Tag 3.
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

-- | FileErrorCode type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data FileErrorCode
  = NotFound  -- ^ Tag 0.
  | PermissionDenied  -- ^ Tag 1.
  | AlreadyExists  -- ^ Tag 2.
  | NotEmpty  -- ^ Tag 3.
  | IsDirectory  -- ^ Tag 4.
  | NotDirectory  -- ^ Tag 5.
  | NoSpace  -- ^ Tag 6.
  | ReadOnly  -- ^ Tag 7.
  | Locked  -- ^ Tag 8.
  | IoError  -- ^ Tag 9.
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

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | Operating  -- ^ Tag 2.
  | FsLocked  -- ^ Tag 3.
  | Disconnecting  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
