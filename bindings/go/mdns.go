// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// mDNS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MdnsRecordType represents the MdnsRecordType type (Idris2 ABI tags).
type MdnsRecordType uint8

const (
	MdnsRecordTypeA MdnsRecordType = iota
	MdnsRecordTypeAaaa
	MdnsRecordTypePtr
	MdnsRecordTypeSrv
	MdnsRecordTypeTxt
)

// QueryType represents the QueryType type (Idris2 ABI tags).
type QueryType uint8

const (
	QueryTypeStandard QueryType = iota
	QueryTypeOneShot
	QueryTypeContinuous
)

// ConflictAction represents the ConflictAction type (Idris2 ABI tags).
type ConflictAction uint8

const (
	ConflictActionProbe ConflictAction = iota
	ConflictActionDefend
	ConflictActionWithdraw
)

// ServiceFlag represents the ServiceFlag type (Idris2 ABI tags).
type ServiceFlag uint8

const (
	ServiceFlagUnique ServiceFlag = iota
	ServiceFlagShared
)

// ResponderState represents the ResponderState type (Idris2 ABI tags).
type ResponderState uint8

const (
	ResponderStateIdle ResponderState = iota
	ResponderStateProbing
	ResponderStateAnnouncing
	ResponderStateRunning
	ResponderStateShuttingDown
)
