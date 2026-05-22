// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Database protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// QueryType represents the QueryType type (Idris2 ABI tags).
type QueryType uint8

const (
	QueryTypeSelect QueryType = iota
	QueryTypeInsert
	QueryTypeUpdate
	QueryTypeDelete
	QueryTypeCreateTable
	QueryTypeDropTable
	QueryTypeAlterTable
	QueryTypeCreateIndex
	QueryTypeDropIndex
	QueryTypeBegin
	QueryTypeCommit
	QueryTypeRollback
)

// DataType represents the DataType type (Idris2 ABI tags).
type DataType uint8

const (
	DataTypeInteger DataType = iota
	DataTypeFloat
	DataTypeText
	DataTypeBlob
	DataTypeBoolean
	DataTypeTimestamp
	DataTypeUuid
	DataTypeJson
	DataTypeNull
)

// IsolationLevel represents the IsolationLevel type (Idris2 ABI tags).
type IsolationLevel uint8

const (
	IsolationLevelReadUncommitted IsolationLevel = iota
	IsolationLevelReadCommitted
	IsolationLevelRepeatableRead
	IsolationLevelSerializable
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeSyntaxError ErrorCode = iota
	ErrorCodeTableNotFound
	ErrorCodeColumnNotFound
	ErrorCodeDuplicateKey
	ErrorCodeConstraintViolation
	ErrorCodeTypeMismatch
	ErrorCodeDeadlockDetected
	ErrorCodeTransactionAborted
	ErrorCodeDiskFull
	ErrorCodeConnectionLost
)

// JoinType represents the JoinType type (Idris2 ABI tags).
type JoinType uint8

const (
	JoinTypeInner JoinType = iota
	JoinTypeLeftOuter
	JoinTypeRightOuter
	JoinTypeFullOuter
	JoinTypeCross
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateConnected
	SessionStateTransaction
	SessionStateExecuting
	SessionStateFinalising
	SessionStateDisconnecting
)
