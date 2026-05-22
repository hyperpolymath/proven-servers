// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store types for the proven-servers ABI.
//
// Mirrors the Idris2 module ObjectstoreABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard MinIO/S3 port.
let objectstorePort = 9000

// ===========================================================================
// Operation (tags 0-11)
// ===========================================================================

/// Standard MinIO/S3 port.
type operation =
  | @as(0) PutObject
  | @as(1) GetObject
  | @as(2) DeleteObject
  | @as(3) ListObjects
  | @as(4) HeadObject
  | @as(5) CopyObject
  | @as(6) CreateBucket
  | @as(7) DeleteBucket
  | @as(8) ListBuckets
  | @as(9) InitMultipartUpload
  | @as(10) UploadPart
  | @as(11) CompleteMultipartUpload

/// Decode from the C-ABI tag value.
let operationFromTag = (tag: int): option<operation> =>
  switch tag {
  | 0 => Some(PutObject)
  | 1 => Some(GetObject)
  | 2 => Some(DeleteObject)
  | 3 => Some(ListObjects)
  | 4 => Some(HeadObject)
  | 5 => Some(CopyObject)
  | 6 => Some(CreateBucket)
  | 7 => Some(DeleteBucket)
  | 8 => Some(ListBuckets)
  | 9 => Some(InitMultipartUpload)
  | 10 => Some(UploadPart)
  | 11 => Some(CompleteMultipartUpload)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let operationToTag = (v: operation): int =>
  switch v {
  | PutObject => 0
  | GetObject => 1
  | DeleteObject => 2
  | ListObjects => 3
  | HeadObject => 4
  | CopyObject => 5
  | CreateBucket => 6
  | DeleteBucket => 7
  | ListBuckets => 8
  | InitMultipartUpload => 9
  | UploadPart => 10
  | CompleteMultipartUpload => 11
  }

/// Whether this is a bucket-level operation.
let operationIsBucketOp = (v: operation): bool =>
  switch v {
  | CreateBucket | DeleteBucket | ListBuckets => true
  | _ => false
  }

/// Whether this is a multipart upload operation.
let operationIsMultipart = (v: operation): bool =>
  switch v {
  | InitMultipartUpload | UploadPart | CompleteMultipartUpload => true
  | _ => false
  }

// ===========================================================================
// StorageClass (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type storageClass =
  | @as(0) Standard
  | @as(1) InfrequentAccess
  | @as(2) Glacier
  | @as(3) DeepArchive
  | @as(4) OneZone

/// Decode from the C-ABI tag value.
let storageClassFromTag = (tag: int): option<storageClass> =>
  switch tag {
  | 0 => Some(Standard)
  | 1 => Some(InfrequentAccess)
  | 2 => Some(Glacier)
  | 3 => Some(DeepArchive)
  | 4 => Some(OneZone)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let storageClassToTag = (v: storageClass): int =>
  switch v {
  | Standard => 0
  | InfrequentAccess => 1
  | Glacier => 2
  | DeepArchive => 3
  | OneZone => 4
  }

// ===========================================================================
// Acl (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type acl =
  | @as(0) Private
  | @as(1) PublicRead
  | @as(2) PublicReadWrite
  | @as(3) AuthenticatedRead

/// Decode from the C-ABI tag value.
let aclFromTag = (tag: int): option<acl> =>
  switch tag {
  | 0 => Some(Private)
  | 1 => Some(PublicRead)
  | 2 => Some(PublicReadWrite)
  | 3 => Some(AuthenticatedRead)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let aclToTag = (v: acl): int =>
  switch v {
  | Private => 0
  | PublicRead => 1
  | PublicReadWrite => 2
  | AuthenticatedRead => 3
  }

// ===========================================================================
// ErrorCode (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) NoSuchBucket
  | @as(1) NoSuchKey
  | @as(2) BucketAlreadyExists
  | @as(3) BucketNotEmpty
  | @as(4) AccessDenied
  | @as(5) EntityTooLarge
  | @as(6) InvalidPart
  | @as(7) IncompleteBody

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(NoSuchBucket)
  | 1 => Some(NoSuchKey)
  | 2 => Some(BucketAlreadyExists)
  | 3 => Some(BucketNotEmpty)
  | 4 => Some(AccessDenied)
  | 5 => Some(EntityTooLarge)
  | 6 => Some(InvalidPart)
  | 7 => Some(IncompleteBody)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | NoSuchBucket => 0
  | NoSuchKey => 1
  | BucketAlreadyExists => 2
  | BucketNotEmpty => 3
  | AccessDenied => 4
  | EntityTooLarge => 5
  | InvalidPart => 6
  | IncompleteBody => 7
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) BucketActive
  | @as(3) Uploading
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(BucketActive)
  | 3 => Some(Uploading)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | BucketActive => 2
  | Uploading => 3
  | Closing => 4
  }

