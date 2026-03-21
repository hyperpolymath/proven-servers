// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM Runtime types for the proven-servers ABI.
//
// Mirrors the Idris2 module WasmABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ValType (tags 0-6)
// ===========================================================================

/// WebAssembly value types.
type valType =
  | @as(0) I32
  | @as(1) I64
  | @as(2) F32
  | @as(3) F64
  | @as(4) V128
  | @as(5) FuncRef
  | @as(6) ExternRef

/// Decode from the C-ABI tag value.
let valTypeFromTag = (tag: int): option<valType> =>
  switch tag {
  | 0 => Some(I32)
  | 1 => Some(I64)
  | 2 => Some(F32)
  | 3 => Some(F64)
  | 4 => Some(V128)
  | 5 => Some(FuncRef)
  | 6 => Some(ExternRef)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let valTypeToTag = (v: valType): int =>
  switch v {
  | I32 => 0
  | I64 => 1
  | F32 => 2
  | F64 => 3
  | V128 => 4
  | FuncRef => 5
  | ExternRef => 6
  }

/// Whether this is a numeric type.
let valTypeIsNumeric = (v: valType): bool =>
  switch v {
  | I32 | I64 | F32 | F64 => true
  | _ => false
  }

/// Whether this is a reference type.
let valTypeIsReference = (v: valType): bool =>
  switch v {
  | FuncRef | ExternRef => true
  | _ => false
  }

// ===========================================================================
// ExternKind (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type externKind =
  | @as(0) FuncExtern
  | @as(1) TableExtern
  | @as(2) MemExtern
  | @as(3) GlobalExtern

/// Decode from the C-ABI tag value.
let externKindFromTag = (tag: int): option<externKind> =>
  switch tag {
  | 0 => Some(FuncExtern)
  | 1 => Some(TableExtern)
  | 2 => Some(MemExtern)
  | 3 => Some(GlobalExtern)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let externKindToTag = (v: externKind): int =>
  switch v {
  | FuncExtern => 0
  | TableExtern => 1
  | MemExtern => 2
  | GlobalExtern => 3
  }

// ===========================================================================
// Mutability (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type mutability =
  | @as(0) Immutable
  | @as(1) Mutable

/// Decode from the C-ABI tag value.
let mutabilityFromTag = (tag: int): option<mutability> =>
  switch tag {
  | 0 => Some(Immutable)
  | 1 => Some(Mutable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mutabilityToTag = (v: mutability): int =>
  switch v {
  | Immutable => 0
  | Mutable => 1
  }

