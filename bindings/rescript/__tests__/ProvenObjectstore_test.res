// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenObjectstore protocol bindings.

open ProvenObjectstore

let test_operation_roundtrip = () => {
  assert(operationFromTag(0) == Some(PutObject))
  assert(operationFromTag(1) == Some(GetObject))
  assert(operationFromTag(2) == Some(DeleteObject))
  assert(operationFromTag(3) == Some(ListObjects))
  assert(operationFromTag(4) == Some(HeadObject))
  assert(operationFromTag(5) == Some(CopyObject))
  assert(operationFromTag(6) == Some(CreateBucket))
  assert(operationFromTag(7) == Some(DeleteBucket))
  assert(operationFromTag(8) == Some(ListBuckets))
  assert(operationFromTag(9) == Some(InitMultipartUpload))
  assert(operationFromTag(10) == Some(UploadPart))
  assert(operationFromTag(11) == Some(CompleteMultipartUpload))
  assert(operationFromTag(12) == None)
}

let test_operation_toTag = () => {
  assert(operationToTag(PutObject) == 0)
  assert(operationToTag(GetObject) == 1)
  assert(operationToTag(DeleteObject) == 2)
  assert(operationToTag(ListObjects) == 3)
  assert(operationToTag(HeadObject) == 4)
  assert(operationToTag(CopyObject) == 5)
  assert(operationToTag(CreateBucket) == 6)
  assert(operationToTag(DeleteBucket) == 7)
  assert(operationToTag(ListBuckets) == 8)
  assert(operationToTag(InitMultipartUpload) == 9)
  assert(operationToTag(UploadPart) == 10)
  assert(operationToTag(CompleteMultipartUpload) == 11)
}

let test_storageClass_roundtrip = () => {
  assert(storageClassFromTag(0) == Some(Standard))
  assert(storageClassFromTag(1) == Some(InfrequentAccess))
  assert(storageClassFromTag(2) == Some(Glacier))
  assert(storageClassFromTag(3) == Some(DeepArchive))
  assert(storageClassFromTag(4) == Some(OneZone))
  assert(storageClassFromTag(5) == None)
}

let test_storageClass_toTag = () => {
  assert(storageClassToTag(Standard) == 0)
  assert(storageClassToTag(InfrequentAccess) == 1)
  assert(storageClassToTag(Glacier) == 2)
  assert(storageClassToTag(DeepArchive) == 3)
  assert(storageClassToTag(OneZone) == 4)
}

let test_acl_roundtrip = () => {
  assert(aclFromTag(0) == Some(Private))
  assert(aclFromTag(1) == Some(PublicRead))
  assert(aclFromTag(2) == Some(PublicReadWrite))
  assert(aclFromTag(3) == Some(AuthenticatedRead))
  assert(aclFromTag(4) == None)
}

let test_acl_toTag = () => {
  assert(aclToTag(Private) == 0)
  assert(aclToTag(PublicRead) == 1)
  assert(aclToTag(PublicReadWrite) == 2)
  assert(aclToTag(AuthenticatedRead) == 3)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(NoSuchBucket))
  assert(errorCodeFromTag(1) == Some(NoSuchKey))
  assert(errorCodeFromTag(2) == Some(BucketAlreadyExists))
  assert(errorCodeFromTag(3) == Some(BucketNotEmpty))
  assert(errorCodeFromTag(4) == Some(AccessDenied))
  assert(errorCodeFromTag(5) == Some(EntityTooLarge))
  assert(errorCodeFromTag(6) == Some(InvalidPart))
  assert(errorCodeFromTag(7) == Some(IncompleteBody))
  assert(errorCodeFromTag(8) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(NoSuchBucket) == 0)
  assert(errorCodeToTag(NoSuchKey) == 1)
  assert(errorCodeToTag(BucketAlreadyExists) == 2)
  assert(errorCodeToTag(BucketNotEmpty) == 3)
  assert(errorCodeToTag(AccessDenied) == 4)
  assert(errorCodeToTag(EntityTooLarge) == 5)
  assert(errorCodeToTag(InvalidPart) == 6)
  assert(errorCodeToTag(IncompleteBody) == 7)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Ready))
  assert(sessionStateFromTag(2) == Some(BucketActive))
  assert(sessionStateFromTag(3) == Some(Uploading))
  assert(sessionStateFromTag(4) == Some(Closing))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Ready) == 1)
  assert(sessionStateToTag(BucketActive) == 2)
  assert(sessionStateToTag(Uploading) == 3)
  assert(sessionStateToTag(Closing) == 4)
}

// Run all tests
test_operation_roundtrip()
test_operation_toTag()
test_storageClass_roundtrip()
test_storageClass_toTag()
test_acl_roundtrip()
test_acl_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
