// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Key Management Service types for the proven-servers ABI.
//
// Mirrors the Idris2 module KmsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard KMIP port.
let kmsPort = 5696

// ===========================================================================
// ObjectType (tags 0-5)
// ===========================================================================

/// Standard KMIP port.
type objectType =
  | @as(0) SymmetricKey
  | @as(1) PublicKey
  | @as(2) PrivateKey
  | @as(3) SecretData
  | @as(4) Certificate
  | @as(5) OpaqueData

/// Decode from the C-ABI tag value.
let objectTypeFromTag = (tag: int): option<objectType> =>
  switch tag {
  | 0 => Some(SymmetricKey)
  | 1 => Some(PublicKey)
  | 2 => Some(PrivateKey)
  | 3 => Some(SecretData)
  | 4 => Some(Certificate)
  | 5 => Some(OpaqueData)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let objectTypeToTag = (v: objectType): int =>
  switch v {
  | SymmetricKey => 0
  | PublicKey => 1
  | PrivateKey => 2
  | SecretData => 3
  | Certificate => 4
  | OpaqueData => 5
  }

// ===========================================================================
// Operation (tags 0-14)
// ===========================================================================

/// Decode from an ABI tag value.
type operation =
  | @as(0) Create
  | @as(1) Get
  | @as(2) Activate
  | @as(3) Revoke
  | @as(4) Destroy
  | @as(5) Locate
  | @as(6) Register
  | @as(7) Rekey
  | @as(8) Encrypt
  | @as(9) Decrypt
  | @as(10) Sign
  | @as(11) Verify
  | @as(12) Wrap
  | @as(13) Unwrap
  | @as(14) Mac

/// Decode from the C-ABI tag value.
let operationFromTag = (tag: int): option<operation> =>
  switch tag {
  | 0 => Some(Create)
  | 1 => Some(Get)
  | 2 => Some(Activate)
  | 3 => Some(Revoke)
  | 4 => Some(Destroy)
  | 5 => Some(Locate)
  | 6 => Some(Register)
  | 7 => Some(Rekey)
  | 8 => Some(Encrypt)
  | 9 => Some(Decrypt)
  | 10 => Some(Sign)
  | 11 => Some(Verify)
  | 12 => Some(Wrap)
  | 13 => Some(Unwrap)
  | 14 => Some(Mac)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let operationToTag = (v: operation): int =>
  switch v {
  | Create => 0
  | Get => 1
  | Activate => 2
  | Revoke => 3
  | Destroy => 4
  | Locate => 5
  | Register => 6
  | Rekey => 7
  | Encrypt => 8
  | Decrypt => 9
  | Sign => 10
  | Verify => 11
  | Wrap => 12
  | Unwrap => 13
  | Mac => 14
  }

/// Whether this is a cryptographic operation.
let operationIsCryptoOp = (v: operation): bool =>
  switch v {
  | Encrypt | Decrypt | Sign | Verify | Wrap | Unwrap | Mac => true
  | _ => false
  }

/// Whether this is a key lifecycle operation.
let operationIsLifecycleOp = (v: operation): bool =>
  switch v {
  | Create | Activate | Revoke | Destroy | Rekey => true
  | _ => false
  }

// ===========================================================================
// KeyState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type keyState =
  | @as(0) PreActive
  | @as(1) Active
  | @as(2) Deactivated
  | @as(3) Compromised
  | @as(4) Destroyed
  | @as(5) DestroyedCompromised

/// Decode from the C-ABI tag value.
let keyStateFromTag = (tag: int): option<keyState> =>
  switch tag {
  | 0 => Some(PreActive)
  | 1 => Some(Active)
  | 2 => Some(Deactivated)
  | 3 => Some(Compromised)
  | 4 => Some(Destroyed)
  | 5 => Some(DestroyedCompromised)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let keyStateToTag = (v: keyState): int =>
  switch v {
  | PreActive => 0
  | Active => 1
  | Deactivated => 2
  | Compromised => 3
  | Destroyed => 4
  | DestroyedCompromised => 5
  }

/// Whether the key can be used for cryptographic operations.
let keyStateIsUsable = (v: keyState): bool =>
  switch v {
  | Active => true
  | _ => false
  }

// ===========================================================================
// KmsAlgorithm (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type kmsAlgorithm =
  | @as(0) Aes128
  | @as(1) Aes256
  | @as(2) Rsa2048
  | @as(3) Rsa4096
  | @as(4) EcdsaP256
  | @as(5) EcdsaP384
  | @as(6) Ed25519
  | @as(7) Chacha20Poly1305
  | @as(8) HmacSha256

/// Decode from the C-ABI tag value.
let kmsAlgorithmFromTag = (tag: int): option<kmsAlgorithm> =>
  switch tag {
  | 0 => Some(Aes128)
  | 1 => Some(Aes256)
  | 2 => Some(Rsa2048)
  | 3 => Some(Rsa4096)
  | 4 => Some(EcdsaP256)
  | 5 => Some(EcdsaP384)
  | 6 => Some(Ed25519)
  | 7 => Some(Chacha20Poly1305)
  | 8 => Some(HmacSha256)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let kmsAlgorithmToTag = (v: kmsAlgorithm): int =>
  switch v {
  | Aes128 => 0
  | Aes256 => 1
  | Rsa2048 => 2
  | Rsa4096 => 3
  | EcdsaP256 => 4
  | EcdsaP384 => 5
  | Ed25519 => 6
  | Chacha20Poly1305 => 7
  | HmacSha256 => 8
  }

