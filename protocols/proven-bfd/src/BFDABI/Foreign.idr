-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BFDABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/bfd.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - BFD state machine per session (RFC 5880 Section 6.2)
--   - Desired/Required min TX/RX intervals
--   - Detection multiplier tracking
--   - Packet counter per session
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching BFDABI.Types exactly.

module BFDABI.Foreign

import BFDABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a BFD session.
||| Created by bfd_create(), destroyed by bfd_destroy().
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
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +----------------------------+--------------------------------------------+
-- | Function                   | Signature                                  |
-- +----------------------------+--------------------------------------------+
-- | bfd_abi_version            | () -> u32                                  |
-- +----------------------------+--------------------------------------------+
-- | bfd_create                 | (discriminator: u32,                       |
-- |                            |  desired_min_tx: u32,                      |
-- |                            |  required_min_rx: u32,                     |
-- |                            |  detect_mult: u8,                          |
-- |                            |  mode: u8) -> c_int (slot)                 |
-- |                            | Creates session in Down state.             |
-- +----------------------------+--------------------------------------------+
-- | bfd_destroy                | (slot: c_int) -> void                      |
-- +----------------------------+--------------------------------------------+
-- | bfd_state                  | (slot: c_int) -> u8 (SessionState tag)     |
-- +----------------------------+--------------------------------------------+
-- | bfd_peer_init              | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions Down -> Negotiating.           |
-- +----------------------------+--------------------------------------------+
-- | bfd_peer_up                | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions Negotiating -> Established.    |
-- +----------------------------+--------------------------------------------+
-- | bfd_peer_down              | (slot: c_int, diag: u8)                    |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- |                            | Transitions Established -> Down.           |
-- +----------------------------+--------------------------------------------+
-- | bfd_admin_down             | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions any -> Teardown.               |
-- +----------------------------+--------------------------------------------+
-- | bfd_is_up                  | (slot: c_int) -> u8 (1=yes, 0=no)         |
-- +----------------------------+--------------------------------------------+
-- | bfd_packets_sent           | (slot: c_int) -> u64                       |
-- +----------------------------+--------------------------------------------+
-- | bfd_send_packet            | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Increment packet counter if Established.   |
-- +----------------------------+--------------------------------------------+
-- | bfd_teardown               | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- +----------------------------+--------------------------------------------+
-- | bfd_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions Teardown -> Idle.              |
-- +----------------------------+--------------------------------------------+
-- | bfd_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)    |
-- +----------------------------+--------------------------------------------+
