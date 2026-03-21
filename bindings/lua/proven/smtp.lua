-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.smtp
--- SMTP protocol bindings for proven-servers.
---
--- Mirrors the Idris2 module `SmtpABI.Types`. Tag values match the ABI
--- definitions for `SmtpCommand`, `SmtpSessionState`, `ReplyCategory`,
--- `AuthMechanism`, and `SmtpExtension`.
---
--- @see protocols/proven-smtp/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- SMTP Constants
---------------------------------------------------------------------------

--- Standard SMTP port (RFC 5321).
M.SMTP_PORT = 25

--- SMTP submission port (RFC 6409).
M.SUBMISSION_PORT = 587

--- SMTPS (implicit TLS) port.
M.SMTPS_PORT = 465

---------------------------------------------------------------------------
-- SmtpCommand (tags 0-11)
---------------------------------------------------------------------------

--- SMTP protocol commands (RFC 5321).
--- @table SmtpCommand
M.SmtpCommand = {
  HELO      = 0,
  EHLO      = 1,
  MAIL_FROM = 2,
  RCPT_TO   = 3,
  DATA      = 4,
  QUIT      = 5,
  RSET      = 6,
  NOOP      = 7,
  VRFY      = 8,
  EXPN      = 9,
  AUTH      = 10,
  STARTTLS  = 11,
}

--- Reverse lookup: tag -> command name.
M.SmtpCommandName = {
  [0] = "HELO", [1] = "EHLO", [2] = "MAIL FROM", [3] = "RCPT TO",
  [4] = "DATA", [5] = "QUIT", [6] = "RSET", [7] = "NOOP",
  [8] = "VRFY", [9] = "EXPN", [10] = "AUTH", [11] = "STARTTLS",
}

---------------------------------------------------------------------------
-- SmtpSessionState (tags 0-8)
---------------------------------------------------------------------------

--- SMTP session state machine.
--- @table SessionState
M.SessionState = {
  CONNECTED     = 0,
  GREETED       = 1,
  MAIL_STARTED  = 2,
  RCPT_ADDED    = 3,
  DATA_MODE     = 4,
  DATA_DONE     = 5,
  AUTH_STARTED   = 6,
  AUTH_COMPLETE  = 7,
  QUIT_SENT     = 8,
}

---------------------------------------------------------------------------
-- AuthMechanism (tags 0-3)
---------------------------------------------------------------------------

--- SASL authentication mechanisms.
--- @table AuthMechanism
M.AuthMechanism = {
  PLAIN    = 0,
  LOGIN    = 1,
  CRAM_MD5 = 2,
  XOAUTH2  = 3,
}

---------------------------------------------------------------------------
-- SmtpExtension (tags 0-6)
---------------------------------------------------------------------------

--- ESMTP extensions.
--- @table SmtpExtension
M.SmtpExtension = {
  EIGHT_BITMIME = 0,
  PIPELINING    = 1,
  SIZE          = 2,
  STARTTLS      = 3,
  AUTH          = 4,
  CHUNKING      = 5,
  DSN           = 6,
}

---------------------------------------------------------------------------
-- ReplyCategory (tags 0-3)
---------------------------------------------------------------------------

--- SMTP reply severity categories.
--- @table ReplyCategory
M.ReplyCategory = {
  POSITIVE_COMPLETION  = 0,
  POSITIVE_INTERMEDIATE = 1,
  NEGATIVE_TRANSIENT   = 2,
  NEGATIVE_PERMANENT   = 3,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- SMTP context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new SMTP context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.smtp_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("smtp.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.smtp_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse an SMTP command from raw bytes.
--- @param data string  Raw SMTP command line.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_command(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.smtp_parse_command(self._slot, buf, #data))
end

--- Get the parsed SMTP command tag.
--- @return number  Command tag (0-11), see `M.SmtpCommand`.
function Context:get_command()
  local lib = ffi_mod.get_lib()
  return lib.smtp_get_command(self._slot)
end

--- Get the current session state tag.
--- @return number  State tag (0-8), see `M.SessionState`.
function Context:get_state()
  local lib = ffi_mod.get_lib()
  return lib.smtp_get_state(self._slot)
end

--- Set the reply code and message.
--- @param code number  SMTP reply code (e.g. 250, 354, 550).
--- @param message string  Reply message text.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_reply(code, message)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", message)
  return err_mod.from_status(lib.smtp_set_reply(self._slot, code, buf, #message))
end

--- Send the constructed reply.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_reply()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.smtp_send_reply(self._slot))
end

Context.__gc = Context.destroy

M.Context = Context

return M
