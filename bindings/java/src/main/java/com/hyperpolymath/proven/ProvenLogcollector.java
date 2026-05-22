// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Log Collector protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenLogcollector {
    private ProvenLogcollector() {}

    /** LogLevel (tags 0-5). */
    public enum LogLevel {
        TRACE(0),
        DEBUG(1),
        INFO(2),
        WARN(3),
        ERR(4),
        FATAL(5);

        private final int tag;
        LogLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LogLevel fromTag(int tag) {
            for (LogLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** InputFormat (tags 0-5). */
    public enum InputFormat {
        JSON(0),
        LOGFMT(1),
        SYSLOG(2),
        CEF(3),
        GELF(4),
        RAW(5);

        private final int tag;
        InputFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static InputFormat fromTag(int tag) {
            for (InputFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OutputTarget (tags 0-4). */
    public enum OutputTarget {
        FILE(0),
        ELASTICSEARCH(1),
        S3(2),
        KAFKA(3),
        STDOUT(4);

        private final int tag;
        OutputTarget(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OutputTarget fromTag(int tag) {
            for (OutputTarget v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FilterOp (tags 0-4). */
    public enum FilterOp {
        INCLUDE(0),
        EXCLUDE(1),
        TRANSFORM(2),
        REDACT(3),
        SAMPLE(4);

        private final int tag;
        FilterOp(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FilterOp fromTag(int tag) {
            for (FilterOp v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PipelineStage (tags 0-4). */
    public enum PipelineStage {
        INPUT(0),
        PARSE(1),
        FILTER(2),
        PIPELINE_TRANSFORM(3),
        OUTPUT(4);

        private final int tag;
        PipelineStage(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PipelineStage fromTag(int tag) {
            for (PipelineStage v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
