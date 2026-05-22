// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenGraphdb protocol bindings.

open ProvenGraphdb

let test_elementType_roundtrip = () => {
  assert(elementTypeFromTag(0) == Some(Node))
  assert(elementTypeFromTag(1) == Some(Edge))
  assert(elementTypeFromTag(2) == Some(Property))
  assert(elementTypeFromTag(3) == Some(Label))
  assert(elementTypeFromTag(4) == Some(Index))
  assert(elementTypeFromTag(5) == None)
}

let test_elementType_toTag = () => {
  assert(elementTypeToTag(Node) == 0)
  assert(elementTypeToTag(Edge) == 1)
  assert(elementTypeToTag(Property) == 2)
  assert(elementTypeToTag(Label) == 3)
  assert(elementTypeToTag(Index) == 4)
}

let test_queryLanguage_roundtrip = () => {
  assert(queryLanguageFromTag(0) == Some(Cypher))
  assert(queryLanguageFromTag(1) == Some(Gremlin))
  assert(queryLanguageFromTag(2) == Some(Sparql))
  assert(queryLanguageFromTag(3) == Some(GraphQl))
  assert(queryLanguageFromTag(4) == None)
}

let test_queryLanguage_toTag = () => {
  assert(queryLanguageToTag(Cypher) == 0)
  assert(queryLanguageToTag(Gremlin) == 1)
  assert(queryLanguageToTag(Sparql) == 2)
  assert(queryLanguageToTag(GraphQl) == 3)
}

let test_traversalStrategy_roundtrip = () => {
  assert(traversalStrategyFromTag(0) == Some(Bfs))
  assert(traversalStrategyFromTag(1) == Some(Dfs))
  assert(traversalStrategyFromTag(2) == Some(Dijkstra))
  assert(traversalStrategyFromTag(3) == Some(AStar))
  assert(traversalStrategyFromTag(4) == Some(Random))
  assert(traversalStrategyFromTag(5) == None)
}

let test_traversalStrategy_toTag = () => {
  assert(traversalStrategyToTag(Bfs) == 0)
  assert(traversalStrategyToTag(Dfs) == 1)
  assert(traversalStrategyToTag(Dijkstra) == 2)
  assert(traversalStrategyToTag(AStar) == 3)
  assert(traversalStrategyToTag(Random) == 4)
}

let test_consistency_roundtrip = () => {
  assert(consistencyFromTag(0) == Some(Strong))
  assert(consistencyFromTag(1) == Some(Eventual))
  assert(consistencyFromTag(2) == Some(Session))
  assert(consistencyFromTag(3) == Some(Causal))
  assert(consistencyFromTag(4) == None)
}

let test_consistency_toTag = () => {
  assert(consistencyToTag(Strong) == 0)
  assert(consistencyToTag(Eventual) == 1)
  assert(consistencyToTag(Session) == 2)
  assert(consistencyToTag(Causal) == 3)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(SyntaxError))
  assert(errorCodeFromTag(1) == Some(NodeNotFound))
  assert(errorCodeFromTag(2) == Some(EdgeNotFound))
  assert(errorCodeFromTag(3) == Some(ConstraintViolation))
  assert(errorCodeFromTag(4) == Some(IndexExists))
  assert(errorCodeFromTag(5) == Some(TransactionConflict))
  assert(errorCodeFromTag(6) == Some(OutOfMemory))
  assert(errorCodeFromTag(7) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(SyntaxError) == 0)
  assert(errorCodeToTag(NodeNotFound) == 1)
  assert(errorCodeToTag(EdgeNotFound) == 2)
  assert(errorCodeToTag(ConstraintViolation) == 3)
  assert(errorCodeToTag(IndexExists) == 4)
  assert(errorCodeToTag(TransactionConflict) == 5)
  assert(errorCodeToTag(OutOfMemory) == 6)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Connected))
  assert(sessionStateFromTag(2) == Some(Querying))
  assert(sessionStateFromTag(3) == Some(Traversing))
  assert(sessionStateFromTag(4) == Some(Disconnecting))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Connected) == 1)
  assert(sessionStateToTag(Querying) == 2)
  assert(sessionStateToTag(Traversing) == 3)
  assert(sessionStateToTag(Disconnecting) == 4)
}

// Run all tests
test_elementType_roundtrip()
test_elementType_toTag()
test_queryLanguage_roundtrip()
test_queryLanguage_toTag()
test_traversalStrategy_roundtrip()
test_traversalStrategy_toTag()
test_consistency_roundtrip()
test_consistency_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
