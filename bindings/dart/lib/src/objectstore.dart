// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Object Store protocol types for proven-servers.

/// Operation matching the Idris2 ABI tags.
enum Operation {
  putObject(0),
  getObject(1),
  deleteObject(2),
  listObjects(3),
  headObject(4),
  copyObject(5),
  createBucket(6),
  deleteBucket(7),
  listBuckets(8),
  initMultipartUpload(9),
  uploadPart(10),
  completeMultipartUpload(11);

  const Operation(this.tag);
  final int tag;

  static Operation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StorageClass matching the Idris2 ABI tags.
enum StorageClass {
  standard(0),
  infrequentAccess(1),
  glacier(2),
  deepArchive(3),
  oneZone(4);

  const StorageClass(this.tag);
  final int tag;

  static StorageClass? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Acl matching the Idris2 ABI tags.
enum Acl {
  private(0),
  publicRead(1),
  publicReadWrite(2),
  authenticatedRead(3);

  const Acl(this.tag);
  final int tag;

  static Acl? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  noSuchBucket(0),
  noSuchKey(1),
  bucketAlreadyExists(2),
  bucketNotEmpty(3),
  accessDenied(4),
  entityTooLarge(5),
  invalidPart(6),
  incompleteBody(7);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  ready(1),
  bucketActive(2),
  uploading(3),
  closing(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
