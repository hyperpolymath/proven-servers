-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TriplestoreABI Types: C-ABI-compatible numeric representations of triplestore types.
--
-- Maps every constructor of the core triplestore sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/triplestore.zig) exactly.
--
-- Types covered:
--   Statement            (2 constructors, tags 0-1)
--   IndexOrder           (6 constructors, tags 0-5)
--   StorageBackend       (4 constructors, tags 0-3)
--   ImportFormat         (6 constructors, tags 0-5)
--   TransactionIsolation (3 constructors, tags 0-2)
--   StoreState           (5 constructors, tags 0-4)

module TriplestoreABI.Types

import Triplestore.Types

%default total

---------------------------------------------------------------------------
-- Statement (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
statementSize : Nat
statementSize = 1

||| Encode a Statement to its ABI tag value.
public export
statementToTag : Statement -> Bits8
statementToTag Triple = 0
statementToTag Quad   = 1

||| Decode an ABI tag to a Statement.
public export
tagToStatement : Bits8 -> Maybe Statement
tagToStatement 0 = Just Triple
tagToStatement 1 = Just Quad
tagToStatement _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all Statement values.
public export
statementRoundtrip : (s : Statement) -> tagToStatement (statementToTag s) = Just s
statementRoundtrip Triple = Refl
statementRoundtrip Quad   = Refl

---------------------------------------------------------------------------
-- IndexOrder (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
indexOrderSize : Nat
indexOrderSize = 1

||| Encode an IndexOrder to its ABI tag value.
public export
indexOrderToTag : IndexOrder -> Bits8
indexOrderToTag SPO  = 0
indexOrderToTag POS  = 1
indexOrderToTag OSP  = 2
indexOrderToTag GSPO = 3
indexOrderToTag GPOS = 4
indexOrderToTag GOSP = 5

||| Decode an ABI tag to an IndexOrder.
public export
tagToIndexOrder : Bits8 -> Maybe IndexOrder
tagToIndexOrder 0 = Just SPO
tagToIndexOrder 1 = Just POS
tagToIndexOrder 2 = Just OSP
tagToIndexOrder 3 = Just GSPO
tagToIndexOrder 4 = Just GPOS
tagToIndexOrder 5 = Just GOSP
tagToIndexOrder _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all IndexOrder values.
public export
indexOrderRoundtrip : (i : IndexOrder) -> tagToIndexOrder (indexOrderToTag i) = Just i
indexOrderRoundtrip SPO  = Refl
indexOrderRoundtrip POS  = Refl
indexOrderRoundtrip OSP  = Refl
indexOrderRoundtrip GSPO = Refl
indexOrderRoundtrip GPOS = Refl
indexOrderRoundtrip GOSP = Refl

---------------------------------------------------------------------------
-- StorageBackend (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
storageBackendSize : Nat
storageBackendSize = 1

||| Encode a StorageBackend to its ABI tag value.
public export
storageBackendToTag : StorageBackend -> Bits8
storageBackendToTag InMemory   = 0
storageBackendToTag BTree      = 1
storageBackendToTag LSM        = 2
storageBackendToTag Persistent = 3

||| Decode an ABI tag to a StorageBackend.
public export
tagToStorageBackend : Bits8 -> Maybe StorageBackend
tagToStorageBackend 0 = Just InMemory
tagToStorageBackend 1 = Just BTree
tagToStorageBackend 2 = Just LSM
tagToStorageBackend 3 = Just Persistent
tagToStorageBackend _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all StorageBackend values.
public export
storageBackendRoundtrip : (b : StorageBackend) -> tagToStorageBackend (storageBackendToTag b) = Just b
storageBackendRoundtrip InMemory   = Refl
storageBackendRoundtrip BTree      = Refl
storageBackendRoundtrip LSM        = Refl
storageBackendRoundtrip Persistent = Refl

---------------------------------------------------------------------------
-- ImportFormat (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
importFormatSize : Nat
importFormatSize = 1

||| Encode an ImportFormat to its ABI tag value.
public export
importFormatToTag : ImportFormat -> Bits8
importFormatToTag NTriples = 0
importFormatToTag Turtle   = 1
importFormatToTag RDFxml   = 2
importFormatToTag JSONLD   = 3
importFormatToTag NQuads   = 4
importFormatToTag Trig     = 5

||| Decode an ABI tag to an ImportFormat.
public export
tagToImportFormat : Bits8 -> Maybe ImportFormat
tagToImportFormat 0 = Just NTriples
tagToImportFormat 1 = Just Turtle
tagToImportFormat 2 = Just RDFxml
tagToImportFormat 3 = Just JSONLD
tagToImportFormat 4 = Just NQuads
tagToImportFormat 5 = Just Trig
tagToImportFormat _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all ImportFormat values.
public export
importFormatRoundtrip : (f : ImportFormat) -> tagToImportFormat (importFormatToTag f) = Just f
importFormatRoundtrip NTriples = Refl
importFormatRoundtrip Turtle   = Refl
importFormatRoundtrip RDFxml   = Refl
importFormatRoundtrip JSONLD   = Refl
importFormatRoundtrip NQuads   = Refl
importFormatRoundtrip Trig     = Refl

---------------------------------------------------------------------------
-- TransactionIsolation (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
transactionIsolationSize : Nat
transactionIsolationSize = 1

||| Encode a TransactionIsolation to its ABI tag value.
public export
transactionIsolationToTag : TransactionIsolation -> Bits8
transactionIsolationToTag ReadCommitted = 0
transactionIsolationToTag Serializable  = 1
transactionIsolationToTag Snapshot      = 2

||| Decode an ABI tag to a TransactionIsolation.
public export
tagToTransactionIsolation : Bits8 -> Maybe TransactionIsolation
tagToTransactionIsolation 0 = Just ReadCommitted
tagToTransactionIsolation 1 = Just Serializable
tagToTransactionIsolation 2 = Just Snapshot
tagToTransactionIsolation _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all TransactionIsolation values.
public export
transactionIsolationRoundtrip : (t : TransactionIsolation) -> tagToTransactionIsolation (transactionIsolationToTag t) = Just t
transactionIsolationRoundtrip ReadCommitted = Refl
transactionIsolationRoundtrip Serializable  = Refl
transactionIsolationRoundtrip Snapshot      = Refl

---------------------------------------------------------------------------
-- StoreState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Triple store lifecycle states for FFI management.
public export
data StoreState : Type where
  ||| Not initialised. Initial and terminal state.
  STIdle        : StoreState
  ||| Store opened, ready for queries.
  STReady       : StoreState
  ||| Transaction in progress.
  STTransaction : StoreState
  ||| Bulk import in progress.
  STImporting   : StoreState
  ||| Store shutting down.
  STClosing     : StoreState

public export
Eq StoreState where
  STIdle        == STIdle        = True
  STReady       == STReady       = True
  STTransaction == STTransaction = True
  STImporting   == STImporting   = True
  STClosing     == STClosing     = True
  _             == _             = False

public export
Show StoreState where
  show STIdle        = "Idle"
  show STReady       = "Ready"
  show STTransaction = "Transaction"
  show STImporting   = "Importing"
  show STClosing     = "Closing"

public export
storeStateSize : Nat
storeStateSize = 1

||| Encode a StoreState to its ABI tag value.
public export
storeStateToTag : StoreState -> Bits8
storeStateToTag STIdle        = 0
storeStateToTag STReady       = 1
storeStateToTag STTransaction = 2
storeStateToTag STImporting   = 3
storeStateToTag STClosing     = 4

||| Decode an ABI tag to a StoreState.
public export
tagToStoreState : Bits8 -> Maybe StoreState
tagToStoreState 0 = Just STIdle
tagToStoreState 1 = Just STReady
tagToStoreState 2 = Just STTransaction
tagToStoreState 3 = Just STImporting
tagToStoreState 4 = Just STClosing
tagToStoreState _ = Nothing

||| Roundtrip proof: decode (encode x) = Just x for all StoreState values.
public export
storeStateRoundtrip : (s : StoreState) -> tagToStoreState (storeStateToTag s) = Just s
storeStateRoundtrip STIdle        = Refl
storeStateRoundtrip STReady       = Refl
storeStateRoundtrip STTransaction = Refl
storeStateRoundtrip STImporting   = Refl
storeStateRoundtrip STClosing     = Refl
