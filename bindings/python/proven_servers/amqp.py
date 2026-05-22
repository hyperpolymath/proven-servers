# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-amqp protocol types.

"""AMQP protocol types for proven-servers."""

from enum import IntEnum


class FrameType(IntEnum):
    """FrameType matching the Idris2 ABI tags."""
    METHOD = 0
    HEADER = 1
    BODY = 2
    HEARTBEAT = 3


class MethodClass(IntEnum):
    """MethodClass matching the Idris2 ABI tags."""
    CONNECTION = 0
    CHANNEL = 1
    EXCHANGE = 2
    QUEUE = 3
    BASIC = 4
    TX = 5
    CONFIRM = 6


class ExchangeType(IntEnum):
    """ExchangeType matching the Idris2 ABI tags."""
    DIRECT = 0
    FANOUT = 1
    TOPIC = 2
    HEADERS = 3


class DeliveryMode(IntEnum):
    """DeliveryMode matching the Idris2 ABI tags."""
    NON_PERSISTENT = 0
    PERSISTENT = 1


class ErrorSeverity(IntEnum):
    """ErrorSeverity matching the Idris2 ABI tags."""
    CHANNEL_LEVEL = 0
    CONNECTION_LEVEL = 1


class ConnectionState(IntEnum):
    """ConnectionState matching the Idris2 ABI tags."""
    CONNECTION_STATE_IDLE = 0
    NEGOTIATING = 1
    TUNING_OK = 2
    OPEN = 3
    CLOSING = 4


class ChannelState(IntEnum):
    """ChannelState matching the Idris2 ABI tags."""
    CLOSED = 0
    OPENING = 1
    CH_OPEN = 2
    CH_CLOSING = 3


class BrokerState(IntEnum):
    """BrokerState matching the Idris2 ABI tags."""
    BROKER_STATE_IDLE = 0
    CONNECTED = 1
    CHANNEL_OPEN = 2
    CONSUMING = 3
    PUBLISHING = 4
    DISCONNECTING = 5
