# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-ssh protocol types.

"""SSH protocol types for proven-servers."""

from enum import IntEnum


class SshMessageType(IntEnum):
    """SshMessageType matching the Idris2 ABI tags."""
    KEXINIT = 0
    NEWKEYS = 1
    SERVICE_REQUEST = 2
    USERAUTH_REQUEST = 3
    SSH_MESSAGE_TYPE_CHANNEL_OPEN = 4
    CHANNEL_DATA = 5
    CHANNEL_CLOSE = 6
    DISCONNECT = 7


class AuthMethod(IntEnum):
    """AuthMethod matching the Idris2 ABI tags."""
    PUBLICKEY = 0
    PASSWORD = 1
    KEYBOARD_INTERACTIVE = 2
    AUTH_NONE = 3


class KexMethod(IntEnum):
    """KexMethod matching the Idris2 ABI tags."""
    DIFFIE_HELLMAN_GROUP14_SHA256 = 0
    CURVE25519_SHA256 = 1
    DIFFIE_HELLMAN_GROUP16_SHA512 = 2
    DIFFIE_HELLMAN_GROUP18_SHA512 = 3
    ECDH_SHA2_NISTP256 = 4
    ECDH_SHA2_NISTP384 = 5


class ChannelType(IntEnum):
    """ChannelType matching the Idris2 ABI tags."""
    SESSION = 0
    DIRECT_TCPIP = 1
    FORWARDED_TCPIP = 2
    X11 = 3


class BastionState(IntEnum):
    """BastionState matching the Idris2 ABI tags."""
    CONNECTED = 0
    KEY_EXCHANGED = 1
    AUTHENTICATED = 2
    BASTION_STATE_CHANNEL_OPEN = 3
    ACTIVE = 4
    BASTION_STATE_CLOSED = 5


class ChannelState(IntEnum):
    """ChannelState matching the Idris2 ABI tags."""
    OPENING = 0
    OPEN = 1
    CLOSING = 2
    CHANNEL_STATE_CLOSED = 3


class DisconnectReason(IntEnum):
    """DisconnectReason matching the Idris2 ABI tags."""
    HOST_NOT_ALLOWED = 0
    PROTOCOL_ERROR = 1
    KEY_EXCHANGE_FAILED = 2
    HOST_AUTH_FAILED = 3
    MAC_ERROR = 4
    SERVICE_NOT_AVAILABLE = 5
    VERSION_NOT_SUPPORTED = 6
    HOST_KEY_NOT_VERIFIABLE = 7
    CONNECTION_LOST = 8
    BY_APPLICATION = 9
    TOO_MANY_CONNECTIONS = 10
    AUTH_CANCELLED = 11


class HostKeyAlgorithm(IntEnum):
    """HostKeyAlgorithm matching the Idris2 ABI tags."""
    SSH_ED25519 = 0
    RSA_SHA2256 = 1
    RSA_SHA2512 = 2
    ECDSA_NISTP256 = 3


class CipherAlgorithm(IntEnum):
    """CipherAlgorithm matching the Idris2 ABI tags."""
    CHACHA20_POLY1305 = 0
    AES256_GCM = 1
    AES128_GCM = 2
    AES256_CTR = 3
    AES192_CTR = 4
    AES128_CTR = 5


class ChannelOpenFailure(IntEnum):
    """ChannelOpenFailure matching the Idris2 ABI tags."""
    ADMIN_PROHIBITED = 0
    CONNECT_FAILED = 1
    UNKNOWN_CHANNEL_TYPE = 2
    RESOURCE_SHORTAGE = 3
