// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file kms.hpp
/// @brief KMS protocol types for proven-servers.

#ifndef PROVEN_KMS_HPP
#define PROVEN_KMS_HPP

#include <cstdint>

namespace proven {

/// @brief ObjectType matching the Idris2 ABI tags.
enum class ObjectType : uint8_t {
    SymmetricKey = 0,
    PublicKey = 1,
    PrivateKey = 2,
    SecretData = 3,
    Certificate = 4,
    OpaqueData = 5
};

/// @brief Operation matching the Idris2 ABI tags.
enum class Operation : uint8_t {
    Create = 0,
    Get = 1,
    Activate = 2,
    Revoke = 3,
    Destroy = 4,
    Locate = 5,
    Register = 6,
    Rekey = 7,
    Encrypt = 8,
    Decrypt = 9,
    Sign = 10,
    Verify = 11,
    Wrap = 12,
    Unwrap = 13,
    Mac = 14
};

/// @brief KeyState matching the Idris2 ABI tags.
enum class KeyState : uint8_t {
    PreActive = 0,
    Active = 1,
    Deactivated = 2,
    Compromised = 3,
    Destroyed = 4,
    DestroyedCompromised = 5
};

/// @brief KmsAlgorithm matching the Idris2 ABI tags.
enum class KmsAlgorithm : uint8_t {
    Aes128 = 0,
    Aes256 = 1,
    Rsa2048 = 2,
    Rsa4096 = 3,
    EcdsaP256 = 4,
    EcdsaP384 = 5,
    Ed25519 = 6,
    Chacha20Poly1305 = 7,
    HmacSha256 = 8
};

} // namespace proven

#endif // PROVEN_KMS_HPP
