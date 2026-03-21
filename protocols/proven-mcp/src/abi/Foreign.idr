-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- abi.Foreign: Foreign function declarations for the MCP C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/mcp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Per-session capability bitmask
--   - Per-session pending request tracking (max 32 in-flight)
--   - Tool/resource/prompt registry per session
--   - Transport selection per session
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching abi.Types exactly.

module abi.Foreign

import abi.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an MCP server session.
||| Created by mcp_create(), destroyed by mcp_destroy().
export
data McpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match mcp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | mcp_abi_version             | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | mcp_create                  | (transport: u8, name_ptr: ptr,            |
-- |                             |  name_len: u32) -> c_int (slot)           |
-- |                             | Creates session in Connecting state.      |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | mcp_destroy                 | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | mcp_state                   | (slot: c_int) -> u8 (SessionState tag)    |
-- |                             | Returns current session state.            |
-- +-----------------------------+-------------------------------------------+
-- | mcp_initialize              | (slot: c_int, caps_bitmask: u8)           |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions Connecting -> Ready.          |
-- +-----------------------------+-------------------------------------------+
-- | mcp_add_capability          | (slot: c_int, cap: u8)                    |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Adds a capability to the session.         |
-- +-----------------------------+-------------------------------------------+
-- | mcp_has_capability          | (slot: c_int, cap: u8) -> u8 (1/0)       |
-- +-----------------------------+-------------------------------------------+
-- | mcp_call_tool               | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32, req_id: u32)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions Ready -> Processing.          |
-- +-----------------------------+-------------------------------------------+
-- | mcp_complete_request        | (slot: c_int, req_id: u32)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | May transition Processing -> Ready.       |
-- +-----------------------------+-------------------------------------------+
-- | mcp_cancel_request          | (slot: c_int, req_id: u32)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | mcp_pending_count           | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | mcp_disconnect              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Disconnecting.             |
-- +-----------------------------+-------------------------------------------+
-- | mcp_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Disconnecting -> Idle.        |
-- +-----------------------------+-------------------------------------------+
-- | mcp_can_transition          | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks session state           |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | mcp_transport               | (slot: c_int) -> u8 (Transport tag)      |
-- |                             | Returns the transport for a session.      |
-- +-----------------------------+-------------------------------------------+
-- | mcp_ping                    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Sends a keepalive ping. Only valid from   |
-- |                             | Ready or Processing state.                |
-- +-----------------------------+-------------------------------------------+
