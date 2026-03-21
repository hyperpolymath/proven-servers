// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenTriplestore protocol bindings.

open ProvenTriplestore

let test_statement_roundtrip = () => {
  assert(statementFromTag(0) == Some(Triple))
  assert(statementFromTag(1) == Some(Quad))
  assert(statementFromTag(2) == None)
}

let test_statement_toTag = () => {
  assert(statementToTag(Triple) == 0)
  assert(statementToTag(Quad) == 1)
}

let test_indexOrder_roundtrip = () => {
  assert(indexOrderFromTag(0) == Some(Spo))
  assert(indexOrderFromTag(1) == Some(Pos))
  assert(indexOrderFromTag(2) == Some(Osp))
  assert(indexOrderFromTag(3) == Some(Gspo))
  assert(indexOrderFromTag(4) == Some(Gpos))
  assert(indexOrderFromTag(5) == Some(Gosp))
  assert(indexOrderFromTag(6) == None)
}

let test_indexOrder_toTag = () => {
  assert(indexOrderToTag(Spo) == 0)
  assert(indexOrderToTag(Pos) == 1)
  assert(indexOrderToTag(Osp) == 2)
  assert(indexOrderToTag(Gspo) == 3)
  assert(indexOrderToTag(Gpos) == 4)
  assert(indexOrderToTag(Gosp) == 5)
}

let test_storageBackend_roundtrip = () => {
  assert(storageBackendFromTag(0) == Some(InMemory))
  assert(storageBackendFromTag(1) == Some(BTree))
  assert(storageBackendFromTag(2) == Some(Lsm))
  assert(storageBackendFromTag(3) == Some(Persistent))
  assert(storageBackendFromTag(4) == None)
}

let test_storageBackend_toTag = () => {
  assert(storageBackendToTag(InMemory) == 0)
  assert(storageBackendToTag(BTree) == 1)
  assert(storageBackendToTag(Lsm) == 2)
  assert(storageBackendToTag(Persistent) == 3)
}

let test_importFormat_roundtrip = () => {
  assert(importFormatFromTag(0) == Some(NTriples))
  assert(importFormatFromTag(1) == Some(Turtle))
  assert(importFormatFromTag(2) == Some(RdfXml))
  assert(importFormatFromTag(3) == Some(JsonLd))
  assert(importFormatFromTag(4) == Some(NQuads))
  assert(importFormatFromTag(5) == Some(Trig))
  assert(importFormatFromTag(6) == None)
}

let test_importFormat_toTag = () => {
  assert(importFormatToTag(NTriples) == 0)
  assert(importFormatToTag(Turtle) == 1)
  assert(importFormatToTag(RdfXml) == 2)
  assert(importFormatToTag(JsonLd) == 3)
  assert(importFormatToTag(NQuads) == 4)
  assert(importFormatToTag(Trig) == 5)
}

let test_transactionIsolation_roundtrip = () => {
  assert(transactionIsolationFromTag(0) == Some(ReadCommitted))
  assert(transactionIsolationFromTag(1) == Some(Serializable))
  assert(transactionIsolationFromTag(2) == Some(Snapshot))
  assert(transactionIsolationFromTag(3) == None)
}

let test_transactionIsolation_toTag = () => {
  assert(transactionIsolationToTag(ReadCommitted) == 0)
  assert(transactionIsolationToTag(Serializable) == 1)
  assert(transactionIsolationToTag(Snapshot) == 2)
}

let test_storeState_roundtrip = () => {
  assert(storeStateFromTag(0) == Some(Idle))
  assert(storeStateFromTag(1) == Some(Ready))
  assert(storeStateFromTag(2) == Some(InTransaction))
  assert(storeStateFromTag(3) == Some(Importing))
  assert(storeStateFromTag(4) == Some(Closing))
  assert(storeStateFromTag(5) == None)
}

let test_storeState_toTag = () => {
  assert(storeStateToTag(Idle) == 0)
  assert(storeStateToTag(Ready) == 1)
  assert(storeStateToTag(InTransaction) == 2)
  assert(storeStateToTag(Importing) == 3)
  assert(storeStateToTag(Closing) == 4)
}

// Run all tests
test_statement_roundtrip()
test_statement_toTag()
test_indexOrder_roundtrip()
test_indexOrder_toTag()
test_storageBackend_roundtrip()
test_storageBackend_toTag()
test_importFormat_roundtrip()
test_importFormat_toTag()
test_transactionIsolation_roundtrip()
test_transactionIsolation_toTag()
test_storeState_roundtrip()
test_storeState_toTag()
