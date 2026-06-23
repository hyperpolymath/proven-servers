// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// cli.zig -- Zig FFI implementation of proven-cli.
//
// Implements a CLI parser context manager with:
//   - 64-slot parser context pool
//   - Per-context option registration and argument type tracking
//   - Subcommand depth tracking with configurable maximum
//   - Parse error tracking
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CLIABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching CLIABI.Types.idr tag assignments)
// =========================================================================

/// Argument type tags (tags 0-5).
pub const ArgTypeTag = enum(u8) {
    string = 0,
    int = 1,
    bool = 2,
    float = 3,
    path = 4,
    enum_type = 5,
};

/// Parse result tags (tags 0-1).
pub const ParseResult = enum(u8) {
    ok = 0,
    err = 1,
};

/// Parse error tags (tags 0-6).
pub const ParseErrorTag = enum(u8) {
    not_an_integer = 0,
    not_a_boolean = 1,
    not_a_float = 2,
    empty_path = 3,
    path_contains_null = 4,
    invalid_enum = 5,
    arg_too_long = 6,
};

/// Option definition error tags (tags 0-3).
pub const OptionDefErrTag = enum(u8) {
    dup_short = 0,
    dup_long = 1,
    empty_long = 2,
    req_with_def = 3,
};

/// Command definition error tags (tags 0-4).
pub const CmdDefErrTag = enum(u8) {
    empty_cmd_name = 0,
    cmd_name_spaces = 1,
    subcmd_too_deep = 2,
    dup_subcmd = 3,
    opt_errors = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent CLI parser contexts.
const MAX_SESSIONS: usize = 64;

/// Maximum options per context.
const MAX_OPTIONS: usize = 32;

/// A registered option entry.
const OptionEntry = struct {
    /// Argument type for this option.
    arg_type: ArgTypeTag,
    /// Whether this option is required.
    required: bool,
    /// Whether this option has been provided.
    provided: bool,
};

/// A CLI parser context.
const Session = struct {
    /// Maximum arguments allowed.
    max_args: u16,
    /// Maximum subcommand depth.
    max_depth: u8,
    /// Current subcommand depth.
    current_depth: u8,
    /// Number of registered options.
    option_count: u16,
    /// Registered options.
    options: [MAX_OPTIONS]OptionEntry,
    /// Number of arguments parsed.
    args_parsed: u16,
    /// Last parse error (valid only after a failed parse).
    last_error: ParseErrorTag,
    /// Whether a parse error has occurred.
    has_error: bool,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default option entry.
const empty_option: OptionEntry = .{
    .arg_type = .string,
    .required = false,
    .provided = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .max_args = 256,
    .max_depth = 5,
    .current_depth = 0,
    .option_count = 0,
    .options = [_]OptionEntry{empty_option} ** MAX_OPTIONS,
    .args_parsed = 0,
    .last_error = .not_an_integer,
    .has_error = false,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn cli_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new CLI parser context. Returns slot index (>=0) or -1.
pub export fn cli_create(max_args: u16, max_depth: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.max_args = max_args;
            s.max_depth = max_depth;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a context, releasing its slot.
pub export fn cli_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Register an option. Returns 0 on success, 1 on invalid slot/type,
/// 2 on capacity full.
pub export fn cli_register_option(slot: c_int, arg_type: u8, required: u8) callconv(.c) u8 {
    if (arg_type > 5) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].option_count >= MAX_OPTIONS) return 2;

    const oidx: usize = sessions[idx].option_count;
    sessions[idx].options[oidx] = .{
        .arg_type = @enumFromInt(arg_type),
        .required = required != 0,
        .provided = false,
    };
    sessions[idx].option_count += 1;
    return 0;
}

/// Returns the number of registered options.
pub export fn cli_option_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].option_count;
}

/// Parse an argument of the given type. Returns 0=ok, 1=error.
/// Simplified model: validates the type tag and tracks parse count.
pub export fn cli_parse_arg(slot: c_int, arg_type: u8) callconv(.c) u8 {
    if (arg_type > 5) {
        mutex.lock();
        defer mutex.unlock();
        const idx = validSlot(slot) orelse return 1;
        sessions[idx].last_error = .not_an_integer;
        sessions[idx].has_error = true;
        return 1;
    }

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].args_parsed >= sessions[idx].max_args) {
        sessions[idx].last_error = .arg_too_long;
        sessions[idx].has_error = true;
        return 1;
    }
    sessions[idx].args_parsed += 1;
    return 0;
}

/// Returns the last parse error tag.
pub export fn cli_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].last_error);
}

/// Enter a subcommand level. Returns 0 on success, 1 if max depth exceeded.
pub export fn cli_push_subcommand(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].current_depth >= sessions[idx].max_depth) return 1;
    sessions[idx].current_depth += 1;
    return 0;
}

/// Exit a subcommand level. Returns 0 on success, 1 if already at root.
pub export fn cli_pop_subcommand(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].current_depth == 0) return 1;
    sessions[idx].current_depth -= 1;
    return 0;
}

/// Returns the current subcommand depth.
pub export fn cli_current_depth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].current_depth;
}

/// Returns the maximum subcommand depth.
pub export fn cli_max_depth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].max_depth;
}

/// Reset the parser context for re-use.
pub export fn cli_reset(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return;
    const max_args = sessions[idx].max_args;
    const max_depth = sessions[idx].max_depth;
    sessions[idx] = empty_session;
    sessions[idx].max_args = max_args;
    sessions[idx].max_depth = max_depth;
    sessions[idx].active = true;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
