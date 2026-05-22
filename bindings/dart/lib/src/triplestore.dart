// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

/// Statement matching the Idris2 ABI tags.
enum Statement {
  triple(0),
  quad(1);

  const Statement(this.tag);
  final int tag;

  static Statement? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IndexOrder matching the Idris2 ABI tags.
enum IndexOrder {
  spo(0),
  pos(1),
  osp(2),
  gspo(3),
  gpos(4),
  gosp(5);

  const IndexOrder(this.tag);
  final int tag;

  static IndexOrder? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StorageBackend matching the Idris2 ABI tags.
enum StorageBackend {
  inMemory(0),
  bTree(1),
  lsm(2),
  persistent(3);

  const StorageBackend(this.tag);
  final int tag;

  static StorageBackend? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ImportFormat matching the Idris2 ABI tags.
enum ImportFormat {
  nTriples(0),
  turtle(1),
  rdfXml(2),
  jsonLd(3),
  nQuads(4),
  trig(5);

  const ImportFormat(this.tag);
  final int tag;

  static ImportFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransactionIsolation matching the Idris2 ABI tags.
enum TransactionIsolation {
  readCommitted(0),
  serializable(1),
  snapshot(2);

  const TransactionIsolation(this.tag);
  final int tag;

  static TransactionIsolation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StoreState matching the Idris2 ABI tags.
enum StoreState {
  idle(0),
  ready(1),
  inTransaction(2),
  importing(3),
  closing(4);

  const StoreState(this.tag);
  final int tag;

  static StoreState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
