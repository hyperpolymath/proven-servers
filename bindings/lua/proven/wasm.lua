-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WASM protocol types for proven-servers.

local M = {}

--- ValType matching the Idris2 ABI tags.
M.ValType = {
    I32 = 0,
    I64 = 1,
    F32 = 2,
    F64 = 3,
    V128 = 4,
    FUNC_REF = 5,
    EXTERN_REF = 6,
}

--- ExternKind matching the Idris2 ABI tags.
M.ExternKind = {
    FUNC_EXTERN = 0,
    TABLE_EXTERN = 1,
    MEM_EXTERN = 2,
    GLOBAL_EXTERN = 3,
}

--- Mutability matching the Idris2 ABI tags.
M.Mutability = {
    IMMUTABLE = 0,
    MUTABLE = 1,
}

return M
