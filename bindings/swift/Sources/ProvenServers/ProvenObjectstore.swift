// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

/// Operation matching the Idris2 ABI tags.
public enum Operation: UInt8, CaseIterable, Sendable {
    case putObject = 0
    case getObject = 1
    case deleteObject = 2
    case listObjects = 3
    case headObject = 4
    case copyObject = 5
    case createBucket = 6
    case deleteBucket = 7
    case listBuckets = 8
    case initMultipartUpload = 9
    case uploadPart = 10
    case completeMultipartUpload = 11
}

/// StorageClass matching the Idris2 ABI tags.
public enum StorageClass: UInt8, CaseIterable, Sendable {
    case standard = 0
    case infrequentAccess = 1
    case glacier = 2
    case deepArchive = 3
    case oneZone = 4
}

/// Acl matching the Idris2 ABI tags.
public enum Acl: UInt8, CaseIterable, Sendable {
    case `private` = 0
    case publicRead = 1
    case publicReadWrite = 2
    case authenticatedRead = 3
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case noSuchBucket = 0
    case noSuchKey = 1
    case bucketAlreadyExists = 2
    case bucketNotEmpty = 3
    case accessDenied = 4
    case entityTooLarge = 5
    case invalidPart = 6
    case incompleteBody = 7
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case bucketActive = 2
    case uploading = 3
    case closing = 4
}
