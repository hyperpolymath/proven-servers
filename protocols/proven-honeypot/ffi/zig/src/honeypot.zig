// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");

pub const ServiceEmulation = enum(u8) { ssh = 0, http = 1, ftp = 2, smtp = 3, telnet = 4, mysql = 5, rdp = 6 };
pub const InteractionLevel = enum(u8) { low = 0, medium = 1, high = 2 };
pub const AlertSeverity = enum(u8) { info = 0, as_low = 1, as_medium = 2, as_high = 3, critical = 4 };
pub const AttackerAction = enum(u8) { scan = 0, brute_force = 1, exploit = 2, payload = 3, lateral = 4, exfiltration = 5 };
pub const ServerState = enum(u8) { idle = 0, deployed = 1, engaged = 2, shutdown = 3 };

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;

const Session = struct {
    state: ServerState, name: [MAX_NAME_LEN]u8, name_len: u32,
    service: ServiceEmulation, interaction: InteractionLevel,
    alert_count: u32, action_count: u32, active: bool,
};
const empty_session: Session = .{ .state = .idle, .name = [_]u8{0} ** MAX_NAME_LEN, .name_len = 0, .service = .ssh, .interaction = .low, .alert_count = 0, .action_count = 0, .active = false };

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

pub export fn hp_abi_version() callconv(.c) u32 { return 1; }

pub export fn hp_create(name_ptr: [*]const u8, name_len: u32, service: u8, interaction: u8) callconv(.c) c_int {
    mutex.lock(); defer mutex.unlock();
    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (service > 6 or interaction > 2) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len; s.service = @enumFromInt(service);
            s.interaction = @enumFromInt(interaction);
            s.state = .deployed; s.active = true; return @intCast(i);
        }
    }
    return -1;
}

pub export fn hp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock(); defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn hp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return @intFromEnum(sessions[idx].state);
}

pub export fn hp_record_action(slot: c_int, action: u8, severity: u8) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = severity;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .deployed and sessions[idx].state != .engaged) return 1;
    if (action > 5) return 1;
    sessions[idx].action_count += 1; sessions[idx].alert_count += 1;
    sessions[idx].state = .engaged; return 0;
}

pub export fn hp_alert_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return sessions[idx].alert_count;
}

pub export fn hp_action_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return sessions[idx].action_count;
}

pub export fn hp_reset_engagement(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .engaged) return 1;
    sessions[idx].state = .deployed; return 0;
}

pub export fn hp_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .deployed or state == .engaged) { sessions[idx].state = .shutdown; return 0; }
    return 1;
}

pub export fn hp_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;
    sessions[idx].state = .idle; sessions[idx].alert_count = 0; sessions[idx].action_count = 0; return 0;
}

pub export fn hp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; if (from == 1 and to == 2) return 1;
    if (from == 2 and to == 1) return 1; if (from == 1 and to == 3) return 1;
    if (from == 2 and to == 3) return 1; if (from == 3 and to == 0) return 1;
    return 0;
}
