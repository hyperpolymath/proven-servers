# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-sdn protocol types.

"""SDN protocol types for proven-servers."""

from enum import IntEnum


class SdnMessageType(IntEnum):
    """SdnMessageType matching the Idris2 ABI tags."""
    HELLO = 0
    ERROR = 1
    ECHO_REQUEST = 2
    ECHO_REPLY = 3
    FEATURES_REQUEST = 4
    FEATURES_REPLY = 5
    FLOW_MOD = 6
    PACKET_IN = 7
    PACKET_OUT = 8
    PORT_STATUS = 9
    BARRIER_REQUEST = 10
    BARRIER_REPLY = 11


class FlowAction(IntEnum):
    """FlowAction matching the Idris2 ABI tags."""
    OUTPUT = 0
    SET_FIELD = 1
    DROP = 2
    PUSH_VLAN = 3
    POP_VLAN = 4
    SET_QUEUE = 5
    GROUP = 6


class MatchField(IntEnum):
    """MatchField matching the Idris2 ABI tags."""
    IN_PORT = 0
    ETH_DST = 1
    ETH_SRC = 2
    ETH_TYPE = 3
    VLAN_ID = 4
    IP_SRC = 5
    IP_DST = 6
    TCP_SRC = 7
    TCP_DST = 8
    UDP_SRC = 9
    UDP_DST = 10


class PortState(IntEnum):
    """PortState matching the Idris2 ABI tags."""
    UP = 0
    DOWN = 1
    BLOCKED = 2
