-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- StorageConn.Types: Core type definitions for object storage connector
-- interfaces.  Closed sum types representing storage operations, connection
-- states, object statuses, error categories, and integrity check
-- algorithms.  These types enforce that any object storage backend
-- connector is type-safe at the boundary.

module StorageConn.Types

%default total

---------------------------------------------------------------------------
-- StorageOp — the operation being requested of the storage backend.
---------------------------------------------------------------------------

||| Operations that can be performed against an object storage backend.
public export
data StorageOp : Type where
  ||| Upload an object to a bucket.
  PutObject    : StorageOp
  ||| Download an object from a bucket.
  GetObject    : StorageOp
  ||| Delete an object from a bucket.
  DeleteObject : StorageOp
  ||| List objects in a bucket, optionally filtered by prefix.
  ListObjects  : StorageOp
  ||| Retrieve object metadata without downloading the body.
  HeadObject   : StorageOp
  ||| Copy an object between keys or buckets.
  CopyObject   : StorageOp
  ||| Create a new bucket.
  CreateBucket : StorageOp
  ||| Delete an empty bucket.
  DeleteBucket : StorageOp

public export
Show StorageOp where
  show PutObject    = "PutObject"
  show GetObject    = "GetObject"
  show DeleteObject = "DeleteObject"
  show ListObjects  = "ListObjects"
  show HeadObject   = "HeadObject"
  show CopyObject   = "CopyObject"
  show CreateBucket = "CreateBucket"
  show DeleteBucket = "DeleteBucket"

---------------------------------------------------------------------------
-- StorageState — the state of a storage connection.
---------------------------------------------------------------------------

||| The lifecycle state of an object storage connection.
public export
data StorageState : Type where
  ||| No connection established to the storage backend.
  Disconnected : StorageState
  ||| Connection established and operational.
  Connected    : StorageState
  ||| A multipart or streaming upload is in progress.
  Uploading    : StorageState
  ||| A streaming download is in progress.
  Downloading  : StorageState
  ||| Connection has entered a failed state.
  Failed       : StorageState

public export
Show StorageState where
  show Disconnected = "Disconnected"
  show Connected    = "Connected"
  show Uploading    = "Uploading"
  show Downloading  = "Downloading"
  show Failed       = "Failed"

---------------------------------------------------------------------------
-- ObjectStatus — the status of a stored object.
---------------------------------------------------------------------------

||| The current status of an object in the storage backend.
public export
data ObjectStatus : Type where
  ||| The object exists and is accessible.
  Exists   : ObjectStatus
  ||| The object was not found at the given key.
  NotFound : ObjectStatus
  ||| The object has been moved to an archive tier (e.g. Glacier).
  Archived : ObjectStatus
  ||| The object has been soft-deleted (tombstoned).
  Deleted  : ObjectStatus
  ||| The object is pending creation (e.g. multipart upload in flight).
  Pending  : ObjectStatus

public export
Show ObjectStatus where
  show Exists   = "Exists"
  show NotFound = "NotFound"
  show Archived = "Archived"
  show Deleted  = "Deleted"
  show Pending  = "Pending"

---------------------------------------------------------------------------
-- StorageError — storage operation error categories.
---------------------------------------------------------------------------

||| Error categories that an object storage connector can report.
public export
data StorageError : Type where
  ||| The specified bucket does not exist.
  BucketNotFound       : StorageError
  ||| The specified object key does not exist in the bucket.
  ObjectNotFound       : StorageError
  ||| The caller lacks permission for this operation.
  AccessDenied         : StorageError
  ||| The storage quota has been exceeded.
  QuotaExceeded        : StorageError
  ||| The object's checksum did not match after transfer.
  IntegrityCheckFailed : StorageError
  ||| A multipart upload did not complete successfully.
  UploadIncomplete     : StorageError
  ||| The object key contains a path traversal sequence (e.g. "..").
  PathTraversal        : StorageError
  ||| The server requires TLS but the connector attempted plaintext.
  TLSRequired          : StorageError

public export
Show StorageError where
  show BucketNotFound       = "BucketNotFound"
  show ObjectNotFound       = "ObjectNotFound"
  show AccessDenied         = "AccessDenied"
  show QuotaExceeded        = "QuotaExceeded"
  show IntegrityCheckFailed = "IntegrityCheckFailed"
  show UploadIncomplete     = "UploadIncomplete"
  show PathTraversal        = "PathTraversal"
  show TLSRequired          = "TLSRequired"

---------------------------------------------------------------------------
-- IntegrityCheck — the hash algorithm used for object integrity.
---------------------------------------------------------------------------

||| Hash algorithms available for verifying object integrity after
||| upload or download.
public export
data IntegrityCheck : Type where
  ||| SHA-256 (FIPS 180-4).
  SHA256 : IntegrityCheck
  ||| SHA-384 (FIPS 180-4).
  SHA384 : IntegrityCheck
  ||| SHA-512 (FIPS 180-4).
  SHA512 : IntegrityCheck
  ||| BLAKE3 — fast, parallel, and cryptographically secure.
  BLAKE3 : IntegrityCheck
  ||| No integrity check (not recommended for production).
  None   : IntegrityCheck

public export
Show IntegrityCheck where
  show SHA256 = "SHA256"
  show SHA384 = "SHA384"
  show SHA512 = "SHA512"
  show BLAKE3 = "BLAKE3"
  show None   = "None"
