-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DDSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dds.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected participant pool
--   - Topic registration per participant (max 32 topics)
--   - DataWriter management per participant (max 16 writers)
--   - DataReader management per participant (max 16 readers)
--   - QoS policy enforcement (reliability, durability, history)
--   - Sample count tracking per writer/reader
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DDSABI.Types exactly.

module DDSABI.Foreign

import DDSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DDS DomainParticipant.
||| Created by dds_create(), destroyed by dds_destroy().
export
data DdsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dds_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +----------------------------+--------------------------------------------+
-- | Function                   | Signature                                  |
-- +----------------------------+--------------------------------------------+
-- | dds_abi_version            | () -> u32                                  |
-- +----------------------------+--------------------------------------------+
-- | dds_create                 | (domain_id: u32) -> c_int (slot)           |
-- |                            | Creates participant in Joined state.       |
-- +----------------------------+--------------------------------------------+
-- | dds_destroy                | (slot: c_int) -> void                      |
-- +----------------------------+--------------------------------------------+
-- | dds_state                  | (slot: c_int) -> u8 (ParticipantState tag) |
-- +----------------------------+--------------------------------------------+
-- | dds_create_topic           | (slot: c_int,                              |
-- |                            |  name_ptr: ptr, name_len: u32,             |
-- |                            |  reliability: u8, durability: u8,          |
-- |                            |  history: u8) -> u8 (0=ok, 1=rejected)    |
-- +----------------------------+--------------------------------------------+
-- | dds_delete_topic           | (slot: c_int,                              |
-- |                            |  name_ptr: ptr, name_len: u32)             |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- +----------------------------+--------------------------------------------+
-- | dds_topic_count            | (slot: c_int) -> u32                       |
-- +----------------------------+--------------------------------------------+
-- | dds_create_writer          | (slot: c_int,                              |
-- |                            |  topic_ptr: ptr, topic_len: u32)           |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- |                            | Transitions Joined -> Publishing.          |
-- +----------------------------+--------------------------------------------+
-- | dds_delete_writer          | (slot: c_int,                              |
-- |                            |  topic_ptr: ptr, topic_len: u32)           |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- +----------------------------+--------------------------------------------+
-- | dds_writer_count           | (slot: c_int) -> u32                       |
-- +----------------------------+--------------------------------------------+
-- | dds_create_reader          | (slot: c_int,                              |
-- |                            |  topic_ptr: ptr, topic_len: u32)           |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- |                            | Transitions Joined -> Subscribing.         |
-- +----------------------------+--------------------------------------------+
-- | dds_delete_reader          | (slot: c_int,                              |
-- |                            |  topic_ptr: ptr, topic_len: u32)           |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- +----------------------------+--------------------------------------------+
-- | dds_reader_count           | (slot: c_int) -> u32                       |
-- +----------------------------+--------------------------------------------+
-- | dds_write_sample           | (slot: c_int,                              |
-- |                            |  topic_ptr: ptr, topic_len: u32)           |
-- |                            | -> u8 (0=ok, 1=rejected)                  |
-- +----------------------------+--------------------------------------------+
-- | dds_samples_written        | (slot: c_int) -> u64                       |
-- +----------------------------+--------------------------------------------+
-- | dds_leave                  | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions to Leaving state.             |
-- +----------------------------+--------------------------------------------+
-- | dds_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                            | Transitions Leaving -> Idle.              |
-- +----------------------------+--------------------------------------------+
-- | dds_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)    |
-- +----------------------------+--------------------------------------------+
