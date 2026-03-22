-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TLS protocol types for proven-servers.

local M = {}

--- TlsState matching the Idris2 ABI tags.
M.TlsState = {
    TLS_IDLE = 0,
    TLS_CLIENT_HELLO = 1,
    TLS_SERVER_HELLO = 2,
    TLS_NEGOTIATING = 3,
    TLS_ESTABLISHED = 4,
    TLS_RENEGOTIATING = 5,
    TLS_SHUTDOWN = 6,
}

--- TlsVersion matching the Idris2 ABI tags.
M.TlsVersion = {
    TLS12 = 0,
    TLS13 = 1,
}

--- CipherSuite matching the Idris2 ABI tags.
M.CipherSuite = {
    AES_GCM128_SHA256 = 0,
    AES_GCM256_SHA384 = 1,
    CHACHA20_POLY1305_SHA256 = 2,
    AES_CCM128_SHA256 = 3,
}

return M
