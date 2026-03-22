-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TFTP protocol types for proven-servers.

local M = {}

--- Opcode matching the Idris2 ABI tags.
M.Opcode = {
    RRQ = 0,
    WRQ = 1,
    DATA = 2,
    ACK = 3,
    ERROR = 4,
}

--- TransferMode matching the Idris2 ABI tags.
M.TransferMode = {
    NET_ASCII = 0,
    OCTET = 1,
    MAIL = 2,
}

--- TftpError matching the Idris2 ABI tags.
M.TftpError = {
    NOT_DEFINED = 0,
    FILE_NOT_FOUND = 1,
    ACCESS_VIOLATION = 2,
    DISK_FULL = 3,
    ILLEGAL_OPERATION = 4,
    UNKNOWN_TID = 5,
    FILE_EXISTS = 6,
    NO_SUCH_USER = 7,
}

--- TransferState matching the Idris2 ABI tags.
M.TransferState = {
    IDLE = 0,
    READING = 1,
    WRITING = 2,
    IN_ERROR = 3,
    COMPLETE = 4,
}

return M
