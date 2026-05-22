// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

namespace Proven;

/// <summary>ObjectType matching the Idris2 ABI tags (0-5).</summary>
public enum ObjectType : byte
{
    SymmetricKey = 0,
    PublicKey = 1,
    PrivateKey = 2,
    SecretData = 3,
    Certificate = 4,
    OpaqueData = 5
}

/// <summary>Operation matching the Idris2 ABI tags (0-14).</summary>
public enum Operation : byte
{
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
}

/// <summary>KeyState matching the Idris2 ABI tags (0-5).</summary>
public enum KeyState : byte
{
    PreActive = 0,
    Active = 1,
    Deactivated = 2,
    Compromised = 3,
    Destroyed = 4,
    DestroyedCompromised = 5
}

/// <summary>KmsAlgorithm matching the Idris2 ABI tags (0-8).</summary>
public enum KmsAlgorithm : byte
{
    Aes128 = 0,
    Aes256 = 1,
    Rsa2048 = 2,
    Rsa4096 = 3,
    EcdsaP256 = 4,
    EcdsaP384 = 5,
    Ed25519 = 6,
    Chacha20Poly1305 = 7,
    HmacSha256 = 8
}
