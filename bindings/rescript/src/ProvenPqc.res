// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Post-Quantum Cryptography types for the proven-servers ABI.
//
// Mirrors the Idris2 module PqcABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// PqcAlgorithm (tags 0-7)
// ===========================================================================

/// Post-quantum cryptographic algorithms.
type pqcAlgorithm =
  | @as(0) CrystalsKyber
  | @as(1) CrystalsDilithium
  | @as(2) Falcon
  | @as(3) SphincsPlus
  | @as(4) ClassicMceliece
  | @as(5) Bike
  | @as(6) Hqc
  | @as(7) Frodokem

/// Decode from the C-ABI tag value.
let pqcAlgorithmFromTag = (tag: int): option<pqcAlgorithm> =>
  switch tag {
  | 0 => Some(CrystalsKyber)
  | 1 => Some(CrystalsDilithium)
  | 2 => Some(Falcon)
  | 3 => Some(SphincsPlus)
  | 4 => Some(ClassicMceliece)
  | 5 => Some(Bike)
  | 6 => Some(Hqc)
  | 7 => Some(Frodokem)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let pqcAlgorithmToTag = (v: pqcAlgorithm): int =>
  switch v {
  | CrystalsKyber => 0
  | CrystalsDilithium => 1
  | Falcon => 2
  | SphincsPlus => 3
  | ClassicMceliece => 4
  | Bike => 5
  | Hqc => 6
  | Frodokem => 7
  }

/// Whether this is a KEM (key encapsulation) algorithm.
let pqcAlgorithmIsKem = (v: pqcAlgorithm): bool =>
  switch v {
  | CrystalsKyber | ClassicMceliece | Bike | Hqc | Frodokem => true
  | _ => false
  }

/// Whether this is a signature algorithm.
let pqcAlgorithmIsSignature = (v: pqcAlgorithm): bool =>
  switch v {
  | CrystalsDilithium | Falcon | SphincsPlus => true
  | _ => false
  }

// ===========================================================================
// NistLevel (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type nistLevel =
  | @as(0) Nist1
  | @as(1) Nist2
  | @as(2) Nist3
  | @as(3) Nist4
  | @as(4) Nist5

/// Decode from the C-ABI tag value.
let nistLevelFromTag = (tag: int): option<nistLevel> =>
  switch tag {
  | 0 => Some(Nist1)
  | 1 => Some(Nist2)
  | 2 => Some(Nist3)
  | 3 => Some(Nist4)
  | 4 => Some(Nist5)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let nistLevelToTag = (v: nistLevel): int =>
  switch v {
  | Nist1 => 0
  | Nist2 => 1
  | Nist3 => 2
  | Nist4 => 3
  | Nist5 => 4
  }

// ===========================================================================
// Operation (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type operation =
  | @as(0) Keygen
  | @as(1) Encapsulate
  | @as(2) Decapsulate
  | @as(3) Sign
  | @as(4) Verify

/// Decode from the C-ABI tag value.
let operationFromTag = (tag: int): option<operation> =>
  switch tag {
  | 0 => Some(Keygen)
  | 1 => Some(Encapsulate)
  | 2 => Some(Decapsulate)
  | 3 => Some(Sign)
  | 4 => Some(Verify)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let operationToTag = (v: operation): int =>
  switch v {
  | Keygen => 0
  | Encapsulate => 1
  | Decapsulate => 2
  | Sign => 3
  | Verify => 4
  }

// ===========================================================================
// HybridMode (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type hybridMode =
  | @as(0) ClassicalOnly
  | @as(1) PqcOnly
  | @as(2) Hybrid

/// Decode from the C-ABI tag value.
let hybridModeFromTag = (tag: int): option<hybridMode> =>
  switch tag {
  | 0 => Some(ClassicalOnly)
  | 1 => Some(PqcOnly)
  | 2 => Some(Hybrid)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hybridModeToTag = (v: hybridMode): int =>
  switch v {
  | ClassicalOnly => 0
  | PqcOnly => 1
  | Hybrid => 2
  }

// ===========================================================================
// AlgorithmCategory (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type algorithmCategory =
  | @as(0) Kem
  | @as(1) Signature

/// Decode from the C-ABI tag value.
let algorithmCategoryFromTag = (tag: int): option<algorithmCategory> =>
  switch tag {
  | 0 => Some(Kem)
  | 1 => Some(Signature)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let algorithmCategoryToTag = (v: algorithmCategory): int =>
  switch v {
  | Kem => 0
  | Signature => 1
  }

// ===========================================================================
// KeyState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type keyState =
  | @as(0) Empty
  | @as(1) Generating
  | @as(2) Generated
  | @as(3) Active
  | @as(4) Expired
  | @as(5) Compromised

/// Decode from the C-ABI tag value.
let keyStateFromTag = (tag: int): option<keyState> =>
  switch tag {
  | 0 => Some(Empty)
  | 1 => Some(Generating)
  | 2 => Some(Generated)
  | 3 => Some(Active)
  | 4 => Some(Expired)
  | 5 => Some(Compromised)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let keyStateToTag = (v: keyState): int =>
  switch v {
  | Empty => 0
  | Generating => 1
  | Generated => 2
  | Active => 3
  | Expired => 4
  | Compromised => 5
  }

/// Whether the key can be used.
let keyStateIsUsable = (v: keyState): bool =>
  switch v {
  | Active => true
  | _ => false
  }

