# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-vpn protocol types.

"""VPN protocol types for proven-servers."""

from enum import IntEnum


class TunnelType(IntEnum):
    """TunnelType matching the Idris2 ABI tags."""
    IPSEC = 0
    WIREGUARD = 1
    OPENVPN = 2
    L2TP = 3


class TunnelPhase(IntEnum):
    """TunnelPhase matching the Idris2 ABI tags."""
    IDLE = 0
    PHASE1_INIT = 1
    PHASE1_AUTH = 2
    PHASE1_DONE = 3
    PHASE2_NEGOTIATING = 4
    ESTABLISHED = 5
    TUNNEL_PHASE_EXPIRED = 6


class EncryptionAlgorithm(IntEnum):
    """EncryptionAlgorithm matching the Idris2 ABI tags."""
    AES128_CBC = 0
    AES256_CBC = 1
    AES128_GCM = 2
    AES256_GCM = 3
    CHACHA20_POLY1305 = 4
    NULL_CIPHER = 5


class IntegrityAlgorithm(IntEnum):
    """IntegrityAlgorithm matching the Idris2 ABI tags."""
    HMAC_SHA1 = 0
    HMAC_SHA256 = 1
    HMAC_SHA384 = 2
    HMAC_SHA512 = 3
    NO_INTEGRITY = 4


class DhGroup(IntEnum):
    """DhGroup matching the Idris2 ABI tags."""
    DH14 = 0
    ECP256 = 1
    ECP384 = 2
    CURVE25519 = 3


class SaLifecycle(IntEnum):
    """SaLifecycle matching the Idris2 ABI tags."""
    NONE = 0
    ACTIVE = 1
    REKEYING = 2
    SA_LIFECYCLE_EXPIRED = 3
    DELETED = 4


class IkeVersion(IntEnum):
    """IkeVersion matching the Idris2 ABI tags."""
    V1 = 0
    V2 = 1


class VpnError(IntEnum):
    """VpnError matching the Idris2 ABI tags."""
    AUTHENTICATION_FAILED = 0
    NO_PROPOSAL_CHOSEN = 1
    LIFETIME_EXPIRED = 2
    INVALID_SPI = 3
    REPLAY_DETECTED = 4
    NEGOTIATION_TIMEOUT = 5
