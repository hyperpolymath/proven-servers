// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Graph DB protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ElementType represents the ElementType type (Idris2 ABI tags).
type ElementType uint8

const (
	ElementTypeNode ElementType = iota
	ElementTypeEdge
	ElementTypeProperty
	ElementTypeLabel
	ElementTypeIndex
)

// QueryLanguage represents the QueryLanguage type (Idris2 ABI tags).
type QueryLanguage uint8

const (
	QueryLanguageCypher QueryLanguage = iota
	QueryLanguageGremlin
	QueryLanguageSparql
	QueryLanguageGraphQl
)

// TraversalStrategy represents the TraversalStrategy type (Idris2 ABI tags).
type TraversalStrategy uint8

const (
	TraversalStrategyBfs TraversalStrategy = iota
	TraversalStrategyDfs
	TraversalStrategyDijkstra
	TraversalStrategyAStar
	TraversalStrategyRandom
)

// Consistency represents the Consistency type (Idris2 ABI tags).
type Consistency uint8

const (
	ConsistencyStrong Consistency = iota
	ConsistencyEventual
	ConsistencySession
	ConsistencyCausal
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeSyntaxError ErrorCode = iota
	ErrorCodeNodeNotFound
	ErrorCodeEdgeNotFound
	ErrorCodeConstraintViolation
	ErrorCodeIndexExists
	ErrorCodeTransactionConflict
	ErrorCodeOutOfMemory
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateConnected
	SessionStateQuerying
	SessionStateTraversing
	SessionStateDisconnecting
)
