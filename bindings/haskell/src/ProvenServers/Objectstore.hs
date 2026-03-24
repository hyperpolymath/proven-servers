-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Object Store types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Objectstore
  (
    objectstorePort
  , Operation(..)
  , operationToTag
  , operationFromTag
  , isBucketOp
  , isMultipart
  , StorageClass(..)
  , storageClassToTag
  , storageClassFromTag
  , Acl(..)
  , aclToTag
  , aclFromTag
  , ErrorCode(..)
  , errorCodeToTag
  , errorCodeFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard MinIO/S3 port.
objectstorePort :: Word16
objectstorePort = 9000

-- ---------------------------------------------------------------------------
-- Operation
-- ---------------------------------------------------------------------------

-- | Standard MinIO/S3 port.
--
-- Tags 0-11 (12 constructors).
data Operation
  = PutObject  -- ^ PutObject (tag 0).
  | GetObject  -- ^ GetObject (tag 1).
  | DeleteObject  -- ^ DeleteObject (tag 2).
  | ListObjects  -- ^ ListObjects (tag 3).
  | HeadObject  -- ^ HeadObject (tag 4).
  | CopyObject  -- ^ CopyObject (tag 5).
  | CreateBucket  -- ^ CreateBucket (tag 6).
  | DeleteBucket  -- ^ DeleteBucket (tag 7).
  | ListBuckets  -- ^ ListBuckets (tag 8).
  | InitMultipartUpload  -- ^ InitMultipartUpload (tag 9).
  | UploadPart  -- ^ UploadPart (tag 10).
  | CompleteMultipartUpload  -- ^ CompleteMultipartUpload (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Operation' to its ABI tag value.
operationToTag :: Operation -> Word8
operationToTag = fromIntegral . fromEnum

-- | Decode a 'Operation' from its ABI tag value.
operationFromTag :: Word8 -> Maybe Operation
operationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Operation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a bucket-level operation.
isBucketOp :: Operation -> Bool
isBucketOp CreateBucket = True
isBucketOp DeleteBucket = True
isBucketOp ListBuckets = True
isBucketOp _ = False

-- | Whether this is a multipart upload operation.
isMultipart :: Operation -> Bool
isMultipart InitMultipartUpload = True
isMultipart UploadPart = True
isMultipart CompleteMultipartUpload = True
isMultipart _ = False

-- ---------------------------------------------------------------------------
-- StorageClass
-- ---------------------------------------------------------------------------

-- | Object storage classes.
--
-- Tags 0-4 (5 constructors).
data StorageClass
  = Standard  -- ^ Standard (tag 0).
  | InfrequentAccess  -- ^ InfrequentAccess (tag 1).
  | Glacier  -- ^ Glacier (tag 2).
  | DeepArchive  -- ^ DeepArchive (tag 3).
  | OneZone  -- ^ OneZone (tag 4).
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

-- | Object ACL policies.
--
-- Tags 0-3 (4 constructors).
data Acl
  = Private  -- ^ Private (tag 0).
  | PublicRead  -- ^ PublicRead (tag 1).
  | PublicReadWrite  -- ^ PublicReadWrite (tag 2).
  | AuthenticatedRead  -- ^ AuthenticatedRead (tag 3).
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

-- | Object store error codes.
--
-- Tags 0-7 (8 constructors).
data ErrorCode
  = NoSuchBucket  -- ^ NoSuchBucket (tag 0).
  | NoSuchKey  -- ^ NoSuchKey (tag 1).
  | BucketAlreadyExists  -- ^ BucketAlreadyExists (tag 2).
  | BucketNotEmpty  -- ^ BucketNotEmpty (tag 3).
  | AccessDenied  -- ^ AccessDenied (tag 4).
  | EntityTooLarge  -- ^ EntityTooLarge (tag 5).
  | InvalidPart  -- ^ InvalidPart (tag 6).
  | IncompleteBody  -- ^ IncompleteBody (tag 7).
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

-- | Object store session states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | Ready  -- ^ Ready (tag 1).
  | BucketActive  -- ^ BucketActive (tag 2).
  | Uploading  -- ^ Uploading (tag 3).
  | Closing  -- ^ Closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
