-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DbserverABI.Types: C-ABI-compatible numeric representations of database
-- server types.
--
-- Maps every constructor of the core Dbserver sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/dbserver.zig)
-- exactly.
--
-- Types covered:
--   QueryType      (12 constructors, tags 0-11)
--   DataType       (9 constructors,  tags 0-8)
--   IsolationLevel (4 constructors,  tags 0-3)
--   ErrorCode      (10 constructors, tags 0-9)
--   JoinType       (5 constructors,  tags 0-4)
--   SessionState   (6 constructors,  tags 0-5)

module DbserverABI.Types

import Dbserver.Types

%default total

---------------------------------------------------------------------------
-- QueryType (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
queryTypeToTag : QueryType -> Bits8
queryTypeToTag Select      = 0
queryTypeToTag Insert      = 1
queryTypeToTag Update      = 2
queryTypeToTag Delete      = 3
queryTypeToTag CreateTable = 4
queryTypeToTag DropTable   = 5
queryTypeToTag AlterTable  = 6
queryTypeToTag CreateIndex = 7
queryTypeToTag DropIndex   = 8
queryTypeToTag Begin       = 9
queryTypeToTag Commit      = 10
queryTypeToTag Rollback    = 11

public export
tagToQueryType : Bits8 -> Maybe QueryType
tagToQueryType 0  = Just Select
tagToQueryType 1  = Just Insert
tagToQueryType 2  = Just Update
tagToQueryType 3  = Just Delete
tagToQueryType 4  = Just CreateTable
tagToQueryType 5  = Just DropTable
tagToQueryType 6  = Just AlterTable
tagToQueryType 7  = Just CreateIndex
tagToQueryType 8  = Just DropIndex
tagToQueryType 9  = Just Begin
tagToQueryType 10 = Just Commit
tagToQueryType 11 = Just Rollback
tagToQueryType _  = Nothing

public export
queryTypeRoundtrip : (q : QueryType) -> tagToQueryType (queryTypeToTag q) = Just q
queryTypeRoundtrip Select      = Refl
queryTypeRoundtrip Insert      = Refl
queryTypeRoundtrip Update      = Refl
queryTypeRoundtrip Delete      = Refl
queryTypeRoundtrip CreateTable = Refl
queryTypeRoundtrip DropTable   = Refl
queryTypeRoundtrip AlterTable  = Refl
queryTypeRoundtrip CreateIndex = Refl
queryTypeRoundtrip DropIndex   = Refl
queryTypeRoundtrip Begin       = Refl
queryTypeRoundtrip Commit      = Refl
queryTypeRoundtrip Rollback    = Refl

---------------------------------------------------------------------------
-- DataType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
dataTypeToTag : DataType -> Bits8
dataTypeToTag Integer   = 0
dataTypeToTag Float     = 1
dataTypeToTag Text      = 2
dataTypeToTag Blob      = 3
dataTypeToTag Boolean   = 4
dataTypeToTag Timestamp = 5
dataTypeToTag UUID      = 6
dataTypeToTag JSON      = 7
dataTypeToTag Null      = 8

public export
tagToDataType : Bits8 -> Maybe DataType
tagToDataType 0 = Just Integer
tagToDataType 1 = Just Float
tagToDataType 2 = Just Text
tagToDataType 3 = Just Blob
tagToDataType 4 = Just Boolean
tagToDataType 5 = Just Timestamp
tagToDataType 6 = Just UUID
tagToDataType 7 = Just JSON
tagToDataType 8 = Just Null
tagToDataType _ = Nothing

public export
dataTypeRoundtrip : (d : DataType) -> tagToDataType (dataTypeToTag d) = Just d
dataTypeRoundtrip Integer   = Refl
dataTypeRoundtrip Float     = Refl
dataTypeRoundtrip Text      = Refl
dataTypeRoundtrip Blob      = Refl
dataTypeRoundtrip Boolean   = Refl
dataTypeRoundtrip Timestamp = Refl
dataTypeRoundtrip UUID      = Refl
dataTypeRoundtrip JSON      = Refl
dataTypeRoundtrip Null      = Refl

---------------------------------------------------------------------------
-- IsolationLevel (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
isolationLevelToTag : IsolationLevel -> Bits8
isolationLevelToTag ReadUncommitted = 0
isolationLevelToTag ReadCommitted   = 1
isolationLevelToTag RepeatableRead  = 2
isolationLevelToTag Serializable    = 3

public export
tagToIsolationLevel : Bits8 -> Maybe IsolationLevel
tagToIsolationLevel 0 = Just ReadUncommitted
tagToIsolationLevel 1 = Just ReadCommitted
tagToIsolationLevel 2 = Just RepeatableRead
tagToIsolationLevel 3 = Just Serializable
tagToIsolationLevel _ = Nothing

public export
isolationLevelRoundtrip : (i : IsolationLevel) -> tagToIsolationLevel (isolationLevelToTag i) = Just i
isolationLevelRoundtrip ReadUncommitted = Refl
isolationLevelRoundtrip ReadCommitted   = Refl
isolationLevelRoundtrip RepeatableRead  = Refl
isolationLevelRoundtrip Serializable    = Refl

---------------------------------------------------------------------------
-- ErrorCode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag SyntaxError         = 0
errorCodeToTag TableNotFound       = 1
errorCodeToTag ColumnNotFound      = 2
errorCodeToTag DuplicateKey        = 3
errorCodeToTag ConstraintViolation = 4
errorCodeToTag TypeMismatch        = 5
errorCodeToTag DeadlockDetected    = 6
errorCodeToTag TransactionAborted  = 7
errorCodeToTag DiskFull            = 8
errorCodeToTag ConnectionLost      = 9

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just SyntaxError
tagToErrorCode 1 = Just TableNotFound
tagToErrorCode 2 = Just ColumnNotFound
tagToErrorCode 3 = Just DuplicateKey
tagToErrorCode 4 = Just ConstraintViolation
tagToErrorCode 5 = Just TypeMismatch
tagToErrorCode 6 = Just DeadlockDetected
tagToErrorCode 7 = Just TransactionAborted
tagToErrorCode 8 = Just DiskFull
tagToErrorCode 9 = Just ConnectionLost
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip SyntaxError         = Refl
errorCodeRoundtrip TableNotFound       = Refl
errorCodeRoundtrip ColumnNotFound      = Refl
errorCodeRoundtrip DuplicateKey        = Refl
errorCodeRoundtrip ConstraintViolation = Refl
errorCodeRoundtrip TypeMismatch        = Refl
errorCodeRoundtrip DeadlockDetected    = Refl
errorCodeRoundtrip TransactionAborted  = Refl
errorCodeRoundtrip DiskFull            = Refl
errorCodeRoundtrip ConnectionLost      = Refl

---------------------------------------------------------------------------
-- JoinType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
joinTypeToTag : JoinType -> Bits8
joinTypeToTag Inner      = 0
joinTypeToTag LeftOuter  = 1
joinTypeToTag RightOuter = 2
joinTypeToTag FullOuter  = 3
joinTypeToTag Cross      = 4

public export
tagToJoinType : Bits8 -> Maybe JoinType
tagToJoinType 0 = Just Inner
tagToJoinType 1 = Just LeftOuter
tagToJoinType 2 = Just RightOuter
tagToJoinType 3 = Just FullOuter
tagToJoinType 4 = Just Cross
tagToJoinType _ = Nothing

public export
joinTypeRoundtrip : (j : JoinType) -> tagToJoinType (joinTypeToTag j) = Just j
joinTypeRoundtrip Inner      = Refl
joinTypeRoundtrip LeftOuter  = Refl
joinTypeRoundtrip RightOuter = Refl
joinTypeRoundtrip FullOuter  = Refl
joinTypeRoundtrip Cross      = Refl

---------------------------------------------------------------------------
-- SessionState (6 constructors, tags 0-5)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Database session lifecycle states.
||| Simplified view used by the FFI layer for the C ABI.
public export
data SessionState : Type where
  ||| No connection. Initial and terminal state.
  DSIdle          : SessionState
  ||| Connection established, ready for queries.
  DSConnected     : SessionState
  ||| Inside an explicit transaction.
  DSTransaction   : SessionState
  ||| Executing a query.
  DSExecuting     : SessionState
  ||| Transaction is being committed or rolled back.
  DSFinalising    : SessionState
  ||| Connection shutting down.
  DSDisconnecting : SessionState

public export
Eq SessionState where
  DSIdle          == DSIdle          = True
  DSConnected     == DSConnected     = True
  DSTransaction   == DSTransaction   = True
  DSExecuting     == DSExecuting     = True
  DSFinalising    == DSFinalising    = True
  DSDisconnecting == DSDisconnecting = True
  _               == _               = False

public export
Show SessionState where
  show DSIdle          = "Idle"
  show DSConnected     = "Connected"
  show DSTransaction   = "Transaction"
  show DSExecuting     = "Executing"
  show DSFinalising    = "Finalising"
  show DSDisconnecting = "Disconnecting"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag DSIdle          = 0
sessionStateToTag DSConnected     = 1
sessionStateToTag DSTransaction   = 2
sessionStateToTag DSExecuting     = 3
sessionStateToTag DSFinalising    = 4
sessionStateToTag DSDisconnecting = 5

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just DSIdle
tagToSessionState 1 = Just DSConnected
tagToSessionState 2 = Just DSTransaction
tagToSessionState 3 = Just DSExecuting
tagToSessionState 4 = Just DSFinalising
tagToSessionState 5 = Just DSDisconnecting
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip DSIdle          = Refl
sessionStateRoundtrip DSConnected     = Refl
sessionStateRoundtrip DSTransaction   = Refl
sessionStateRoundtrip DSExecuting     = Refl
sessionStateRoundtrip DSFinalising    = Refl
sessionStateRoundtrip DSDisconnecting = Refl

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Proof witness that a database session state transition is valid.
public export
data ValidSessionTransition : SessionState -> SessionState -> Type where
  ClientConnected      : ValidSessionTransition DSIdle DSConnected
  BeginTransaction     : ValidSessionTransition DSConnected DSTransaction
  ExecuteFromConnected : ValidSessionTransition DSConnected DSExecuting
  ExecuteInTransaction : ValidSessionTransition DSTransaction DSExecuting
  QueryDoneConnected   : ValidSessionTransition DSExecuting DSConnected
  QueryDoneTransaction : ValidSessionTransition DSExecuting DSTransaction
  BeginFinalise        : ValidSessionTransition DSTransaction DSFinalising
  FinaliseDone         : ValidSessionTransition DSFinalising DSConnected
  DisconnectFromConn   : ValidSessionTransition DSConnected DSDisconnecting
  DisconnectFromTx     : ValidSessionTransition DSTransaction DSDisconnecting
  DisconnectFromExec   : ValidSessionTransition DSExecuting DSDisconnecting
  CleanupDone          : ValidSessionTransition DSDisconnecting DSIdle

||| Check whether a session state transition is valid.
public export
validateSessionTransition : (from : SessionState) -> (to : SessionState)
                          -> Maybe (ValidSessionTransition from to)
validateSessionTransition DSIdle          DSConnected     = Just ClientConnected
validateSessionTransition DSConnected     DSTransaction   = Just BeginTransaction
validateSessionTransition DSConnected     DSExecuting     = Just ExecuteFromConnected
validateSessionTransition DSTransaction   DSExecuting     = Just ExecuteInTransaction
validateSessionTransition DSExecuting     DSConnected     = Just QueryDoneConnected
validateSessionTransition DSExecuting     DSTransaction   = Just QueryDoneTransaction
validateSessionTransition DSTransaction   DSFinalising    = Just BeginFinalise
validateSessionTransition DSFinalising    DSConnected     = Just FinaliseDone
validateSessionTransition DSConnected     DSDisconnecting = Just DisconnectFromConn
validateSessionTransition DSTransaction   DSDisconnecting = Just DisconnectFromTx
validateSessionTransition DSExecuting     DSDisconnecting = Just DisconnectFromExec
validateSessionTransition DSDisconnecting DSIdle          = Just CleanupDone
validateSessionTransition _               _               = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot execute queries from Idle.
public export
idleCannotExecute : ValidSessionTransition DSIdle DSExecuting -> Void
idleCannotExecute _ impossible

||| Cannot begin transactions from Idle.
public export
idleCannotBeginTx : ValidSessionTransition DSIdle DSTransaction -> Void
idleCannotBeginTx _ impossible

||| Cannot go from Disconnecting back to Connected directly.
public export
cannotReconnectFromDisconnecting : ValidSessionTransition DSDisconnecting DSConnected -> Void
cannotReconnectFromDisconnecting _ impossible
