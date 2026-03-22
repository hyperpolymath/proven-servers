// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Log Collector protocol types for proven-servers.

package com.hyperpolymath.proven

/** LogLevel matching the Idris2 ABI tags. */
enum class LogLevel(val tag: Int) {
    TRACE(0),
    DEBUG(1),
    INFO(2),
    WARN(3),
    ERR(4),
    FATAL(5);

    companion object {
        fun fromTag(tag: Int): LogLevel? = entries.find { it.tag == tag }
    }
}

/** InputFormat matching the Idris2 ABI tags. */
enum class InputFormat(val tag: Int) {
    JSON(0),
    LOGFMT(1),
    SYSLOG(2),
    CEF(3),
    GELF(4),
    RAW(5);

    companion object {
        fun fromTag(tag: Int): InputFormat? = entries.find { it.tag == tag }
    }
}

/** OutputTarget matching the Idris2 ABI tags. */
enum class OutputTarget(val tag: Int) {
    FILE(0),
    ELASTICSEARCH(1),
    S3(2),
    KAFKA(3),
    STDOUT(4);

    companion object {
        fun fromTag(tag: Int): OutputTarget? = entries.find { it.tag == tag }
    }
}

/** FilterOp matching the Idris2 ABI tags. */
enum class FilterOp(val tag: Int) {
    INCLUDE(0),
    EXCLUDE(1),
    TRANSFORM(2),
    REDACT(3),
    SAMPLE(4);

    companion object {
        fun fromTag(tag: Int): FilterOp? = entries.find { it.tag == tag }
    }
}

/** PipelineStage matching the Idris2 ABI tags. */
enum class PipelineStage(val tag: Int) {
    INPUT(0),
    PARSE(1),
    FILTER(2),
    PIPELINE_TRANSFORM(3),
    OUTPUT(4);

    companion object {
        fun fromTag(tag: Int): PipelineStage? = entries.find { it.tag == tag }
    }
}
