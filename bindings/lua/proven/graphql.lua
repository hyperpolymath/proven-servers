-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.graphql
--- GraphQL protocol bindings for proven-servers.
---
--- Mirrors the Idris2 module `GraphQL.Types` which defines
--- `OperationType`, `TypeKind`, `DirectiveLocation`, and `ErrorCategory`.
---
--- @see protocols/proven-graphql/src/ for the Idris2 definitions.

local ffi_mod = require("proven.ffi")
local err_mod = require("proven.error")

local M = {}

---------------------------------------------------------------------------
-- OperationType (tags 0-2)
---------------------------------------------------------------------------

--- GraphQL root operation types.
--- @table OperationType
M.OperationType = {
  QUERY        = 0,
  MUTATION     = 1,
  SUBSCRIPTION = 2,
}

--- Reverse lookup: tag -> keyword string.
M.OperationTypeName = {
  [0] = "query", [1] = "mutation", [2] = "subscription",
}

---------------------------------------------------------------------------
-- TypeKind (__TypeKind introspection, tags 0-7)
---------------------------------------------------------------------------

--- GraphQL introspection type kinds.
--- @table TypeKind
M.TypeKind = {
  SCALAR       = 0,
  OBJECT       = 1,
  INTERFACE    = 2,
  UNION        = 3,
  ENUM         = 4,
  INPUT_OBJECT = 5,
  LIST         = 6,
  NON_NULL     = 7,
}

--- Reverse lookup: tag -> name.
M.TypeKindName = {
  [0] = "SCALAR", [1] = "OBJECT", [2] = "INTERFACE", [3] = "UNION",
  [4] = "ENUM", [5] = "INPUT_OBJECT", [6] = "LIST", [7] = "NON_NULL",
}

---------------------------------------------------------------------------
-- DirectiveLocation (tags 0-12)
---------------------------------------------------------------------------

--- GraphQL directive locations (executable and type system).
--- @table DirectiveLocation
M.DirectiveLocation = {
  -- Executable locations
  QUERY                  = 0,
  MUTATION               = 1,
  SUBSCRIPTION           = 2,
  FIELD                  = 3,
  FRAGMENT_DEFINITION    = 4,
  FRAGMENT_SPREAD        = 5,
  INLINE_FRAGMENT        = 6,
  -- Type system locations
  SCHEMA                 = 7,
  SCALAR                 = 8,
  OBJECT                 = 9,
  FIELD_DEFINITION       = 10,
  ARGUMENT_DEFINITION    = 11,
  ENUM_VALUE             = 12,
}

---------------------------------------------------------------------------
-- ErrorCategory (tags 0-4)
---------------------------------------------------------------------------

--- Structured GraphQL error classifications.
--- @table ErrorCategory
M.ErrorCategory = {
  SYNTAX     = 0,
  VALIDATION = 1,
  EXECUTION  = 2,
  INTERNAL   = 3,
  TRANSPORT  = 4,
}

--- Reverse lookup: tag -> name.
M.ErrorCategoryName = {
  [0] = "SYNTAX", [1] = "VALIDATION", [2] = "EXECUTION",
  [3] = "INTERNAL", [4] = "TRANSPORT",
}

---------------------------------------------------------------------------
-- Context (OOP wrapper)
---------------------------------------------------------------------------

--- GraphQL context wrapping a slot in the Zig FFI pool.
--- @type Context
local Context = {}
Context.__index = Context

--- Create a new GraphQL context.
--- @return Context  A new context, or raises on pool exhaustion.
function Context.new()
  local lib = ffi_mod.get_lib()
  local slot = lib.graphql_create_context()
  local s, e = err_mod.from_slot(slot)
  if not s then err_mod.raise("graphql.Context.new", e) end
  return setmetatable({ _slot = s, _destroyed = false }, Context)
end

--- Destroy the context.
function Context:destroy()
  if not self._destroyed then
    local lib = ffi_mod.get_lib()
    lib.graphql_destroy_context(self._slot)
    self._destroyed = true
  end
end

--- Parse a GraphQL query string.
--- @param query string  GraphQL query document.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:parse_query(query)
  local lib = ffi_mod.get_lib()
  local ffi = ffi_mod.ffi
  local buf = ffi.cast("const uint8_t *", query)
  return err_mod.from_status(lib.graphql_parse_query(self._slot, buf, #query))
end

--- Get the parsed operation type tag.
--- @return number  Operation type tag (0-2), see `M.OperationType`.
function Context:get_operation_type()
  local lib = ffi_mod.get_lib()
  return lib.graphql_get_operation_type(self._slot)
end

--- Validate the parsed query against a schema.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function Context:validate()
  local lib = ffi_mod.get_lib()
  return err_mod.from_status(lib.graphql_validate(self._slot))
end

Context.__gc = Context.destroy

M.Context = Context

return M
