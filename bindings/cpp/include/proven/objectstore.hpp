// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file objectstore.hpp
/// @brief Object Store protocol types for proven-servers.

#ifndef PROVEN_OBJECTSTORE_HPP
#define PROVEN_OBJECTSTORE_HPP

#include <cstdint>

namespace proven {

/// @brief Operation matching the Idris2 ABI tags.
enum class Operation : uint8_t {
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
};

/// @brief StorageClass matching the Idris2 ABI tags.
enum class StorageClass : uint8_t {
    Standard = 0,
    InfrequentAccess = 1,
    Glacier = 2,
    DeepArchive = 3,
    OneZone = 4
};

/// @brief Acl matching the Idris2 ABI tags.
enum class Acl : uint8_t {
    Private = 0,
    PublicRead = 1,
    PublicReadWrite = 2,
    AuthenticatedRead = 3
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
    NoSuchBucket = 0,
    NoSuchKey = 1,
    BucketAlreadyExists = 2,
    BucketNotEmpty = 3,
    AccessDenied = 4,
    EntityTooLarge = 5,
    InvalidPart = 6,
    IncompleteBody = 7
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Ready = 1,
    BucketActive = 2,
    Uploading = 3,
    Closing = 4
};

} // namespace proven

#endif // PROVEN_OBJECTSTORE_HPP
