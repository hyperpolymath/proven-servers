// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph DB protocol types for proven-servers.

/// ElementType matching the Idris2 ABI tags.
enum ElementType {
  node(0),
  edge(1),
  property(2),
  label(3),
  index(4);

  const ElementType(this.tag);
  final int tag;

  static ElementType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// QueryLanguage matching the Idris2 ABI tags.
enum QueryLanguage {
  cypher(0),
  gremlin(1),
  sparql(2),
  graphQl(3);

  const QueryLanguage(this.tag);
  final int tag;

  static QueryLanguage? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TraversalStrategy matching the Idris2 ABI tags.
enum TraversalStrategy {
  bfs(0),
  dfs(1),
  dijkstra(2),
  aStar(3),
  random(4);

  const TraversalStrategy(this.tag);
  final int tag;

  static TraversalStrategy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Consistency matching the Idris2 ABI tags.
enum Consistency {
  strong(0),
  eventual(1),
  session(2),
  causal(3);

  const Consistency(this.tag);
  final int tag;

  static Consistency? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  syntaxError(0),
  nodeNotFound(1),
  edgeNotFound(2),
  constraintViolation(3),
  indexExists(4),
  transactionConflict(5),
  outOfMemory(6);

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
  connected(1),
  querying(2),
  traversing(3),
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
