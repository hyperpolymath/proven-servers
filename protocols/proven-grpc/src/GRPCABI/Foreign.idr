-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GRPCABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.  The Zig FFI (ffi/zig/src/grpc.zig)
-- implements all functions listed below with matching signatures.

module GRPCABI.Foreign

import GRPC.Types
import GRPCABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a gRPC context (connection + stream pool).
||| Created by grpc_create(), destroyed by grpc_destroy().
export
data GrpcHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match grpc_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | grpc_abi_version        | () -> Bits32                                |
-- +-------------------------+---------------------------------------------+
-- | grpc_create             | (compression: u8) -> c_int (slot)           |
-- |                         | Creates context with a stream in Idle.      |
-- +-------------------------+---------------------------------------------+
-- | grpc_destroy            | (slot: c_int) -> ()                         |
-- +-------------------------+---------------------------------------------+
-- | grpc_stream_state       | (slot: c_int) -> u8 (StreamState tag)       |
-- +-------------------------+---------------------------------------------+
-- | grpc_compression        | (slot: c_int) -> u8 (Compression tag)       |
-- +-------------------------+---------------------------------------------+
-- | grpc_status_code        | (slot: c_int) -> u8 (StatusCode tag)        |
-- +-------------------------+---------------------------------------------+
-- | grpc_set_status         | (slot: c_int, status: u8) -> u8             |
-- |                         | Records a gRPC status code.                 |
-- +-------------------------+---------------------------------------------+
-- | grpc_send_headers       | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Idle -> Open transition.                    |
-- +-------------------------+---------------------------------------------+
-- | grpc_local_end_stream   | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Open -> HalfClosedLocal.                    |
-- +-------------------------+---------------------------------------------+
-- | grpc_remote_end_stream  | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Open -> HalfClosedRemote.                   |
-- +-------------------------+---------------------------------------------+
-- | grpc_reset_stream       | (slot: c_int, status: u8) -> u8             |
-- |                         | Moves to Closed from Open/HalfClosed/Rsv.  |
-- +-------------------------+---------------------------------------------+
-- | grpc_close_half_local   | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | HalfClosedLocal -> Closed.                  |
-- +-------------------------+---------------------------------------------+
-- | grpc_close_half_remote  | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | HalfClosedRemote -> Closed.                 |
-- +-------------------------+---------------------------------------------+
-- | grpc_push_promise       | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Idle -> Reserved.                           |
-- +-------------------------+---------------------------------------------+
-- | grpc_reserved_to_half   | (slot: c_int) -> u8 (0=ok, 1=rejected)     |
-- |                         | Reserved -> HalfClosedRemote.               |
-- +-------------------------+---------------------------------------------+
-- | grpc_can_send           | (slot: c_int) -> u8 (1=yes, 0=no)          |
-- |                         | Whether local can send DATA (Open/HCR).     |
-- +-------------------------+---------------------------------------------+
-- | grpc_can_receive        | (slot: c_int) -> u8 (1=yes, 0=no)          |
-- |                         | Whether remote can send DATA (Open/HCL).    |
-- +-------------------------+---------------------------------------------+
-- | grpc_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)     |
-- |                         | Stateless transition table query.           |
-- +-------------------------+---------------------------------------------+
-- | grpc_send_window        | (slot: c_int) -> i32                        |
-- |                         | Current send flow control window.           |
-- +-------------------------+---------------------------------------------+
-- | grpc_recv_window        | (slot: c_int) -> i32                        |
-- |                         | Current receive flow control window.        |
-- +-------------------------+---------------------------------------------+
-- | grpc_update_send_window | (slot: c_int, delta: i32) -> u8             |
-- |                         | Adjusts send flow control window.           |
-- +-------------------------+---------------------------------------------+
-- | grpc_update_recv_window | (slot: c_int, delta: i32) -> u8             |
-- |                         | Adjusts receive flow control window.        |
-- +-------------------------+---------------------------------------------+
-- | grpc_stream_id          | (slot: c_int) -> u32                        |
-- |                         | Returns the HTTP/2 stream identifier.       |
-- +-------------------------+---------------------------------------------+
