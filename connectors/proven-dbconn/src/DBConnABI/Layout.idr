-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the six core sum types (ConnState, IsolationLevel,
-- ParamType, QueryResult, ConnError, PoolState) to a fixed Bits8 value for
-- C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/dbconn.h) and the
-- Zig FFI enums (ffi/zig/src/dbconn.zig) exactly.

module DBConnABI.Layout

import DBConn.Types

%default total

---------------------------------------------------------------------------
-- ConnState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for ConnState (1 byte).
public export
connStateSize : Nat
connStateSize = 1

||| Map ConnState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Disconnected  = 0
|||   Connected     = 1
|||   InTransaction = 2
|||   Failed        = 3
public export
connStateToTag : ConnState -> Bits8
connStateToTag Disconnected  = 0
connStateToTag Connected     = 1
connStateToTag InTransaction = 2
connStateToTag Failed        = 3

||| Recover ConnState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToConnState : Bits8 -> Maybe ConnState
tagToConnState 0 = Just Disconnected
tagToConnState 1 = Just Connected
tagToConnState 2 = Just InTransaction
tagToConnState 3 = Just Failed
tagToConnState _ = Nothing

||| Proof: encoding then decoding ConnState is the identity.
||| This is exhaustive over all four constructors — the type checker
||| verifies that (tagToConnState (connStateToTag s)) reduces to (Just s)
||| for every possible value of s.
public export
connStateRoundtrip : (s : ConnState) -> tagToConnState (connStateToTag s) = Just s
connStateRoundtrip Disconnected  = Refl
connStateRoundtrip Connected     = Refl
connStateRoundtrip InTransaction = Refl
connStateRoundtrip Failed        = Refl

---------------------------------------------------------------------------
-- IsolationLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| C-ABI representation size for IsolationLevel (1 byte).
public export
isolationLevelSize : Nat
isolationLevelSize = 1

||| Map IsolationLevel to its C-ABI byte value.
|||
||| Tag assignments:
|||   ReadUncommitted = 0
|||   ReadCommitted   = 1
|||   RepeatableRead  = 2
|||   Serializable    = 3
|||   Snapshot        = 4
public export
isolationLevelToTag : IsolationLevel -> Bits8
isolationLevelToTag ReadUncommitted = 0
isolationLevelToTag ReadCommitted   = 1
isolationLevelToTag RepeatableRead  = 2
isolationLevelToTag Serializable    = 3
isolationLevelToTag Snapshot        = 4

||| Recover IsolationLevel from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-4.
public export
tagToIsolationLevel : Bits8 -> Maybe IsolationLevel
tagToIsolationLevel 0 = Just ReadUncommitted
tagToIsolationLevel 1 = Just ReadCommitted
tagToIsolationLevel 2 = Just RepeatableRead
tagToIsolationLevel 3 = Just Serializable
tagToIsolationLevel 4 = Just Snapshot
tagToIsolationLevel _ = Nothing

||| Proof: encoding then decoding IsolationLevel is the identity.
public export
isolationLevelRoundtrip : (iso : IsolationLevel) -> tagToIsolationLevel (isolationLevelToTag iso) = Just iso
isolationLevelRoundtrip ReadUncommitted = Refl
isolationLevelRoundtrip ReadCommitted   = Refl
isolationLevelRoundtrip RepeatableRead  = Refl
isolationLevelRoundtrip Serializable    = Refl
isolationLevelRoundtrip Snapshot        = Refl

---------------------------------------------------------------------------
-- ParamType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for ParamType (1 byte).
public export
paramTypeSize : Nat
paramTypeSize = 1

||| Map ParamType to its C-ABI byte value.
|||
||| Tag assignments:
|||   PText      = 0
|||   PInt       = 1
|||   PFloat     = 2
|||   PBool      = 3
|||   PNull      = 4
|||   PBytes     = 5
|||   PTimestamp = 6
|||   PUUID      = 7
public export
paramTypeToTag : ParamType -> Bits8
paramTypeToTag PText      = 0
paramTypeToTag PInt       = 1
paramTypeToTag PFloat     = 2
paramTypeToTag PBool      = 3
paramTypeToTag PNull      = 4
paramTypeToTag PBytes     = 5
paramTypeToTag PTimestamp = 6
paramTypeToTag PUUID      = 7

||| Recover ParamType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToParamType : Bits8 -> Maybe ParamType
tagToParamType 0 = Just PText
tagToParamType 1 = Just PInt
tagToParamType 2 = Just PFloat
tagToParamType 3 = Just PBool
tagToParamType 4 = Just PNull
tagToParamType 5 = Just PBytes
tagToParamType 6 = Just PTimestamp
tagToParamType 7 = Just PUUID
tagToParamType _ = Nothing

||| Proof: encoding then decoding ParamType is the identity.
public export
paramTypeRoundtrip : (p : ParamType) -> tagToParamType (paramTypeToTag p) = Just p
paramTypeRoundtrip PText      = Refl
paramTypeRoundtrip PInt       = Refl
paramTypeRoundtrip PFloat     = Refl
paramTypeRoundtrip PBool      = Refl
paramTypeRoundtrip PNull      = Refl
paramTypeRoundtrip PBytes     = Refl
paramTypeRoundtrip PTimestamp = Refl
paramTypeRoundtrip PUUID      = Refl

---------------------------------------------------------------------------
-- QueryResult (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for QueryResult (1 byte).
public export
queryResultSize : Nat
queryResultSize = 1

||| Map QueryResult to its C-ABI byte value.
|||
||| Tag assignments:
|||   ResultSet = 0
|||   RowCount  = 1
|||   Empty     = 2
|||   Error     = 3
public export
queryResultToTag : QueryResult -> Bits8
queryResultToTag ResultSet = 0
queryResultToTag RowCount  = 1
queryResultToTag Empty     = 2
queryResultToTag Error     = 3

||| Recover QueryResult from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToQueryResult : Bits8 -> Maybe QueryResult
tagToQueryResult 0 = Just ResultSet
tagToQueryResult 1 = Just RowCount
tagToQueryResult 2 = Just Empty
tagToQueryResult 3 = Just Error
tagToQueryResult _ = Nothing

||| Proof: encoding then decoding QueryResult is the identity.
public export
queryResultRoundtrip : (r : QueryResult) -> tagToQueryResult (queryResultToTag r) = Just r
queryResultRoundtrip ResultSet = Refl
queryResultRoundtrip RowCount  = Refl
queryResultRoundtrip Empty     = Refl
queryResultRoundtrip Error     = Refl

---------------------------------------------------------------------------
-- ConnError (8 constructors, tags 1-8; 0 = no error)
---------------------------------------------------------------------------

||| C-ABI representation size for ConnError (1 byte).
||| Note: tag 0 is reserved for "no error" in the C header (DBCONN_ERR_NONE).
||| The Idris2 type has no "None" constructor — the absence of an error
||| is represented by the absence of a ConnError value (i.e. by returning
||| success/Nothing rather than Just ConnError).
public export
connErrorSize : Nat
connErrorSize = 1

||| Map ConnError to its C-ABI byte value.
|||
||| Tag assignments (tag 0 reserved for DBCONN_ERR_NONE):
|||   ConnectionRefused    = 1
|||   AuthenticationFailed = 2
|||   QueryError           = 3
|||   TransactionError     = 4
|||   Timeout              = 5
|||   PoolExhausted        = 6
|||   ProtocolError        = 7
|||   TLSRequired          = 8
public export
connErrorToTag : ConnError -> Bits8
connErrorToTag ConnectionRefused    = 1
connErrorToTag AuthenticationFailed = 2
connErrorToTag QueryError           = 3
connErrorToTag TransactionError     = 4
connErrorToTag Timeout              = 5
connErrorToTag PoolExhausted        = 6
connErrorToTag ProtocolError        = 7
connErrorToTag TLSRequired          = 8

||| Recover ConnError from its C-ABI byte value.
||| Returns Nothing for tag 0 (no error) and for values > 8.
public export
tagToConnError : Bits8 -> Maybe ConnError
tagToConnError 1 = Just ConnectionRefused
tagToConnError 2 = Just AuthenticationFailed
tagToConnError 3 = Just QueryError
tagToConnError 4 = Just TransactionError
tagToConnError 5 = Just Timeout
tagToConnError 6 = Just PoolExhausted
tagToConnError 7 = Just ProtocolError
tagToConnError 8 = Just TLSRequired
tagToConnError _ = Nothing

||| Proof: encoding then decoding ConnError is the identity.
public export
connErrorRoundtrip : (e : ConnError) -> tagToConnError (connErrorToTag e) = Just e
connErrorRoundtrip ConnectionRefused    = Refl
connErrorRoundtrip AuthenticationFailed = Refl
connErrorRoundtrip QueryError           = Refl
connErrorRoundtrip TransactionError     = Refl
connErrorRoundtrip Timeout              = Refl
connErrorRoundtrip PoolExhausted        = Refl
connErrorRoundtrip ProtocolError        = Refl
connErrorRoundtrip TLSRequired          = Refl

---------------------------------------------------------------------------
-- PoolState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for PoolState (1 byte).
public export
poolStateSize : Nat
poolStateSize = 1

||| Map PoolState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Idle     = 0
|||   Active   = 1
|||   Draining = 2
|||   Closed   = 3
public export
poolStateToTag : PoolState -> Bits8
poolStateToTag Idle     = 0
poolStateToTag Active   = 1
poolStateToTag Draining = 2
poolStateToTag Closed   = 3

||| Recover PoolState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToPoolState : Bits8 -> Maybe PoolState
tagToPoolState 0 = Just Idle
tagToPoolState 1 = Just Active
tagToPoolState 2 = Just Draining
tagToPoolState 3 = Just Closed
tagToPoolState _ = Nothing

||| Proof: encoding then decoding PoolState is the identity.
public export
poolStateRoundtrip : (ps : PoolState) -> tagToPoolState (poolStateToTag ps) = Just ps
poolStateRoundtrip Idle     = Refl
poolStateRoundtrip Active   = Refl
poolStateRoundtrip Draining = Refl
poolStateRoundtrip Closed   = Refl
