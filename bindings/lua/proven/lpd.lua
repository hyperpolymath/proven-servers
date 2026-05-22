-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LPD protocol types for proven-servers.

local M = {}

--- CommandCode matching the Idris2 ABI tags.
M.CommandCode = {
    PRINT_JOB = 1,
    RECEIVE_JOB = 2,
    SHORT_QUEUE = 3,
    LONG_QUEUE = 4,
    REMOVE_JOBS = 5,
}

--- SubCommandCode matching the Idris2 ABI tags.
M.SubCommandCode = {
    ABORT_JOB = 1,
    CONTROL_FILE = 2,
    DATA_FILE = 3,
}

--- JobStatus matching the Idris2 ABI tags.
M.JobStatus = {
    PENDING = 0,
    PRINTING = 1,
    COMPLETE = 2,
    FAILED = 3,
}

return M
