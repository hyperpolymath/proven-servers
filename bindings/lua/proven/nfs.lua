-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NFS protocol types for proven-servers.

local M = {}

--- Operation matching the Idris2 ABI tags.
M.Operation = {
    OPERATION__ACCESS = 0,
    CLOSE = 1,
    COMMIT = 2,
    CREATE = 3,
    GET_ATTR = 4,
    OPERATION__LINK = 5,
    LOCK = 6,
    LOOKUP = 7,
    OPEN = 8,
    READ = 9,
    READ_DIR = 10,
    REMOVE = 11,
    RENAME = 12,
    SET_ATTR = 13,
    WRITE = 14,
}

--- FileType matching the Idris2 ABI tags.
M.FileType = {
    REGULAR = 0,
    DIRECTORY = 1,
    BLOCK_DEVICE = 2,
    CHAR_DEVICE = 3,
    FILE_TYPE__LINK = 4,
    SOCKET = 5,
    FIFO = 6,
}

--- Status matching the Idris2 ABI tags.
M.Status = {
    OK = 0,
    PERM = 1,
    NO_ENT = 2,
    IO = 3,
    NX_IO = 4,
    STATUS__ACCESS = 5,
    EXIST = 6,
    NOT_DIR = 7,
    IS_DIR = 8,
    F_BIG = 9,
    NO_SPC = 10,
    R_OFS = 11,
    NOT_EMPTY = 12,
    STALE = 13,
}

--- NfsState matching the Idris2 ABI tags.
M.NfsState = {
    IDLE = 0,
    MOUNTED = 1,
    FILE_OPEN = 2,
    LOCKED = 3,
    BUSY = 4,
    UNMOUNTING = 5,
}

return M
