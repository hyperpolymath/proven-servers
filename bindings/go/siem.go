// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SIEM protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// EventSeverity represents the EventSeverity type (Idris2 ABI tags).
type EventSeverity uint8

const (
	EventSeverityInfo EventSeverity = iota
	EventSeverityLow
	EventSeverityMedium
	EventSeverityHigh
	EventSeverityCritical
)

// EventCategory represents the EventCategory type (Idris2 ABI tags).
type EventCategory uint8

const (
	EventCategoryAuthentication EventCategory = iota
	EventCategoryNetworkTraffic
	EventCategoryFileActivity
	EventCategoryProcessExecution
	EventCategoryPolicyViolation
	EventCategoryMalware
	EventCategoryDataExfiltration
)

// CorrelationRule represents the CorrelationRule type (Idris2 ABI tags).
type CorrelationRule uint8

const (
	CorrelationRuleThreshold CorrelationRule = iota
	CorrelationRuleSequence
	CorrelationRuleAggregation
	CorrelationRuleAbsence
	CorrelationRuleStatistical
)

// AlertState represents the AlertState type (Idris2 ABI tags).
type AlertState uint8

const (
	AlertStateNew AlertState = iota
	AlertStateAcknowledged
	AlertStateInProgress
	AlertStateResolved
	AlertStateFalsePositive
)
