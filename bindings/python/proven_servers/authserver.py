# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-authserver protocol types.

"""Auth protocol types for proven-servers."""

from enum import IntEnum


class AuthMethod(IntEnum):
    """AuthMethod matching the Idris2 ABI tags."""
    PASSWORD = 0
    CERTIFICATE = 1
    O_AUTH2 = 2
    SAML = 3
    FIDO2 = 4
    KERBEROS = 5
    LDAP = 6
    RADIUS = 7


class TokenType(IntEnum):
    """TokenType matching the Idris2 ABI tags."""
    ACCESS = 0
    REFRESH = 1
    ID = 2
    API = 3


class AuthResult(IntEnum):
    """AuthResult matching the Idris2 ABI tags."""
    SUCCESS = 0
    INVALID_CREDENTIALS = 1
    ACCOUNT_LOCKED = 2
    ACCOUNT_EXPIRED = 3
    MFA_REQUIRED = 4
    IP_BLOCKED = 5


class MfaMethod(IntEnum):
    """MfaMethod matching the Idris2 ABI tags."""
    TOTP = 0
    SMS = 1
    PUSH = 2
    FIDO2_MFA = 3
    EMAIL = 4


class SessionState(IntEnum):
    """SessionState matching the Idris2 ABI tags."""
    ACTIVE = 0
    EXPIRED = 1
    REVOKED = 2
    LOCKED = 3
