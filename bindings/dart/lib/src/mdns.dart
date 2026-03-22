// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

/// MdnsRecordType matching the Idris2 ABI tags.
enum MdnsRecordType {
  a(0),
  aaaa(1),
  ptr(2),
  srv(3),
  txt(4);

  const MdnsRecordType(this.tag);
  final int tag;

  static MdnsRecordType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// QueryType matching the Idris2 ABI tags.
enum QueryType {
  standard(0),
  oneShot(1),
  continuous(2);

  const QueryType(this.tag);
  final int tag;

  static QueryType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ConflictAction matching the Idris2 ABI tags.
enum ConflictAction {
  probe(0),
  defend(1),
  withdraw(2);

  const ConflictAction(this.tag);
  final int tag;

  static ConflictAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServiceFlag matching the Idris2 ABI tags.
enum ServiceFlag {
  unique(0),
  shared(1);

  const ServiceFlag(this.tag);
  final int tag;

  static ServiceFlag? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponderState matching the Idris2 ABI tags.
enum ResponderState {
  idle(0),
  probing(1),
  announcing(2),
  running(3),
  shuttingDown(4);

  const ResponderState(this.tag);
  final int tag;

  static ResponderState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
