-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.ftp
--- FTP protocol bindings for proven-servers.
---
--- Mirrors the Idris2 module `FtpABI.Types`. Tag values match the ABI
--- definitions for `SessionState`, `TransferType`, `DataMode`,
--- `TransferState`, `ReplyCategory`, and `Command`.
---
--- @see protocols/proven-ftp/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- FTP Constants
---------------------------------------------------------------------------

--- Standard FTP control port (RFC 959).
M.FTP_CONTROL_PORT = 21

--- Standard FTP data port (RFC 959).
M.FTP_DATA_PORT = 20

--- FTPS (implicit TLS) control port.
M.FTPS_PORT = 990

---------------------------------------------------------------------------
-- SessionState (tags 0-4)
---------------------------------------------------------------------------

--- FTP session state machine.
--- @table SessionState
M.SessionState = {
  CONNECTED     = 0,
  USER_OK       = 1,
  AUTHENTICATED = 2,
  RENAMING      = 3,
  QUIT          = 4,
}

--- Reverse lookup: tag -> state name.
M.SessionStateName = {
  [0] = "CONNECTED", [1] = "USER_OK", [2] = "AUTHENTICATED",
  [3] = "RENAMING", [4] = "QUIT",
}

---------------------------------------------------------------------------
-- TransferType (tags 0-1)
---------------------------------------------------------------------------

--- FTP data transfer types.
--- @table TransferType
M.TransferType = {
  ASCII  = 0,
  BINARY = 1,
}

---------------------------------------------------------------------------
-- DataMode (tags 0-1)
---------------------------------------------------------------------------

--- FTP data connection modes.
--- @table DataMode
M.DataMode = {
  ACTIVE  = 0,
  PASSIVE = 1,
}

---------------------------------------------------------------------------
-- TransferState (tags 0-3)
---------------------------------------------------------------------------

--- FTP file transfer state machine.
--- @table TransferState
M.TransferState = {
  IDLE        = 0,
  IN_PROGRESS = 1,
  COMPLETE    = 2,
  ABORTED     = 3,
}

---------------------------------------------------------------------------
-- Command (tags 0-22)
---------------------------------------------------------------------------

--- FTP commands (RFC 959).
--- @table Command
M.Command = {
  USER = 0,  PASS = 1,  ACCT = 2,  CWD  = 3,  CDUP = 4,
  QUIT = 5,  PORT = 6,  PASV = 7,  TYPE = 8,  RETR = 9,
  STOR = 10, APPE = 11, RNFR = 12, RNTO = 13, DELE = 14,
  RMD  = 15, MKD  = 16, PWD  = 17, LIST = 18, NLST = 19,
  SYST = 20, NOOP = 21, FEAT = 22,
}

--- Reverse lookup: tag -> command string.
M.CommandName = {
  [0]  = "USER", [1]  = "PASS", [2]  = "ACCT", [3]  = "CWD",
  [4]  = "CDUP", [5]  = "QUIT", [6]  = "PORT", [7]  = "PASV",
  [8]  = "TYPE", [9]  = "RETR", [10] = "STOR", [11] = "APPE",
  [12] = "RNFR", [13] = "RNTO", [14] = "DELE", [15] = "RMD",
  [16] = "MKD",  [17] = "PWD",  [18] = "LIST", [19] = "NLST",
  [20] = "SYST", [21] = "NOOP", [22] = "FEAT",
}

---------------------------------------------------------------------------
-- ReplyCategory (tags 0-4)
---------------------------------------------------------------------------

--- FTP reply categories (RFC 959 Section 4.2).
--- @table ReplyCategory
M.ReplyCategory = {
  POSITIVE_PRELIMINARY  = 0,
  POSITIVE_COMPLETION   = 1,
  POSITIVE_INTERMEDIATE = 2,
  NEGATIVE_TRANSIENT    = 3,
  NEGATIVE_PERMANENT    = 4,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- FTP context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new FTP context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.ftp_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("ftp.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.ftp_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse an FTP command from raw bytes.
--- @param data string  Raw FTP command line.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_command(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.ftp_parse_command(self._slot, buf, #data))
end

--- Get the parsed FTP command tag.
--- @return number  Command tag (0-22), see `M.Command`.
function Context:get_command()
  local lib = ffi_mod.get_lib()
  return lib.ftp_get_command(self._slot)
end

--- Get the current session state tag.
--- @return number  State tag (0-4), see `M.SessionState`.
function Context:get_session_state()
  local lib = ffi_mod.get_lib()
  return lib.ftp_get_session_state(self._slot)
end

--- Set the reply code and message.
--- @param code number  FTP reply code (e.g. 220, 230, 550).
--- @param message string  Reply message text.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_reply(code, message)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", message)
  return err_mod.from_status(lib.ftp_set_reply(self._slot, code, buf, #message))
end

--- Send the constructed reply.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_reply()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.ftp_send_reply(self._slot))
end

Context.__gc = Context.destroy

M.Context = Context

return M
