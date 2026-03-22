// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Hardened protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// HardeningLevel represents the HardeningLevel type (Idris2 ABI tags).
type HardeningLevel uint8

const (
	HardeningLevelMinimal HardeningLevel = iota
	HardeningLevelStandard
	HardeningLevelHigh
	HardeningLevelMaximum
)

// SecurityControl represents the SecurityControl type (Idris2 ABI tags).
type SecurityControl uint8

const (
	SecurityControlAslr SecurityControl = iota
	SecurityControlDep
	SecurityControlStackCanary
	SecurityControlCfi
	SecurityControlSandboxing
	SecurityControlSecureBoot
	SecurityControlAuditLog
)

// ComplianceStandard represents the ComplianceStandard type (Idris2 ABI tags).
type ComplianceStandard uint8

const (
	ComplianceStandardCis ComplianceStandard = iota
	ComplianceStandardStig
	ComplianceStandardNist80053
	ComplianceStandardPciDss
	ComplianceStandardFips140
)

// AuditEvent represents the AuditEvent type (Idris2 ABI tags).
type AuditEvent uint8

const (
	AuditEventProcessStart AuditEvent = iota
	AuditEventFileAccess
	AuditEventNetworkConn
	AuditEventPrivilegeEscalation
	AuditEventConfigChange
	AuditEventAuthAttempt
)

// HardenedHealthStatus represents the HardenedHealthStatus type (Idris2 ABI tags).
type HardenedHealthStatus uint8

const (
	HardenedHealthStatusHealthy HardenedHealthStatus = iota
	HardenedHealthStatusDegraded
	HardenedHealthStatusCompromised
	HardenedHealthStatusUnresponsive
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateHardening
	ServerStateActive
	ServerStateAuditing
	ServerStateShutdown
)
