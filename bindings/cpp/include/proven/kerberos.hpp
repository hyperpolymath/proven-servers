// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file kerberos.hpp
/// @brief Kerberos protocol types for proven-servers.

#ifndef PROVEN_KERBEROS_HPP
#define PROVEN_KERBEROS_HPP

#include <cstdint>

namespace proven {

/// @brief MessageType matching the Idris2 ABI tags.
enum class MessageType : uint8_t {
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
};

/// @brief EncryptionType matching the Idris2 ABI tags.
enum class EncryptionType : uint8_t {
    Aes256CtsHmacSha1 = 0,
    Aes128CtsHmacSha1 = 1,
    Aes256CtsHmacSha384 = 2,
    Rc4Hmac = 3,
    Des3CbcSha1 = 4
};

/// @brief PrincipalType matching the Idris2 ABI tags.
enum class PrincipalType : uint8_t {
    NtUnknown = 0,
    NtPrincipal = 1,
    NtSrvInst = 2,
    NtSrvHst = 3,
    NtUid = 4,
    NtX500 = 5,
    NtEnterprise = 6
};

/// @brief TicketFlag matching the Idris2 ABI tags.
enum class TicketFlag : uint8_t {
    Forwardable = 0,
    Forwarded = 1,
    Proxiable = 2,
    Proxy = 3,
    Renewable = 4,
    PreAuthent = 5,
    HwAuthent = 6
};

/// @brief ErrorCode matching the Idris2 ABI tags.
enum class ErrorCode : uint8_t {
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
};

/// @brief AuthState matching the Idris2 ABI tags.
enum class AuthState : uint8_t {
    Initial = 0,
    TgtObtained = 1,
    ServiceTicketObtained = 2,
    Authenticated = 3,
    AuthFailed = 4
};

/// @brief EncStrength matching the Idris2 ABI tags.
enum class EncStrength : uint8_t {
    Strong = 0,
    Medium = 1,
    Weak = 2
};

/// @brief PreAuthType matching the Idris2 ABI tags.
enum class PreAuthType : uint8_t {
    PaEncTimestamp = 0,
    PaEtypeInfo2 = 1,
    PaFxFast = 2,
    PaFxCookie = 3
};

/// @brief NegotiationState matching the Idris2 ABI tags.
enum class NegotiationState : uint8_t {
    NegIdle = 0,
    Proposed = 1,
    Selected = 2,
    NegFailed = 3
};

} // namespace proven

#endif // PROVEN_KERBEROS_HPP
