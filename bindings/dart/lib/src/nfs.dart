// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NFS protocol types for proven-servers.

/// Operation matching the Idris2 ABI tags.
enum Operation {
  operation_Access(0),
  close(1),
  commit(2),
  create(3),
  getAttr(4),
  operation_Link(5),
  lock(6),
  lookup(7),
  open(8),
  read(9),
  readDir(10),
  remove(11),
  rename(12),
  setAttr(13),
  write(14);

  const Operation(this.tag);
  final int tag;

  static Operation? fromTag(int tag) {
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
  blockDevice(2),
  charDevice(3),
  fileType_Link(4),
  socket(5),
  fifo(6);

  const FileType(this.tag);
  final int tag;

  static FileType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Status matching the Idris2 ABI tags.
enum Status {
  ok(0),
  perm(1),
  noEnt(2),
  io(3),
  nxIo(4),
  status_Access(5),
  exist(6),
  notDir(7),
  isDir(8),
  fBig(9),
  noSpc(10),
  rOfs(11),
  notEmpty(12),
  stale(13);

  const Status(this.tag);
  final int tag;

  static Status? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NfsState matching the Idris2 ABI tags.
enum NfsState {
  idle(0),
  mounted(1),
  fileOpen(2),
  locked(3),
  busy(4),
  unmounting(5);

  const NfsState(this.tag);
  final int tag;

  static NfsState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
