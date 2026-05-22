-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- RTSPABI.Foreign: Foreign function declarations for the RTSP C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (RTSPSessionContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function rtsp_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module RTSPABI.Foreign

import RTSP.Types
import RTSPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an RTSP session context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via rtsp_create() and destroyed via
||| rtsp_destroy().
export
data RTSPSessionContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's rtsp_abi_version() function MUST return
||| this exact value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/rtsp.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | rtsp_abi_version              | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | rtsp_create                   | (transport: u8) -> c_int                 |
-- |                               | Creates a new session in Init state.     |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | rtsp_destroy                  | (slot: c_int) -> void                    |
-- |                               | Frees the session context.               |
-- +-------------------------------+------------------------------------------+
-- | rtsp_get_state                | (slot: c_int) -> u8                      |
-- |                               | Returns the SessionState tag.            |
-- |                               | Returns Init (0) if slot invalid.        |
-- +-------------------------------+------------------------------------------+
-- | rtsp_get_transport            | (slot: c_int) -> u8                      |
-- |                               | Returns the TransportProtocol tag.       |
-- +-------------------------------+------------------------------------------+
-- | rtsp_transition               | (slot: c_int, new_state: u8)             |
-- |                               |  -> u8 (RTSPError tag)                   |
-- |                               | Advance session to new_state.            |
-- +-------------------------------+------------------------------------------+
-- | rtsp_execute_method           | (slot: c_int, method: u8)                |
-- |                               |  -> u8 (RTSPError tag)                   |
-- |                               | Execute an RTSP method.                  |
-- +-------------------------------+------------------------------------------+
-- | rtsp_get_method_count         | (slot: c_int) -> u32                     |
-- |                               | Returns number of methods executed.      |
-- +-------------------------------+------------------------------------------+
-- | rtsp_get_last_status          | (slot: c_int) -> u8                      |
-- |                               | Returns the last StatusCode tag.         |
-- +-------------------------------+------------------------------------------+
-- | rtsp_get_last_error           | (slot: c_int) -> u8                      |
-- |                               | Returns the last RTSPError tag,          |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | rtsp_can_transition           | (from: u8, to: u8) -> u8                 |
-- |                               | Returns 1 if transition is valid.        |
-- +-------------------------------+------------------------------------------+
