-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- File Server protocol types for proven-servers.

local M = {}

--- FileOperation matching the Idris2 ABI tags.
M.FileOperation = {
    READ = 0,
    WRITE = 1,
    CREATE = 2,
    DELETE = 3,
    RENAME = 4,
    LIST = 5,
    STAT = 6,
    LOCK = 7,
    UNLOCK = 8,
    WATCH = 9,
}

--- FileType matching the Idris2 ABI tags.
M.FileType = {
    REGULAR = 0,
    DIRECTORY = 1,
    SYMLINK = 2,
    BLOCK_DEVICE = 3,
    CHAR_DEVICE = 4,
    FIFO = 5,
    SOCKET = 6,
}

--- FilePermission matching the Idris2 ABI tags.
M.FilePermission = {
    OWNER_READ = 0,
    OWNER_WRITE = 1,
    OWNER_EXECUTE = 2,
    GROUP_READ = 3,
    GROUP_WRITE = 4,
    GROUP_EXECUTE = 5,
    OTHER_READ = 6,
    OTHER_WRITE = 7,
    OTHER_EXECUTE = 8,
}

--- LockType matching the Idris2 ABI tags.
M.LockType = {
    SHARED = 0,
    EXCLUSIVE = 1,
    ADVISORY = 2,
    MANDATORY = 3,
}

--- FileErrorCode matching the Idris2 ABI tags.
M.FileErrorCode = {
    NOT_FOUND = 0,
    PERMISSION_DENIED = 1,
    ALREADY_EXISTS = 2,
    NOT_EMPTY = 3,
    IS_DIRECTORY = 4,
    NOT_DIRECTORY = 5,
    NO_SPACE = 6,
    READ_ONLY = 7,
    LOCKED = 8,
    IO_ERROR = 9,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    CONNECTED = 1,
    OPERATING = 2,
    FS_LOCKED = 3,
    DISCONNECTING = 4,
}

return M
