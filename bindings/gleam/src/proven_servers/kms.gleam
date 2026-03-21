//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Key Management Service protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `KmsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Key Management Service Constants
// ===========================================================================

/// Kms Port constant.
pub const kms_port = 5696

// ===========================================================================
// ObjectType
// ===========================================================================

/// Managed cryptographic object types.
/// 
/// Matches `ObjectType` in `KmsABI.Types`.
pub type ObjectType {
  /// SymmetricKey (tag 0).
  SymmetricKey
  /// PublicKey (tag 1).
  PublicKey
  /// PrivateKey (tag 2).
  PrivateKey
  /// SecretData (tag 3).
  SecretData
  /// Certificate (tag 4).
  Certificate
  /// OpaqueData (tag 5).
  OpaqueData
}

/// Convert a `ObjectType` to its C-ABI tag value.
pub fn object_type_to_int(value: ObjectType) -> Int {
  case value {
    SymmetricKey -> 0
    PublicKey -> 1
    PrivateKey -> 2
    SecretData -> 3
    Certificate -> 4
    OpaqueData -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn object_type_from_int(tag: Int) -> Result(ObjectType, Nil) {
  case tag {
    0 -> Ok(SymmetricKey)
    1 -> Ok(PublicKey)
    2 -> Ok(PrivateKey)
    3 -> Ok(SecretData)
    4 -> Ok(Certificate)
    5 -> Ok(OpaqueData)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Operation
// ===========================================================================

/// KMS operations.
/// 
/// Matches `Operation` in `KmsABI.Types`.
pub type Operation {
  /// Create (tag 0).
  Create
  /// Get (tag 1).
  Get
  /// Activate (tag 2).
  Activate
  /// Revoke (tag 3).
  Revoke
  /// Destroy (tag 4).
  Destroy
  /// Locate (tag 5).
  Locate
  /// Register (tag 6).
  Register
  /// Rekey (tag 7).
  Rekey
  /// Encrypt (tag 8).
  Encrypt
  /// Decrypt (tag 9).
  Decrypt
  /// Sign (tag 10).
  Sign
  /// Verify (tag 11).
  Verify
  /// Wrap (tag 12).
  Wrap
  /// Unwrap (tag 13).
  Unwrap
  /// MAC (tag 14).
  Mac
}

/// Convert a `Operation` to its C-ABI tag value.
pub fn operation_to_int(value: Operation) -> Int {
  case value {
    Create -> 0
    Get -> 1
    Activate -> 2
    Revoke -> 3
    Destroy -> 4
    Locate -> 5
    Register -> 6
    Rekey -> 7
    Encrypt -> 8
    Decrypt -> 9
    Sign -> 10
    Verify -> 11
    Wrap -> 12
    Unwrap -> 13
    Mac -> 14
  }
}

/// Decode from a C-ABI tag value.
pub fn operation_from_int(tag: Int) -> Result(Operation, Nil) {
  case tag {
    0 -> Ok(Create)
    1 -> Ok(Get)
    2 -> Ok(Activate)
    3 -> Ok(Revoke)
    4 -> Ok(Destroy)
    5 -> Ok(Locate)
    6 -> Ok(Register)
    7 -> Ok(Rekey)
    8 -> Ok(Encrypt)
    9 -> Ok(Decrypt)
    10 -> Ok(Sign)
    11 -> Ok(Verify)
    12 -> Ok(Wrap)
    13 -> Ok(Unwrap)
    14 -> Ok(Mac)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KeyState
// ===========================================================================

/// Key lifecycle states (KMIP).
/// 
/// Matches `KeyState` in `KmsABI.Types`.
pub type KeyState {
  /// PreActive (tag 0).
  PreActive
  /// Active (tag 1).
  Active
  /// Deactivated (tag 2).
  Deactivated
  /// Compromised (tag 3).
  Compromised
  /// Destroyed (tag 4).
  Destroyed
  /// DestroyedCompromised (tag 5).
  DestroyedCompromised
}

/// Convert a `KeyState` to its C-ABI tag value.
pub fn key_state_to_int(value: KeyState) -> Int {
  case value {
    PreActive -> 0
    Active -> 1
    Deactivated -> 2
    Compromised -> 3
    Destroyed -> 4
    DestroyedCompromised -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn key_state_from_int(tag: Int) -> Result(KeyState, Nil) {
  case tag {
    0 -> Ok(PreActive)
    1 -> Ok(Active)
    2 -> Ok(Deactivated)
    3 -> Ok(Compromised)
    4 -> Ok(Destroyed)
    5 -> Ok(DestroyedCompromised)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KmsAlgorithm
// ===========================================================================

/// Cryptographic algorithms.
/// 
/// Matches `KmsAlgorithm` in `KmsABI.Types`.
pub type KmsAlgorithm {
  /// AES-128 (tag 0).
  Aes128
  /// AES-256 (tag 1).
  Aes256
  /// RSA-2048 (tag 2).
  Rsa2048
  /// RSA-4096 (tag 3).
  Rsa4096
  /// ECDSA P-256 (tag 4).
  EcdsaP256
  /// ECDSA P-384 (tag 5).
  EcdsaP384
  /// Ed25519 (tag 6).
  Ed25519
  /// Chacha20Poly1305 (tag 7).
  Chacha20Poly1305
  /// HMAC-SHA256 (tag 8).
  HmacSha256
}

/// Convert a `KmsAlgorithm` to its C-ABI tag value.
pub fn kms_algorithm_to_int(value: KmsAlgorithm) -> Int {
  case value {
    Aes128 -> 0
    Aes256 -> 1
    Rsa2048 -> 2
    Rsa4096 -> 3
    EcdsaP256 -> 4
    EcdsaP384 -> 5
    Ed25519 -> 6
    Chacha20Poly1305 -> 7
    HmacSha256 -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn kms_algorithm_from_int(tag: Int) -> Result(KmsAlgorithm, Nil) {
  case tag {
    0 -> Ok(Aes128)
    1 -> Ok(Aes256)
    2 -> Ok(Rsa2048)
    3 -> Ok(Rsa4096)
    4 -> Ok(EcdsaP256)
    5 -> Ok(EcdsaP384)
    6 -> Ok(Ed25519)
    7 -> Ok(Chacha20Poly1305)
    8 -> Ok(HmacSha256)
    _ -> Error(Nil)
  }
}

