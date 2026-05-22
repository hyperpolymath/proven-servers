// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// git.zig -- Zig FFI implementation of proven-git.
//
// Implements the Git smart transport server state machine with:
//   - 64-slot mutex-protected session pool
//   - Ref advertisement tracking
//   - Pack negotiation lifecycle
//   - Hook execution simulation
//   - Thread-safe via per-pool mutex

const std = @import("std");

pub const Command = enum(u8) { upload_pack = 0, receive_pack = 1, upload_archive = 2 };
pub const PacketType = enum(u8) { flush = 0, delimiter = 1, response_end = 2, data = 3, pkt_error = 4, sideband_data = 5, sideband_progress = 6, sideband_error = 7 };
pub const RefType = enum(u8) { branch = 0, tag = 1, head = 2, remote = 3, note = 4 };
pub const Capability = enum(u8) { multi_ack = 0, thin_pack = 1, side_band_64k = 2, ofs_delta = 3, shallow = 4, deepen_since = 5, deepen_not = 6, filter_spec = 7, object_format = 8 };
pub const HookResult = enum(u8) { accept = 0, reject = 1 };
pub const ServerState = enum(u8) { idle = 0, discovery = 1, negotiating = 2, transfer = 3, shutdown = 4 };

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;
const MAX_REFS: usize = 256;

const Ref = struct { name: [MAX_NAME_LEN]u8, name_len: u32, ref_type: RefType, active: bool };
const empty_ref: Ref = .{ .name = [_]u8{0} ** MAX_NAME_LEN, .name_len = 0, .ref_type = .branch, .active = false };

const Session = struct {
    state: ServerState, path: [MAX_NAME_LEN]u8, path_len: u32, command: Command,
    refs: [MAX_REFS]Ref, ref_count: u32, active: bool,
};
const empty_session: Session = .{
    .state = .idle, .path = [_]u8{0} ** MAX_NAME_LEN, .path_len = 0, .command = .upload_pack,
    .refs = [_]Ref{empty_ref} ** MAX_REFS, .ref_count = 0, .active = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

pub export fn git_abi_version() callconv(.c) u32 { return 1; }

pub export fn git_create(path_ptr: [*]const u8, path_len: u32, cmd: u8) callconv(.c) c_int {
    mutex.lock(); defer mutex.unlock();
    if (path_len == 0 or path_len > MAX_NAME_LEN) return -1;
    if (cmd > 2) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.path[0..path_len], path_ptr[0..path_len]);
            s.path_len = path_len; s.command = @enumFromInt(cmd);
            s.state = .discovery; s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn git_destroy(slot: c_int) callconv(.c) void {
    mutex.lock(); defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn git_state(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn git_advertise_ref(slot: c_int, ref_type: u8, name_ptr: [*]const u8, name_len: u32) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .discovery) return 1;
    if (ref_type > 4) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    for (&sessions[idx].refs) |*r| {
        if (!r.active) {
            @memcpy(r.name[0..name_len], name_ptr[0..name_len]);
            r.name_len = name_len; r.ref_type = @enumFromInt(ref_type); r.active = true;
            sessions[idx].ref_count += 1;
            return 0;
        }
    }
    return 1;
}

pub export fn git_ref_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].ref_count;
}

pub export fn git_begin_negotiation(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .discovery) return 1;
    sessions[idx].state = .negotiating; return 0;
}

pub export fn git_finish_negotiation(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiating) return 1;
    sessions[idx].state = .transfer; return 0;
}

pub export fn git_begin_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiating) return 1;
    sessions[idx].state = .transfer; return 0;
}

pub export fn git_finish_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transfer) return 1;
    sessions[idx].state = .idle; return 0;
}

pub export fn git_run_hook(slot: c_int, hook_type: u8) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = hook_type;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transfer and sessions[idx].state != .negotiating) return 1;
    return 0; // accept
}

pub export fn git_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .discovery or state == .negotiating or state == .transfer) {
        sessions[idx].state = .shutdown; return 0;
    }
    return 1;
}

pub export fn git_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;
    sessions[idx].state = .idle; sessions[idx].refs = [_]Ref{empty_ref} ** MAX_REFS;
    sessions[idx].ref_count = 0; return 0;
}

pub export fn git_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1;
    if (from == 1 and to == 2) return 1;
    if (from == 2 and to == 3) return 1;
    if (from == 3 and to == 0) return 1;
    if (from == 1 and to == 4) return 1;
    if (from == 2 and to == 4) return 1;
    if (from == 3 and to == 4) return 1;
    if (from == 4 and to == 0) return 1;
    return 0;
}
