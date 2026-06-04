-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- GrpcABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/grpc.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching GrpcABI.Types exactly.

module GrpcABI.Foreign

import GrpcABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Grpc context.
||| Created by grpc_create*(), destroyed by grpc_destroy*().
export
data GrpcContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match grpc_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (23 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | grpc_abi_version                  | () -> u32                                   |
-- | grpc_create                       | (compression: u8) -> c_int                  |
-- | grpc_destroy                      | (slot: c_int) -> void                       |
-- | grpc_stream_state                 | (slot: c_int) -> u8                         |
-- | grpc_compression                  | (slot: c_int) -> u8                         |
-- | grpc_status_code                  | (slot: c_int) -> u8                         |
-- | grpc_set_status                   | (slot: c_int, status: u8) -> u8             |
-- | grpc_stream_id                    | (slot: c_int) -> u32                        |
-- | grpc_send_headers                 | (slot: c_int) -> u8                         |
-- | grpc_local_end_stream             | (slot: c_int) -> u8                         |
-- | grpc_remote_end_stream            | (slot: c_int) -> u8                         |
-- | grpc_reset_stream                 | (slot: c_int, status: u8) -> u8             |
-- | grpc_close_half_local             | (slot: c_int) -> u8                         |
-- | grpc_close_half_remote            | (slot: c_int) -> u8                         |
-- | grpc_push_promise                 | (slot: c_int) -> u8                         |
-- | grpc_reserved_to_half             | (slot: c_int) -> u8                         |
-- | grpc_can_send                     | (slot: c_int) -> u8                         |
-- | grpc_can_receive                  | (slot: c_int) -> u8                         |
-- | grpc_send_window                  | (slot: c_int) -> i32                        |
-- | grpc_recv_window                  | (slot: c_int) -> i32                        |
-- | grpc_update_send_window           | (slot: c_int, delta: i32) -> u8             |
-- | grpc_update_recv_window           | (slot: c_int, delta: i32) -> u8             |
-- | grpc_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
