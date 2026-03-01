-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- StorageConn: Top-level module for proven-storageconn.
-- Re-exports StorageConn.Types and provides storage-related constants.

module StorageConn

import public StorageConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum object size in bytes (5 GiB).
public export
maxObjectSize : Nat
maxObjectSize = 5368709120

||| Maximum object key length in bytes.
public export
maxKeyLength : Nat
maxKeyLength = 1024

||| Maximum bucket name length in characters.
||| Matches the S3/MinIO/GCS common constraint.
public export
maxBucketNameLength : Nat
maxBucketNameLength = 63
