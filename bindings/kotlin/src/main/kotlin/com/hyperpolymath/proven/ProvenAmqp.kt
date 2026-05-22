// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

package com.hyperpolymath.proven

/** FrameType matching the Idris2 ABI tags. */
enum class FrameType(val tag: Int) {
    METHOD(0),
    HEADER(1),
    BODY(2),
    HEARTBEAT(3);

    companion object {
        fun fromTag(tag: Int): FrameType? = entries.find { it.tag == tag }
    }
}

/** MethodClass matching the Idris2 ABI tags. */
enum class MethodClass(val tag: Int) {
    CONNECTION(0),
    CHANNEL(1),
    EXCHANGE(2),
    QUEUE(3),
    BASIC(4),
    TX(5),
    CONFIRM(6);

    companion object {
        fun fromTag(tag: Int): MethodClass? = entries.find { it.tag == tag }
    }
}

/** ExchangeType matching the Idris2 ABI tags. */
enum class ExchangeType(val tag: Int) {
    DIRECT(0),
    FANOUT(1),
    TOPIC(2),
    HEADERS(3);

    companion object {
        fun fromTag(tag: Int): ExchangeType? = entries.find { it.tag == tag }
    }
}

/** DeliveryMode matching the Idris2 ABI tags. */
enum class DeliveryMode(val tag: Int) {
    NON_PERSISTENT(0),
    PERSISTENT(1);

    companion object {
        fun fromTag(tag: Int): DeliveryMode? = entries.find { it.tag == tag }
    }
}

/** ErrorSeverity matching the Idris2 ABI tags. */
enum class ErrorSeverity(val tag: Int) {
    CHANNEL_LEVEL(0),
    CONNECTION_LEVEL(1);

    companion object {
        fun fromTag(tag: Int): ErrorSeverity? = entries.find { it.tag == tag }
    }
}

/** ConnectionState matching the Idris2 ABI tags. */
enum class ConnectionState(val tag: Int) {
    CONNECTION_STATE__IDLE(0),
    NEGOTIATING(1),
    TUNING_OK(2),
    OPEN(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): ConnectionState? = entries.find { it.tag == tag }
    }
}

/** ChannelState matching the Idris2 ABI tags. */
enum class ChannelState(val tag: Int) {
    CLOSED(0),
    OPENING(1),
    CH_OPEN(2),
    CH_CLOSING(3);

    companion object {
        fun fromTag(tag: Int): ChannelState? = entries.find { it.tag == tag }
    }
}

/** BrokerState matching the Idris2 ABI tags. */
enum class BrokerState(val tag: Int) {
    BROKER_STATE__IDLE(0),
    CONNECTED(1),
    CHANNEL_OPEN(2),
    CONSUMING(3),
    PUBLISHING(4),
    DISCONNECTING(5);

    companion object {
        fun fromTag(tag: Int): BrokerState? = entries.find { it.tag == tag }
    }
}
