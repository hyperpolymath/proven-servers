// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
enum Method {
  propfind(0),
  proppatch(1),
  mkcol(2),
  copy(3),
  move(4),
  lock(5),
  unlock(6);

  const Method(this.tag);
  final int tag;

  static Method? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StatusCode matching the Idris2 ABI tags.
enum StatusCode {
  multiStatus(0),
  unprocessableEntity(1),
  locked(2),
  failedDependency(3),
  insufficientStorage(4);

  const StatusCode(this.tag);
  final int tag;

  static StatusCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LockScope matching the Idris2 ABI tags.
enum LockScope {
  exclusive(0),
  shared(1);

  const LockScope(this.tag);
  final int tag;

  static LockScope? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LockType matching the Idris2 ABI tags.
enum LockType {
  write(0);

  const LockType(this.tag);
  final int tag;

  static LockType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Depth matching the Idris2 ABI tags.
enum Depth {
  zero(0),
  one(1),
  infinity(2);

  const Depth(this.tag);
  final int tag;

  static Depth? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PropertyOp matching the Idris2 ABI tags.
enum PropertyOp {
  set_(0),
  remove(1);

  const PropertyOp(this.tag);
  final int tag;

  static PropertyOp? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
