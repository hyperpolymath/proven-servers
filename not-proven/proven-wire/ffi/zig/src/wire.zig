// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// wire.zig — Zig FFI implementation of proven-wire.
//
// Implements verified serialisation/deserialisation with:
//   - Slot-based codec session management (up to 64 concurrent)
//   - Endianness-aware encoding/decoding
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via mutex

const std = @import("std");

// ── Enums (matching WireABI.Layout.idr tag assignments) ─────────────────

pub const Endianness = enum(u8) {
    big_endian = 0,
    little_endian = 1,
    network_order = 2,
    host_order = 3,
};

pub const WireType = enum(u8) {
    uint8 = 0, uint16 = 1, uint32 = 2, uint64 = 3,
    int8 = 4, int16 = 5, int32 = 6, int64 = 7,
    float32 = 8, float64 = 9, bool_ = 10,
    utf8_string = 11, bytes = 12, optional = 13,
    sequence = 14, record = 15,
};

pub const EncodeError = enum(u8) {
    overflow = 0, underflow = 1, invalid_utf8 = 2,
    buffer_full = 3, field_missing = 4, type_mismatch = 5,
};

pub const DecodeError = enum(u8) {
    unexpected_eof = 0, invalid_tag = 1, invalid_length = 2,
    malformed_data = 3, unsupported_version = 4, checksum_mismatch = 5,
};

pub const CodecState = enum(u8) {
    idle = 0, encoding = 1, decoding = 2, complete = 3, failed = 4,
};

// ── Codec session ───────────────────────────────────────────────────────

const MAX_BUF: usize = 4096;

const Session = struct {
    state: CodecState,
    endianness: Endianness,
    buf: [MAX_BUF]u8,
    write_pos: u32,
    read_pos: u32,
    last_error: u8, // 255 = no error
    active: bool,
};

const MAX_SESSIONS: usize = 64;
var sessions: [MAX_SESSIONS]Session = [_]Session{.{
    .state = .idle, .endianness = .big_endian,
    .buf = [_]u8{0} ** MAX_BUF, .write_pos = 0, .read_pos = 0,
    .last_error = 255, .active = false,
}} ** MAX_SESSIONS;

var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// ── ABI version ─────────────────────────────────────────────────────────

pub export fn wire_abi_version() callconv(.c) u32 { return 1; }

// ── Lifecycle ───────────────────────────────────────────────────────────

pub export fn wire_create(endianness: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (endianness > 3) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .idle, .endianness = @enumFromInt(endianness),
                .buf = [_]u8{0} ** MAX_BUF, .write_pos = 0, .read_pos = 0,
                .last_error = 255, .active = true,
            };
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn wire_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

pub export fn wire_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn wire_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_error;
}

pub export fn wire_bytes_written(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].write_pos;
}

// ── Transitions ─────────────────────────────────────────────────────────

pub export fn wire_begin_encode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // rejected
    if (sessions[idx].state == .idle) {
        sessions[idx].state = .encoding;
        sessions[idx].write_pos = 0;
        sessions[idx].last_error = 255;
        return 0; // accepted
    }
    sessions[idx].last_error = 0; // invalid_transition
    return 1; // rejected
}

pub export fn wire_begin_decode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .idle) {
        sessions[idx].state = .decoding;
        sessions[idx].read_pos = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

pub export fn wire_finalize(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .encoding or sessions[idx].state == .decoding) {
        sessions[idx].state = .complete;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

pub export fn wire_fail(slot: c_int, err_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .encoding or sessions[idx].state == .decoding) {
        sessions[idx].state = .failed;
        sessions[idx].last_error = err_tag;
        return 0;
    }
    return 1;
}

pub export fn wire_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .failed) {
        sessions[idx].state = .idle;
        sessions[idx].write_pos = 0;
        sessions[idx].read_pos = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    if (sessions[idx].state == .complete) {
        sessions[idx].state = .idle;
        // Preserve write_pos so decode can read what was encoded (roundtrip).
        // read_pos resets for fresh decode pass.
        sessions[idx].read_pos = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

// ── Encode (endianness-aware) ───────────────────────────────────────────

fn resolveEndian(e: Endianness) std.builtin.Endian {
    return switch (e) {
        .big_endian, .network_order => .big,
        .little_endian => .little,
        .host_order => .little, // x86-64
    };
}

pub export fn wire_encode_u8(slot: c_int, val: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5; // type_mismatch
    if (sessions[idx].state != .encoding) return 5;
    if (sessions[idx].write_pos >= MAX_BUF) return 3; // buffer_full
    sessions[idx].buf[sessions[idx].write_pos] = val;
    sessions[idx].write_pos += 1;
    return 255; // ok
}

pub export fn wire_encode_u16(slot: c_int, val: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5;
    if (sessions[idx].state != .encoding) return 5;
    if (sessions[idx].write_pos + 2 > MAX_BUF) return 3;
    const endian = resolveEndian(sessions[idx].endianness);
    const bytes = std.mem.toBytes(if (endian == .big) @byteSwap(val) else val);
    @memcpy(sessions[idx].buf[sessions[idx].write_pos..][0..2], &bytes);
    sessions[idx].write_pos += 2;
    return 255;
}

pub export fn wire_encode_u32(slot: c_int, val: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5;
    if (sessions[idx].state != .encoding) return 5;
    if (sessions[idx].write_pos + 4 > MAX_BUF) return 3;
    const endian = resolveEndian(sessions[idx].endianness);
    const bytes = std.mem.toBytes(if (endian == .big) @byteSwap(val) else val);
    @memcpy(sessions[idx].buf[sessions[idx].write_pos..][0..4], &bytes);
    sessions[idx].write_pos += 4;
    return 255;
}

pub export fn wire_encode_u64(slot: c_int, val: u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5;
    if (sessions[idx].state != .encoding) return 5;
    if (sessions[idx].write_pos + 8 > MAX_BUF) return 3;
    const endian = resolveEndian(sessions[idx].endianness);
    const bytes = std.mem.toBytes(if (endian == .big) @byteSwap(val) else val);
    @memcpy(sessions[idx].buf[sessions[idx].write_pos..][0..8], &bytes);
    sessions[idx].write_pos += 8;
    return 255;
}

// ── Decode ──────────────────────────────────────────────────────────────

pub export fn wire_decode_u8(slot: c_int, out: ?*u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // invalid_tag
    if (sessions[idx].state != .decoding) return 1;
    if (sessions[idx].read_pos >= sessions[idx].write_pos) return 0; // unexpected_eof
    if (out) |p| p.* = sessions[idx].buf[sessions[idx].read_pos];
    sessions[idx].read_pos += 1;
    return 255; // ok
}

pub export fn wire_decode_u16(slot: c_int, out: ?*u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .decoding) return 1;
    if (sessions[idx].read_pos + 2 > sessions[idx].write_pos) return 0;
    const bytes = sessions[idx].buf[sessions[idx].read_pos..][0..2];
    const endian = resolveEndian(sessions[idx].endianness);
    var val = std.mem.bytesToValue(u16, bytes);
    if (endian == .big) val = @byteSwap(val);
    if (out) |p| p.* = val;
    sessions[idx].read_pos += 2;
    return 255;
}

pub export fn wire_decode_u32(slot: c_int, out: ?*u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .decoding) return 1;
    if (sessions[idx].read_pos + 4 > sessions[idx].write_pos) return 0;
    const bytes = sessions[idx].buf[sessions[idx].read_pos..][0..4];
    const endian = resolveEndian(sessions[idx].endianness);
    var val = std.mem.bytesToValue(u32, bytes);
    if (endian == .big) val = @byteSwap(val);
    if (out) |p| p.* = val;
    sessions[idx].read_pos += 4;
    return 255;
}

pub export fn wire_decode_u64(slot: c_int, out: ?*u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .decoding) return 1;
    if (sessions[idx].read_pos + 8 > sessions[idx].write_pos) return 0;
    const bytes = sessions[idx].buf[sessions[idx].read_pos..][0..8];
    const endian = resolveEndian(sessions[idx].endianness);
    var val = std.mem.bytesToValue(u64, bytes);
    if (endian == .big) val = @byteSwap(val);
    if (out) |p| p.* = val;
    sessions[idx].read_pos += 8;
    return 255;
}

// ── Stateless queries ───────────────────────────────────────────────────

pub export fn wire_type_byte_size(wtype: u8) callconv(.c) u8 {
    return switch (wtype) {
        0, 4, 10 => 1,   // u8, i8, bool
        1, 5 => 2,       // u16, i16
        2, 6, 8 => 4,    // u32, i32, f32
        3, 7, 9 => 8,    // u64, i64, f64
        else => 0,        // variable-length
    };
}

pub export fn wire_is_fixed_size(wtype: u8) callconv(.c) u8 {
    return if (wire_type_byte_size(wtype) > 0) 1 else 0;
}

pub export fn wire_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateCodecTransition exactly
    if (from == 0 and to == 1) return 1; // Idle -> Encoding
    if (from == 0 and to == 2) return 1; // Idle -> Decoding
    if (from == 1 and to == 3) return 1; // Encoding -> Complete
    if (from == 2 and to == 3) return 1; // Decoding -> Complete
    if (from == 1 and to == 4) return 1; // Encoding -> Failed
    if (from == 2 and to == 4) return 1; // Decoding -> Failed
    if (from == 4 and to == 0) return 1; // Failed -> Idle
    if (from == 3 and to == 0) return 1; // Complete -> Idle
    return 0;
}
