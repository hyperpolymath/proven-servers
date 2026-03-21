-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AmqpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/amqp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AmqpABI.Types exactly.

module AmqpABI.Foreign

import AmqpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Amqp context.
||| Created by amqp_create*(), destroyed by amqp_destroy*().
export
data AmqpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match amqp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (12 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | amqp_abi_version                  | () -> u32                                   |
-- | amqp_destroy                      | (slot: c_int) -> void                       |
-- | amqp_state                        | (slot: c_int) -> u8                         |
-- | amqp_can_publish                  | (slot: c_int) -> u8                         |
-- | amqp_can_consume                  | (slot: c_int) -> u8                         |
-- | amqp_channel_open                 | (slot: c_int, channel: u16) -> u8           |
-- | amqp_channel_close                | (slot: c_int, channel: u16) -> u8           |
-- | amqp_channel_count                | (slot: c_int) -> u16                        |
-- | amqp_consumer_count               | (slot: c_int) -> u32                        |
-- | amqp_disconnect                   | (slot: c_int) -> u8                         |
-- | amqp_cleanup                      | (slot: c_int) -> u8                         |
-- | amqp_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
