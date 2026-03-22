// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
public enum MessageType: UInt8, CaseIterable, Sendable {
    case asReq = 0
    case asRep = 1
    case tgsReq = 2
    case tgsRep = 3
    case apReq = 4
    case apRep = 5
    case krbError = 6
    case krbSafe = 7
    case krbPriv = 8
    case krbCred = 9
}

/// EncryptionType matching the Idris2 ABI tags.
public enum EncryptionType: UInt8, CaseIterable, Sendable {
    case aes256CtsHmacSha1 = 0
    case aes128CtsHmacSha1 = 1
    case aes256CtsHmacSha384 = 2
    case rc4Hmac = 3
    case des3CbcSha1 = 4
}

/// PrincipalType matching the Idris2 ABI tags.
public enum PrincipalType: UInt8, CaseIterable, Sendable {
    case ntUnknown = 0
    case ntPrincipal = 1
    case ntSrvInst = 2
    case ntSrvHst = 3
    case ntUid = 4
    case ntX500 = 5
    case ntEnterprise = 6
}

/// TicketFlag matching the Idris2 ABI tags.
public enum TicketFlag: UInt8, CaseIterable, Sendable {
    case forwardable = 0
    case forwarded = 1
    case proxiable = 2
    case proxy = 3
    case renewable = 4
    case preAuthent = 5
    case hwAuthent = 6
}

/// ErrorCode matching the Idris2 ABI tags.
public enum ErrorCode: UInt8, CaseIterable, Sendable {
    case kdcErrNone = 0
    case kdcErrNameExp = 1
    case kdcErrServiceExp = 2
    case kdcErrBadPvno = 3
    case kdcErrCOldMastKvno = 4
    case kdcErrSOldMastKvno = 5
    case kdcErrCPrincipalUnknown = 6
    case kdcErrSPrincipalUnknown = 7
    case kdcErrPreauthFailed = 8
    case kdcErrPreauthRequired = 9
}

/// AuthState matching the Idris2 ABI tags.
public enum AuthState: UInt8, CaseIterable, Sendable {
    case initial = 0
    case tgtObtained = 1
    case serviceTicketObtained = 2
    case authenticated = 3
    case authFailed = 4
}

/// EncStrength matching the Idris2 ABI tags.
public enum EncStrength: UInt8, CaseIterable, Sendable {
    case strong = 0
    case medium = 1
    case weak = 2
}

/// PreAuthType matching the Idris2 ABI tags.
public enum PreAuthType: UInt8, CaseIterable, Sendable {
    case paEncTimestamp = 0
    case paEtypeInfo2 = 1
    case paFxFast = 2
    case paFxCookie = 3
}

/// NegotiationState matching the Idris2 ABI tags.
public enum NegotiationState: UInt8, CaseIterable, Sendable {
    case negIdle = 0
    case proposed = 1
    case selected = 2
    case negFailed = 3
}
