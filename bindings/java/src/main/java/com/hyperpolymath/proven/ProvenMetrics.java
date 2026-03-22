// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Metrics protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Metrics protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMetrics {
    private ProvenMetrics() {}

    /** MetricType (tags 0-5). */
    public enum MetricType {
        COUNTER(0),
        GAUGE(1),
        HISTOGRAM(2),
        SUMMARY(3),
        INFO(4),
        STATE_SET(5);

        private final int tag;
        MetricType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MetricType fromTag(int tag) {
            for (MetricType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ScrapeResult (tags 0-3). */
    public enum ScrapeResult {
        SUCCESS(0),
        SCRAPE_TIMEOUT(1),
        CONNECTION_REFUSED(2),
        INVALID_RESPONSE(3);

        private final int tag;
        ScrapeResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ScrapeResult fromTag(int tag) {
            for (ScrapeResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AlertState (tags 0-3). */
    public enum AlertState {
        INACTIVE(0),
        PENDING(1),
        FIRING(2),
        RESOLVED(3);

        private final int tag;
        AlertState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlertState fromTag(int tag) {
            for (AlertState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AggregationOp (tags 0-10). */
    public enum AggregationOp {
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

        private final int tag;
        AggregationOp(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AggregationOp fromTag(int tag) {
            for (AggregationOp v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** QueryError (tags 0-3). */
    public enum QueryError {
        PARSE_ERROR(0),
        EXECUTION_ERROR(1),
        QUERY_TIMEOUT(2),
        TOO_MANY_SERIES(3);

        private final int tag;
        QueryError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static QueryError fromTag(int tag) {
            for (QueryError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CollectorState (tags 0-4). */
    public enum CollectorState {
        IDLE(0),
        CONFIGURED(1),
        SCRAPING(2),
        ALERTING(3),
        STOPPING(4);

        private final int tag;
        CollectorState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CollectorState fromTag(int tag) {
            for (CollectorState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
