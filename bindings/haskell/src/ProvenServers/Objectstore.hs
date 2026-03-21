-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Object Store protocol types for proven-servers.
--
-- S3-compatible object store types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Objectstore
  ( -- * ADT types matching Idris2 ABI
      Operation(..)
    , StorageClass(..)
    , Acl(..)
    , ErrorCode(..)
    , SessionState(..)
    , operationToTag
    , operationFromTag
    , storageClassToTag
    , storageClassFromTag
    , aclToTag
    , aclFromTag
    , errorCodeToTag
    , errorCodeFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Operation type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data Operation
  = PutObject  -- ^ Tag 0.
  | GetObject  -- ^ Tag 1.
  | DeleteObject  -- ^ Tag 2.
  | ListObjects  -- ^ Tag 3.
  | HeadObject  -- ^ Tag 4.
  | CopyObject  -- ^ Tag 5.
  | CreateBucket  -- ^ Tag 6.
  | DeleteBucket  -- ^ Tag 7.
  | ListBuckets  -- ^ Tag 8.
  | InitMultipartUpload  -- ^ Tag 9.
  | UploadPart  -- ^ Tag 10.
  | CompleteMultipartUpload  -- ^ Tag 11.
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
-- StorageClass
-- ---------------------------------------------------------------------------

-- | StorageClass type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data StorageClass
  = Standard  -- ^ Tag 0.
  | InfrequentAccess  -- ^ Tag 1.
  | Glacier  -- ^ Tag 2.
  | DeepArchive  -- ^ Tag 3.
  | OneZone  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'StorageClass' to its ABI tag value.
storageClassToTag :: StorageClass -> Word8
storageClassToTag = fromIntegral . fromEnum

-- | Decode a 'StorageClass' from its ABI tag value.
storageClassFromTag :: Word8 -> Maybe StorageClass
storageClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: StorageClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Acl
-- ---------------------------------------------------------------------------

-- | Acl type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data Acl
  = Private  -- ^ Tag 0.
  | PublicRead  -- ^ Tag 1.
  | PublicReadWrite  -- ^ Tag 2.
  | AuthenticatedRead  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Acl' to its ABI tag value.
aclToTag :: Acl -> Word8
aclToTag = fromIntegral . fromEnum

-- | Decode a 'Acl' from its ABI tag value.
aclFromTag :: Word8 -> Maybe Acl
aclFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Acl)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCode
-- ---------------------------------------------------------------------------

-- | ErrorCode type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data ErrorCode
  = NoSuchBucket  -- ^ Tag 0.
  | NoSuchKey  -- ^ Tag 1.
  | BucketAlreadyExists  -- ^ Tag 2.
  | BucketNotEmpty  -- ^ Tag 3.
  | AccessDenied  -- ^ Tag 4.
  | EntityTooLarge  -- ^ Tag 5.
  | InvalidPart  -- ^ Tag 6.
  | IncompleteBody  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCode' to its ABI tag value.
errorCodeToTag :: ErrorCode -> Word8
errorCodeToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCode' from its ABI tag value.
errorCodeFromTag :: Word8 -> Maybe ErrorCode
errorCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | Ready  -- ^ Tag 1.
  | BucketActive  -- ^ Tag 2.
  | Uploading  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
