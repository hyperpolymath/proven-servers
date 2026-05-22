-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OSPFABI.Foreign: Foreign function declarations for the OSPF C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (NeighborContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function ospf_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module OSPFABI.Foreign

import OSPF.Types
import OSPFABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an OSPF neighbor context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via ospf_create() and destroyed via
||| ospf_destroy().
export
data NeighborContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's ospf_abi_version() function MUST return
||| this exact value.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Types.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/ospf.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | ospf_abi_version              | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | ospf_create                   | (area_type: u8) -> c_int                 |
-- |                               | Creates a new neighbor in Down state.    |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | ospf_destroy                  | (slot: c_int) -> void                    |
-- |                               | Frees the neighbor context.              |
-- +-------------------------------+------------------------------------------+
-- | ospf_get_state                | (slot: c_int) -> u8                      |
-- |                               | Returns the NeighborState tag.           |
-- |                               | Returns Down (0) if slot invalid.        |
-- +-------------------------------+------------------------------------------+
-- | ospf_get_area_type            | (slot: c_int) -> u8                      |
-- |                               | Returns the AreaType tag.                |
-- |                               | Returns Normal (0) if slot invalid.      |
-- +-------------------------------+------------------------------------------+
-- | ospf_transition               | (slot: c_int, new_state: u8)             |
-- |                               |  -> u8 (OSPFError tag)                   |
-- |                               | Advance neighbor to new_state.           |
-- +-------------------------------+------------------------------------------+
-- | ospf_send_packet              | (slot: c_int, packet_type: u8)           |
-- |                               |  -> u8 (OSPFError tag)                   |
-- |                               | Record sending a packet.                 |
-- +-------------------------------+------------------------------------------+
-- | ospf_get_lsa_count            | (slot: c_int) -> u32                     |
-- |                               | Returns count of LSAs in database.       |
-- +-------------------------------+------------------------------------------+
-- | ospf_add_lsa                  | (slot: c_int, lsa_type: u8)              |
-- |                               |  -> u8 (OSPFError tag)                   |
-- |                               | Add an LSA to the database.              |
-- +-------------------------------+------------------------------------------+
-- | ospf_get_packet_count         | (slot: c_int) -> u32                     |
-- |                               | Returns number of packets sent.          |
-- +-------------------------------+------------------------------------------+
-- | ospf_get_last_error           | (slot: c_int) -> u8                      |
-- |                               | Returns the last OSPFError tag,          |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | ospf_can_transition           | (from: u8, to: u8) -> u8                 |
-- |                               | Returns 1 if transition is valid.        |
-- +-------------------------------+------------------------------------------+
