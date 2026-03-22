// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// File Server protocol types for proven-servers.

/// FileOperation matching the Idris2 ABI tags.
enum FileOperation {
  read(0),
  write(1),
  create(2),
  delete(3),
  rename(4),
  list(5),
  stat(6),
  lock(7),
  unlock(8),
  watch(9);

  const FileOperation(this.tag);
  final int tag;

  static FileOperation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FileType matching the Idris2 ABI tags.
enum FileType {
  regular(0),
  directory(1),
  symlink(2),
  blockDevice(3),
  charDevice(4),
  fifo(5),
  socket(6);

  const FileType(this.tag);
  final int tag;

  static FileType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FilePermission matching the Idris2 ABI tags.
enum FilePermission {
  ownerRead(0),
  ownerWrite(1),
  ownerExecute(2),
  groupRead(3),
  groupWrite(4),
  groupExecute(5),
  otherRead(6),
  otherWrite(7),
  otherExecute(8);

  const FilePermission(this.tag);
  final int tag;

  static FilePermission? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LockType matching the Idris2 ABI tags.
enum LockType {
  shared(0),
  exclusive(1),
  advisory(2),
  mandatory(3);

  const LockType(this.tag);
  final int tag;

  static LockType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FileErrorCode matching the Idris2 ABI tags.
enum FileErrorCode {
  notFound(0),
  permissionDenied(1),
  alreadyExists(2),
  notEmpty(3),
  isDirectory(4),
  notDirectory(5),
  noSpace(6),
  readOnly(7),
  locked(8),
  ioError(9);

  const FileErrorCode(this.tag);
  final int tag;

  static FileErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  connected(1),
  operating(2),
  fsLocked(3),
  disconnecting(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
