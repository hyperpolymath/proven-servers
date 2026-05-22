-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- POP3ABI.Foreign: Foreign function declarations for the POP3 C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (SessionContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function pop3_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module POP3ABI.Foreign

import POP3.Types
import POP3ABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a POP3 session context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via pop3_create() and destroyed via
||| pop3_destroy().
export
data SessionContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's pop3_abi_version() function MUST return
||| this exact value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/pop3.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | pop3_abi_version              | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | pop3_create                   | () -> c_int                              |
-- |                               | Creates a new session in Authorization.  |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | pop3_destroy                  | (slot: c_int) -> void                    |
-- |                               | Frees the session context.               |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_state                | (slot: c_int) -> u8                      |
-- |                               | Returns the State tag.                   |
-- |                               | Returns Authorization (0) if invalid.    |
-- +-------------------------------+------------------------------------------+
-- | pop3_execute_command          | (slot: c_int, cmd: u8)                   |
-- |                               |  -> u8 (POP3Error tag)                   |
-- |                               | Execute a POP3 command.                  |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_message_count        | (slot: c_int) -> u32                     |
-- |                               | Returns count of messages.               |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_deleted_count        | (slot: c_int) -> u32                     |
-- |                               | Returns count of deleted messages.       |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_command_count        | (slot: c_int) -> u32                     |
-- |                               | Returns total commands executed.         |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_last_response        | (slot: c_int) -> u8                      |
-- |                               | Returns the last Response tag.           |
-- +-------------------------------+------------------------------------------+
-- | pop3_get_last_error           | (slot: c_int) -> u8                      |
-- |                               | Returns the last POP3Error tag,          |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | pop3_authenticate             | (slot: c_int) -> u8 (POP3Error tag)      |
-- |                               | Transition from Authorization to         |
-- |                               | Transaction state.                       |
-- +-------------------------------+------------------------------------------+
