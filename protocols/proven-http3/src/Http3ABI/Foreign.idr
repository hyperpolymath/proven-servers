-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Http3ABI.Foreign: opaque handle and the FFI contract that the Zig engine
-- (ffi/zig/src/http3.zig) provides.  The engine parses HTTP/3 frame headers
-- (type + length varints), classifies frames and stream types, enforces the
-- frame-vs-stream rules, and runs the request-stream frame-sequence state
-- machine over a mutex-protected pool of request streams.  Enum values cross
-- the boundary as Bits8 tags matching Http3ABI.Types.

module Http3ABI.Foreign

import Http3ABI.Types

%default total

||| Opaque handle to an HTTP/3 request-stream tracker.
export
data Http3Context : Type where [external]

||| ABI version -- must match http3_abi_version() in the Zig engine.
public export
abiVersion : Bits32
abiVersion = 1

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature / behaviour                   |
-- +-------------------------------+-----------------------------------------+
-- | http3_abi_version             | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | http3_parse_frame_header      | (in:ptr, len:usize, out_type:*u64,      |
-- |                               |  out_len:*u64) -> i32 (consumed) or -1  |
-- |                               | Decodes the two leading varints.        |
-- | http3_frame_tag_from_wire     | (code:u64) -> i32 (H3Frame tag) or -1   |
-- | http3_frame_wire_from_tag     | (tag:u8) -> i64 (wire code) or -1       |
-- | http3_stream_tag_from_wire    | (code:u64) -> i32 (H3StreamType) or -1  |
-- +-------------------------------+-----------------------------------------+
-- | http3_allowed_on_control      | (frame_tag:u8) -> u8 (1/0)              |
-- | http3_allowed_on_request      | (frame_tag:u8) -> u8 (1/0)              |
-- +-------------------------------+-----------------------------------------+
-- | http3_req_create              | () -> c_int (slot)                      |
-- | http3_req_destroy             | (slot:c_int) -> void                    |
-- | http3_req_state               | (slot:c_int) -> u8 (ReqState tag)       |
-- | http3_req_feed                | (slot:c_int, frame_tag:u8) -> u8        |
-- |                               | Apply a frame to the request stream.    |
-- |                               | 0 = accepted, 1 = illegal in this state.|
-- | http3_req_finish              | (slot:c_int) -> u8 (0 ok / 1 illegal)   |
-- |                               | End of stream -> Done.                   |
-- | http3_req_can_transition      | (from:u8, to:u8) -> u8 (1/0)            |
-- +-------------------------------+-----------------------------------------+

-- TODO(qpack): QPACK (RFC 9204) field-section encode/decode and the
-- encoder/decoder streams plug in alongside the request state machine.
-- TODO(settings): the SETTINGS exchange and server push (PUSH_PROMISE /
-- push streams) build on the control-stream handling sketched here.
-- TODO(semantics): the HTTP message/semantics layer (RFC 9110) sits above.
