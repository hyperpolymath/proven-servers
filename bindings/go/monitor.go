// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Monitor protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// CheckType represents the CheckType type (Idris2 ABI tags).
type CheckType uint8

const (
	CheckTypeHttp CheckType = iota
	CheckTypeTcp
	CheckTypeUdp
	CheckTypeIcmp
	CheckTypeDns
	CheckTypeCertificate
	CheckTypeDisk
	CheckTypeCpu
	CheckTypeMemory
	CheckTypeProcess
	CheckTypeCustom
)

// Status represents the Status type (Idris2 ABI tags).
type Status uint8

const (
	StatusUp Status = iota
	StatusDown
	StatusDegraded
	StatusUnknown
	StatusMaintenance
)

// AlertChannel represents the AlertChannel type (Idris2 ABI tags).
type AlertChannel uint8

const (
	AlertChannelEmail AlertChannel = iota
	AlertChannelSms
	AlertChannelWebhook
	AlertChannelSlack
	AlertChannelPagerDuty
)

// Severity represents the Severity type (Idris2 ABI tags).
type Severity uint8

const (
	SeverityInfo Severity = iota
	SeverityWarning
	SeverityError
	SeverityCritical
)

// CheckState represents the CheckState type (Idris2 ABI tags).
type CheckState uint8

const (
	CheckStatePending CheckState = iota
	CheckStateRunning
	CheckStatePassed
	CheckStateFailed
	CheckStateTimeout
	CheckStateCsError
)

// MonitorState represents the MonitorState type (Idris2 ABI tags).
type MonitorState uint8

const (
	MonitorStateIdle MonitorState = iota
	MonitorStateConfigured
	MonitorStateRunning
	MonitorStateMonPaused
	MonitorStateAlerting
	MonitorStateShutdown
)
