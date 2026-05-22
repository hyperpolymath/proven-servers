-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ObjectstoreABI.Types: C-ABI-compatible numeric representations of
-- object store types.
--
-- Maps every constructor of the Objectstore sum types to fixed Bits8
-- values for C interop. Each type gets a total encoder, partial decoder,
-- and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums
-- (ffi/zig/src/objectstore.zig) exactly.
--
-- Types covered:
--   Operation     (12 constructors, tags 0-11)
--   StorageClass  (5 constructors, tags 0-4)
--   ACL           (4 constructors, tags 0-3)
--   ErrorCode     (8 constructors, tags 0-7)
--   SessionState  (5 constructors, tags 0-4)

module ObjectstoreABI.Types

import Objectstore.Types

%default total

---------------------------------------------------------------------------
-- Operation (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

public export
operationToTag : Operation -> Bits8
operationToTag PutObject               = 0
operationToTag GetObject               = 1
operationToTag DeleteObject            = 2
operationToTag ListObjects             = 3
operationToTag HeadObject              = 4
operationToTag CopyObject              = 5
operationToTag CreateBucket            = 6
operationToTag DeleteBucket            = 7
operationToTag ListBuckets             = 8
operationToTag InitMultipartUpload     = 9
operationToTag UploadPart              = 10
operationToTag CompleteMultipartUpload = 11

public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just PutObject
tagToOperation 1  = Just GetObject
tagToOperation 2  = Just DeleteObject
tagToOperation 3  = Just ListObjects
tagToOperation 4  = Just HeadObject
tagToOperation 5  = Just CopyObject
tagToOperation 6  = Just CreateBucket
tagToOperation 7  = Just DeleteBucket
tagToOperation 8  = Just ListBuckets
tagToOperation 9  = Just InitMultipartUpload
tagToOperation 10 = Just UploadPart
tagToOperation 11 = Just CompleteMultipartUpload
tagToOperation _  = Nothing

public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip PutObject               = Refl
operationRoundtrip GetObject               = Refl
operationRoundtrip DeleteObject            = Refl
operationRoundtrip ListObjects             = Refl
operationRoundtrip HeadObject              = Refl
operationRoundtrip CopyObject              = Refl
operationRoundtrip CreateBucket            = Refl
operationRoundtrip DeleteBucket            = Refl
operationRoundtrip ListBuckets             = Refl
operationRoundtrip InitMultipartUpload     = Refl
operationRoundtrip UploadPart              = Refl
operationRoundtrip CompleteMultipartUpload = Refl

---------------------------------------------------------------------------
-- StorageClass (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
storageClassSize : Nat
storageClassSize = 1

public export
storageClassToTag : StorageClass -> Bits8
storageClassToTag Standard         = 0
storageClassToTag InfrequentAccess = 1
storageClassToTag Glacier          = 2
storageClassToTag DeepArchive      = 3
storageClassToTag OneZone          = 4

public export
tagToStorageClass : Bits8 -> Maybe StorageClass
tagToStorageClass 0 = Just Standard
tagToStorageClass 1 = Just InfrequentAccess
tagToStorageClass 2 = Just Glacier
tagToStorageClass 3 = Just DeepArchive
tagToStorageClass 4 = Just OneZone
tagToStorageClass _ = Nothing

public export
storageClassRoundtrip : (s : StorageClass) -> tagToStorageClass (storageClassToTag s) = Just s
storageClassRoundtrip Standard         = Refl
storageClassRoundtrip InfrequentAccess = Refl
storageClassRoundtrip Glacier          = Refl
storageClassRoundtrip DeepArchive      = Refl
storageClassRoundtrip OneZone          = Refl

---------------------------------------------------------------------------
-- ACL (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
aclSize : Nat
aclSize = 1

public export
aclToTag : ACL -> Bits8
aclToTag Private           = 0
aclToTag PublicRead        = 1
aclToTag PublicReadWrite   = 2
aclToTag AuthenticatedRead = 3

public export
tagToACL : Bits8 -> Maybe ACL
tagToACL 0 = Just Private
tagToACL 1 = Just PublicRead
tagToACL 2 = Just PublicReadWrite
tagToACL 3 = Just AuthenticatedRead
tagToACL _ = Nothing

public export
aclRoundtrip : (a : ACL) -> tagToACL (aclToTag a) = Just a
aclRoundtrip Private           = Refl
aclRoundtrip PublicRead        = Refl
aclRoundtrip PublicReadWrite   = Refl
aclRoundtrip AuthenticatedRead = Refl

---------------------------------------------------------------------------
-- ErrorCode (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
errorCodeSize : Nat
errorCodeSize = 1

public export
errorCodeToTag : Objectstore.Types.ErrorCode -> Bits8
errorCodeToTag NoSuchBucket       = 0
errorCodeToTag NoSuchKey          = 1
errorCodeToTag BucketAlreadyExists = 2
errorCodeToTag BucketNotEmpty     = 3
errorCodeToTag AccessDenied       = 4
errorCodeToTag EntityTooLarge     = 5
errorCodeToTag InvalidPart        = 6
errorCodeToTag IncompleteBody     = 7

public export
tagToErrorCode : Bits8 -> Maybe Objectstore.Types.ErrorCode
tagToErrorCode 0 = Just NoSuchBucket
tagToErrorCode 1 = Just NoSuchKey
tagToErrorCode 2 = Just BucketAlreadyExists
tagToErrorCode 3 = Just BucketNotEmpty
tagToErrorCode 4 = Just AccessDenied
tagToErrorCode 5 = Just EntityTooLarge
tagToErrorCode 6 = Just InvalidPart
tagToErrorCode 7 = Just IncompleteBody
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : Objectstore.Types.ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip NoSuchBucket       = Refl
errorCodeRoundtrip NoSuchKey          = Refl
errorCodeRoundtrip BucketAlreadyExists = Refl
errorCodeRoundtrip BucketNotEmpty     = Refl
errorCodeRoundtrip AccessDenied       = Refl
errorCodeRoundtrip EntityTooLarge     = Refl
errorCodeRoundtrip InvalidPart        = Refl
errorCodeRoundtrip IncompleteBody     = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Object store session lifecycle states for the FFI layer.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle          : SessionState
  ||| Session authenticated and ready.
  SSReady         : SessionState
  ||| Bucket context selected.
  SSBucketActive  : SessionState
  ||| Multipart upload in progress.
  SSUploading     : SessionState
  ||| Session closing / cleanup.
  SSClosing       : SessionState

public export
Eq SessionState where
  SSIdle         == SSIdle         = True
  SSReady        == SSReady        = True
  SSBucketActive == SSBucketActive = True
  SSUploading    == SSUploading    = True
  SSClosing      == SSClosing      = True
  _              == _              = False

public export
Show SessionState where
  show SSIdle         = "Idle"
  show SSReady        = "Ready"
  show SSBucketActive = "BucketActive"
  show SSUploading    = "Uploading"
  show SSClosing      = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle         = 0
sessionStateToTag SSReady        = 1
sessionStateToTag SSBucketActive = 2
sessionStateToTag SSUploading    = 3
sessionStateToTag SSClosing      = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSReady
tagToSessionState 2 = Just SSBucketActive
tagToSessionState 3 = Just SSUploading
tagToSessionState 4 = Just SSClosing
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle         = Refl
sessionStateRoundtrip SSReady        = Refl
sessionStateRoundtrip SSBucketActive = Refl
sessionStateRoundtrip SSUploading    = Refl
sessionStateRoundtrip SSClosing      = Refl
