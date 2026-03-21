-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BfdABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/bfd.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching BfdABI.Types exactly.

module BfdABI.Foreign

import BfdABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Bfd context.
||| Created by bfd_create*(), destroyed by bfd_destroy*().
export
data BfdContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match bfd_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (13 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | bfd_abi_version                   | () -> u32                                   |
-- | bfd_destroy                       | (slot: c_int) -> void                       |
-- | bfd_state                         | (slot: c_int) -> u8                         |
-- | bfd_peer_init                     | (slot: c_int) -> u8                         |
-- | bfd_peer_up                       | (slot: c_int) -> u8                         |
-- | bfd_peer_down                     | (slot: c_int, diag: u8) -> u8               |
-- | bfd_admin_down                    | (slot: c_int) -> u8                         |
-- | bfd_is_up                         | (slot: c_int) -> u8                         |
-- | bfd_packets_sent                  | (slot: c_int) -> u64                        |
-- | bfd_send_packet                   | (slot: c_int) -> u8                         |
-- | bfd_teardown                      | (slot: c_int) -> u8                         |
-- | bfd_cleanup                       | (slot: c_int) -> u8                         |
-- | bfd_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
