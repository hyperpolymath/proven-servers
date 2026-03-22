// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Honeypot protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ServiceEmulation represents the ServiceEmulation type (Idris2 ABI tags).
type ServiceEmulation uint8

const (
	ServiceEmulationSsh ServiceEmulation = iota
	ServiceEmulationHttp
	ServiceEmulationFtp
	ServiceEmulationSmtp
	ServiceEmulationTelnet
	ServiceEmulationMysql
	ServiceEmulationRdp
)

// InteractionLevel represents the InteractionLevel type (Idris2 ABI tags).
type InteractionLevel uint8

const (
	InteractionLevelLow InteractionLevel = iota
	InteractionLevelMedium
	InteractionLevelHigh
)

// HoneypotAlertSeverity represents the HoneypotAlertSeverity type (Idris2 ABI tags).
type HoneypotAlertSeverity uint8

const (
	HoneypotAlertSeverityInfo HoneypotAlertSeverity = iota
	HoneypotAlertSeverityAsLow
	HoneypotAlertSeverityAsMedium
	HoneypotAlertSeverityAsHigh
	HoneypotAlertSeverityCritical
)

// AttackerAction represents the AttackerAction type (Idris2 ABI tags).
type AttackerAction uint8

const (
	AttackerActionScan AttackerAction = iota
	AttackerActionBruteForce
	AttackerActionExploit
	AttackerActionPayload
	AttackerActionLateral
	AttackerActionExfiltration
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateDeployed
	ServerStateEngaged
	ServerStateShutdown
)
