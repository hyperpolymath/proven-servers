-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- QuicABI.Foreign: opaque handle and the complete FFI contract that the Zig
-- engine (ffi/zig/src/quic.zig) provides.
--
-- The engine manages a mutex-protected pool of connections, each with a
-- table of streams carrying the sending/receiving state machines, plus
-- stateless helpers: the RFC 9000 variable-length-integer codec, stream-ID
-- classification, access rules, and the frame-in-packet table.  Enum values
-- cross the boundary as Bits8 tags matching QuicABI.Types.

module QuicABI.Foreign

import QuicABI.Types

%default total

||| Opaque handle to a QUIC connection session.
export
data QuicContext : Type where [external]

||| ABI version -- must match quic_abi_version() in the Zig engine.
public export
abiVersion : Bits32
abiVersion = 1

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature / behaviour                   |
-- +-------------------------------+-----------------------------------------+
-- | quic_abi_version              | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | quic_varint_encode            | (value:u64, out:ptr, cap:usize) -> i32  |
-- |                               | RFC 9000 Section 16 encoding; returns    |
-- |                               | bytes written (1/2/4/8) or -1.          |
-- | quic_varint_decode            | (in:ptr, len:usize, out:*u64) -> i32    |
-- |                               | Returns bytes consumed (1/2/4/8) or -1. |
-- | quic_varint_len               | (value:u64) -> i32 (1/2/4/8) or -1      |
-- +-------------------------------+-----------------------------------------+
-- | quic_stream_code              | (id:u64) -> u8  (StreamKind tag 0-3)    |
-- | quic_stream_initiator         | (id:u64) -> u8  (Endpoint tag 0/1)      |
-- | quic_stream_is_uni            | (id:u64) -> u8  (1 if unidirectional)   |
-- +-------------------------------+-----------------------------------------+
-- | quic_can_send                 | (endpoint:u8, stream_code:u8) -> u8     |
-- | quic_can_receive              | (endpoint:u8, stream_code:u8) -> u8     |
-- |                               | RFC 9000 Sections 2.1/3 access rules.   |
-- +-------------------------------+-----------------------------------------+
-- | quic_frame_allowed            | (frame:u8, packet:u8) -> u8 (1/0)       |
-- |                               | RFC 9000 Section 12.4 table.            |
-- +-------------------------------+-----------------------------------------+
-- | quic_create                   | (endpoint:u8) -> c_int (slot)           |
-- |                               | New connection in Initial state; -1 on  |
-- |                               | failure.                                |
-- | quic_destroy                  | (slot:c_int) -> void                    |
-- | quic_conn_state               | (slot:c_int) -> u8 (ConnState tag)      |
-- | quic_conn_transition          | (slot:c_int, to:u8) -> u8 (0 ok/1 rej)  |
-- +-------------------------------+-----------------------------------------+
-- | quic_open_stream              | (slot:c_int, stream_code:u8) -> i32     |
-- |                               | Stream index (>=0) or -1.  Bidi streams |
-- |                               | start Send=Ready, Recv=Recv; uni streams|
-- |                               | initialise only the half this endpoint  |
-- |                               | owns.                                   |
-- | quic_send_state               | (slot, idx:u32) -> u8 (SendState tag)   |
-- | quic_recv_state               | (slot, idx:u32) -> u8 (RecvState tag)   |
-- | quic_send_transition          | (slot, idx:u32, to:u8) -> u8 (0/1)      |
-- | quic_recv_transition          | (slot, idx:u32, to:u8) -> u8 (0/1)      |
-- +-------------------------------+-----------------------------------------+
-- | quic_conn_can_transition      | (from:u8, to:u8) -> u8 (1/0)            |
-- | quic_send_can_transition      | (from:u8, to:u8) -> u8 (1/0)            |
-- | quic_recv_can_transition      | (from:u8, to:u8) -> u8 (1/0)            |
-- +-------------------------------+-----------------------------------------+

-- TODO(crypto): TLS 1.3 handshake, packet number spaces, AEAD packet
-- protection, and header protection are out of scope for this core and would
-- plug in around quic_conn_transition (handshake) and a future packet codec.
-- TODO(recovery): congestion control and loss recovery (RFC 9002).
