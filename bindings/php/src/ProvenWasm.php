<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ValType matching the Idris2 ABI tags. */
enum ValType: int
{
    case I32 = 0;
    case I64 = 1;
    case F32 = 2;
    case F64 = 3;
    case V128 = 4;
    case FuncRef = 5;
    case ExternRef = 6;
}

/** ExternKind matching the Idris2 ABI tags. */
enum ExternKind: int
{
    case FuncExtern = 0;
    case TableExtern = 1;
    case MemExtern = 2;
    case GlobalExtern = 3;
}

/** Mutability matching the Idris2 ABI tags. */
enum Mutability: int
{
    case Immutable = 0;
    case Mutable = 1;
}
