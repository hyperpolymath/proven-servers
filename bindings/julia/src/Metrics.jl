# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-metrics protocol (Metrics/Prometheus server).
#
# Wraps the C-ABI functions from protocols/proven-metrics/ffi/zig/src/metrics.zig
# via ccall into libproven_metrics.so.

module Metrics

using ..ProvenServers: check_status, check_slot, SlotId

export METRICS_PORT,
       MetricType,
       ScrapeResult,
       AlertState,
       AggregationOp,
       QueryError,
       CollectorState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_metrics"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""METRICS_PORT: protocol constant."""
const METRICS_PORT = UInt16(9090)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Metric data types (OpenMetrics)."""
@enum MetricType::UInt8 begin
    METRIC_COUNTER = 0
    METRIC_GAUGE = 1
    METRIC_HISTOGRAM = 2
    METRIC_SUMMARY = 3
    METRIC_INFO = 4
    METRIC_STATE_SET = 5
end

"""Metrics scrape results."""
@enum ScrapeResult::UInt8 begin
    SCRAPE_SUCCESS = 0
    SCRAPE_TIMEOUT = 1
    SCRAPE_CONNECTION_REFUSED = 2
    SCRAPE_INVALID_RESPONSE = 3
end

"""Alert rule states."""
@enum AlertState::UInt8 begin
    ALERT_INACTIVE = 0
    ALERT_PENDING = 1
    ALERT_FIRING = 2
    ALERT_RESOLVED = 3
end

"""Metrics aggregation operations."""
@enum AggregationOp::UInt8 begin
    AGG_SUM = 0
    AGG_AVG = 1
    AGG_MIN = 2
    AGG_MAX = 3
    AGG_COUNT = 4
    AGG_RATE = 5
    AGG_INCREASE = 6
    AGG_P50 = 7
    AGG_P90 = 8
    AGG_P95 = 9
    AGG_P99 = 10
end

"""Metrics query error codes."""
@enum QueryError::UInt8 begin
    QERR_PARSE = 0
    QERR_EXECUTION = 1
    QERR_TIMEOUT = 2
    QERR_TOO_MANY_SERIES = 3
end

"""Metrics collector states."""
@enum CollectorState::UInt8 begin
    STATE_IDLE = 0
    STATE_CONFIGURED = 1
    STATE_SCRAPING = 2
    STATE_ALERTING = 3
    STATE_STOPPING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_metrics."""
function abi_version()::UInt32
    ccall((:metrics_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Metrics context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:metrics_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Metrics context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:metrics_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> CollectorState

Get the current Metrics lifecycle state.
"""
function get_state(slot::SlotId)::CollectorState
    CollectorState(ccall((:metrics_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::CollectorState, to::CollectorState) -> Bool

Check whether a Metrics state transition is valid.
"""
function can_transition(from::CollectorState, to::CollectorState)::Bool
    ccall((:metrics_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Metrics
