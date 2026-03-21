-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.websocket
--- WebSocket protocol bindings for proven-servers.
---
--- Mirrors the Idris2 modules `WS.Opcode`, `WS.CloseCode`, and `WS.Frame`.
--- All numeric encodings match the wire values from RFC 6455.
---
--- @see protocols/proven-ws/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- Opcode (WS.Opcode, RFC 6455 Section 5.2)
---------------------------------------------------------------------------

--- WebSocket frame opcodes. Values are 4-bit wire codes.
--- @table Opcode
M.Opcode = {
  CONTINUATION = 0x0,
  TEXT         = 0x1,
  BINARY       = 0x2,
  CLOSE        = 0x8,
  PING         = 0x9,
  PONG         = 0xA,
}

--- Reverse lookup: nibble -> name.
M.OpcodeName = {
  [0x0] = "CONTINUATION", [0x1] = "TEXT", [0x2] = "BINARY",
  [0x8] = "CLOSE", [0x9] = "PING", [0xA] = "PONG",
}

--- Check whether an opcode is a control frame.
--- @param opcode number  Opcode nibble.
--- @return boolean  true if opcode >= 0x8.
function M.is_control(opcode)
  return opcode >= 0x8
end

--- Check whether an opcode is a data frame.
--- @param opcode number  Opcode nibble.
--- @return boolean  true if opcode < 0x8.
function M.is_data(opcode)
  return opcode < 0x8
end

---------------------------------------------------------------------------
-- CloseCode (WS.CloseCode, RFC 6455 Section 7.4)
---------------------------------------------------------------------------

--- WebSocket close status codes.
--- @table CloseCode
M.CloseCode = {
  NORMAL_CLOSURE    = 1000,
  GOING_AWAY        = 1001,
  PROTOCOL_ERROR    = 1002,
  UNSUPPORTED_DATA  = 1003,
  NO_STATUS_RECEIVED = 1005,
  ABNORMAL_CLOSURE  = 1006,
  INVALID_PAYLOAD   = 1007,
  POLICY_VIOLATION  = 1008,
  MESSAGE_TOO_BIG   = 1009,
  MANDATORY_EXT     = 1010,
  INTERNAL_ERROR    = 1011,
}

--- Reverse lookup: code -> name.
M.CloseCodeName = {
  [1000] = "NORMAL_CLOSURE",    [1001] = "GOING_AWAY",
  [1002] = "PROTOCOL_ERROR",    [1003] = "UNSUPPORTED_DATA",
  [1005] = "NO_STATUS_RECEIVED", [1006] = "ABNORMAL_CLOSURE",
  [1007] = "INVALID_PAYLOAD",   [1008] = "POLICY_VIOLATION",
  [1009] = "MESSAGE_TOO_BIG",   [1010] = "MANDATORY_EXT",
  [1011] = "INTERNAL_ERROR",
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- WebSocket context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new WebSocket context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.ws_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("websocket.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.ws_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse a WebSocket frame from raw bytes.
--- @param data string  Raw WebSocket frame bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_frame(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.ws_parse_frame(self._slot, buf, #data))
end

--- Get the opcode of the last parsed frame.
--- @return number  Opcode nibble, see `M.Opcode`.
function Context:get_opcode()
  local lib = ffi_mod.get_lib()
  return lib.ws_get_opcode(self._slot)
end

--- Send a WebSocket frame.
--- @param opcode number  Opcode nibble, see `M.Opcode`.
--- @param data string  Frame payload.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_frame(opcode, data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.ws_send_frame(self._slot, opcode, buf, #data))
end

--- Send a close frame with a status code.
--- @param code number  Close status code, see `M.CloseCode`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_close(code)
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.ws_send_close(self._slot, code))
end

Context.__gc = Context.destroy

M.Context = Context

return M
