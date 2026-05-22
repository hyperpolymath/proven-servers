// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ca.hpp
/// @brief CA protocol types for proven-servers.

#ifndef PROVEN_CA_HPP
#define PROVEN_CA_HPP

#include <cstdint>

namespace proven {

/// @brief CertType matching the Idris2 ABI tags.
enum class CertType : uint8_t {
    Root = 0,
    Intermediate = 1,
    EndEntity = 2,
    CrossSigned = 3,
    CodeSigning = 4,
    EmailProtection = 5,
    OcspSigning = 6
};

/// @brief KeyAlgorithm matching the Idris2 ABI tags.
enum class KeyAlgorithm : uint8_t {
    Rsa2048 = 0,
    Rsa4096 = 1,
    EcdsaP256 = 2,
    EcdsaP384 = 3,
    Ed25519 = 4,
    Ed448 = 5
};

/// @brief SignatureAlgorithm matching the Idris2 ABI tags.
enum class SignatureAlgorithm : uint8_t {
    Sha256WithRsa = 0,
    Sha384WithRsa = 1,
    Sha512WithRsa = 2,
    Sha256WithEcdsa = 3,
    Sha384WithEcdsa = 4,
    PureEd25519 = 5,
    PureEd448 = 6
};

/// @brief CertState matching the Idris2 ABI tags.
enum class CertState : uint8_t {
    Pending = 0,
    Active = 1,
    Revoked = 2,
    Expired = 3,
    Suspended = 4
};

/// @brief RevocationReason matching the Idris2 ABI tags.
enum class RevocationReason : uint8_t {
    Unspecified = 0,
    KeyCompromise = 1,
    CaCompromise = 2,
    AffiliationChanged = 3,
    Superseded = 4,
    CessationOfOperation = 5,
    CertificateHold = 6
};

/// @brief CrlStatus matching the Idris2 ABI tags.
enum class CrlStatus : uint8_t {
    Current = 0,
    CrlExpired = 1,
    CrlPending = 2,
    CrlError = 3
};

/// @brief OcspStatus matching the Idris2 ABI tags.
enum class OcspStatus : uint8_t {
    Good = 0,
    OcspRevoked = 1,
    Unknown = 2,
    Unavailable = 3
};

/// @brief Extension matching the Idris2 ABI tags.
enum class Extension : uint8_t {
    BasicConstraints = 0,
    KeyUsage = 1,
    ExtKeyUsage = 2,
    SubjectAltName = 3,
    AuthorityInfoAccess = 4,
    CrlDistributionPoints = 5
};

/// @brief KeyUsageBit matching the Idris2 ABI tags.
enum class KeyUsageBit : uint8_t {
    DigitalSignature = 0,
    NonRepudiation = 1,
    KeyEncipherment = 2,
    DataEncipherment = 3,
    KeyAgreement = 4,
    KeyCertSign = 5,
    CrlSign = 6,
    EncipherOnly = 7,
    DecipherOnly = 8
};

} // namespace proven

#endif // PROVEN_CA_HPP
