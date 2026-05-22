// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// pop3.zig — Zig FFI implementation of proven-pop3.
//
// Implements the POP3 (RFC 1939) session state machine with:
//   - Slot-based context management (up to 64 concurrent sessions)
//   - 3-state session machine (Authorization -> Transaction -> Update)
//   - Command validation per state
//   - Message and deletion tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)

const std = @import("std");

// ── Enums (matching Idris2 Types.idr tag assignments exactly) ──────────

/// Command — matches commandToTag
pub const Command = enum(u8) {
    user = 0,
    pass = 1,
    stat = 2,
    list = 3,
    retr = 4,
    dele = 5,
    noop = 6,
    rset = 7,
    quit = 8,
    top = 9,
    uidl = 10,
};

/// State — matches stateToTag
pub const State = enum(u8) {
    authorization = 0,
    transaction = 1,
    update = 2,
};

/// Response — matches responseToTag
pub const Response = enum(u8) {
    ok = 0,
    err = 1,
};

/// POP3Error — matches pop3ErrorToTag
pub const POP3Error = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    invalid_command = 4,
    auth_failed = 5,
};

// ── Session Context instance ────────────────────────────────────────────

const SessionCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current session state.
    state: State,
    /// Last response indicator.
    last_response: Response,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of messages in the mailbox.
    message_count: u32,
    /// Number of messages marked for deletion.
    deleted_count: u32,
    /// Total commands executed.
    command_count: u32,
    /// Whether the user has been authenticated.
    authenticated: bool,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: SessionCtx = .{
    .active = false,
    .state = .authorization,
    .last_response = .ok,
    .last_error = 255,
    .message_count = 0,
    .deleted_count = 0,
    .command_count = 0,
    .authenticated = false,
};

var contexts: [MAX_CONTEXTS]SessionCtx = [_]SessionCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*SessionCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

/// Check if a command is valid in the given state (RFC 1939).
fn isCommandValidInState(cmd: Command, state: State) bool {
    return switch (state) {
        .authorization => switch (cmd) {
            .user, .pass, .quit => true,
            else => false,
        },
        .transaction => switch (cmd) {
            .stat, .list, .retr, .dele, .noop, .rset, .quit, .top, .uidl => true,
            else => false,
        },
        .update => false, // No commands valid in Update state
    };
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match POP3ABI.Foreign.abiVersion (currently 1).
pub export fn pop3_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new POP3 session.
/// Returns slot index (0-63) or -1 if no slots available.
pub export fn pop3_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session context, freeing its slot.
pub export fn pop3_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current State tag for a slot.
pub export fn pop3_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the message count.
pub export fn pop3_get_message_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.message_count;
}

/// Get the deleted message count.
pub export fn pop3_get_deleted_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.deleted_count;
}

/// Get the total command count.
pub export fn pop3_get_command_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.command_count;
}

/// Get the last Response tag.
pub export fn pop3_get_last_response(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.last_response);
}

/// Get the last error tag, or 255 if no error.
pub export fn pop3_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Authentication ──────────────────────────────────────────────────────

/// Authenticate a session (Authorization -> Transaction).
pub export fn pop3_authenticate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(POP3Error.invalid_slot);

    if (ctx.state != .authorization) {
        ctx.last_error = @intFromEnum(POP3Error.invalid_transition);
        return @intFromEnum(POP3Error.invalid_transition);
    }

    ctx.state = .transaction;
    ctx.authenticated = true;
    ctx.last_response = .ok;
    ctx.last_error = 255;
    return @intFromEnum(POP3Error.ok);
}

// ── Command execution ───────────────────────────────────────────────────

/// Execute a POP3 command.
pub export fn pop3_execute_command(slot: c_int, cmd: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(POP3Error.invalid_slot);

    if (cmd > 10) {
        ctx.last_error = @intFromEnum(POP3Error.invalid_command);
        ctx.last_response = .err;
        return @intFromEnum(POP3Error.invalid_command);
    }

    const command: Command = @enumFromInt(cmd);

    if (!isCommandValidInState(command, ctx.state)) {
        ctx.last_error = @intFromEnum(POP3Error.invalid_command);
        ctx.last_response = .err;
        return @intFromEnum(POP3Error.invalid_command);
    }

    ctx.command_count += 1;

    // Handle QUIT: transition to Update state
    if (command == .quit) {
        ctx.state = .update;
        ctx.last_response = .ok;
        ctx.last_error = 255;
        return @intFromEnum(POP3Error.ok);
    }

    // Handle DELE: mark a message for deletion
    if (command == .dele) {
        ctx.deleted_count += 1;
    }

    // Handle RSET: unmark all deleted messages
    if (command == .rset) {
        ctx.deleted_count = 0;
    }

    // Handle RETR: simulate reading a message
    if (command == .retr) {
        ctx.message_count += 1;
    }

    ctx.last_response = .ok;
    ctx.last_error = 255;
    return @intFromEnum(POP3Error.ok);
}
