-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WebDAV protocol types for proven-servers.

local M = {}

--- Method matching the Idris2 ABI tags.
M.Method = {
    PROPFIND = 0,
    PROPPATCH = 1,
    MKCOL = 2,
    COPY = 3,
    MOVE = 4,
    LOCK = 5,
    UNLOCK = 6,
}

--- StatusCode matching the Idris2 ABI tags.
M.StatusCode = {
    MULTI_STATUS = 0,
    UNPROCESSABLE_ENTITY = 1,
    LOCKED = 2,
    FAILED_DEPENDENCY = 3,
    INSUFFICIENT_STORAGE = 4,
}

--- LockScope matching the Idris2 ABI tags.
M.LockScope = {
    EXCLUSIVE = 0,
    SHARED = 1,
}

--- LockType matching the Idris2 ABI tags.
M.LockType = {
    WRITE = 0,
}

--- Depth matching the Idris2 ABI tags.
M.Depth = {
    ZERO = 0,
    ONE = 1,
    INFINITY = 2,
}

--- PropertyOp matching the Idris2 ABI tags.
M.PropertyOp = {
    SET = 0,
    REMOVE = 1,
}

return M
