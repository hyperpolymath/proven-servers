# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-kms protocol types.

"""KMS protocol types for proven-servers."""

from enum import IntEnum


class ObjectType(IntEnum):
    """ObjectType matching the Idris2 ABI tags."""
    SYMMETRIC_KEY = 0
    PUBLIC_KEY = 1
    PRIVATE_KEY = 2
    SECRET_DATA = 3
    CERTIFICATE = 4
    OPAQUE_DATA = 5


class Operation(IntEnum):
    """Operation matching the Idris2 ABI tags."""
    CREATE = 0
    GET = 1
    ACTIVATE = 2
    REVOKE = 3
    DESTROY = 4
    LOCATE = 5
    REGISTER = 6
    REKEY = 7
    ENCRYPT = 8
    DECRYPT = 9
    SIGN = 10
    VERIFY = 11
    WRAP = 12
    UNWRAP = 13
    MAC = 14


class KeyState(IntEnum):
    """KeyState matching the Idris2 ABI tags."""
    PRE_ACTIVE = 0
    ACTIVE = 1
    DEACTIVATED = 2
    COMPROMISED = 3
    DESTROYED = 4
    DESTROYED_COMPROMISED = 5


class KmsAlgorithm(IntEnum):
    """KmsAlgorithm matching the Idris2 ABI tags."""
    AES128 = 0
    AES256 = 1
    RSA2048 = 2
    RSA4096 = 3
    ECDSA_P256 = 4
    ECDSA_P384 = 5
    ED25519 = 6
    CHACHA20_POLY1305 = 7
    HMAC_SHA256 = 8
