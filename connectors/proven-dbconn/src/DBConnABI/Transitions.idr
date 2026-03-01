-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConnABI.Transitions: Valid state transition proofs for database connections.
--
-- This module is the heart of the formal verification layer.  It defines:
--
--   1. ValidTransition — a GADT whose constructors enumerate every legal
--      state transition.  Because only legal transitions have constructors,
--      any function requiring a ValidTransition proof as an argument is
--      *statically guaranteed* to only perform valid transitions.
--
--   2. CanQuery — a proof witness that a connection is in a state where
--      queries are permitted (Connected or InTransaction).
--
--   3. CanBeginTx — a proof witness that a transaction can be started
--      (only from Connected, not from any other state).
--
--   4. Impossibility proofs — functions that prove certain transitions
--      cannot occur.  These are used by callers to handle exhaustive
--      pattern matching: the Idris2 type checker confirms that the
--      "impossible" branch truly has no inhabitants.
--
-- The state machine modelled here is:
--
--   Disconnected --Connect--> Connected --BeginTx--> InTransaction
--        ^                      |   |                     |   |
--        |                      |   |                     |   |
--       Reset                   |   +---ConnDropped-->    |   |
--        |                      |                    |    |   |
--        +--- Failed <----------+--- TxFailed -------+----+   |
--                                                             |
--        +--- Disconnected <--- Connected <--- EndTx ---------+
--
-- Every arrow in the diagram above has exactly one ValidTransition
-- constructor.  There are no other arrows — the type system prevents
-- any transition not shown.

module DBConnABI.Transitions

import DBConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a state transition is valid.
||| Only constructors for legal transitions exist — the type system
||| prevents any transition not listed here.
public export
data ValidTransition : ConnState -> ConnState -> Type where
  ||| Disconnected -> Connected (connection attempt succeeded).
  Connect       : ValidTransition Disconnected Connected
  ||| Disconnected -> Failed (connection attempt failed).
  ConnectFail   : ValidTransition Disconnected Failed
  ||| Connected -> InTransaction (BEGIN issued).
  BeginTx       : ValidTransition Connected InTransaction
  ||| Connected -> Disconnected (graceful disconnect).
  Disconnect    : ValidTransition Connected Disconnected
  ||| Connected -> Failed (connection dropped unexpectedly).
  ConnDropped   : ValidTransition Connected Failed
  ||| InTransaction -> Connected (COMMIT or ROLLBACK succeeded).
  EndTx         : ValidTransition InTransaction Connected
  ||| InTransaction -> Failed (transaction failed irrecoverably).
  TxFailed      : ValidTransition InTransaction Failed
  ||| Failed -> Disconnected (reset/discard the failed connection).
  Reset         : ValidTransition Failed Disconnected

||| Show instance for ValidTransition, producing a human-readable label
||| for each transition kind.
public export
Show (ValidTransition from to) where
  show Connect     = "Connect"
  show ConnectFail = "ConnectFail"
  show BeginTx     = "BeginTx"
  show Disconnect  = "Disconnect"
  show ConnDropped = "ConnDropped"
  show EndTx       = "EndTx"
  show TxFailed    = "TxFailed"
  show Reset       = "Reset"

---------------------------------------------------------------------------
-- CanQuery: proof that a state permits query execution.
---------------------------------------------------------------------------

||| Proof witness that a query can be executed in the given connection state.
||| Only Connected and InTransaction permit queries — there are no
||| constructors for Disconnected or Failed.
public export
data CanQuery : ConnState -> Type where
  ||| Queries are allowed when the connection is established.
  QueryConnected     : CanQuery Connected
  ||| Queries are allowed inside an active transaction.
  QueryInTransaction : CanQuery InTransaction

---------------------------------------------------------------------------
-- CanBeginTx: proof that a transaction can be started.
---------------------------------------------------------------------------

||| Proof witness that a transaction can be started from the given state.
||| Transactions can only begin from Connected — not from Disconnected
||| (no connection), InTransaction (already in one), or Failed (must reset).
public export
data CanBeginTx : ConnState -> Type where
  ||| Transactions can only begin when Connected (not already in one).
  BeginFromConnected : CanBeginTx Connected

---------------------------------------------------------------------------
-- Impossibility proofs: these confirm that certain states do NOT
-- permit certain operations.  The Idris2 type checker verifies that
-- the `impossible` keyword is justified — i.e. that no constructor
-- of the given type can produce a value at the specified index.
---------------------------------------------------------------------------

||| Proof that you cannot query when Disconnected.
||| There is no CanQuery constructor indexed by Disconnected, so this
||| function body is empty — the type checker confirms the impossibility.
public export
disconnectedCantQuery : CanQuery Disconnected -> Void
disconnectedCantQuery x impossible

||| Proof that you cannot query when Failed.
||| There is no CanQuery constructor indexed by Failed.
public export
failedCantQuery : CanQuery Failed -> Void
failedCantQuery x impossible

||| Proof that you cannot begin a transaction when Disconnected.
||| There is no CanBeginTx constructor indexed by Disconnected.
public export
disconnectedCantBeginTx : CanBeginTx Disconnected -> Void
disconnectedCantBeginTx x impossible

||| Proof that you cannot begin a transaction when already in one.
||| There is no CanBeginTx constructor indexed by InTransaction.
public export
inTransactionCantBeginTx : CanBeginTx InTransaction -> Void
inTransactionCantBeginTx x impossible

||| Proof that you cannot begin a transaction when Failed.
||| There is no CanBeginTx constructor indexed by Failed.
public export
failedCantBeginTx : CanBeginTx Failed -> Void
failedCantBeginTx x impossible

---------------------------------------------------------------------------
-- Decidability: runtime decision procedures for capabilities.
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits queries.
||| Returns either a proof that queries are allowed, or a proof
||| that they are not.  This is used at the FFI boundary where
||| the state is known only at runtime.
public export
canQuery : (s : ConnState) -> Dec (CanQuery s)
canQuery Disconnected  = No disconnectedCantQuery
canQuery Connected     = Yes QueryConnected
canQuery InTransaction = Yes QueryInTransaction
canQuery Failed        = No failedCantQuery

||| Decide at runtime whether a given state permits beginning a transaction.
public export
canBeginTx : (s : ConnState) -> Dec (CanBeginTx s)
canBeginTx Disconnected  = No disconnectedCantBeginTx
canBeginTx Connected     = Yes BeginFromConnected
canBeginTx InTransaction = No inTransactionCantBeginTx
canBeginTx Failed        = No failedCantBeginTx
