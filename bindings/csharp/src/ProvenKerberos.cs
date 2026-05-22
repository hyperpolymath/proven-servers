// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for proven-servers.

namespace Proven;

/// <summary>MessageType matching the Idris2 ABI tags (0-9).</summary>
public enum MessageType : byte
{
    AsReq = 0,
    AsRep = 1,
    TgsReq = 2,
    TgsRep = 3,
    ApReq = 4,
    ApRep = 5,
    KrbError = 6,
    KrbSafe = 7,
    KrbPriv = 8,
    KrbCred = 9
}

/// <summary>EncryptionType matching the Idris2 ABI tags (0-4).</summary>
public enum EncryptionType : byte
{
    Aes256CtsHmacSha1 = 0,
    Aes128CtsHmacSha1 = 1,
    Aes256CtsHmacSha384 = 2,
    Rc4Hmac = 3,
    Des3CbcSha1 = 4
}

/// <summary>PrincipalType matching the Idris2 ABI tags (0-6).</summary>
public enum PrincipalType : byte
{
    NtUnknown = 0,
    NtPrincipal = 1,
    NtSrvInst = 2,
    NtSrvHst = 3,
    NtUid = 4,
    NtX500 = 5,
    NtEnterprise = 6
}

/// <summary>TicketFlag matching the Idris2 ABI tags (0-6).</summary>
public enum TicketFlag : byte
{
    Forwardable = 0,
    Forwarded = 1,
    Proxiable = 2,
    Proxy = 3,
    Renewable = 4,
    PreAuthent = 5,
    HwAuthent = 6
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-9).</summary>
public enum ErrorCode : byte
{
    KdcErrNone = 0,
    KdcErrNameExp = 1,
    KdcErrServiceExp = 2,
    KdcErrBadPvno = 3,
    KdcErrCOldMastKvno = 4,
    KdcErrSOldMastKvno = 5,
    KdcErrCPrincipalUnknown = 6,
    KdcErrSPrincipalUnknown = 7,
    KdcErrPreauthFailed = 8,
    KdcErrPreauthRequired = 9
}

/// <summary>AuthState matching the Idris2 ABI tags (0-4).</summary>
public enum AuthState : byte
{
    Initial = 0,
    TgtObtained = 1,
    ServiceTicketObtained = 2,
    Authenticated = 3,
    AuthFailed = 4
}

/// <summary>EncStrength matching the Idris2 ABI tags (0-2).</summary>
public enum EncStrength : byte
{
    Strong = 0,
    Medium = 1,
    Weak = 2
}

/// <summary>PreAuthType matching the Idris2 ABI tags (0-3).</summary>
public enum PreAuthType : byte
{
    PaEncTimestamp = 0,
    PaEtypeInfo2 = 1,
    PaFxFast = 2,
    PaFxCookie = 3
}

/// <summary>NegotiationState matching the Idris2 ABI tags (0-3).</summary>
public enum NegotiationState : byte
{
    NegIdle = 0,
    Proposed = 1,
    Selected = 2,
    NegFailed = 3
}
