// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Object Store types for the proven-servers ABI.
//!
//! Formally verified S3-compatible object store types.
//! Mirrors the Idris2 module `ObjectstoreABI.Types`.
//!
//! - `Operation` -- Object store operations.
//! - `StorageClass` -- Object storage classes.
//! - `Acl` -- Object ACL policies.
//! - `ErrorCode` -- Object store error codes.
//! - `SessionState` -- Object store session states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Object Store Constants
// ===========================================================================

/// Standard MinIO/S3 port.
pub const OBJECTSTORE_PORT: u16 = 9000;

// ===========================================================================
// Operation (tags 0-11)
// ===========================================================================

/// Object store operations.
///
/// Matches `Operation` in `ObjectstoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Operation {
    /// PutObject (tag 0).
    PutObject = 0,
    /// GetObject (tag 1).
    GetObject = 1,
    /// DeleteObject (tag 2).
    DeleteObject = 2,
    /// ListObjects (tag 3).
    ListObjects = 3,
    /// HeadObject (tag 4).
    HeadObject = 4,
    /// CopyObject (tag 5).
    CopyObject = 5,
    /// CreateBucket (tag 6).
    CreateBucket = 6,
    /// DeleteBucket (tag 7).
    DeleteBucket = 7,
    /// ListBuckets (tag 8).
    ListBuckets = 8,
    /// InitMultipartUpload (tag 9).
    InitMultipartUpload = 9,
    /// UploadPart (tag 10).
    UploadPart = 10,
    /// CompleteMultipartUpload (tag 11).
    CompleteMultipartUpload = 11,
}

impl Operation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::PutObject),
            1 => Some(Self::GetObject),
            2 => Some(Self::DeleteObject),
            3 => Some(Self::ListObjects),
            4 => Some(Self::HeadObject),
            5 => Some(Self::CopyObject),
            6 => Some(Self::CreateBucket),
            7 => Some(Self::DeleteBucket),
            8 => Some(Self::ListBuckets),
            9 => Some(Self::InitMultipartUpload),
            10 => Some(Self::UploadPart),
            11 => Some(Self::CompleteMultipartUpload),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a bucket-level operation.
    pub fn is_bucket_op(self) -> bool {
        matches!(self, Self::CreateBucket | Self::DeleteBucket | Self::ListBuckets)
    }

    /// Whether this is a multipart upload operation.
    pub fn is_multipart(self) -> bool {
        matches!(self, Self::InitMultipartUpload | Self::UploadPart | Self::CompleteMultipartUpload)
    }

    /// All variants of this type.
    pub const ALL: [Operation; 12] = [
        Self::PutObject, Self::GetObject, Self::DeleteObject, Self::ListObjects, Self::HeadObject, Self::CopyObject, Self::CreateBucket, Self::DeleteBucket, Self::ListBuckets, Self::InitMultipartUpload, Self::UploadPart, Self::CompleteMultipartUpload,
    ];
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StorageClass (tags 0-4)
// ===========================================================================

/// Object storage classes.
///
/// Matches `StorageClass` in `ObjectstoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StorageClass {
    /// Standard (tag 0).
    Standard = 0,
    /// InfrequentAccess (tag 1).
    InfrequentAccess = 1,
    /// Glacier (tag 2).
    Glacier = 2,
    /// DeepArchive (tag 3).
    DeepArchive = 3,
    /// OneZone (tag 4).
    OneZone = 4,
}

impl StorageClass {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Standard),
            1 => Some(Self::InfrequentAccess),
            2 => Some(Self::Glacier),
            3 => Some(Self::DeepArchive),
            4 => Some(Self::OneZone),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [StorageClass; 5] = [
        Self::Standard, Self::InfrequentAccess, Self::Glacier, Self::DeepArchive, Self::OneZone,
    ];
}

impl fmt::Display for StorageClass {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Acl (tags 0-3)
// ===========================================================================

/// Object ACL policies.
///
/// Matches `Acl` in `ObjectstoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Acl {
    /// Private (tag 0).
    Private = 0,
    /// PublicRead (tag 1).
    PublicRead = 1,
    /// PublicReadWrite (tag 2).
    PublicReadWrite = 2,
    /// AuthenticatedRead (tag 3).
    AuthenticatedRead = 3,
}

impl Acl {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Private),
            1 => Some(Self::PublicRead),
            2 => Some(Self::PublicReadWrite),
            3 => Some(Self::AuthenticatedRead),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Acl; 4] = [
        Self::Private, Self::PublicRead, Self::PublicReadWrite, Self::AuthenticatedRead,
    ];
}

impl fmt::Display for Acl {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-7)
// ===========================================================================

/// Object store error codes.
///
/// Matches `ErrorCode` in `ObjectstoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// NoSuchBucket (tag 0).
    NoSuchBucket = 0,
    /// NoSuchKey (tag 1).
    NoSuchKey = 1,
    /// BucketAlreadyExists (tag 2).
    BucketAlreadyExists = 2,
    /// BucketNotEmpty (tag 3).
    BucketNotEmpty = 3,
    /// AccessDenied (tag 4).
    AccessDenied = 4,
    /// EntityTooLarge (tag 5).
    EntityTooLarge = 5,
    /// InvalidPart (tag 6).
    InvalidPart = 6,
    /// IncompleteBody (tag 7).
    IncompleteBody = 7,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoSuchBucket),
            1 => Some(Self::NoSuchKey),
            2 => Some(Self::BucketAlreadyExists),
            3 => Some(Self::BucketNotEmpty),
            4 => Some(Self::AccessDenied),
            5 => Some(Self::EntityTooLarge),
            6 => Some(Self::InvalidPart),
            7 => Some(Self::IncompleteBody),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 8] = [
        Self::NoSuchBucket, Self::NoSuchKey, Self::BucketAlreadyExists, Self::BucketNotEmpty, Self::AccessDenied, Self::EntityTooLarge, Self::InvalidPart, Self::IncompleteBody,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Object store session states.
///
/// Matches `SessionState` in `ObjectstoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// BucketActive (tag 2).
    BucketActive = 2,
    /// Uploading (tag 3).
    Uploading = 3,
    /// Closing (tag 4).
    Closing = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::BucketActive),
            3 => Some(Self::Uploading),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Ready, Self::BucketActive, Self::Uploading, Self::Closing,
    ];
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn operation_roundtrip() {
        for v in Operation::ALL {
            let tag = v.to_tag();
            let decoded = Operation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Operation::from_tag(12).is_none());
    }

    #[test]
    fn storage_class_roundtrip() {
        for v in StorageClass::ALL {
            let tag = v.to_tag();
            let decoded = StorageClass::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(StorageClass::from_tag(5).is_none());
    }

    #[test]
    fn acl_roundtrip() {
        for v in Acl::ALL {
            let tag = v.to_tag();
            let decoded = Acl::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Acl::from_tag(4).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(8).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(OBJECTSTORE_PORT, 9000);
    }

}
