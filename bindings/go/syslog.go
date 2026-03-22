// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Syslog protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Severity represents the Severity type (Idris2 ABI tags).
type Severity uint8

const (
	SeverityEmergency Severity = iota
	SeverityAlert
	SeverityCritical
	SeverityError
	SeverityWarning
	SeverityNotice
	SeverityInformational
	SeverityDebug
)

// Facility represents the Facility type (Idris2 ABI tags).
type Facility uint8

const (
	FacilityKern Facility = iota
	FacilityUser
	FacilityMail
	FacilityDaemon
	FacilityAuth
	FacilitySyslog
	FacilityLpr
	FacilityNews
	FacilityUucp
	FacilityCron
	FacilityAuthPriv
	FacilityFtp
	FacilityNtp
	FacilityAudit
	FacilityAlert
	FacilityClock
	FacilityLocal0
	FacilityLocal1
	FacilityLocal2
	FacilityLocal3
	FacilityLocal4
	FacilityLocal5
	FacilityLocal6
	FacilityLocal7
)

// Transport represents the Transport type (Idris2 ABI tags).
type Transport uint8

const (
	TransportUdp514 Transport = iota
	TransportTcp514
	TransportTls6514
)
