-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SNMPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/snmp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SNMP session pool
--   - PDU construction and tracking
--   - Version negotiation
--   - Error status management
--   - OID variable binding count tracking
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SNMPABI.Types exactly.

module SNMPABI.Foreign

import SNMPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an SNMP session context.
||| Created by snmp_create(), destroyed by snmp_destroy().
export
data SNMPContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match snmp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | snmp_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | snmp_create                 | (version: u8) -> c_int                    |
-- |                             | Creates session in Idle state.            |
-- |                             | Returns slot (0-63) or -1 on failure.     |
-- +-----------------------------+-------------------------------------------+
-- | snmp_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | snmp_get_version            | (slot: c_int) -> u8 (Version tag)         |
-- |                             | Returns protocol version tag.             |
-- +-----------------------------+-------------------------------------------+
-- | snmp_get_error              | (slot: c_int) -> u8 (ErrorStatus tag)     |
-- |                             | Returns current error status tag.         |
-- +-----------------------------+-------------------------------------------+
-- | snmp_set_error              | (slot: c_int, err: u8) -> u8              |
-- |                             | Sets error status. Returns 0=ok, 1=fail.  |
-- +-----------------------------+-------------------------------------------+
-- | snmp_send_pdu               | (slot: c_int, pdu: u8) -> u8              |
-- |                             | Sends a PDU of given type.                |
-- |                             | Returns 0=ok, 1=fail.                     |
-- +-----------------------------+-------------------------------------------+
-- | snmp_get_pdu_count          | (slot: c_int) -> u32                      |
-- |                             | Returns number of PDUs sent.              |
-- +-----------------------------+-------------------------------------------+
-- | snmp_add_varbind            | (slot: c_int) -> u8                       |
-- |                             | Adds a variable binding.                  |
-- |                             | Returns 0=ok, 1=fail.                     |
-- +-----------------------------+-------------------------------------------+
-- | snmp_get_varbind_count      | (slot: c_int) -> u32                      |
-- |                             | Returns variable binding count.           |
-- +-----------------------------+-------------------------------------------+
-- | snmp_clear_varbinds         | (slot: c_int) -> void                     |
-- |                             | Resets variable binding count.            |
-- +-----------------------------+-------------------------------------------+
-- | snmp_get_last_pdu_type      | (slot: c_int) -> u8 (PDUType tag)         |
-- |                             | Returns last sent PDU type tag.           |
-- +-----------------------------+-------------------------------------------+
-- | snmp_set_version            | (slot: c_int, ver: u8) -> u8              |
-- |                             | Changes protocol version.                 |
-- |                             | Returns 0=ok, 1=fail.                     |
-- +-----------------------------+-------------------------------------------+
-- | snmp_can_send_pdu           | (version: u8, pdu: u8) -> u8              |
-- |                             | Stateless: checks if a PDU type is valid  |
-- |                             | for a given version. 1=yes, 0=no.         |
-- +-----------------------------+-------------------------------------------+
