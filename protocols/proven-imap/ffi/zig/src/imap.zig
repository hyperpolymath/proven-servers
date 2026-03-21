// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");

pub const Command = enum(u8) { login=0,logout=1,select=2,examine=3,create=4,delete=5,rename=6,list=7,fetch=8,store=9,search=10,copy=11,noop=12,capability=13 };
pub const ImapState = enum(u8) { not_authenticated=0,authenticated=1,selected=2,logout_state=3 };
pub const Flag = enum(u8) { seen=0,answered=1,flagged=2,deleted=3,draft=4,recent=5 };

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;
const MAX_MAILBOXES: usize = 64;
const MAX_MESSAGES: usize = 256;

const Mailbox = struct { name: [MAX_NAME_LEN]u8, name_len: u32, msg_count: u32, active: bool };
const empty_mailbox: Mailbox = .{ .name = [_]u8{0} ** MAX_NAME_LEN, .name_len = 0, .msg_count = 0, .active = false };

const Session = struct {
    state: ImapState, user: [MAX_NAME_LEN]u8, user_len: u32,
    mailboxes: [MAX_MAILBOXES]Mailbox, mailbox_count: u32,
    selected_mailbox: i32, cmd_count: u32, active: bool,
};
const empty_session: Session = .{
    .state = .not_authenticated, .user = [_]u8{0} ** MAX_NAME_LEN, .user_len = 0,
    .mailboxes = [_]Mailbox{empty_mailbox} ** MAX_MAILBOXES, .mailbox_count = 0,
    .selected_mailbox = -1, .cmd_count = 0, .active = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

pub export fn imap_abi_version() callconv(.c) u32 { return 1; }

pub export fn imap_create() callconv(.c) c_int {
    mutex.lock(); defer mutex.unlock();
    for (&sessions, 0..) |*s, i| {
        if (!s.active) { s.* = empty_session; s.state = .not_authenticated; s.active = true; return @intCast(i); }
    }
    return -1;
}

pub export fn imap_destroy(slot: c_int) callconv(.c) void {
    mutex.lock(); defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn imap_state(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return @intFromEnum(sessions[idx].state);
}

pub export fn imap_login(slot: c_int, user_ptr: [*]const u8, user_len: u32, pass_ptr: [*]const u8, pass_len: u32) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    _ = pass_ptr; _ = pass_len;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .not_authenticated) return 1;
    if (user_len == 0 or user_len > MAX_NAME_LEN) return 1;
    @memcpy(sessions[idx].user[0..user_len], user_ptr[0..user_len]);
    sessions[idx].user_len = user_len; sessions[idx].state = .authenticated;
    sessions[idx].cmd_count += 1; return 0;
}

pub export fn imap_select(slot: c_int, name_ptr: [*]const u8, name_len: u32) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .authenticated and sessions[idx].state != .selected) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    // Find or create mailbox
    const name = name_ptr[0..name_len];
    for (&sessions[idx].mailboxes, 0..) |*mb, mi| {
        if (mb.active and mb.name_len == name_len and std.mem.eql(u8, mb.name[0..mb.name_len], name)) {
            sessions[idx].selected_mailbox = @intCast(mi); sessions[idx].state = .selected;
            sessions[idx].cmd_count += 1; return 0;
        }
    }
    // Create new mailbox
    for (&sessions[idx].mailboxes, 0..) |*mb, mi| {
        if (!mb.active) {
            @memcpy(mb.name[0..name_len], name); mb.name_len = name_len;
            mb.active = true; sessions[idx].mailbox_count += 1;
            sessions[idx].selected_mailbox = @intCast(mi); sessions[idx].state = .selected;
            sessions[idx].cmd_count += 1; return 0;
        }
    }
    return 1;
}

pub export fn imap_close(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .selected) return 1;
    sessions[idx].selected_mailbox = -1; sessions[idx].state = .authenticated;
    sessions[idx].cmd_count += 1; return 0;
}

pub export fn imap_logout(slot: c_int) callconv(.c) u8 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .logout_state) return 1;
    sessions[idx].state = .logout_state; sessions[idx].cmd_count += 1; return 0;
}

pub export fn imap_cmd_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return sessions[idx].cmd_count;
}

pub export fn imap_mailbox_count(slot: c_int) callconv(.c) u32 {
    mutex.lock(); defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; return sessions[idx].mailbox_count;
}

pub export fn imap_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // NotAuth -> Auth
    if (from == 1 and to == 2) return 1; // Auth -> Selected
    if (from == 2 and to == 1) return 1; // Selected -> Auth
    if (from == 0 and to == 3) return 1; // NotAuth -> Logout
    if (from == 1 and to == 3) return 1; // Auth -> Logout
    if (from == 2 and to == 3) return 1; // Selected -> Logout
    return 0;
}
