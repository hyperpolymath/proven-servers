// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

/// SparqlQueryType matching the Idris2 ABI tags.
enum SparqlQueryType {
  select(0),
  construct(1),
  ask(2),
  describe(3);

  const SparqlQueryType(this.tag);
  final int tag;

  static SparqlQueryType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// UpdateType matching the Idris2 ABI tags.
enum UpdateType {
  insert(0),
  delete(1),
  load(2),
  clear(3),
  create(4),
  drop(5);

  const UpdateType(this.tag);
  final int tag;

  static UpdateType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResultFormat matching the Idris2 ABI tags.
enum ResultFormat {
  xml(0),
  json(1),
  csv(2),
  tsv(3);

  const ResultFormat(this.tag);
  final int tag;

  static ResultFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SparqlErrorType matching the Idris2 ABI tags.
enum SparqlErrorType {
  parseError(0),
  queryTimeout(1),
  resultsTooLarge(2),
  unknownGraph(3),
  accessDenied(4);

  const SparqlErrorType(this.tag);
  final int tag;

  static SparqlErrorType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
