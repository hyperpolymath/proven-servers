-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTP protocol types for proven-servers.

local M = {}

--- LeapIndicator matching the Idris2 ABI tags.
M.LeapIndicator = {
    NO_WARNING = 0,
    LAST_MINUTE61 = 1,
    LAST_MINUTE59 = 2,
    UNSYNCHRONISED = 3,
}

--- NtpMode matching the Idris2 ABI tags.
M.NtpMode = {
    RESERVED = 0,
    SYMMETRIC_ACTIVE = 1,
    SYMMETRIC_PASSIVE = 2,
    CLIENT = 3,
    SERVER = 4,
    BROADCAST = 5,
    CONTROL_MESSAGE = 6,
    PRIVATE = 7,
}

--- ExchangeState matching the Idris2 ABI tags.
M.ExchangeState = {
    IDLE = 0,
    REQUEST_RECEIVED = 1,
    TIMESTAMP_CALCULATED = 2,
    RESPONSE_SENT = 3,
}

--- ClockDisciplineState matching the Idris2 ABI tags.
M.ClockDisciplineState = {
    UNSET = 0,
    SPIKE = 1,
    FREQ = 2,
    SYNC = 3,
    PANIC = 4,
}

--- KissCode matching the Idris2 ABI tags.
M.KissCode = {
    DENY = 0,
    RSTR = 1,
    RATE = 2,
    OTHER = 3,
}

--- NtpError matching the Idris2 ABI tags.
M.NtpError = {
    OK = 0,
    INVALID_SLOT = 1,
    NOT_ACTIVE = 2,
    INVALID_PACKET = 3,
    KISS_OF_DEATH = 4,
    STRATUM_TOO_HIGH = 5,
}

return M
