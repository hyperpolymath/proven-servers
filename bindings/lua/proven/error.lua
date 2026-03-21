-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
--- @module proven.error
--- Shared error handling for proven-servers Lua bindings.
---
--- Provides a unified error type mirroring the Rust `ProvenError` enum and
--- the Idris2 `Result` type from `src/abi/Types.idr`. All protocol wrappers
--- use these utilities for consistent error reporting.

local M = {}

--- Error code constants matching the Idris2 ABI `Result` type.
--- @table ResultCode
--- @field OK             Operation succeeded (0).
--- @field ERROR          Generic error (1).
--- @field INVALID_PARAM  Invalid parameter provided (2).
--- @field OUT_OF_MEMORY  Out of memory (3).
--- @field NULL_POINTER   Null pointer encountered (4).
M.ResultCode = {
  OK            = 0,
  ERROR         = 1,
  INVALID_PARAM = 2,
  OUT_OF_MEMORY = 3,
  NULL_POINTER  = 4,
}

--- Reverse lookup table: integer code -> string name.
local result_names = {
  [0] = "OK",
  [1] = "ERROR",
  [2] = "INVALID_PARAM",
  [3] = "OUT_OF_MEMORY",
  [4] = "NULL_POINTER",
}

--- Extended error codes for FFI pool operations, matching the Rust
--- `ProvenError` enum used across all protocol FFI wrappers.
--- @table ProvenError
--- @field POOL_EXHAUSTED   No free context slots in the 64-slot pool (-1).
--- @field INVALID_SLOT     Slot index invalid or context not active.
--- @field INVALID_STATE    Wrong lifecycle state for requested transition.
--- @field INVALID_PARAMETER Parameter outside valid ABI tag range.
--- @field CAPACITY_EXCEEDED Fixed-size buffer or array limit exceeded.
--- @field VALIDATION_FAILED Input validation failed.
M.ProvenError = {
  POOL_EXHAUSTED    = "pool_exhausted",
  INVALID_SLOT      = "invalid_slot",
  INVALID_STATE     = "invalid_state",
  INVALID_PARAMETER = "invalid_parameter",
  CAPACITY_EXCEEDED = "capacity_exceeded",
  VALIDATION_FAILED = "validation_failed",
}

--- Human-readable descriptions for each error variant.
local error_descriptions = {
  pool_exhausted    = "context pool exhausted (64-slot limit)",
  invalid_slot      = "invalid or inactive context slot",
  invalid_state     = "operation rejected: wrong lifecycle state",
  invalid_parameter = "parameter value outside valid ABI tag range",
  capacity_exceeded = "fixed-size buffer or array capacity exceeded",
  validation_failed = "input validation failed",
}

--- Convert a ResultCode integer to its string name.
--- @param code number  An integer result code (0-4).
--- @return string|nil  The name, or nil if the code is unknown.
function M.result_name(code)
  return result_names[code]
end

--- Get a human-readable description for a ProvenError string key.
--- @param err_key string  One of the ProvenError values.
--- @return string  A descriptive error message.
function M.describe(err_key)
  return error_descriptions[err_key] or ("unknown error: " .. tostring(err_key))
end

--- Interpret a slot-returning FFI call.
--- Returns the slot index on success, or nil + error string on failure.
--- @param raw number  The raw c_int return value from the FFI.
--- @return number|nil  Slot index (>= 0) on success.
--- @return string|nil  Error key on failure.
function M.from_slot(raw)
  if raw >= 0 then
    return raw, nil
  end
  return nil, M.ProvenError.POOL_EXHAUSTED
end

--- Interpret a status-returning FFI call (0 = success).
--- Returns true on success, or nil + error string on failure.
--- @param raw number  The raw u8 return value from the FFI.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function M.from_status(raw)
  if raw == 0 then
    return true, nil
  elseif raw == 1 then
    return nil, M.ProvenError.INVALID_STATE
  elseif raw == 2 then
    return nil, M.ProvenError.VALIDATION_FAILED
  end
  return nil, "unknown_error_" .. tostring(raw)
end

--- Interpret a parameter-status FFI call (0 = success, 1 = invalid param).
--- @param raw number  The raw u8 return value from the FFI.
--- @return boolean|nil  true on success.
--- @return string|nil  Error key on failure.
function M.from_param_status(raw)
  if raw == 0 then
    return true, nil
  elseif raw == 1 then
    return nil, M.ProvenError.INVALID_PARAMETER
  end
  return nil, "unknown_error_" .. tostring(raw)
end

--- Raise a Lua error with a formatted proven-servers error message.
--- @param context string  Calling context (e.g. "httpd.parse_request").
--- @param err_key string  One of the ProvenError values.
function M.raise(context, err_key)
  error(string.format("proven-servers [%s]: %s", context, M.describe(err_key)), 2)
end

return M
