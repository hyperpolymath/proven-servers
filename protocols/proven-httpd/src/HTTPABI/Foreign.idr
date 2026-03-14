-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- HTTPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module HTTPABI.Foreign

import HTTPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an HTTP context (request/response pair).
||| Created by http_create_context(), destroyed by http_destroy_context().
export
data HttpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match http_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | http_abi_version        | () -> Bits32                                |
-- +-------------------------+---------------------------------------------+
-- | http_create_context     | () -> c_int (slot, -1 on failure)           |
-- |                         | Creates context in Idle phase.              |
-- +-------------------------+---------------------------------------------+
-- | http_destroy_context    | (slot: c_int) -> ()                         |
-- +-------------------------+---------------------------------------------+
-- | http_parse_request      | (slot: c_int, data: [*]u8, len: u32)       |
-- |                         | -> u8 (0=ok, 1=rejected, 2=need_more)      |
-- |                         | Feed raw bytes; advances through Receiving, |
-- |                         | HeadersParsed, BodyReceiving, Complete.     |
-- +-------------------------+---------------------------------------------+
-- | http_get_method         | (slot: c_int) -> u8 (HttpMethod tag)        |
-- +-------------------------+---------------------------------------------+
-- | http_get_path           | (slot: c_int, buf: [*]u8, len: u32)        |
-- |                         | -> u32 (bytes written, 0 on error)         |
-- +-------------------------+---------------------------------------------+
-- | http_get_header         | (slot: c_int, key: [*]u8, klen: u32,       |
-- |                         |   buf: [*]u8, blen: u32)                   |
-- |                         | -> u32 (bytes written, 0 if not found)     |
-- +-------------------------+---------------------------------------------+
-- | http_get_body           | (slot: c_int, buf: [*]u8, len: u32)        |
-- |                         | -> u32 (bytes written, 0 on error)         |
-- +-------------------------+---------------------------------------------+
-- | http_set_status         | (slot: c_int, status_tag: u8) -> u8        |
-- |                         | (0=ok, 1=rejected). Requires Complete.     |
-- +-------------------------+---------------------------------------------+
-- | http_set_header         | (slot: c_int, key: [*]u8, klen: u32,       |
-- |                         |   val: [*]u8, vlen: u32)                   |
-- |                         | -> u8 (0=ok, 1=rejected)                   |
-- +-------------------------+---------------------------------------------+
-- | http_set_body           | (slot: c_int, data: [*]u8, len: u32)       |
-- |                         | -> u8 (0=ok, 1=rejected)                   |
-- +-------------------------+---------------------------------------------+
-- | http_send_response      | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Transitions Responding -> Sent.            |
-- +-------------------------+---------------------------------------------+
-- | http_keep_alive_check   | (slot: c_int) -> u8 (1=yes, 0=no)          |
-- |                         | Whether Connection: keep-alive is set.     |
-- +-------------------------+---------------------------------------------+
-- | http_get_phase          | (slot: c_int) -> u8 (RequestPhase tag)      |
-- +-------------------------+---------------------------------------------+
-- | http_get_version        | (slot: c_int) -> u8 (HttpVersion tag)       |
-- +-------------------------+---------------------------------------------+
-- | http_reset_context      | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Sent -> Idle (keep-alive recycle).         |
-- +-------------------------+---------------------------------------------+
-- | http_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)     |
-- +-------------------------+---------------------------------------------+
