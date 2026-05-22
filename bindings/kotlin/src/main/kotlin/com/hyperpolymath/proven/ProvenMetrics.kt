// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

package com.hyperpolymath.proven

/** MetricType matching the Idris2 ABI tags. */
enum class MetricType(val tag: Int) {
    COUNTER(0),
    GAUGE(1),
    HISTOGRAM(2),
    SUMMARY(3),
    INFO(4),
    STATE_SET(5);

    companion object {
        fun fromTag(tag: Int): MetricType? = entries.find { it.tag == tag }
    }
}

/** ScrapeResult matching the Idris2 ABI tags. */
enum class ScrapeResult(val tag: Int) {
    SUCCESS(0),
    SCRAPE_TIMEOUT(1),
    CONNECTION_REFUSED(2),
    INVALID_RESPONSE(3);

    companion object {
        fun fromTag(tag: Int): ScrapeResult? = entries.find { it.tag == tag }
    }
}

/** AlertState matching the Idris2 ABI tags. */
enum class AlertState(val tag: Int) {
    INACTIVE(0),
    PENDING(1),
    FIRING(2),
    RESOLVED(3);

    companion object {
        fun fromTag(tag: Int): AlertState? = entries.find { it.tag == tag }
    }
}

/** AggregationOp matching the Idris2 ABI tags. */
enum class AggregationOp(val tag: Int) {
    SUM(0),
    AVG(1),
    MIN(2),
    MAX(3),
    COUNT(4),
    RATE(5),
    INCREASE(6),
    P50(7),
    P90(8),
    P95(9),
    P99(10);

    companion object {
        fun fromTag(tag: Int): AggregationOp? = entries.find { it.tag == tag }
    }
}

/** QueryError matching the Idris2 ABI tags. */
enum class QueryError(val tag: Int) {
    PARSE_ERROR(0),
    EXECUTION_ERROR(1),
    QUERY_TIMEOUT(2),
    TOO_MANY_SERIES(3);

    companion object {
        fun fromTag(tag: Int): QueryError? = entries.find { it.tag == tag }
    }
}

/** CollectorState matching the Idris2 ABI tags. */
enum class CollectorState(val tag: Int) {
    IDLE(0),
    CONFIGURED(1),
    SCRAPING(2),
    ALERTING(3),
    STOPPING(4);

    companion object {
        fun fromTag(tag: Int): CollectorState? = entries.find { it.tag == tag }
    }
}
