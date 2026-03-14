// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// wire_test.zig — Integration tests for proven-wire FFI.

const std = @import("std");
const wire = @import("wire");

// ═══════════════════════════════════════════════════════════════════════
// ABI version
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), wire.wire_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams
// ═══════════════════════════════════════════════════════════════════════

test "Endianness encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wire.Endianness.big_endian));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wire.Endianness.little_endian));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(wire.Endianness.network_order));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(wire.Endianness.host_order));
}

test "WireType encoding matches Layout.idr (16 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wire.WireType.uint8));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(wire.WireType.int64));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(wire.WireType.bool_));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(wire.WireType.record));
}

test "CodecState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(wire.CodecState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(wire.CodecState.encoding));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(wire.CodecState.decoding));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(wire.CodecState.complete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(wire.CodecState.failed));
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = wire.wire_create(0); // big-endian
    try std.testing.expect(slot >= 0);
    defer wire.wire_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_state(slot)); // idle
}

test "create rejects invalid endianness" {
    try std.testing.expectEqual(@as(c_int, -1), wire.wire_create(99));
}

test "destroy is safe with invalid slot" {
    wire.wire_destroy(-1);
    wire.wire_destroy(999);
}

// ═══════════════════════════════════════════════════════════════════════
// Valid transitions
// ═══════════════════════════════════════════════════════════════════════

test "BeginEncode: Idle -> Encoding" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_begin_encode(slot));
    try std.testing.expectEqual(@as(u8, 1), wire.wire_state(slot));
}

test "BeginDecode: Idle -> Decoding" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_begin_decode(slot));
    try std.testing.expectEqual(@as(u8, 2), wire.wire_state(slot));
}

test "FinalizeEnc: Encoding -> Complete" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_finalize(slot));
    try std.testing.expectEqual(@as(u8, 3), wire.wire_state(slot));
}

test "ResetComplete: Complete -> Idle" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_finalize(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), wire.wire_state(slot));
}

test "FailEncode + ResetFailed" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    try std.testing.expectEqual(@as(u8, 0), wire.wire_fail(slot, 3)); // buffer_full
    try std.testing.expectEqual(@as(u8, 4), wire.wire_state(slot)); // failed
    try std.testing.expectEqual(@as(u8, 3), wire.wire_last_error(slot)); // buffer_full
    try std.testing.expectEqual(@as(u8, 0), wire.wire_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), wire.wire_state(slot)); // idle
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid transitions (impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "cannot encode while decoding" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_decode(slot);
    try std.testing.expectEqual(@as(u8, 1), wire.wire_begin_encode(slot)); // rejected
}

test "cannot decode while encoding" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    try std.testing.expectEqual(@as(u8, 1), wire.wire_begin_decode(slot)); // rejected
}

test "cannot begin from Complete without reset" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_finalize(slot);
    try std.testing.expectEqual(@as(u8, 1), wire.wire_begin_encode(slot)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Encode/decode roundtrip (big-endian)
// ═══════════════════════════════════════════════════════════════════════

test "u8 roundtrip" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    try std.testing.expectEqual(@as(u8, 255), wire.wire_encode_u8(slot, 42));
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u8 = 0;
    try std.testing.expectEqual(@as(u8, 255), wire.wire_decode_u8(slot, &out));
    try std.testing.expectEqual(@as(u8, 42), out);
}

test "u16 roundtrip big-endian" {
    const slot = wire.wire_create(0); // big-endian
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    try std.testing.expectEqual(@as(u8, 255), wire.wire_encode_u16(slot, 0xCAFE));
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u16 = 0;
    try std.testing.expectEqual(@as(u8, 255), wire.wire_decode_u16(slot, &out));
    try std.testing.expectEqual(@as(u16, 0xCAFE), out);
}

test "u32 roundtrip big-endian" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_encode_u32(slot, 0xDEADBEEF);
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u32 = 0;
    _ = wire.wire_decode_u32(slot, &out);
    try std.testing.expectEqual(@as(u32, 0xDEADBEEF), out);
}

test "u64 roundtrip big-endian" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_encode_u64(slot, 0x0102030405060708);
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u64 = 0;
    _ = wire.wire_decode_u64(slot, &out);
    try std.testing.expectEqual(@as(u64, 0x0102030405060708), out);
}

test "u16 roundtrip little-endian" {
    const slot = wire.wire_create(1); // little-endian
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_encode_u16(slot, 0xCAFE);
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u16 = 0;
    _ = wire.wire_decode_u16(slot, &out);
    try std.testing.expectEqual(@as(u16, 0xCAFE), out);
}

// ═══════════════════════════════════════════════════════════════════════
// Decode errors
// ═══════════════════════════════════════════════════════════════════════

test "decode past end returns UnexpectedEOF" {
    const slot = wire.wire_create(0);
    defer wire.wire_destroy(slot);
    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_encode_u8(slot, 1); // 1 byte written
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);
    _ = wire.wire_begin_decode(slot);
    var out: u16 = 0;
    try std.testing.expectEqual(@as(u8, 0), wire.wire_decode_u16(slot, &out)); // unexpected_eof
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless queries
// ═══════════════════════════════════════════════════════════════════════

test "wire_type_byte_size matches Layout.idr wireTypeByteSize" {
    try std.testing.expectEqual(@as(u8, 1), wire.wire_type_byte_size(0));  // uint8
    try std.testing.expectEqual(@as(u8, 2), wire.wire_type_byte_size(1));  // uint16
    try std.testing.expectEqual(@as(u8, 4), wire.wire_type_byte_size(2));  // uint32
    try std.testing.expectEqual(@as(u8, 8), wire.wire_type_byte_size(3));  // uint64
    try std.testing.expectEqual(@as(u8, 1), wire.wire_type_byte_size(10)); // bool
    try std.testing.expectEqual(@as(u8, 0), wire.wire_type_byte_size(11)); // utf8string (variable)
    try std.testing.expectEqual(@as(u8, 0), wire.wire_type_byte_size(15)); // record (variable)
}

test "wire_is_fixed_size matches Layout.idr isFixedSize" {
    try std.testing.expectEqual(@as(u8, 1), wire.wire_is_fixed_size(0));  // uint8 = fixed
    try std.testing.expectEqual(@as(u8, 0), wire.wire_is_fixed_size(12)); // bytes = variable
}

test "wire_can_transition matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(0, 1)); // Idle -> Encoding
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(0, 2)); // Idle -> Decoding
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(1, 3)); // Encoding -> Complete
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(2, 4)); // Decoding -> Failed
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(4, 0)); // Failed -> Idle
    try std.testing.expectEqual(@as(u8, 1), wire.wire_can_transition(3, 0)); // Complete -> Idle
    try std.testing.expectEqual(@as(u8, 0), wire.wire_can_transition(2, 1)); // Decoding -/-> Encoding
    try std.testing.expectEqual(@as(u8, 0), wire.wire_can_transition(1, 2)); // Encoding -/-> Decoding
    try std.testing.expectEqual(@as(u8, 0), wire.wire_can_transition(3, 1)); // Complete -/-> Encoding
}

// ═══════════════════════════════════════════════════════════════════════
// Multi-value encode/decode
// ═══════════════════════════════════════════════════════════════════════

test "encode multiple values then decode in order" {
    const slot = wire.wire_create(0); // big-endian
    defer wire.wire_destroy(slot);

    _ = wire.wire_begin_encode(slot);
    _ = wire.wire_encode_u8(slot, 0xFF);
    _ = wire.wire_encode_u16(slot, 0x1234);
    _ = wire.wire_encode_u32(slot, 0xABCDEF01);
    try std.testing.expectEqual(@as(u32, 7), wire.wire_bytes_written(slot)); // 1+2+4
    _ = wire.wire_finalize(slot);
    _ = wire.wire_reset(slot);

    _ = wire.wire_begin_decode(slot);
    var v8: u8 = 0;
    var v16: u16 = 0;
    var v32: u32 = 0;
    _ = wire.wire_decode_u8(slot, &v8);
    _ = wire.wire_decode_u16(slot, &v16);
    _ = wire.wire_decode_u32(slot, &v32);
    try std.testing.expectEqual(@as(u8, 0xFF), v8);
    try std.testing.expectEqual(@as(u16, 0x1234), v16);
    try std.testing.expectEqual(@as(u32, 0xABCDEF01), v32);
}
