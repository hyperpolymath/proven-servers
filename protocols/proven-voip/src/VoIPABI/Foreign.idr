-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- VoIPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/voip.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SIP session pool
--   - Dialog state tracking per session
--   - SIP method request/response processing
--   - Call-ID and CSeq management
--   - Registration binding tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching VoIPABI.Types exactly.

module VoIPABI.Foreign

import VoIPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a VoIP SIP session context.
||| Created by voip_create(), destroyed by voip_destroy().
export
data VoIPContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match voip_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | voip_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | voip_create                 | (call_id_ptr: [*]u8, call_id_len: u32)    |
-- |                             | -> c_int                                  |
-- |                             | Creates session in Early state.           |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | voip_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | voip_state                  | (slot: c_int) -> u8 (DialogState tag)     |
-- |                             | Returns current dialog state.             |
-- +-----------------------------+-------------------------------------------+
-- | voip_send_request           | (slot: c_int, method: u8)                 |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sends a SIP request via method tag.       |
-- +-----------------------------+-------------------------------------------+
-- | voip_recv_response          | (slot: c_int, code: u8)                   |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Processes a SIP response code tag.        |
-- +-----------------------------+-------------------------------------------+
-- | voip_confirm                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Early -> Confirmed.           |
-- +-----------------------------+-------------------------------------------+
-- | voip_terminate              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Terminated.                |
-- +-----------------------------+-------------------------------------------+
-- | voip_cseq                   | (slot: c_int) -> u32                     |
-- |                             | Returns current CSeq number.             |
-- +-----------------------------+-------------------------------------------+
-- | voip_register               | (slot: c_int, contact_ptr: [*]u8,        |
-- |                             |  contact_len: u32, expires: u32)          |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Registers a contact binding.             |
-- +-----------------------------+-------------------------------------------+
-- | voip_registration_count     | (slot: c_int) -> u32                     |
-- |                             | Returns number of active registrations.  |
-- +-----------------------------+-------------------------------------------+
-- | voip_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks dialog state            |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | voip_request_count          | (slot: c_int) -> u32                     |
-- |                             | Returns number of requests sent.         |
-- +-----------------------------+-------------------------------------------+
-- | voip_response_count         | (slot: c_int) -> u32                     |
-- |                             | Returns number of responses received.    |
-- +-----------------------------+-------------------------------------------+
