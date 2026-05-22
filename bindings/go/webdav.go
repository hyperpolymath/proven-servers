// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// WebDAV protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Method represents the Method type (Idris2 ABI tags).
type Method uint8

const (
	MethodPropfind Method = iota
	MethodProppatch
	MethodMkcol
	MethodCopy
	MethodMove
	MethodLock
	MethodUnlock
)

// StatusCode represents the StatusCode type (Idris2 ABI tags).
type StatusCode uint8

const (
	StatusCodeMultiStatus StatusCode = iota
	StatusCodeUnprocessableEntity
	StatusCodeLocked
	StatusCodeFailedDependency
	StatusCodeInsufficientStorage
)

// LockScope represents the LockScope type (Idris2 ABI tags).
type LockScope uint8

const (
	LockScopeExclusive LockScope = iota
	LockScopeShared
)

// LockType represents the LockType type (Idris2 ABI tags).
type LockType uint8

const (
	LockTypeWrite LockType = iota
)

// Depth represents the Depth type (Idris2 ABI tags).
type Depth uint8

const (
	DepthZero Depth = iota
	DepthOne
	DepthInfinity
)

// PropertyOp represents the PropertyOp type (Idris2 ABI tags).
type PropertyOp uint8

const (
	PropertyOpSet PropertyOp = iota
	PropertyOpRemove
)
