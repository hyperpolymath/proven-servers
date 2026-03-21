-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CLIABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/cli.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot CLI parser context pool
--   - Per-context option registration and argument parsing
--   - Subcommand resolution with depth tracking
--   - Parse error tracking and retrieval
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CLIABI.Types exactly.

module CLIABI.Foreign

import CLIABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CLI parser context.
||| Created by cli_create(), destroyed by cli_destroy().
export
data CLIContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match cli_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +---------------------------+-----------------------------------------------+
-- | Function                  | Signature                                     |
-- +---------------------------+-----------------------------------------------+
-- | cli_abi_version           | () -> u32                                     |
-- |                           | Returns ABI version (must equal abiVersion).  |
-- +---------------------------+-----------------------------------------------+
-- | cli_create                | (max_args: u16, max_depth: u8)                |
-- |                           |   -> c_int (slot)                             |
-- |                           | Creates a CLI context. Returns -1 on failure. |
-- +---------------------------+-----------------------------------------------+
-- | cli_destroy               | (slot: c_int) -> void                         |
-- |                           | Releases a context slot.                      |
-- +---------------------------+-----------------------------------------------+
-- | cli_register_option       | (slot: c_int, arg_type: u8,                   |
-- |                           |  required: u8) -> u8                          |
-- |                           | Register an option. Returns 0 on success,     |
-- |                           | 1 on invalid slot/type, 2 on capacity full.   |
-- +---------------------------+-----------------------------------------------+
-- | cli_option_count          | (slot: c_int) -> u16                          |
-- |                           | Returns the number of registered options.     |
-- +---------------------------+-----------------------------------------------+
-- | cli_parse_arg             | (slot: c_int, arg_type: u8) -> u8             |
-- |                           | Parse an argument of the given type.          |
-- |                           | Returns ParseResult tag (0=ok, 1=error).      |
-- +---------------------------+-----------------------------------------------+
-- | cli_last_error            | (slot: c_int) -> u8 (ParseErrorTag)           |
-- |                           | Returns the last parse error tag.             |
-- +---------------------------+-----------------------------------------------+
-- | cli_push_subcommand       | (slot: c_int) -> u8                           |
-- |                           | Enter a subcommand level. Returns 0 on        |
-- |                           | success, 1 if max depth exceeded.             |
-- +---------------------------+-----------------------------------------------+
-- | cli_pop_subcommand        | (slot: c_int) -> u8                           |
-- |                           | Exit a subcommand level. Returns 0 on         |
-- |                           | success, 1 if already at root.                |
-- +---------------------------+-----------------------------------------------+
-- | cli_current_depth         | (slot: c_int) -> u8                           |
-- |                           | Returns the current subcommand depth.         |
-- +---------------------------+-----------------------------------------------+
-- | cli_max_depth             | (slot: c_int) -> u8                           |
-- |                           | Returns the maximum subcommand depth.         |
-- +---------------------------+-----------------------------------------------+
-- | cli_reset                 | (slot: c_int) -> void                         |
-- |                           | Reset the parser context for re-use.          |
-- +---------------------------+-----------------------------------------------+
