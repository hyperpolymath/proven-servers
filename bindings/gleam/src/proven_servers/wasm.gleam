//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// WebAssembly Runtime protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `WasmABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ValType
// ===========================================================================

/// WebAssembly value types.
/// 
/// Matches `ValType` in `WasmABI.Types`.
pub type ValType {
  /// I32 (tag 0).
  I32
  /// I64 (tag 1).
  I64
  /// F32 (tag 2).
  F32
  /// F64 (tag 3).
  F64
  /// V128 (tag 4).
  V128
  /// FuncRef (tag 5).
  FuncRef
  /// ExternRef (tag 6).
  ExternRef
}

/// Convert a `ValType` to its C-ABI tag value.
pub fn val_type_to_int(value: ValType) -> Int {
  case value {
    I32 -> 0
    I64 -> 1
    F32 -> 2
    F64 -> 3
    V128 -> 4
    FuncRef -> 5
    ExternRef -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn val_type_from_int(tag: Int) -> Result(ValType, Nil) {
  case tag {
    0 -> Ok(I32)
    1 -> Ok(I64)
    2 -> Ok(F32)
    3 -> Ok(F64)
    4 -> Ok(V128)
    5 -> Ok(FuncRef)
    6 -> Ok(ExternRef)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ExternKind
// ===========================================================================

/// WebAssembly external kinds.
/// 
/// Matches `ExternKind` in `WasmABI.Types`.
pub type ExternKind {
  /// Function (tag 0).
  FuncExtern
  /// Table (tag 1).
  TableExtern
  /// Memory (tag 2).
  MemExtern
  /// Global (tag 3).
  GlobalExtern
}

/// Convert a `ExternKind` to its C-ABI tag value.
pub fn extern_kind_to_int(value: ExternKind) -> Int {
  case value {
    FuncExtern -> 0
    TableExtern -> 1
    MemExtern -> 2
    GlobalExtern -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn extern_kind_from_int(tag: Int) -> Result(ExternKind, Nil) {
  case tag {
    0 -> Ok(FuncExtern)
    1 -> Ok(TableExtern)
    2 -> Ok(MemExtern)
    3 -> Ok(GlobalExtern)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Mutability
// ===========================================================================

/// WebAssembly global mutability.
/// 
/// Matches `Mutability` in `WasmABI.Types`.
pub type Mutability {
  /// Immutable (tag 0).
  Immutable
  /// Mutable (tag 1).
  Mutable
}

/// Convert a `Mutability` to its C-ABI tag value.
pub fn mutability_to_int(value: Mutability) -> Int {
  case value {
    Immutable -> 0
    Mutable -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn mutability_from_int(tag: Int) -> Result(Mutability, Nil) {
  case tag {
    0 -> Ok(Immutable)
    1 -> Ok(Mutable)
    _ -> Error(Nil)
  }
}

