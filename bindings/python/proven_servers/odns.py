# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-odns protocol types.

"""ODNS protocol types for proven-servers."""

from enum import IntEnum


class Role(IntEnum):
    """Role matching the Idris2 ABI tags."""
    CLIENT = 0
    PROXY = 1
    TARGET = 2


class OdnsMessageType(IntEnum):
    """OdnsMessageType matching the Idris2 ABI tags."""
    QUERY = 0
    RESPONSE = 1


class OdnsErrorReason(IntEnum):
    """OdnsErrorReason matching the Idris2 ABI tags."""
    PROXY_ERROR = 0
    TARGET_ERROR = 1
    DECRYPTION_FAILED = 2
    INVALID_CONFIG = 3
    PAYLOAD_TOO_LARGE = 4


class EncapsulationFormat(IntEnum):
    """EncapsulationFormat matching the Idris2 ABI tags."""
    HPKE = 0


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    IDLE = 0
    KEY_EXCHANGE = 1
    READY = 2
    PROCESSING = 3
    CLOSING = 4
