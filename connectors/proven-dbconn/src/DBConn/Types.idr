-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConn.Types: Core type definitions for database connector interfaces.
-- Closed sum types representing connection states, isolation levels,
-- parameterised query parameter types, query results, connection errors,
-- and connection pool states.  These types enforce that any database
-- backend connector is type-safe at the boundary — no raw string
-- interpolation is possible because all parameters are typed.

module DBConn.Types

%default total

---------------------------------------------------------------------------
-- ConnState — the state of a database connection.
---------------------------------------------------------------------------

||| The lifecycle state of a database connection.
public export
data ConnState : Type where
  ||| No connection established.
  Disconnected  : ConnState
  ||| Connection established, ready for queries.
  Connected     : ConnState
  ||| Inside an active transaction.
  InTransaction : ConnState
  ||| Connection has entered a failed state and must be reset or discarded.
  Failed        : ConnState

public export
Show ConnState where
  show Disconnected  = "Disconnected"
  show Connected     = "Connected"
  show InTransaction = "InTransaction"
  show Failed        = "Failed"

---------------------------------------------------------------------------
-- IsolationLevel — transaction isolation semantics.
---------------------------------------------------------------------------

||| SQL transaction isolation levels per the SQL standard, plus the
||| Snapshot isolation level supported by some engines.
public export
data IsolationLevel : Type where
  ||| Permits dirty reads.  Weakest isolation.
  ReadUncommitted : IsolationLevel
  ||| Prevents dirty reads but permits non-repeatable reads.
  ReadCommitted   : IsolationLevel
  ||| Prevents dirty and non-repeatable reads but permits phantom reads.
  RepeatableRead  : IsolationLevel
  ||| Full serialisation of concurrent transactions.
  Serializable    : IsolationLevel
  ||| Multi-version concurrency snapshot (e.g. SQL Server, CockroachDB).
  Snapshot        : IsolationLevel

public export
Show IsolationLevel where
  show ReadUncommitted = "ReadUncommitted"
  show ReadCommitted   = "ReadCommitted"
  show RepeatableRead  = "RepeatableRead"
  show Serializable    = "Serializable"
  show Snapshot        = "Snapshot"

---------------------------------------------------------------------------
-- ParamType — typed query parameters.
---------------------------------------------------------------------------

||| The type of a single parameter in a parameterised query.
||| By requiring callers to tag every parameter with a ParamType,
||| raw string interpolation into SQL is structurally impossible.
public export
data ParamType : Type where
  ||| A text/string parameter.
  PText      : ParamType
  ||| A signed integer parameter.
  PInt       : ParamType
  ||| A floating-point parameter.
  PFloat     : ParamType
  ||| A boolean parameter.
  PBool      : ParamType
  ||| An explicit SQL NULL.
  PNull      : ParamType
  ||| A raw byte-array parameter (e.g. BYTEA).
  PBytes     : ParamType
  ||| A timestamp parameter (ISO 8601 / RFC 3339).
  PTimestamp : ParamType
  ||| A UUID parameter (RFC 9562).
  PUUID      : ParamType

public export
Show ParamType where
  show PText      = "PText"
  show PInt       = "PInt"
  show PFloat     = "PFloat"
  show PBool      = "PBool"
  show PNull      = "PNull"
  show PBytes     = "PBytes"
  show PTimestamp = "PTimestamp"
  show PUUID      = "PUUID"

---------------------------------------------------------------------------
-- QueryResult — the outcome of executing a query.
---------------------------------------------------------------------------

||| The result category returned after executing a database query.
public export
data QueryResult : Type where
  ||| A set of rows was returned (SELECT).
  ResultSet : QueryResult
  ||| An affected-row count was returned (INSERT/UPDATE/DELETE).
  RowCount  : QueryResult
  ||| The query produced no output (e.g. DDL with no result).
  Empty     : QueryResult
  ||| The query failed with a database-level error.
  Error     : QueryResult

public export
Show QueryResult where
  show ResultSet = "ResultSet"
  show RowCount  = "RowCount"
  show Empty     = "Empty"
  show Error     = "Error"

---------------------------------------------------------------------------
-- ConnError — database connection and query error categories.
---------------------------------------------------------------------------

||| Error categories that a database connector can report.
public export
data ConnError : Type where
  ||| The remote database refused the TCP connection.
  ConnectionRefused    : ConnError
  ||| Credentials were rejected by the database server.
  AuthenticationFailed : ConnError
  ||| The SQL query itself failed (syntax, constraint, etc.).
  QueryError           : ConnError
  ||| A transaction could not be committed or rolled back.
  TransactionError     : ConnError
  ||| The operation exceeded the configured timeout.
  Timeout              : ConnError
  ||| All connections in the pool are in use and none could be acquired.
  PoolExhausted        : ConnError
  ||| A wire-protocol violation was detected.
  ProtocolError        : ConnError
  ||| The server requires TLS but the connector attempted plaintext.
  TLSRequired          : ConnError

public export
Show ConnError where
  show ConnectionRefused    = "ConnectionRefused"
  show AuthenticationFailed = "AuthenticationFailed"
  show QueryError           = "QueryError"
  show TransactionError     = "TransactionError"
  show Timeout              = "Timeout"
  show PoolExhausted        = "PoolExhausted"
  show ProtocolError        = "ProtocolError"
  show TLSRequired          = "TLSRequired"

---------------------------------------------------------------------------
-- PoolState — connection pool lifecycle.
---------------------------------------------------------------------------

||| The lifecycle state of a connection pool.
public export
data PoolState : Type where
  ||| Pool is idle with no active checkouts.
  Idle     : PoolState
  ||| Pool has at least one connection checked out.
  Active   : PoolState
  ||| Pool is draining — returning connections but not issuing new ones.
  Draining : PoolState
  ||| Pool is shut down; all connections released.
  Closed   : PoolState

public export
Show PoolState where
  show Idle     = "Idle"
  show Active   = "Active"
  show Draining = "Draining"
  show Closed   = "Closed"
