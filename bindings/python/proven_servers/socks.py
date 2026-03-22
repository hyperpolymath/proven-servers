# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-socks protocol types.

"""SOCKS5 protocol types for proven-servers."""

from enum import IntEnum


class AuthMethod(IntEnum):
    """AuthMethod matching the Idris2 ABI tags."""
    NO_AUTH = 0
    GSSAPI = 1
    USERNAME_PASSWORD = 2
    NO_ACCEPTABLE = 3


class Command(IntEnum):
    """Command matching the Idris2 ABI tags."""
    CONNECT = 0
    BIND = 1
    UDP_ASSOCIATE = 2


class AddressType(IntEnum):
    """AddressType matching the Idris2 ABI tags."""
    I_PV4 = 0
    DOMAIN_NAME = 1
    I_PV6 = 2


class Reply(IntEnum):
    """Reply matching the Idris2 ABI tags."""
    SUCCEEDED = 0
    GENERAL_FAILURE = 1
    NOT_ALLOWED = 2
    NETWORK_UNREACHABLE = 3
    HOST_UNREACHABLE = 4
    CONNECTION_REFUSED = 5
    TTL_EXPIRED = 6
    COMMAND_NOT_SUPPORTED = 7
    ADDRESS_TYPE_NOT_SUPPORTED = 8


class State(IntEnum):
    """State matching the Idris2 ABI tags."""
    INITIAL = 0
    AUTHENTICATING = 1
    AUTHENTICATED = 2
    CONNECTING = 3
    ESTABLISHED = 4
    CLOSED = 5
