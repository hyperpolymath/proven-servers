// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

package com.hyperpolymath.proven

/** ComponentType matching the Idris2 ABI tags. */
enum class ComponentType(val tag: Int) {
    VEVENT(0),
    VTODO(1),
    VJOURNAL(2),
    VFREEBUSY(3);

    companion object {
        fun fromTag(tag: Int): ComponentType? = entries.find { it.tag == tag }
    }
}

/** CalMethod matching the Idris2 ABI tags. */
enum class CalMethod(val tag: Int) {
    GET(0),
    PUT(1),
    DELETE(2),
    PROPFIND(3),
    PROPPATCH(4),
    REPORT(5),
    MKCALENDAR(6);

    companion object {
        fun fromTag(tag: Int): CalMethod? = entries.find { it.tag == tag }
    }
}

/** ScheduleStatus matching the Idris2 ABI tags. */
enum class ScheduleStatus(val tag: Int) {
    NEEDS_ACTION(0),
    ACCEPTED(1),
    DECLINED(2),
    TENTATIVE(3),
    DELEGATED(4);

    companion object {
        fun fromTag(tag: Int): ScheduleStatus? = entries.find { it.tag == tag }
    }
}

/** CalError matching the Idris2 ABI tags. */
enum class CalError(val tag: Int) {
    VALID_CALENDAR_DATA(0),
    NO_RESOURCE_TYPE_CHANGE(1),
    SUPPORTED_COMPONENT_MISMATCH(2),
    MAX_RESOURCE_SIZE(3),
    UID_CONFLICT(4),
    PRECONDITION_FAILED(5);

    companion object {
        fun fromTag(tag: Int): CalError? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    BOUND(1),
    SERVING(2),
    SCHEDULING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
