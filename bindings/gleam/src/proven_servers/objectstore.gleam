//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Object Store protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ObjectstoreABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Object Store Constants
// ===========================================================================

/// Objectstore Port constant.
pub const objectstore_port = 9000

// ===========================================================================
// Operation
// ===========================================================================

/// Object store operations.
/// 
/// Matches `Operation` in `ObjectstoreABI.Types`.
pub type Operation {
  /// PutObject (tag 0).
  PutObject
  /// GetObject (tag 1).
  GetObject
  /// DeleteObject (tag 2).
  DeleteObject
  /// ListObjects (tag 3).
  ListObjects
  /// HeadObject (tag 4).
  HeadObject
  /// CopyObject (tag 5).
  CopyObject
  /// CreateBucket (tag 6).
  CreateBucket
  /// DeleteBucket (tag 7).
  DeleteBucket
  /// ListBuckets (tag 8).
  ListBuckets
  /// InitMultipartUpload (tag 9).
  InitMultipartUpload
  /// UploadPart (tag 10).
  UploadPart
  /// CompleteMultipartUpload (tag 11).
  CompleteMultipartUpload
}

/// Convert a `Operation` to its C-ABI tag value.
pub fn operation_to_int(value: Operation) -> Int {
  case value {
    PutObject -> 0
    GetObject -> 1
    DeleteObject -> 2
    ListObjects -> 3
    HeadObject -> 4
    CopyObject -> 5
    CreateBucket -> 6
    DeleteBucket -> 7
    ListBuckets -> 8
    InitMultipartUpload -> 9
    UploadPart -> 10
    CompleteMultipartUpload -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn operation_from_int(tag: Int) -> Result(Operation, Nil) {
  case tag {
    0 -> Ok(PutObject)
    1 -> Ok(GetObject)
    2 -> Ok(DeleteObject)
    3 -> Ok(ListObjects)
    4 -> Ok(HeadObject)
    5 -> Ok(CopyObject)
    6 -> Ok(CreateBucket)
    7 -> Ok(DeleteBucket)
    8 -> Ok(ListBuckets)
    9 -> Ok(InitMultipartUpload)
    10 -> Ok(UploadPart)
    11 -> Ok(CompleteMultipartUpload)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StorageClass
// ===========================================================================

/// Object storage classes.
/// 
/// Matches `StorageClass` in `ObjectstoreABI.Types`.
pub type StorageClass {
  /// Standard (tag 0).
  Standard
  /// InfrequentAccess (tag 1).
  InfrequentAccess
  /// Glacier (tag 2).
  Glacier
  /// DeepArchive (tag 3).
  DeepArchive
  /// OneZone (tag 4).
  OneZone
}

/// Convert a `StorageClass` to its C-ABI tag value.
pub fn storage_class_to_int(value: StorageClass) -> Int {
  case value {
    Standard -> 0
    InfrequentAccess -> 1
    Glacier -> 2
    DeepArchive -> 3
    OneZone -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn storage_class_from_int(tag: Int) -> Result(StorageClass, Nil) {
  case tag {
    0 -> Ok(Standard)
    1 -> Ok(InfrequentAccess)
    2 -> Ok(Glacier)
    3 -> Ok(DeepArchive)
    4 -> Ok(OneZone)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Acl
// ===========================================================================

/// Object ACL policies.
/// 
/// Matches `Acl` in `ObjectstoreABI.Types`.
pub type Acl {
  /// Private (tag 0).
  Private
  /// PublicRead (tag 1).
  PublicRead
  /// PublicReadWrite (tag 2).
  PublicReadWrite
  /// AuthenticatedRead (tag 3).
  AuthenticatedRead
}

/// Convert a `Acl` to its C-ABI tag value.
pub fn acl_to_int(value: Acl) -> Int {
  case value {
    Private -> 0
    PublicRead -> 1
    PublicReadWrite -> 2
    AuthenticatedRead -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn acl_from_int(tag: Int) -> Result(Acl, Nil) {
  case tag {
    0 -> Ok(Private)
    1 -> Ok(PublicRead)
    2 -> Ok(PublicReadWrite)
    3 -> Ok(AuthenticatedRead)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// Object store error codes.
/// 
/// Matches `ErrorCode` in `ObjectstoreABI.Types`.
pub type ErrorCode {
  /// NoSuchBucket (tag 0).
  NoSuchBucket
  /// NoSuchKey (tag 1).
  NoSuchKey
  /// BucketAlreadyExists (tag 2).
  BucketAlreadyExists
  /// BucketNotEmpty (tag 3).
  BucketNotEmpty
  /// AccessDenied (tag 4).
  AccessDenied
  /// EntityTooLarge (tag 5).
  EntityTooLarge
  /// InvalidPart (tag 6).
  InvalidPart
  /// IncompleteBody (tag 7).
  IncompleteBody
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    NoSuchBucket -> 0
    NoSuchKey -> 1
    BucketAlreadyExists -> 2
    BucketNotEmpty -> 3
    AccessDenied -> 4
    EntityTooLarge -> 5
    InvalidPart -> 6
    IncompleteBody -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(NoSuchBucket)
    1 -> Ok(NoSuchKey)
    2 -> Ok(BucketAlreadyExists)
    3 -> Ok(BucketNotEmpty)
    4 -> Ok(AccessDenied)
    5 -> Ok(EntityTooLarge)
    6 -> Ok(InvalidPart)
    7 -> Ok(IncompleteBody)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// Object store session states.
/// 
/// Matches `SessionState` in `ObjectstoreABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// BucketActive (tag 2).
  BucketActive
  /// Uploading (tag 3).
  Uploading
  /// Closing (tag 4).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    BucketActive -> 2
    Uploading -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(BucketActive)
    3 -> Ok(Uploading)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

