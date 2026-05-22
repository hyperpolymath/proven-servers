// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

namespace Proven;

/// <summary>ValType matching the Idris2 ABI tags (0-6).</summary>
public enum ValType : byte
{
    I32 = 0,
    I64 = 1,
    F32 = 2,
    F64 = 3,
    V128 = 4,
    FuncRef = 5,
    ExternRef = 6
}

/// <summary>ExternKind matching the Idris2 ABI tags (0-3).</summary>
public enum ExternKind : byte
{
    FuncExtern = 0,
    TableExtern = 1,
    MemExtern = 2,
    GlobalExtern = 3
}

/// <summary>Mutability matching the Idris2 ABI tags (0-1).</summary>
public enum Mutability : byte
{
    Immutable = 0,
    Mutable = 1
}
