// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// WASM protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ValType represents the ValType type (Idris2 ABI tags).
type ValType uint8

const (
	ValTypeI32 ValType = iota
	ValTypeI64
	ValTypeF32
	ValTypeF64
	ValTypeV128
	ValTypeFuncRef
	ValTypeExternRef
)

// ExternKind represents the ExternKind type (Idris2 ABI tags).
type ExternKind uint8

const (
	ExternKindFuncExtern ExternKind = iota
	ExternKindTableExtern
	ExternKindMemExtern
	ExternKindGlobalExtern
)

// Mutability represents the Mutability type (Idris2 ABI tags).
type Mutability uint8

const (
	MutabilityImmutable Mutability = iota
	MutabilityMutable
)
