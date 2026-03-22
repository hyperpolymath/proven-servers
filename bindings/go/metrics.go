// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Metrics protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MetricType represents the MetricType type (Idris2 ABI tags).
type MetricType uint8

const (
	MetricTypeCounter MetricType = iota
	MetricTypeGauge
	MetricTypeHistogram
	MetricTypeSummary
	MetricTypeInfo
	MetricTypeStateSet
)

// ScrapeResult represents the ScrapeResult type (Idris2 ABI tags).
type ScrapeResult uint8

const (
	ScrapeResultSuccess ScrapeResult = iota
	ScrapeResultScrapeTimeout
	ScrapeResultConnectionRefused
	ScrapeResultInvalidResponse
)

// AlertState represents the AlertState type (Idris2 ABI tags).
type AlertState uint8

const (
	AlertStateInactive AlertState = iota
	AlertStatePending
	AlertStateFiring
	AlertStateResolved
)

// AggregationOp represents the AggregationOp type (Idris2 ABI tags).
type AggregationOp uint8

const (
	AggregationOpSum AggregationOp = iota
	AggregationOpAvg
	AggregationOpMin
	AggregationOpMax
	AggregationOpCount
	AggregationOpRate
	AggregationOpIncrease
	AggregationOpP50
	AggregationOpP90
	AggregationOpP95
	AggregationOpP99
)

// QueryError represents the QueryError type (Idris2 ABI tags).
type QueryError uint8

const (
	QueryErrorParseError QueryError = iota
	QueryErrorExecutionError
	QueryErrorQueryTimeout
	QueryErrorTooManySeries
)

// CollectorState represents the CollectorState type (Idris2 ABI tags).
type CollectorState uint8

const (
	CollectorStateIdle CollectorState = iota
	CollectorStateConfigured
	CollectorStateScraping
	CollectorStateAlerting
	CollectorStateStopping
)
