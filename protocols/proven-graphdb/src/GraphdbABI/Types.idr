-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- GraphdbABI.Types: C-ABI-compatible tag encodings for graph database types.

module GraphdbABI.Types

import Graphdb.Types

%default total

public export
elementTypeToTag : ElementType -> Bits8
elementTypeToTag Node     = 0
elementTypeToTag Edge     = 1
elementTypeToTag Property = 2
elementTypeToTag Label    = 3
elementTypeToTag Index    = 4

public export
tagToElementType : Bits8 -> Maybe ElementType
tagToElementType 0 = Just Node
tagToElementType 1 = Just Edge
tagToElementType 2 = Just Property
tagToElementType 3 = Just Label
tagToElementType 4 = Just Index
tagToElementType _ = Nothing

public export
elementTypeRoundtrip : (e : ElementType) -> tagToElementType (elementTypeToTag e) = Just e
elementTypeRoundtrip Node     = Refl
elementTypeRoundtrip Edge     = Refl
elementTypeRoundtrip Property = Refl
elementTypeRoundtrip Label    = Refl
elementTypeRoundtrip Index    = Refl

public export
queryLanguageToTag : QueryLanguage -> Bits8
queryLanguageToTag Cypher  = 0
queryLanguageToTag Gremlin = 1
queryLanguageToTag SPARQL  = 2
queryLanguageToTag GraphQL = 3

public export
tagToQueryLanguage : Bits8 -> Maybe QueryLanguage
tagToQueryLanguage 0 = Just Cypher
tagToQueryLanguage 1 = Just Gremlin
tagToQueryLanguage 2 = Just SPARQL
tagToQueryLanguage 3 = Just GraphQL
tagToQueryLanguage _ = Nothing

public export
queryLanguageRoundtrip : (q : QueryLanguage) -> tagToQueryLanguage (queryLanguageToTag q) = Just q
queryLanguageRoundtrip Cypher  = Refl
queryLanguageRoundtrip Gremlin = Refl
queryLanguageRoundtrip SPARQL  = Refl
queryLanguageRoundtrip GraphQL = Refl

public export
traversalStrategyToTag : TraversalStrategy -> Bits8
traversalStrategyToTag BFS      = 0
traversalStrategyToTag DFS      = 1
traversalStrategyToTag Dijkstra = 2
traversalStrategyToTag AStar    = 3
traversalStrategyToTag Random   = 4

public export
tagToTraversalStrategy : Bits8 -> Maybe TraversalStrategy
tagToTraversalStrategy 0 = Just BFS
tagToTraversalStrategy 1 = Just DFS
tagToTraversalStrategy 2 = Just Dijkstra
tagToTraversalStrategy 3 = Just AStar
tagToTraversalStrategy 4 = Just Random
tagToTraversalStrategy _ = Nothing

public export
traversalStrategyRoundtrip : (t : TraversalStrategy) -> tagToTraversalStrategy (traversalStrategyToTag t) = Just t
traversalStrategyRoundtrip BFS      = Refl
traversalStrategyRoundtrip DFS      = Refl
traversalStrategyRoundtrip Dijkstra = Refl
traversalStrategyRoundtrip AStar    = Refl
traversalStrategyRoundtrip Random   = Refl

public export
consistencyToTag : Consistency -> Bits8
consistencyToTag Strong   = 0
consistencyToTag Eventual = 1
consistencyToTag Session  = 2
consistencyToTag Causal   = 3

public export
tagToConsistency : Bits8 -> Maybe Consistency
tagToConsistency 0 = Just Strong
tagToConsistency 1 = Just Eventual
tagToConsistency 2 = Just Session
tagToConsistency 3 = Just Causal
tagToConsistency _ = Nothing

public export
consistencyRoundtrip : (c : Consistency) -> tagToConsistency (consistencyToTag c) = Just c
consistencyRoundtrip Strong   = Refl
consistencyRoundtrip Eventual = Refl
consistencyRoundtrip Session  = Refl
consistencyRoundtrip Causal   = Refl

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag SyntaxError         = 0
errorCodeToTag NodeNotFound        = 1
errorCodeToTag EdgeNotFound        = 2
errorCodeToTag ConstraintViolation = 3
errorCodeToTag IndexExists         = 4
errorCodeToTag TransactionConflict = 5
errorCodeToTag OutOfMemory         = 6

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just SyntaxError
tagToErrorCode 1 = Just NodeNotFound
tagToErrorCode 2 = Just EdgeNotFound
tagToErrorCode 3 = Just ConstraintViolation
tagToErrorCode 4 = Just IndexExists
tagToErrorCode 5 = Just TransactionConflict
tagToErrorCode 6 = Just OutOfMemory
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip SyntaxError         = Refl
errorCodeRoundtrip NodeNotFound        = Refl
errorCodeRoundtrip EdgeNotFound        = Refl
errorCodeRoundtrip ConstraintViolation = Refl
errorCodeRoundtrip IndexExists         = Refl
errorCodeRoundtrip TransactionConflict = Refl
errorCodeRoundtrip OutOfMemory         = Refl

public export
data SessionState : Type where
  GDBIdle : SessionState
  GDBConnected : SessionState
  GDBQuerying : SessionState
  GDBTraversing : SessionState
  GDBDisconnecting : SessionState

public export
Eq SessionState where
  GDBIdle == GDBIdle = True
  GDBConnected == GDBConnected = True
  GDBQuerying == GDBQuerying = True
  GDBTraversing == GDBTraversing = True
  GDBDisconnecting == GDBDisconnecting = True
  _ == _ = False

public export
Show SessionState where
  show GDBIdle = "Idle"
  show GDBConnected = "Connected"
  show GDBQuerying = "Querying"
  show GDBTraversing = "Traversing"
  show GDBDisconnecting = "Disconnecting"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag GDBIdle = 0
sessionStateToTag GDBConnected = 1
sessionStateToTag GDBQuerying = 2
sessionStateToTag GDBTraversing = 3
sessionStateToTag GDBDisconnecting = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just GDBIdle
tagToSessionState 1 = Just GDBConnected
tagToSessionState 2 = Just GDBQuerying
tagToSessionState 3 = Just GDBTraversing
tagToSessionState 4 = Just GDBDisconnecting
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip GDBIdle = Refl
sessionStateRoundtrip GDBConnected = Refl
sessionStateRoundtrip GDBQuerying = Refl
sessionStateRoundtrip GDBTraversing = Refl
sessionStateRoundtrip GDBDisconnecting = Refl

||| Proof witness that a session state permits query operations.
||| Only a connected or actively-querying session may issue queries.
public export
data CanQuery : SessionState -> Type where
  ConnectedCanQuery : CanQuery GDBConnected
  QueryingCanQuery  : CanQuery GDBQuerying

||| An idle session cannot run queries — it must connect first.
||| (Previously written as `SessionState -> Void`, which is not a valid
||| impossible case: SessionState is inhabited. The intended statement is
||| the impossibility of the *query capability* in the Idle state.)
public export
idleCannotQuery : CanQuery GDBIdle -> Void
idleCannotQuery _ impossible
