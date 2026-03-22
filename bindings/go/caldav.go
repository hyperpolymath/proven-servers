// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// CalDAV protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ComponentType represents the ComponentType type (Idris2 ABI tags).
type ComponentType uint8

const (
	ComponentTypeVevent ComponentType = iota
	ComponentTypeVtodo
	ComponentTypeVjournal
	ComponentTypeVfreebusy
)

// CalMethod represents the CalMethod type (Idris2 ABI tags).
type CalMethod uint8

const (
	CalMethodGet CalMethod = iota
	CalMethodPut
	CalMethodDelete
	CalMethodPropfind
	CalMethodProppatch
	CalMethodReport
	CalMethodMkcalendar
)

// ScheduleStatus represents the ScheduleStatus type (Idris2 ABI tags).
type ScheduleStatus uint8

const (
	ScheduleStatusNeedsAction ScheduleStatus = iota
	ScheduleStatusAccepted
	ScheduleStatusDeclined
	ScheduleStatusTentative
	ScheduleStatusDelegated
)

// CalError represents the CalError type (Idris2 ABI tags).
type CalError uint8

const (
	CalErrorValidCalendarData CalError = iota
	CalErrorNoResourceTypeChange
	CalErrorSupportedComponentMismatch
	CalErrorMaxResourceSize
	CalErrorUidConflict
	CalErrorPreconditionFailed
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateBound
	ServerStateServing
	ServerStateScheduling
	ServerStateShutdown
)
