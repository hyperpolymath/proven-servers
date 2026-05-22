# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Python bindings for the proven-kerberos protocol types.

"""Kerberos protocol types for proven-servers."""

from enum import IntEnum


class MessageType(IntEnum):
    """MessageType matching the Idris2 ABI tags."""
    AS_REQ = 0
    AS_REP = 1
    TGS_REQ = 2
    TGS_REP = 3
    AP_REQ = 4
    AP_REP = 5
    KRB_ERROR = 6
    KRB_SAFE = 7
    KRB_PRIV = 8
    KRB_CRED = 9


class EncryptionType(IntEnum):
    """EncryptionType matching the Idris2 ABI tags."""
    AES256_CTS_HMAC_SHA1 = 0
    AES128_CTS_HMAC_SHA1 = 1
    AES256_CTS_HMAC_SHA384 = 2
    RC4_HMAC = 3
    DES3_CBC_SHA1 = 4


class PrincipalType(IntEnum):
    """PrincipalType matching the Idris2 ABI tags."""
    NT_UNKNOWN = 0
    NT_PRINCIPAL = 1
    NT_SRV_INST = 2
    NT_SRV_HST = 3
    NT_UID = 4
    NT_X500 = 5
    NT_ENTERPRISE = 6


class TicketFlag(IntEnum):
    """TicketFlag matching the Idris2 ABI tags."""
    FORWARDABLE = 0
    FORWARDED = 1
    PROXIABLE = 2
    PROXY = 3
    RENEWABLE = 4
    PRE_AUTHENT = 5
    HW_AUTHENT = 6


class ErrorCode(IntEnum):
    """ErrorCode matching the Idris2 ABI tags."""
    KDC_ERR_NONE = 0
    KDC_ERR_NAME_EXP = 1
    KDC_ERR_SERVICE_EXP = 2
    KDC_ERR_BAD_PVNO = 3
    KDC_ERR_C_OLD_MAST_KVNO = 4
    KDC_ERR_S_OLD_MAST_KVNO = 5
    KDC_ERR_C_PRINCIPAL_UNKNOWN = 6
    KDC_ERR_S_PRINCIPAL_UNKNOWN = 7
    KDC_ERR_PREAUTH_FAILED = 8
    KDC_ERR_PREAUTH_REQUIRED = 9


class AuthState(IntEnum):
    """AuthState matching the Idris2 ABI tags."""
    INITIAL = 0
    TGT_OBTAINED = 1
    SERVICE_TICKET_OBTAINED = 2
    AUTHENTICATED = 3
    AUTH_FAILED = 4


class EncStrength(IntEnum):
    """EncStrength matching the Idris2 ABI tags."""
    STRONG = 0
    MEDIUM = 1
    WEAK = 2


class PreAuthType(IntEnum):
    """PreAuthType matching the Idris2 ABI tags."""
    PA_ENC_TIMESTAMP = 0
    PA_ETYPE_INFO2 = 1
    PA_FX_FAST = 2
    PA_FX_COOKIE = 3


class NegotiationState(IntEnum):
    """NegotiationState matching the Idris2 ABI tags."""
    NEG_IDLE = 0
    PROPOSED = 1
    SELECTED = 2
    NEG_FAILED = 3
