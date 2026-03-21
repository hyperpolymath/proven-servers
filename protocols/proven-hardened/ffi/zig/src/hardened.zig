// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");

pub const HardeningLevel = enum(u8) { minimal = 0, standard = 1, high = 2, maximum = 3 };
pub const SecurityControl = enum(u8) { aslr = 0, dep = 1, stack_canary = 2, cfi = 3, sandboxing = 4, secure_boot = 5, audit_log = 6 };
pub const ComplianceStandard = enum(u8) { cis = 0, stig = 1, nist80053 = 2, pci_dss = 3, fips140 = 4 };
pub const AuditEvent = enum(u8) { process_start = 0, file_access = 1, network_conn = 2, privilege_escalation = 3, config_change = 4, auth_attempt = 5 };
pub const HealthStatus = enum(u8) { healthy = 0, degraded = 1, compromised = 2, unresponsive = 3 };
pub const ServerState = enum(u8) { idle = 0, hardening = 1, active = 2, auditing = 3, shutdown = 4 };

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;
const MAX_CONTROLS: usize = 7;

const Session = struct {
    state: ServerState, name: [MAX_NAME_LEN]u8, name_len: u32,
    level: HardeningLevel, health: HealthStatus,
    controls_enabled: [MAX_CONTROLS]bool, control_count: u32,
    audit_count: u32, active: bool,
};
const empty_session: Session = .{
    .state = .idle, .name = [_]u8{0} ** MAX_NAME_LEN, .name_len = 0,
    .level = .minimal, .health = .healthy,
    .controls_enabled = [_]bool{false} ** MAX_CONTROLS, .control_count = 0,
    .audit_count = 0, .active = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

pub export fn hrd_abi_version() callconv(.c) u32 { return 1; }

pub export fn hrd_create(name_ptr: [*]const u8, name_len: u32, level: u8) callconv(.c) c_int {
    mutex.lock(); defer mutex.unlock();
    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (level > 3) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len; s.level = @enumFromInt(level);
            s.state = .hardening; s.active = true; return @intCast(i);
        }
    }
    return -1;
}

pub export fn hrd_destroy(slot: c_int) callconv(.c) void {
    mutex.lock(); defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn hrd_state(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return @intFromEnum(sessions[idx].state);
}

pub export fn hrd_enable_control(slot: c_int, control: u8) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .hardening) return 1;
    if (control > 6) return 1;
    if (sessions[idx].controls_enabled[control]) return 1;
    sessions[idx].controls_enabled[control] = true; sessions[idx].control_count += 1; return 0;
}

pub export fn hrd_control_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return sessions[idx].control_count;
}

pub export fn hrd_activate(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .hardening) return 1;
    sessions[idx].state = .active; return 0;
}

pub export fn hrd_begin_audit(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    sessions[idx].state = .auditing; return 0;
}

pub export fn hrd_log_event(slot: c_int, event: u8) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = event;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active and sessions[idx].state != .auditing) return 1;
    sessions[idx].audit_count += 1; return 0;
}

pub export fn hrd_finish_audit(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .auditing) return 1;
    sessions[idx].state = .active; return 0;
}

pub export fn hrd_health(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3; return @intFromEnum(sessions[idx].health);
}

pub export fn hrd_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .active or state == .hardening or state == .auditing) { sessions[idx].state = .shutdown; return 0; }
    return 1;
}

pub export fn hrd_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;
    sessions[idx].state = .idle; sessions[idx].control_count = 0; sessions[idx].audit_count = 0;
    sessions[idx].controls_enabled = [_]bool{false} ** MAX_CONTROLS; return 0;
}

pub export fn hrd_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; if (from == 1 and to == 2) return 1;
    if (from == 2 and to == 3) return 1; if (from == 3 and to == 2) return 1;
    if (from == 1 and to == 4) return 1; if (from == 2 and to == 4) return 1;
    if (from == 3 and to == 4) return 1; if (from == 4 and to == 0) return 1;
    return 0;
}
