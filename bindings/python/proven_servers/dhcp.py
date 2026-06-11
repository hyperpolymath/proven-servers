# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-dhcp protocol types.

"""DHCP protocol types for proven-servers."""

from enum import IntEnum


class MessageType(IntEnum):
    """MessageType matching the Idris2 ABI tags."""
    DISCOVER = 0
    OFFER = 1
    REQUEST = 2
    ACK = 3
    NAK = 4
    RELEASE = 5
    INFORM = 6
    DECLINE = 7


class OptionCode(IntEnum):
    """OptionCode matching the Idris2 ABI tags."""
    SUBNET_MASK = 0
    ROUTER = 1
    DNS = 2
    DOMAIN_NAME = 3
    LEASE_TIME = 4
    SERVER_ID = 5
    REQUESTED_IP = 6
    MSG_TYPE = 7


class HardwareType(IntEnum):
    """HardwareType matching the Idris2 ABI tags."""
    ETHERNET = 0
    IEEE802 = 1
    ARCNET = 2
    FRAME_RELAY = 3


class DhcpState(IntEnum):
    """DhcpState matching the Idris2 ABI tags."""
    IDLE = 0
    DISCOVER_RECEIVED = 1
    OFFER_SENT = 2
    REQUEST_RECEIVED = 3
    ACK_SENT = 4
    NAK_SENT = 5


class LeaseState(IntEnum):
    """LeaseState matching the Idris2 ABI tags."""
    AVAILABLE = 0
    OFFERED = 1
    BOUND = 2
    RENEWING = 3
    REBINDING = 4
    EXPIRED = 5


class RelaySubOption(IntEnum):
    """RelaySubOption matching the Idris2 ABI tags."""
    CIRCUIT_ID = 0
    REMOTE_ID = 1
