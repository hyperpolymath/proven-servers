-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- StorageConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (StorageOp, StorageState,
-- ObjectStatus, StorageError, IntegrityCheck) to a fixed Bits8 value for C interop.
--
-- Tag values here MUST match the C header (generated/abi/storageconn.h) and the
-- Zig FFI enums (ffi/zig/src/storageconn.zig) exactly.

module StorageConnABI.Layout

import StorageConn.Types

%default total

---------------------------------------------------------------------------
-- StorageOp (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
storageOpSize : Nat
storageOpSize = 1

public export
storageOpToTag : StorageOp -> Bits8
storageOpToTag PutObject    = 0
storageOpToTag GetObject    = 1
storageOpToTag DeleteObject = 2
storageOpToTag ListObjects  = 3
storageOpToTag HeadObject   = 4
storageOpToTag CopyObject   = 5
storageOpToTag CreateBucket = 6
storageOpToTag DeleteBucket = 7

public export
tagToStorageOp : Bits8 -> Maybe StorageOp
tagToStorageOp 0 = Just PutObject
tagToStorageOp 1 = Just GetObject
tagToStorageOp 2 = Just DeleteObject
tagToStorageOp 3 = Just ListObjects
tagToStorageOp 4 = Just HeadObject
tagToStorageOp 5 = Just CopyObject
tagToStorageOp 6 = Just CreateBucket
tagToStorageOp 7 = Just DeleteBucket
tagToStorageOp _ = Nothing

public export
storageOpRoundtrip : (op : StorageOp) -> tagToStorageOp (storageOpToTag op) = Just op
storageOpRoundtrip PutObject    = Refl
storageOpRoundtrip GetObject    = Refl
storageOpRoundtrip DeleteObject = Refl
storageOpRoundtrip ListObjects  = Refl
storageOpRoundtrip HeadObject   = Refl
storageOpRoundtrip CopyObject   = Refl
storageOpRoundtrip CreateBucket = Refl
storageOpRoundtrip DeleteBucket = Refl

---------------------------------------------------------------------------
-- StorageState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
storageStateSize : Nat
storageStateSize = 1

public export
storageStateToTag : StorageState -> Bits8
storageStateToTag Disconnected = 0
storageStateToTag Connected    = 1
storageStateToTag Uploading    = 2
storageStateToTag Downloading  = 3
storageStateToTag Failed       = 4

public export
tagToStorageState : Bits8 -> Maybe StorageState
tagToStorageState 0 = Just Disconnected
tagToStorageState 1 = Just Connected
tagToStorageState 2 = Just Uploading
tagToStorageState 3 = Just Downloading
tagToStorageState 4 = Just Failed
tagToStorageState _ = Nothing

public export
storageStateRoundtrip : (s : StorageState) -> tagToStorageState (storageStateToTag s) = Just s
storageStateRoundtrip Disconnected = Refl
storageStateRoundtrip Connected    = Refl
storageStateRoundtrip Uploading    = Refl
storageStateRoundtrip Downloading  = Refl
storageStateRoundtrip Failed       = Refl

---------------------------------------------------------------------------
-- ObjectStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
objectStatusSize : Nat
objectStatusSize = 1

public export
objectStatusToTag : ObjectStatus -> Bits8
objectStatusToTag Exists   = 0
objectStatusToTag NotFound = 1
objectStatusToTag Archived = 2
objectStatusToTag Deleted  = 3
objectStatusToTag Pending  = 4

public export
tagToObjectStatus : Bits8 -> Maybe ObjectStatus
tagToObjectStatus 0 = Just Exists
tagToObjectStatus 1 = Just NotFound
tagToObjectStatus 2 = Just Archived
tagToObjectStatus 3 = Just Deleted
tagToObjectStatus 4 = Just Pending
tagToObjectStatus _ = Nothing

public export
objectStatusRoundtrip : (os : ObjectStatus) -> tagToObjectStatus (objectStatusToTag os) = Just os
objectStatusRoundtrip Exists   = Refl
objectStatusRoundtrip NotFound = Refl
objectStatusRoundtrip Archived = Refl
objectStatusRoundtrip Deleted  = Refl
objectStatusRoundtrip Pending  = Refl

---------------------------------------------------------------------------
-- StorageError (8 constructors, tags 1-8; 0 = no error)
---------------------------------------------------------------------------

public export
storageErrorSize : Nat
storageErrorSize = 1

public export
storageErrorToTag : StorageError -> Bits8
storageErrorToTag BucketNotFound       = 1
storageErrorToTag ObjectNotFound       = 2
storageErrorToTag AccessDenied         = 3
storageErrorToTag QuotaExceeded        = 4
storageErrorToTag IntegrityCheckFailed = 5
storageErrorToTag UploadIncomplete     = 6
storageErrorToTag PathTraversal        = 7
storageErrorToTag TLSRequired          = 8

public export
tagToStorageError : Bits8 -> Maybe StorageError
tagToStorageError 1 = Just BucketNotFound
tagToStorageError 2 = Just ObjectNotFound
tagToStorageError 3 = Just AccessDenied
tagToStorageError 4 = Just QuotaExceeded
tagToStorageError 5 = Just IntegrityCheckFailed
tagToStorageError 6 = Just UploadIncomplete
tagToStorageError 7 = Just PathTraversal
tagToStorageError 8 = Just TLSRequired
tagToStorageError _ = Nothing

public export
storageErrorRoundtrip : (e : StorageError) -> tagToStorageError (storageErrorToTag e) = Just e
storageErrorRoundtrip BucketNotFound       = Refl
storageErrorRoundtrip ObjectNotFound       = Refl
storageErrorRoundtrip AccessDenied         = Refl
storageErrorRoundtrip QuotaExceeded        = Refl
storageErrorRoundtrip IntegrityCheckFailed = Refl
storageErrorRoundtrip UploadIncomplete     = Refl
storageErrorRoundtrip PathTraversal        = Refl
storageErrorRoundtrip TLSRequired          = Refl

---------------------------------------------------------------------------
-- IntegrityCheck (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
integrityCheckSize : Nat
integrityCheckSize = 1

public export
integrityCheckToTag : IntegrityCheck -> Bits8
integrityCheckToTag SHA256 = 0
integrityCheckToTag SHA384 = 1
integrityCheckToTag SHA512 = 2
integrityCheckToTag BLAKE3 = 3
integrityCheckToTag None   = 4

public export
tagToIntegrityCheck : Bits8 -> Maybe IntegrityCheck
tagToIntegrityCheck 0 = Just SHA256
tagToIntegrityCheck 1 = Just SHA384
tagToIntegrityCheck 2 = Just SHA512
tagToIntegrityCheck 3 = Just BLAKE3
tagToIntegrityCheck 4 = Just None
tagToIntegrityCheck _ = Nothing

public export
integrityCheckRoundtrip : (ic : IntegrityCheck) -> tagToIntegrityCheck (integrityCheckToTag ic) = Just ic
integrityCheckRoundtrip SHA256 = Refl
integrityCheckRoundtrip SHA384 = Refl
integrityCheckRoundtrip SHA512 = Refl
integrityCheckRoundtrip BLAKE3 = Refl
integrityCheckRoundtrip None   = Refl
