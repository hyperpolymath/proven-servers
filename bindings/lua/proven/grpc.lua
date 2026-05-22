-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.grpc
--- gRPC/HTTP2 protocol bindings for proven-servers.
---
--- Mirrors the Idris2 modules `GRPC.Types`, `GRPCABI.Layout`, and
--- `GRPCABI.Transitions`. Status codes match the gRPC specification.
--- Stream states model RFC 7540 Section 5.1.
---
--- @see protocols/proven-grpc/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- StatusCode (GRPC.Types.StatusCode, tags 0-16)
---------------------------------------------------------------------------

--- gRPC status codes per the gRPC specification.
--- @table StatusCode
M.StatusCode = {
  OK                  = 0,
  CANCELLED           = 1,
  UNKNOWN             = 2,
  INVALID_ARGUMENT    = 3,
  DEADLINE_EXCEEDED   = 4,
  NOT_FOUND           = 5,
  ALREADY_EXISTS      = 6,
  PERMISSION_DENIED   = 7,
  RESOURCE_EXHAUSTED  = 8,
  FAILED_PRECONDITION = 9,
  ABORTED             = 10,
  OUT_OF_RANGE        = 11,
  UNIMPLEMENTED       = 12,
  INTERNAL            = 13,
  UNAVAILABLE         = 14,
  DATA_LOSS           = 15,
  UNAUTHENTICATED     = 16,
}

--- Reverse lookup: code -> name.
M.StatusCodeName = {
  [0]  = "OK",           [1]  = "CANCELLED",        [2]  = "UNKNOWN",
  [3]  = "INVALID_ARGUMENT", [4] = "DEADLINE_EXCEEDED", [5] = "NOT_FOUND",
  [6]  = "ALREADY_EXISTS", [7] = "PERMISSION_DENIED", [8] = "RESOURCE_EXHAUSTED",
  [9]  = "FAILED_PRECONDITION", [10] = "ABORTED", [11] = "OUT_OF_RANGE",
  [12] = "UNIMPLEMENTED", [13] = "INTERNAL", [14] = "UNAVAILABLE",
  [15] = "DATA_LOSS", [16] = "UNAUTHENTICATED",
}

---------------------------------------------------------------------------
-- StreamType (GRPC.Types.StreamType, tags 0-3)
---------------------------------------------------------------------------

--- gRPC stream types.
--- @table StreamType
M.StreamType = {
  UNARY            = 0,
  SERVER_STREAMING = 1,
  CLIENT_STREAMING = 2,
  BIDI_STREAMING   = 3,
}

---------------------------------------------------------------------------
-- StreamState (GRPCABI.Layout, RFC 7540 Section 5.1, tags 0-6)
---------------------------------------------------------------------------

--- HTTP/2 stream states.
--- @table StreamState
M.StreamState = {
  IDLE             = 0,
  RESERVED_LOCAL   = 1,
  RESERVED_REMOTE  = 2,
  OPEN             = 3,
  HALF_CLOSED_LOCAL  = 4,
  HALF_CLOSED_REMOTE = 5,
  CLOSED           = 6,
}

--- Reverse lookup: tag -> name.
M.StreamStateName = {
  [0] = "IDLE", [1] = "RESERVED_LOCAL", [2] = "RESERVED_REMOTE",
  [3] = "OPEN", [4] = "HALF_CLOSED_LOCAL", [5] = "HALF_CLOSED_REMOTE",
  [6] = "CLOSED",
}

---------------------------------------------------------------------------
-- Compression (GRPC.Types, tags 0-3)
---------------------------------------------------------------------------

--- gRPC compression algorithms.
--- @table Compression
M.Compression = {
  NONE    = 0,
  GZIP    = 1,
  DEFLATE = 2,
  SNAPPY  = 3,
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- gRPC context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new gRPC context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.grpc_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("grpc.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.grpc_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Get the current stream state tag.
--- @return number  Stream state tag (0-6), see `M.StreamState`.
function Context:get_stream_state()
  local lib = ffi_mod.get_lib()
  return lib.grpc_get_stream_state(self._slot)
end

--- Set the gRPC response status.
--- @param status_tag number  Status code (0-16), see `M.StatusCode`.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:set_status(status_tag)
  local lib = ffi_mod.get_lib()
  return err_mod.from_param_status(lib.grpc_set_status(self._slot, status_tag))
end

--- Send a gRPC message.
--- @param data string  Serialised protobuf message bytes.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:send_message(data)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", data)
  return err_mod.from_status(lib.grpc_send_message(self._slot, buf, #data))
end

Context.__gc = Context.destroy

M.Context = Context

return M
