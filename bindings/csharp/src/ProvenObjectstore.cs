// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

namespace Proven;

/// <summary>Operation matching the Idris2 ABI tags (0-11).</summary>
public enum Operation : byte
{
    PutObject = 0,
    GetObject = 1,
    DeleteObject = 2,
    ListObjects = 3,
    HeadObject = 4,
    CopyObject = 5,
    CreateBucket = 6,
    DeleteBucket = 7,
    ListBuckets = 8,
    InitMultipartUpload = 9,
    UploadPart = 10,
    CompleteMultipartUpload = 11
}

/// <summary>StorageClass matching the Idris2 ABI tags (0-4).</summary>
public enum StorageClass : byte
{
    Standard = 0,
    InfrequentAccess = 1,
    Glacier = 2,
    DeepArchive = 3,
    OneZone = 4
}

/// <summary>Acl matching the Idris2 ABI tags (0-3).</summary>
public enum Acl : byte
{
    Private = 0,
    PublicRead = 1,
    PublicReadWrite = 2,
    AuthenticatedRead = 3
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-7).</summary>
public enum ErrorCode : byte
{
    NoSuchBucket = 0,
    NoSuchKey = 1,
    BucketAlreadyExists = 2,
    BucketNotEmpty = 3,
    AccessDenied = 4,
    EntityTooLarge = 5,
    InvalidPart = 6,
    IncompleteBody = 7
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Ready = 1,
    BucketActive = 2,
    Uploading = 3,
    Closing = 4
}
