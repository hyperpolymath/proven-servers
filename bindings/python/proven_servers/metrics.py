# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-metrics protocol types.

"""Metrics protocol types for proven-servers."""

from enum import IntEnum


class MetricType(IntEnum):
    """MetricType matching the Idris2 ABI tags."""
    COUNTER = 0
    GAUGE = 1
    HISTOGRAM = 2
    SUMMARY = 3
    INFO = 4
    STATE_SET = 5


class ScrapeResult(IntEnum):
    """ScrapeResult matching the Idris2 ABI tags."""
    SUCCESS = 0
    SCRAPE_TIMEOUT = 1
    CONNECTION_REFUSED = 2
    INVALID_RESPONSE = 3


class AlertState(IntEnum):
    """AlertState matching the Idris2 ABI tags."""
    INACTIVE = 0
    PENDING = 1
    FIRING = 2
    RESOLVED = 3


class AggregationOp(IntEnum):
    """AggregationOp matching the Idris2 ABI tags."""
    SUM = 0
    AVG = 1
    MIN = 2
    MAX = 3
    COUNT = 4
    RATE = 5
    INCREASE = 6
    P50 = 7
    P90 = 8
    P95 = 9
    P99 = 10


class QueryError(IntEnum):
    """QueryError matching the Idris2 ABI tags."""
    PARSE_ERROR = 0
    EXECUTION_ERROR = 1
    QUERY_TIMEOUT = 2
    TOO_MANY_SERIES = 3


class CollectorState(IntEnum):
    """CollectorState matching the Idris2 ABI tags."""
    IDLE = 0
    CONFIGURED = 1
    SCRAPING = 2
    ALERTING = 3
    STOPPING = 4
