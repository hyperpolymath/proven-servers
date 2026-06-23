-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ModbusABI.Foreign: Foreign function declarations for the Modbus C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/modbus.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected gateway session pool
--   - Per-session register file (coils, discrete inputs, holding, input)
--   - Per-session transaction tracking (max 32 pending)
--   - Modbus TCP/RTU gateway lifecycle
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ModbusABI.Types exactly.

module ModbusABI.Foreign

import ModbusABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Modbus gateway session.
||| Created by modbus_create(), destroyed by modbus_destroy().
export
data ModbusContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match modbus_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | modbus_abi_version          | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | modbus_create               | (unit_id: u8, role: u8)                   |
-- |                             |  -> c_int (slot). Returns -1 on failure.  |
-- +-----------------------------+-------------------------------------------+
-- | modbus_destroy              | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | modbus_state                | (slot: c_int) -> u8 (GatewayState tag)    |
-- +-----------------------------+-------------------------------------------+
-- | modbus_listen               | (slot: c_int, port: u16)                  |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions Idle -> Listening.            |
-- +-----------------------------+-------------------------------------------+
-- | modbus_read_coils           | (slot: c_int, addr: u16, count: u16)      |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions Listening -> Processing.      |
-- +-----------------------------+-------------------------------------------+
-- | modbus_read_holding         | (slot: c_int, addr: u16, count: u16)      |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | modbus_write_coil           | (slot: c_int, addr: u16, value: u8)       |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | modbus_write_register       | (slot: c_int, addr: u16, value: u16)      |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | modbus_complete_transaction | (slot: c_int, txn_id: u32)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | May transition Processing -> Listening.   |
-- +-----------------------------+-------------------------------------------+
-- | modbus_report_error         | (slot: c_int, exc_code: u8)               |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions to Error state.               |
-- +-----------------------------+-------------------------------------------+
-- | modbus_recover              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Error -> Listening.           |
-- +-----------------------------+-------------------------------------------+
-- | modbus_pending_count        | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | modbus_get_coil             | (slot: c_int, addr: u16) -> u8 (value)    |
-- +-----------------------------+-------------------------------------------+
-- | modbus_get_register         | (slot: c_int, addr: u16) -> u16 (value)   |
-- +-----------------------------+-------------------------------------------+
-- | modbus_stop                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Stopping.                  |
-- +-----------------------------+-------------------------------------------+
-- | modbus_cleanup              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Stopping -> Idle.             |
-- +-----------------------------+-------------------------------------------+
-- | modbus_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
