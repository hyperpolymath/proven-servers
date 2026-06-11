-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- GameserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/gameserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected game server session pool
--   - Player management (connect/disconnect/state tracking)
--   - Game state lifecycle (lobby/running/paused)
--   - Sync strategy configuration
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching GameserverABI.Types exactly.

module GameserverABI.Foreign

import GameserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a game server session.
||| Created by gs_create(), destroyed by gs_destroy().
export
data GsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match gs_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | gs_abi_version                | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | gs_create                     | (name_ptr: ptr, name_len: u32,          |
-- |                               |  max_players: u16, sync: u8)            |
-- |                               |  -> c_int (slot)                        |
-- +-------------------------------+-----------------------------------------+
-- | gs_destroy                    | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | gs_state                      | (slot: c_int) -> u8 (ServerState tag)   |
-- +-------------------------------+-----------------------------------------+
-- | gs_player_join                | (slot: c_int, name_ptr: ptr,            |
-- |                               |  name_len: u32) -> u8 (0=ok, 1=rej)    |
-- +-------------------------------+-----------------------------------------+
-- | gs_player_leave               | (slot: c_int, player_idx: u16,          |
-- |                               |  reason: u8) -> u8 (0=ok, 1=rej)       |
-- +-------------------------------+-----------------------------------------+
-- | gs_player_count               | (slot: c_int) -> u16                    |
-- +-------------------------------+-----------------------------------------+
-- | gs_player_state               | (slot: c_int, player_idx: u16)          |
-- |                               |  -> u8 (PlayerState tag)                |
-- +-------------------------------+-----------------------------------------+
-- | gs_start_game                 | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_pause_game                 | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_resume_game                | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_end_game                   | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_game_state                 | (slot: c_int) -> u8 (GameState tag)     |
-- +-------------------------------+-----------------------------------------+
-- | gs_shutdown                   | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rej)      |
-- +-------------------------------+-----------------------------------------+
-- | gs_can_transition             | (from: u8, to: u8) -> u8 (1/0)         |
-- +-------------------------------+-----------------------------------------+
