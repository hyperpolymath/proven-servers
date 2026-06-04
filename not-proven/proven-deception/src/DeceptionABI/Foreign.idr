-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DeceptionABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/deception.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected server pool
--   - Decoy deployment per server (max 32 decoys per server)
--   - Alert tracking per server (max 64 alerts)
--   - Trigger event matching and alert priority assignment
--   - Response action execution per triggered decoy
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DeceptionABI.Types exactly.

module DeceptionABI.Foreign

import DeceptionABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a deception server instance.
||| Created by deception_create(), destroyed by deception_destroy().
export
data DeceptionContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match deception_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | deception_abi_version          | () -> u32                               |
-- |                                | Returns ABI version (must equal         |
-- |                                | abiVersion).                            |
-- +-------------------------------+-----------------------------------------+
-- | deception_create               | () -> c_int (slot)                      |
-- |                                | Creates server in Configured state.     |
-- |                                | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | deception_destroy              | (slot: c_int) -> void                   |
-- |                                | Releases a server slot.                 |
-- +-------------------------------+-----------------------------------------+
-- | deception_state                | (slot: c_int) -> u8 (ServerState tag)   |
-- |                                | Returns current server state.           |
-- +-------------------------------+-----------------------------------------+
-- | deception_deploy_decoy         | (slot: c_int,                           |
-- |                                |  name_ptr: ptr, name_len: u32,          |
-- |                                |  decoy_type: u8) -> u8 (0=ok, 1=rej)   |
-- |                                | Transitions Configured -> Monitoring.   |
-- +-------------------------------+-----------------------------------------+
-- | deception_remove_decoy         | (slot: c_int,                           |
-- |                                |  name_ptr: ptr, name_len: u32)          |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | May transition Monitoring -> Configured.|
-- +-------------------------------+-----------------------------------------+
-- | deception_decoy_count          | (slot: c_int) -> u32                    |
-- |                                | Returns number of deployed decoys.      |
-- +-------------------------------+-----------------------------------------+
-- | deception_trigger              | (slot: c_int,                           |
-- |                                |  name_ptr: ptr, name_len: u32,          |
-- |                                |  event: u8, priority: u8)               |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Transitions Monitoring -> Responding.   |
-- +-------------------------------+-----------------------------------------+
-- | deception_respond              | (slot: c_int,                           |
-- |                                |  name_ptr: ptr, name_len: u32,          |
-- |                                |  action: u8) -> u8 (0=ok, 1=rejected)  |
-- |                                | Executes response action on triggered   |
-- |                                | decoy. May return to Monitoring.        |
-- +-------------------------------+-----------------------------------------+
-- | deception_alert_count          | (slot: c_int) -> u32                    |
-- |                                | Returns total active alerts.            |
-- +-------------------------------+-----------------------------------------+
-- | deception_can_monitor          | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | deception_shutdown             | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions to Shutdown state.          |
-- +-------------------------------+-----------------------------------------+
-- | deception_cleanup              | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | deception_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                                | Stateless transition validity check.    |
-- +-------------------------------+-----------------------------------------+
