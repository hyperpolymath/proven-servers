-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.httpd
--- HTTP/1.1+ protocol bindings for proven-servers.
---
--- Mirrors the Idris2 modules `HTTP.Method`, `HTTP.Status`, `HTTPABI.Layout`,
--- and `HTTPABI.Transitions`. Tag values match `httpMethodToTag` and related
--- functions in the ABI exactly.
---
--- @see protocols/proven-httpd/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- HTTP Method (HTTPABI.Layout.HttpMethod, tags 0-8)
---------------------------------------------------------------------------

--- HTTP request methods (RFC 7231, RFC 5789).
--- Tag values match `httpMethodToTag` in `HTTPABI.Layout`.
--- @table Method
M.Method = {
  GET     = 0,
  POST    = 1,
  PUT     = 2,
  DELETE  = 3,
  PATCH   = 4,
  HEAD    = 5,
  OPTIONS = 6,
  TRACE   = 7,
  CONNECT = 8,
}

--- Reverse lookup: tag -> method name string.
M.MethodName = {
  [0] = "GET", [1] = "POST", [2] = "PUT", [3] = "DELETE", [4] = "PATCH",
  [5] = "HEAD", [6] = "OPTIONS", [7] = "TRACE", [8] = "CONNECT",
}

---------------------------------------------------------------------------
-- HTTP Version (HTTPABI.Layout, tags 0-2)
---------------------------------------------------------------------------

--- HTTP protocol versions.
--- @table Version
M.Version = {
  HTTP_1_0 = 0,
  HTTP_1_1 = 1,
  HTTP_2   = 2,
}

--- Reverse lookup: tag -> version string.
M.VersionName = {
  [0] = "HTTP/1.0", [1] = "HTTP/1.1", [2] = "HTTP/2",
}

---------------------------------------------------------------------------
-- HTTP Status Code Categories (HTTP.Status)
---------------------------------------------------------------------------

--- HTTP status code categories (RFC 7231).
--- @table StatusCategory
M.StatusCategory = {
  INFORMATIONAL = 0,
  SUCCESS       = 1,
  REDIRECTION   = 2,
  CLIENT_ERROR  = 3,
  SERVER_ERROR  = 4,
}

---------------------------------------------------------------------------
-- Request Phase (HTTPABI.Transitions, tags 0-5)
---------------------------------------------------------------------------

--- HTTP request lifecycle phases for the typestate pattern.
--- @table RequestPhase
M.RequestPhase = {
  IDLE      = 0,
  PARSING   = 1,
  PARSED    = 2,
  HANDLING  = 3,
  RESPONDED = 4,
  CLOSED    = 5,
}

--- Reverse lookup: tag -> phase name.
M.RequestPhaseName = {
  [0] = "IDLE", [1] = "PARSING", [2] = "PARSED",
  [3] = "HANDLING", [4] = "RESPONDED", [5] = "CLOSED",
}

---------------------------------------------------------------------------
-- Content Type (HTTPABI.Layout, tags 0-6)
---------------------------------------------------------------------------

--- Common HTTP content types.
--- @table ContentType
M.ContentType = {
  TEXT_PLAIN       = 0,
  TEXT_HTML        = 1,
  APPLICATION_JSON = 2,
  APPLICATION_XML  = 3,
  MULTIPART_FORM   = 4,
  URLENCODED       = 5,
  OCTET_STREAM     = 6,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper with metatable)
---------------------------------------------------------------------------

--- HTTP context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new HTTP context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.http_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then
    err_mod.raise("httpd.Context.new", e)
  end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context, releasing the slot back to the pool.
--- Safe to call multiple times.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.http_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse an HTTP request from raw bytes.
--- @param data string  Raw HTTP request data.
--- @return boolean  true if parsing completed successfully.
--- @return string|nil  Error key on failure.
function Context:parse_request(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  local result = lib.http_parse_request(self._slot, buf, #data)
  return err_mod.from_status(result)
end

--- Get the parsed HTTP method tag.
--- @return number  Method tag (0-8), see `M.Method`.
function Context:get_method()
  local lib = ffi_mod.get_lib()
  return lib.http_get_method(self._slot)
end

--- Get the current request phase tag.
--- @return number  Phase tag (0-5), see `M.RequestPhase`.
function Context:get_phase()
  local lib = ffi_mod.get_lib()
  return lib.http_get_phase(self._slot)
end

--- Get the HTTP version tag.
--- @return number  Version tag (0-2), see `M.Version`.
function Context:get_version()
  local lib = ffi_mod.get_lib()
  return lib.http_get_version(self._slot)
end

--- Set the response status code.
--- @param status_tag number  Status tag from the ABI.
--- @return boolean  true on success.
--- @return string|nil  Error key on failure.
function Context:set_status(status_tag)
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.http_set_status(self._slot, status_tag))
end

--- Send the constructed response.
--- @return boolean  true on success.
--- @return string|nil  Error key on failure.
function Context:send_response()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.http_send_response(self._slot))
end

--- Check whether the connection supports keep-alive.
--- @return boolean  true if keep-alive is possible.
function Context:keep_alive()
  local lib = ffi_mod.get_lib()
  return lib.http_keep_alive_check(self._slot) == 1
end

--- Reset the context for a new request on the same connection.
--- @return boolean  true on success.
--- @return string|nil  Error key on failure.
function Context:reset()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.http_reset_context(self._slot))
end

--- Garbage-collection hook: destroy the context if not already done.
Context.__gc = Context.destroy

M.Context = Context

return M
