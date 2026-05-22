// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

/// NetconfOperation matching the Idris2 ABI tags.
enum NetconfOperation {
  get_(0),
  getConfig(1),
  editConfig(2),
  copyConfig(3),
  deleteConfig(4),
  lock(5),
  unlock(6),
  closeSession(7),
  killSession(8),
  commit(9),
  validate(10),
  discardChanges(11);

  const NetconfOperation(this.tag);
  final int tag;

  static NetconfOperation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Datastore matching the Idris2 ABI tags.
enum Datastore {
  running(0),
  startup(1),
  candidate(2);

  const Datastore(this.tag);
  final int tag;

  static Datastore? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EditOperation matching the Idris2 ABI tags.
enum EditOperation {
  merge(0),
  replace(1),
  create(2),
  delete(3),
  remove(4);

  const EditOperation(this.tag);
  final int tag;

  static EditOperation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NetconfErrorType matching the Idris2 ABI tags.
enum NetconfErrorType {
  transport(0),
  rpc(1),
  protocol(2),
  application(3);

  const NetconfErrorType(this.tag);
  final int tag;

  static NetconfErrorType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorSeverity matching the Idris2 ABI tags.
enum ErrorSeverity {
  error(0),
  warning(1);

  const ErrorSeverity(this.tag);
  final int tag;

  static ErrorSeverity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NetconfState matching the Idris2 ABI tags.
enum NetconfState {
  idle(0),
  connected(1),
  locked(2),
  editing(3),
  closing(4),
  terminated(5);

  const NetconfState(this.tag);
  final int tag;

  static NetconfState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
