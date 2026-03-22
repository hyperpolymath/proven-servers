<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Operation matching the Idris2 ABI tags. */
enum Operation: int
{
    case PutObject = 0;
    case GetObject = 1;
    case DeleteObject = 2;
    case ListObjects = 3;
    case HeadObject = 4;
    case CopyObject = 5;
    case CreateBucket = 6;
    case DeleteBucket = 7;
    case ListBuckets = 8;
    case InitMultipartUpload = 9;
    case UploadPart = 10;
    case CompleteMultipartUpload = 11;
}

/** StorageClass matching the Idris2 ABI tags. */
enum StorageClass: int
{
    case Standard = 0;
    case InfrequentAccess = 1;
    case Glacier = 2;
    case DeepArchive = 3;
    case OneZone = 4;
}

/** Acl matching the Idris2 ABI tags. */
enum Acl: int
{
    case Private = 0;
    case PublicRead = 1;
    case PublicReadWrite = 2;
    case AuthenticatedRead = 3;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case NoSuchBucket = 0;
    case NoSuchKey = 1;
    case BucketAlreadyExists = 2;
    case BucketNotEmpty = 3;
    case AccessDenied = 4;
    case EntityTooLarge = 5;
    case InvalidPart = 6;
    case IncompleteBody = 7;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Ready = 1;
    case BucketActive = 2;
    case Uploading = 3;
    case Closing = 4;
}
