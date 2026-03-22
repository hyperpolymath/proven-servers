<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case AsReq = 0;
    case AsRep = 1;
    case TgsReq = 2;
    case TgsRep = 3;
    case ApReq = 4;
    case ApRep = 5;
    case KrbError = 6;
    case KrbSafe = 7;
    case KrbPriv = 8;
    case KrbCred = 9;
}

/** EncryptionType matching the Idris2 ABI tags. */
enum EncryptionType: int
{
    case Aes256CtsHmacSha1 = 0;
    case Aes128CtsHmacSha1 = 1;
    case Aes256CtsHmacSha384 = 2;
    case Rc4Hmac = 3;
    case Des3CbcSha1 = 4;
}

/** PrincipalType matching the Idris2 ABI tags. */
enum PrincipalType: int
{
    case NtUnknown = 0;
    case NtPrincipal = 1;
    case NtSrvInst = 2;
    case NtSrvHst = 3;
    case NtUid = 4;
    case NtX500 = 5;
    case NtEnterprise = 6;
}

/** TicketFlag matching the Idris2 ABI tags. */
enum TicketFlag: int
{
    case Forwardable = 0;
    case Forwarded = 1;
    case Proxiable = 2;
    case Proxy = 3;
    case Renewable = 4;
    case PreAuthent = 5;
    case HwAuthent = 6;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case KdcErrNone = 0;
    case KdcErrNameExp = 1;
    case KdcErrServiceExp = 2;
    case KdcErrBadPvno = 3;
    case KdcErrCOldMastKvno = 4;
    case KdcErrSOldMastKvno = 5;
    case KdcErrCPrincipalUnknown = 6;
    case KdcErrSPrincipalUnknown = 7;
    case KdcErrPreauthFailed = 8;
    case KdcErrPreauthRequired = 9;
}

/** AuthState matching the Idris2 ABI tags. */
enum AuthState: int
{
    case Initial = 0;
    case TgtObtained = 1;
    case ServiceTicketObtained = 2;
    case Authenticated = 3;
    case AuthFailed = 4;
}

/** EncStrength matching the Idris2 ABI tags. */
enum EncStrength: int
{
    case Strong = 0;
    case Medium = 1;
    case Weak = 2;
}

/** PreAuthType matching the Idris2 ABI tags. */
enum PreAuthType: int
{
    case PaEncTimestamp = 0;
    case PaEtypeInfo2 = 1;
    case PaFxFast = 2;
    case PaFxCookie = 3;
}

/** NegotiationState matching the Idris2 ABI tags. */
enum NegotiationState: int
{
    case NegIdle = 0;
    case Proposed = 1;
    case Selected = 2;
    case NegFailed = 3;
}
