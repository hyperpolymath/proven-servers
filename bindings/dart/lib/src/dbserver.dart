// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

/// QueryType matching the Idris2 ABI tags.
enum QueryType {
  select(0),
  insert(1),
  update(2),
  delete(3),
  createTable(4),
  dropTable(5),
  alterTable(6),
  createIndex(7),
  dropIndex(8),
  begin(9),
  commit(10),
  rollback(11);

  const QueryType(this.tag);
  final int tag;

  static QueryType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DataType matching the Idris2 ABI tags.
enum DataType {
  integer(0),
  float(1),
  text(2),
  blob(3),
  boolean(4),
  timestamp(5),
  uuid(6),
  json(7),
  null_(8);

  const DataType(this.tag);
  final int tag;

  static DataType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IsolationLevel matching the Idris2 ABI tags.
enum IsolationLevel {
  readUncommitted(0),
  readCommitted(1),
  repeatableRead(2),
  serializable(3);

  const IsolationLevel(this.tag);
  final int tag;

  static IsolationLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  syntaxError(0),
  tableNotFound(1),
  columnNotFound(2),
  duplicateKey(3),
  constraintViolation(4),
  typeMismatch(5),
  deadlockDetected(6),
  transactionAborted(7),
  diskFull(8),
  connectionLost(9);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// JoinType matching the Idris2 ABI tags.
enum JoinType {
  inner(0),
  leftOuter(1),
  rightOuter(2),
  fullOuter(3),
  cross(4);

  const JoinType(this.tag);
  final int tag;

  static JoinType? fromTag(int tag) {
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
  transaction(2),
  executing(3),
  finalising(4),
  disconnecting(5);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
