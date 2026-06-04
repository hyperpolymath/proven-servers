-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- IrcABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/irc.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected client session pool
--   - Registration state machine (NICK + USER -> Registered)
--   - Channel join/part/mode tracking (max 16 channels per client)
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching IrcABI.Types exactly.

module IrcABI.Foreign

import IrcABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an IRC client session context.
||| Created by irc_create(), destroyed by irc_destroy().
export
data IrcContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match irc_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (20 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | irc_abi_version                   | () -> u32                                   |
-- | irc_create                        | () -> c_int                                 |
-- | irc_destroy                       | (slot: c_int) -> void                       |
-- | irc_state                         | (slot: c_int) -> u8                         |
-- | irc_last_error                    | (slot: c_int) -> u8                         |
-- | irc_has_nick                      | (slot: c_int) -> u8                         |
-- | irc_has_user                      | (slot: c_int) -> u8                         |
-- | irc_channel_count                 | (slot: c_int) -> u32                        |
-- | irc_message_count                 | (slot: c_int) -> u64                        |
-- | irc_nick                          | (slot: c_int) -> u8                         |
-- | irc_user                          | (slot: c_int) -> u8                         |
-- | irc_join                          | (slot: c_int) -> u8                         |
-- | irc_part                          | (slot: c_int) -> u8                         |
-- | irc_privmsg                       | (slot: c_int) -> u8                         |
-- | irc_notice                        | (slot: c_int) -> u8                         |
-- | irc_ping                          | (slot: c_int) -> u8                         |
-- | irc_pong                          | (slot: c_int) -> u8                         |
-- | irc_set_mode                      | (slot: c_int, ch: u8, mode: u8) -> u8       |
-- | irc_get_modes                     | (slot: c_int, ch: u8) -> u16                |
-- | irc_quit                          | (slot: c_int) -> u8                         |
-- | irc_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
