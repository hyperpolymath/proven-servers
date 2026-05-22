// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Cache protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandGet Command = iota
	CommandSet
	CommandDelete
	CommandExists
	CommandExpire
	CommandTtl
	CommandKeys
	CommandFlush
	CommandIncr
	CommandDecr
	CommandAppend
	CommandPrepend
	CommandCas
)

// EvictionPolicy represents the EvictionPolicy type (Idris2 ABI tags).
type EvictionPolicy uint8

const (
	EvictionPolicyLru EvictionPolicy = iota
	EvictionPolicyLfu
	EvictionPolicyRandom
	EvictionPolicyEvictTtl
	EvictionPolicyNoEviction
)

// DataType represents the DataType type (Idris2 ABI tags).
type DataType uint8

const (
	DataTypeStringVal DataType = iota
	DataTypeIntVal
	DataTypeListVal
	DataTypeSetVal
	DataTypeHashVal
)

// ErrorCode represents the ErrorCode type (Idris2 ABI tags).
type ErrorCode uint8

const (
	ErrorCodeNotFound ErrorCode = iota
	ErrorCodeTypeMismatch
	ErrorCodeOutOfMemory
	ErrorCodeKeyTooLong
	ErrorCodeValueTooLarge
	ErrorCodeCasConflict
)

// ReplicationMode represents the ReplicationMode type (Idris2 ABI tags).
type ReplicationMode uint8

const (
	ReplicationModeNone ReplicationMode = iota
	ReplicationModePrimary
	ReplicationModeReplica
	ReplicationModeSentinel
)
