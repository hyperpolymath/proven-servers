// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

package com.hyperpolymath.proven

/** Method matching the Idris2 ABI tags. */
enum class Method(val tag: Int) {
    DESCRIBE(0),
    SETUP(1),
    PLAY(2),
    PAUSE(3),
    TEARDOWN(4),
    GET_PARAMETER(5),
    SET_PARAMETER(6),
    OPTIONS(7),
    ANNOUNCE(8),
    RECORD(9),
    REDIRECT(10);

    companion object {
        fun fromTag(tag: Int): Method? = entries.find { it.tag == tag }
    }
}

/** TransportProtocol matching the Idris2 ABI tags. */
enum class TransportProtocol(val tag: Int) {
    RTP_AVP_UDP(0),
    RTP_AVP_TCP(1),
    RTP_AVP_UDP_MULTICAST(2);

    companion object {
        fun fromTag(tag: Int): TransportProtocol? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    INIT(0),
    READY(1),
    PLAYING(2),
    RECORDING(3);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}

/** StatusCode matching the Idris2 ABI tags. */
enum class StatusCode(val tag: Int) {
    STATUS_CODE__OK(0),
    MOVED_PERMANENTLY(1),
    MOVED_TEMPORARILY(2),
    BAD_REQUEST(3),
    UNAUTHORIZED(4),
    NOT_FOUND(5),
    STATUS_CODE__METHOD_NOT_ALLOWED(6),
    NOT_ACCEPTABLE(7),
    SESSION_NOT_FOUND(8),
    INTERNAL_SERVER_ERROR(9),
    NOT_IMPLEMENTED(10),
    SERVICE_UNAVAILABLE(11);

    companion object {
        fun fromTag(tag: Int): StatusCode? = entries.find { it.tag == tag }
    }
}

/** RtspError matching the Idris2 ABI tags. */
enum class RtspError(val tag: Int) {
    RTSP_ERROR__OK(0),
    INVALID_SLOT(1),
    NOT_ACTIVE(2),
    INVALID_TRANSITION(3),
    RTSP_ERROR__METHOD_NOT_ALLOWED(4),
    TRANSPORT_ERROR(5),
    SESSION_EXPIRED(6);

    companion object {
        fun fromTag(tag: Int): RtspError? = entries.find { it.tag == tag }
    }
}
