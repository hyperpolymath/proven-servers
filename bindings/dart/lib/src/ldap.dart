// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  anonymous(0),
  bound(1),
  closed(2),
  binding(3);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Operation matching the Idris2 ABI tags.
enum Operation {
  bind(0),
  unbind(1),
  search(2),
  modify(3),
  add(4),
  delete(5),
  modDn(6),
  compare(7),
  abandon(8),
  extended(9);

  const Operation(this.tag);
  final int tag;

  static Operation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SearchScope matching the Idris2 ABI tags.
enum SearchScope {
  baseObject(0),
  singleLevel(1),
  wholeSubtree(2);

  const SearchScope(this.tag);
  final int tag;

  static SearchScope? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResultCode matching the Idris2 ABI tags.
enum ResultCode {
  success(0),
  operationsError(1),
  protocolError(2),
  timeLimitExceeded(3),
  sizeLimitExceeded(4),
  authMethodNotSupported(5),
  noSuchObject(6),
  invalidCredentials(7),
  insufficientAccessRights(8),
  busy(9),
  unavailable(10);

  const ResultCode(this.tag);
  final int tag;

  static ResultCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
