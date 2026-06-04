// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

/** ValType matching the Idris2 ABI tags. */
export const ValType = Object.freeze({
  I32: 0,
  I64: 1,
  F32: 2,
  F64: 3,
  V128: 4,
  FUNC_REF: 5,
  EXTERN_REF: 6,
});

/** ExternKind matching the Idris2 ABI tags. */
export const ExternKind = Object.freeze({
  FUNC_EXTERN: 0,
  TABLE_EXTERN: 1,
  MEM_EXTERN: 2,
  GLOBAL_EXTERN: 3,
});

/** Mutability matching the Idris2 ABI tags. */
export const Mutability = Object.freeze({
  IMMUTABLE: 0,
  MUTABLE: 1,
});
