// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Metrics Server types for the proven-servers ABI.
//!
//! Formally verified metrics/Prometheus types.
//! Mirrors the Idris2 module `MetricsABI.Types`.
//!
//! - `MetricType` -- Metric data types (OpenMetrics).
//! - `ScrapeResult` -- Metrics scrape results.
//! - `AlertState` -- Alert rule states.
//! - `AggregationOp` -- Metrics aggregation operations.
//! - `QueryError` -- Metrics query error codes.
//! - `CollectorState` -- Metrics collector states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Metrics Server Constants
// ===========================================================================

/// Standard Prometheus port.
pub const METRICS_PORT: u16 = 9090;

// ===========================================================================
// MetricType (tags 0-5)
// ===========================================================================

/// Metric data types (OpenMetrics).
///
/// Matches `MetricType` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MetricType {
    /// Counter (tag 0).
    Counter = 0,
    /// Gauge (tag 1).
    Gauge = 1,
    /// Histogram (tag 2).
    Histogram = 2,
    /// Summary (tag 3).
    Summary = 3,
    /// Info (tag 4).
    Info = 4,
    /// StateSet (tag 5).
    StateSet = 5,
}

impl MetricType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Counter),
            1 => Some(Self::Gauge),
            2 => Some(Self::Histogram),
            3 => Some(Self::Summary),
            4 => Some(Self::Info),
            5 => Some(Self::StateSet),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MetricType; 6] = [
        Self::Counter, Self::Gauge, Self::Histogram, Self::Summary, Self::Info, Self::StateSet,
    ];
}

impl fmt::Display for MetricType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ScrapeResult (tags 0-3)
// ===========================================================================

/// Metrics scrape results.
///
/// Matches `ScrapeResult` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ScrapeResult {
    /// Success (tag 0).
    Success = 0,
    /// ScrapeTimeout (tag 1).
    ScrapeTimeout = 1,
    /// ConnectionRefused (tag 2).
    ConnectionRefused = 2,
    /// InvalidResponse (tag 3).
    InvalidResponse = 3,
}

impl ScrapeResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Success),
            1 => Some(Self::ScrapeTimeout),
            2 => Some(Self::ConnectionRefused),
            3 => Some(Self::InvalidResponse),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ScrapeResult; 4] = [
        Self::Success, Self::ScrapeTimeout, Self::ConnectionRefused, Self::InvalidResponse,
    ];
}

impl fmt::Display for ScrapeResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AlertState (tags 0-3)
// ===========================================================================

/// Alert rule states.
///
/// Matches `AlertState` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlertState {
    /// Inactive (tag 0).
    Inactive = 0,
    /// Pending (tag 1).
    Pending = 1,
    /// Firing (tag 2).
    Firing = 2,
    /// Resolved (tag 3).
    Resolved = 3,
}

impl AlertState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Inactive),
            1 => Some(Self::Pending),
            2 => Some(Self::Firing),
            3 => Some(Self::Resolved),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AlertState; 4] = [
        Self::Inactive, Self::Pending, Self::Firing, Self::Resolved,
    ];
}

impl fmt::Display for AlertState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AggregationOp (tags 0-10)
// ===========================================================================

/// Metrics aggregation operations.
///
/// Matches `AggregationOp` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AggregationOp {
    /// Sum (tag 0).
    Sum = 0,
    /// Avg (tag 1).
    Avg = 1,
    /// Min (tag 2).
    Min = 2,
    /// Max (tag 3).
    Max = 3,
    /// Count (tag 4).
    Count = 4,
    /// Rate (tag 5).
    Rate = 5,
    /// Increase (tag 6).
    Increase = 6,
    /// P50 (tag 7).
    P50 = 7,
    /// P90 (tag 8).
    P90 = 8,
    /// P95 (tag 9).
    P95 = 9,
    /// P99 (tag 10).
    P99 = 10,
}

impl AggregationOp {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Sum),
            1 => Some(Self::Avg),
            2 => Some(Self::Min),
            3 => Some(Self::Max),
            4 => Some(Self::Count),
            5 => Some(Self::Rate),
            6 => Some(Self::Increase),
            7 => Some(Self::P50),
            8 => Some(Self::P90),
            9 => Some(Self::P95),
            10 => Some(Self::P99),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AggregationOp; 11] = [
        Self::Sum, Self::Avg, Self::Min, Self::Max, Self::Count, Self::Rate, Self::Increase, Self::P50, Self::P90, Self::P95, Self::P99,
    ];
}

impl fmt::Display for AggregationOp {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// QueryError (tags 0-3)
// ===========================================================================

/// Metrics query error codes.
///
/// Matches `QueryError` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum QueryError {
    /// ParseError (tag 0).
    ParseError = 0,
    /// ExecutionError (tag 1).
    ExecutionError = 1,
    /// QueryTimeout (tag 2).
    QueryTimeout = 2,
    /// TooManySeries (tag 3).
    TooManySeries = 3,
}

impl QueryError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ParseError),
            1 => Some(Self::ExecutionError),
            2 => Some(Self::QueryTimeout),
            3 => Some(Self::TooManySeries),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [QueryError; 4] = [
        Self::ParseError, Self::ExecutionError, Self::QueryTimeout, Self::TooManySeries,
    ];
}

impl fmt::Display for QueryError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CollectorState (tags 0-4)
// ===========================================================================

/// Metrics collector states.
///
/// Matches `CollectorState` in `MetricsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CollectorState {
    /// Idle (tag 0).
    Idle = 0,
    /// Configured (tag 1).
    Configured = 1,
    /// Scraping (tag 2).
    Scraping = 2,
    /// Alerting (tag 3).
    Alerting = 3,
    /// Stopping (tag 4).
    Stopping = 4,
}

impl CollectorState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Configured),
            2 => Some(Self::Scraping),
            3 => Some(Self::Alerting),
            4 => Some(Self::Stopping),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CollectorState; 5] = [
        Self::Idle, Self::Configured, Self::Scraping, Self::Alerting, Self::Stopping,
    ];
}

impl fmt::Display for CollectorState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn metric_type_roundtrip() {
        for v in MetricType::ALL {
            let tag = v.to_tag();
            let decoded = MetricType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MetricType::from_tag(6).is_none());
    }

    #[test]
    fn scrape_result_roundtrip() {
        for v in ScrapeResult::ALL {
            let tag = v.to_tag();
            let decoded = ScrapeResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ScrapeResult::from_tag(4).is_none());
    }

    #[test]
    fn alert_state_roundtrip() {
        for v in AlertState::ALL {
            let tag = v.to_tag();
            let decoded = AlertState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlertState::from_tag(4).is_none());
    }

    #[test]
    fn aggregation_op_roundtrip() {
        for v in AggregationOp::ALL {
            let tag = v.to_tag();
            let decoded = AggregationOp::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AggregationOp::from_tag(11).is_none());
    }

    #[test]
    fn query_error_roundtrip() {
        for v in QueryError::ALL {
            let tag = v.to_tag();
            let decoded = QueryError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(QueryError::from_tag(4).is_none());
    }

    #[test]
    fn collector_state_roundtrip() {
        for v in CollectorState::ALL {
            let tag = v.to_tag();
            let decoded = CollectorState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CollectorState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(METRICS_PORT, 9090);
    }

}
