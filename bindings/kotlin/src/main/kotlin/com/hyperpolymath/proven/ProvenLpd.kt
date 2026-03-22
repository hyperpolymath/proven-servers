// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

package com.hyperpolymath.proven

/** CommandCode matching the Idris2 ABI tags. */
enum class CommandCode(val tag: Int) {
    PRINT_JOB(1),
    RECEIVE_JOB(2),
    SHORT_QUEUE(3),
    LONG_QUEUE(4),
    REMOVE_JOBS(5);

    companion object {
        fun fromTag(tag: Int): CommandCode? = entries.find { it.tag == tag }
    }
}

/** SubCommandCode matching the Idris2 ABI tags. */
enum class SubCommandCode(val tag: Int) {
    ABORT_JOB(1),
    CONTROL_FILE(2),
    DATA_FILE(3);

    companion object {
        fun fromTag(tag: Int): SubCommandCode? = entries.find { it.tag == tag }
    }
}

/** JobStatus matching the Idris2 ABI tags. */
enum class JobStatus(val tag: Int) {
    PENDING(0),
    PRINTING(1),
    COMPLETE(2),
    FAILED(3);

    companion object {
        fun fromTag(tag: Int): JobStatus? = entries.find { it.tag == tag }
    }
}
