// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  get_(0),
  set_(1),
  delete(2),
  exists(3),
  expire(4),
  ttl(5),
  keys(6),
  flush(7),
  incr(8),
  decr(9),
  append(10),
  prepend(11),
  cas(12);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EvictionPolicy matching the Idris2 ABI tags.
enum EvictionPolicy {
  lru(0),
  lfu(1),
  random(2),
  evictTtl(3),
  noEviction(4);

  const EvictionPolicy(this.tag);
  final int tag;

  static EvictionPolicy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DataType matching the Idris2 ABI tags.
enum DataType {
  stringVal(0),
  intVal(1),
  listVal(2),
  setVal(3),
  hashVal(4);

  const DataType(this.tag);
  final int tag;

  static DataType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  notFound(0),
  typeMismatch(1),
  outOfMemory(2),
  keyTooLong(3),
  valueTooLarge(4),
  casConflict(5);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ReplicationMode matching the Idris2 ABI tags.
enum ReplicationMode {
  none(0),
  primary(1),
  replica(2),
  sentinel(3);

  const ReplicationMode(this.tag);
  final int tag;

  static ReplicationMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
