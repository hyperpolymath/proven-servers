// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// IDS protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// AlertSeverity represents the AlertSeverity type (Idris2 ABI tags).
type AlertSeverity uint8

const (
	AlertSeverityLow AlertSeverity = iota
	AlertSeverityMedium
	AlertSeverityHigh
	AlertSeverityCritical
)

// DetectionMethod represents the DetectionMethod type (Idris2 ABI tags).
type DetectionMethod uint8

const (
	DetectionMethodSignature DetectionMethod = iota
	DetectionMethodAnomaly
	DetectionMethodStateful
	DetectionMethodHeuristic
)

// IdsProtocol represents the IdsProtocol type (Idris2 ABI tags).
type IdsProtocol uint8

const (
	IdsProtocolTcp IdsProtocol = iota
	IdsProtocolUdp
	IdsProtocolIcmp
	IdsProtocolDns
	IdsProtocolHttp
	IdsProtocolTls
	IdsProtocolSsh
)

// IdsAction represents the IdsAction type (Idris2 ABI tags).
type IdsAction uint8

const (
	IdsActionAlert IdsAction = iota
	IdsActionDrop
	IdsActionLog
	IdsActionBlock
	IdsActionPass
)

// Direction represents the Direction type (Idris2 ABI tags).
type Direction uint8

const (
	DirectionInbound Direction = iota
	DirectionOutbound
	DirectionBoth
)

// ThreatLevel represents the ThreatLevel type (Idris2 ABI tags).
type ThreatLevel uint8

const (
	ThreatLevelInfo ThreatLevel = iota
	ThreatLevelLow
	ThreatLevelMedium
	ThreatLevelHigh
	ThreatLevelCritical
)
