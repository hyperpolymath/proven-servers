//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Post-Quantum Cryptography protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `PqcABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// PqcAlgorithm
// ===========================================================================

/// Post-quantum cryptographic algorithms.
/// 
/// Matches `PqcAlgorithm` in `PqcABI.Types`.
pub type PqcAlgorithm {
  /// CRYSTALS-Kyber KEM (tag 0).
  CrystalsKyber
  /// CRYSTALS-Dilithium signature (tag 1).
  CrystalsDilithium
  /// FALCON signature (tag 2).
  Falcon
  /// SPHINCS+ signature (tag 3).
  SphincsPlus
  /// Classic McEliece KEM (tag 4).
  ClassicMceliece
  /// BIKE KEM (tag 5).
  Bike
  /// HQC KEM (tag 6).
  Hqc
  /// FrodoKEM (tag 7).
  Frodokem
}

/// Convert a `PqcAlgorithm` to its C-ABI tag value.
pub fn pqc_algorithm_to_int(value: PqcAlgorithm) -> Int {
  case value {
    CrystalsKyber -> 0
    CrystalsDilithium -> 1
    Falcon -> 2
    SphincsPlus -> 3
    ClassicMceliece -> 4
    Bike -> 5
    Hqc -> 6
    Frodokem -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn pqc_algorithm_from_int(tag: Int) -> Result(PqcAlgorithm, Nil) {
  case tag {
    0 -> Ok(CrystalsKyber)
    1 -> Ok(CrystalsDilithium)
    2 -> Ok(Falcon)
    3 -> Ok(SphincsPlus)
    4 -> Ok(ClassicMceliece)
    5 -> Ok(Bike)
    6 -> Ok(Hqc)
    7 -> Ok(Frodokem)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NistLevel
// ===========================================================================

/// NIST security levels (1-5).
/// 
/// Matches `NistLevel` in `PqcABI.Types`.
pub type NistLevel {
  /// Nist1 (tag 0).
  Nist1
  /// Nist2 (tag 1).
  Nist2
  /// Nist3 (tag 2).
  Nist3
  /// Nist4 (tag 3).
  Nist4
  /// Nist5 (tag 4).
  Nist5
}

/// Convert a `NistLevel` to its C-ABI tag value.
pub fn nist_level_to_int(value: NistLevel) -> Int {
  case value {
    Nist1 -> 0
    Nist2 -> 1
    Nist3 -> 2
    Nist4 -> 3
    Nist5 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn nist_level_from_int(tag: Int) -> Result(NistLevel, Nil) {
  case tag {
    0 -> Ok(Nist1)
    1 -> Ok(Nist2)
    2 -> Ok(Nist3)
    3 -> Ok(Nist4)
    4 -> Ok(Nist5)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Operation
// ===========================================================================

/// PQC cryptographic operations.
/// 
/// Matches `Operation` in `PqcABI.Types`.
pub type Operation {
  /// Keygen (tag 0).
  Keygen
  /// Encapsulate (tag 1).
  Encapsulate
  /// Decapsulate (tag 2).
  Decapsulate
  /// Sign (tag 3).
  Sign
  /// Verify (tag 4).
  Verify
}

/// Convert a `Operation` to its C-ABI tag value.
pub fn operation_to_int(value: Operation) -> Int {
  case value {
    Keygen -> 0
    Encapsulate -> 1
    Decapsulate -> 2
    Sign -> 3
    Verify -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn operation_from_int(tag: Int) -> Result(Operation, Nil) {
  case tag {
    0 -> Ok(Keygen)
    1 -> Ok(Encapsulate)
    2 -> Ok(Decapsulate)
    3 -> Ok(Sign)
    4 -> Ok(Verify)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HybridMode
// ===========================================================================

/// Classical/PQC hybrid modes.
/// 
/// Matches `HybridMode` in `PqcABI.Types`.
pub type HybridMode {
  /// ClassicalOnly (tag 0).
  ClassicalOnly
  /// PqcOnly (tag 1).
  PqcOnly
  /// Hybrid (tag 2).
  Hybrid
}

/// Convert a `HybridMode` to its C-ABI tag value.
pub fn hybrid_mode_to_int(value: HybridMode) -> Int {
  case value {
    ClassicalOnly -> 0
    PqcOnly -> 1
    Hybrid -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn hybrid_mode_from_int(tag: Int) -> Result(HybridMode, Nil) {
  case tag {
    0 -> Ok(ClassicalOnly)
    1 -> Ok(PqcOnly)
    2 -> Ok(Hybrid)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AlgorithmCategory
// ===========================================================================

/// PQC algorithm categories.
/// 
/// Matches `AlgorithmCategory` in `PqcABI.Types`.
pub type AlgorithmCategory {
  /// Key encapsulation (tag 0).
  Kem
  /// Signature (tag 1).
  Signature
}

/// Convert a `AlgorithmCategory` to its C-ABI tag value.
pub fn algorithm_category_to_int(value: AlgorithmCategory) -> Int {
  case value {
    Kem -> 0
    Signature -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn algorithm_category_from_int(tag: Int) -> Result(AlgorithmCategory, Nil) {
  case tag {
    0 -> Ok(Kem)
    1 -> Ok(Signature)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KeyState
// ===========================================================================

/// PQC key lifecycle states.
/// 
/// Matches `KeyState` in `PqcABI.Types`.
pub type KeyState {
  /// Empty (tag 0).
  Empty
  /// Generating (tag 1).
  Generating
  /// Generated (tag 2).
  Generated
  /// Active (tag 3).
  Active
  /// Expired (tag 4).
  Expired
  /// Compromised (tag 5).
  Compromised
}

/// Convert a `KeyState` to its C-ABI tag value.
pub fn key_state_to_int(value: KeyState) -> Int {
  case value {
    Empty -> 0
    Generating -> 1
    Generated -> 2
    Active -> 3
    Expired -> 4
    Compromised -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn key_state_from_int(tag: Int) -> Result(KeyState, Nil) {
  case tag {
    0 -> Ok(Empty)
    1 -> Ok(Generating)
    2 -> Ok(Generated)
    3 -> Ok(Active)
    4 -> Ok(Expired)
    5 -> Ok(Compromised)
    _ -> Error(Nil)
  }
}

