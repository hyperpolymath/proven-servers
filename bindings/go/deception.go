// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Deception protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// DecoyType represents the DecoyType type (Idris2 ABI tags).
type DecoyType uint8

const (
	DecoyTypeService DecoyType = iota
	DecoyTypeCredential
	DecoyTypeFile
	DecoyTypeNetwork
	DecoyTypeToken
	DecoyTypeBreadcrumb
)

// TriggerEvent represents the TriggerEvent type (Idris2 ABI tags).
type TriggerEvent uint8

const (
	TriggerEventAccess TriggerEvent = iota
	TriggerEventLogin
	TriggerEventRead
	TriggerEventWrite
	TriggerEventExecute
	TriggerEventScan
)

// AlertPriority represents the AlertPriority type (Idris2 ABI tags).
type AlertPriority uint8

const (
	AlertPriorityLow AlertPriority = iota
	AlertPriorityMedium
	AlertPriorityHigh
	AlertPriorityCritical
)

// DecoyState represents the DecoyState type (Idris2 ABI tags).
type DecoyState uint8

const (
	DecoyStateActive DecoyState = iota
	DecoyStateTriggered
	DecoyStateDisabled
	DecoyStateExpired
)

// ResponseAction represents the ResponseAction type (Idris2 ABI tags).
type ResponseAction uint8

const (
	ResponseActionAlert ResponseAction = iota
	ResponseActionRedirect
	ResponseActionDelay
	ResponseActionFingerprint
	ResponseActionIsolate
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateConfigured
	ServerStateMonitoring
	ServerStateResponding
	ServerStateShutdown
)
