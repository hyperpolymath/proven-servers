-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- abi.Foreign: Foreign function declarations for the Media C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/media.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected player session pool
--   - Per-session stream metadata (codec, protocol, profile)
--   - Per-session event tracking
--   - Playback lifecycle (load/play/pause/seek/stop)
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching abi.Types exactly.

module abi.Foreign

import abi.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a media player session.
||| Created by media_create(), destroyed by media_destroy().
export
data MediaContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match media_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | media_abi_version           | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | media_create                | (protocol: u8, profile: u8)               |
-- |                             |  -> c_int (slot). Returns -1 on failure.  |
-- +-----------------------------+-------------------------------------------+
-- | media_destroy               | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | media_state                 | (slot: c_int) -> u8 (PlayerState tag)     |
-- +-----------------------------+-------------------------------------------+
-- | media_load                  | (slot: c_int, url_ptr: ptr,               |
-- |                             |  url_len: u32, media_type: u8,            |
-- |                             |  codec: u8) -> u8 (0=ok, 1=rejected)      |
-- |                             | Transitions Idle -> Ready.                |
-- +-----------------------------+-------------------------------------------+
-- | media_play                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Ready/Paused -> Playing.      |
-- +-----------------------------+-------------------------------------------+
-- | media_pause                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Playing -> Paused.            |
-- +-----------------------------+-------------------------------------------+
-- | media_seek                  | (slot: c_int, position_ms: u64)           |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Valid from Playing or Paused.             |
-- +-----------------------------+-------------------------------------------+
-- | media_stop                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Stopping.                  |
-- +-----------------------------+-------------------------------------------+
-- | media_cleanup               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Stopping -> Idle.             |
-- +-----------------------------+-------------------------------------------+
-- | media_set_profile           | (slot: c_int, profile: u8)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | media_get_profile           | (slot: c_int) -> u8 (TranscodeProfile)    |
-- +-----------------------------+-------------------------------------------+
-- | media_get_codec             | (slot: c_int) -> u8 (Codec tag)           |
-- +-----------------------------+-------------------------------------------+
-- | media_get_protocol          | (slot: c_int) -> u8 (StreamProtocol tag)  |
-- +-----------------------------+-------------------------------------------+
-- | media_event_count           | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | media_can_transition        | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
