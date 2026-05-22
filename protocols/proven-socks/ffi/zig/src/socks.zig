// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// socks.zig — Zig FFI implementation of proven-socks.
//
// Implements the SOCKS5 proxy connection primitive (RFC 1928) with:
//   - Slot-based connection management (up to 64 concurrent connections)
//   - Connection lifecycle state machine
//     (Initial -> Authenticating -> Authenticated -> Connecting ->
//      Established -> Closed)
//   - Authentication method tracking
//   - Command and address type management
//   - Reply code tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)
//   - C header   (generated/abi/socks.h)

const std = @import("std");

// ── Enums (matching Idris2 SOCKSABI.Types tag assignments exactly) ───────

/// AuthMethod — matches authMethodToTag
pub const AuthMethod = enum(u8) {
    no_auth = 0,
    gssapi = 1,
    username_password = 2,
    no_acceptable = 3,
};

/// Command — matches commandToTag
pub const Command = enum(u8) {
    connect = 0,
    bind = 1,
    udp_associate = 2,
};

/// AddressType — matches addressTypeToTag
pub const AddressType = enum(u8) {
    ipv4 = 0,
    domain_name = 1,
    ipv6 = 2,
};

/// Reply — matches replyToTag
pub const Reply = enum(u8) {
    succeeded = 0,
    general_failure = 1,
    not_allowed = 2,
    network_unreachable = 3,
    host_unreachable = 4,
    connection_refused = 5,
    ttl_expired = 6,
    command_not_supported = 7,
    address_type_not_supported = 8,
};

/// State — matches stateToTag
pub const State = enum(u8) {
    initial = 0,
    authenticating = 1,
    authenticated = 2,
    connecting = 3,
    established = 4,
    closed = 5,
};

/// SOCKSError — error codes for FFI operations
pub const SOCKSError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_state = 3,
    invalid_auth = 4,
    invalid_command = 5,
    invalid_addr_type = 6,
    invalid_reply = 7,
};

// ── Connection Context ──────────────────────────────────────────────────

const ConnCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current connection state.
    state: State,
    /// Authentication method.
    auth_method: AuthMethod,
    /// Active command (255 = none).
    command: u8,
    /// Address type (255 = none).
    addr_type: u8,
    /// Last reply code (255 = none).
    last_reply: u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: ConnCtx = .{
    .active = false,
    .state = .initial,
    .auth_method = .no_auth,
    .command = 255,
    .addr_type = 255,
    .last_reply = 255,
};

var contexts: [MAX_CONTEXTS]ConnCtx = [_]ConnCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*ConnCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match SOCKSABI.Foreign.abiVersion (currently 1).
pub export fn socks_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new SOCKS5 connection context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn socks_create(auth: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate auth method (0-3)
    if (auth > 3) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.auth_method = @enumFromInt(auth);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a connection context, freeing its slot.
pub export fn socks_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current State tag for a slot.
/// Returns Initial (0) for invalid/inactive slots.
pub export fn socks_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the AuthMethod tag for a slot.
/// Returns NoAuth (0) for invalid/inactive slots.
pub export fn socks_get_auth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.auth_method);
}

/// Get the last Reply tag for a slot.
/// Returns 255 for invalid/inactive slots or if no reply received yet.
pub export fn socks_get_reply(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_reply;
}

/// Get the active Command tag for a slot.
/// Returns 255 for invalid/inactive slots or if no command sent yet.
pub export fn socks_get_command(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.command;
}

/// Get the AddressType tag for a slot.
/// Returns 255 for invalid/inactive slots or if no address type set.
pub export fn socks_get_addr_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.addr_type;
}

// ── State transitions ───────────────────────────────────────────────────

/// Begin authentication. Transitions Initial -> Authenticating.
/// Returns SOCKSError tag.
pub export fn socks_authenticate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SOCKSError.invalid_slot);

    if (ctx.state != .initial) {
        return @intFromEnum(SOCKSError.invalid_state);
    }

    ctx.state = .authenticating;
    return @intFromEnum(SOCKSError.ok);
}

/// Complete authentication. Transitions Authenticating -> Authenticated
/// (if reply=Succeeded) or Authenticating -> Closed (any other reply).
/// Returns SOCKSError tag.
pub export fn socks_auth_complete(slot: c_int, reply: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SOCKSError.invalid_slot);

    if (ctx.state != .authenticating) {
        return @intFromEnum(SOCKSError.invalid_state);
    }

    if (reply > 8) {
        return @intFromEnum(SOCKSError.invalid_reply);
    }

    ctx.last_reply = reply;
    if (reply == 0) {
        ctx.state = .authenticated;
    } else {
        ctx.state = .closed;
    }
    return @intFromEnum(SOCKSError.ok);
}

/// Send a SOCKS5 command. Transitions Authenticated -> Connecting.
/// Returns SOCKSError tag.
pub export fn socks_connect(slot: c_int, cmd: u8, addr: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SOCKSError.invalid_slot);

    if (ctx.state != .authenticated) {
        return @intFromEnum(SOCKSError.invalid_state);
    }

    if (cmd > 2) {
        return @intFromEnum(SOCKSError.invalid_command);
    }

    if (addr > 2) {
        return @intFromEnum(SOCKSError.invalid_addr_type);
    }

    ctx.command = cmd;
    ctx.addr_type = addr;
    ctx.state = .connecting;
    return @intFromEnum(SOCKSError.ok);
}

/// Complete connection. Transitions Connecting -> Established
/// (if reply=Succeeded) or Connecting -> Closed (any other reply).
/// Returns SOCKSError tag.
pub export fn socks_connect_complete(slot: c_int, reply: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SOCKSError.invalid_slot);

    if (ctx.state != .connecting) {
        return @intFromEnum(SOCKSError.invalid_state);
    }

    if (reply > 8) {
        return @intFromEnum(SOCKSError.invalid_reply);
    }

    ctx.last_reply = reply;
    if (reply == 0) {
        ctx.state = .established;
    } else {
        ctx.state = .closed;
    }
    return @intFromEnum(SOCKSError.ok);
}

/// Close a connection. Transitions any state to Closed.
pub export fn socks_close(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return;
    ctx.state = .closed;
}

// ── Stateless transition validation ─────────────────────────────────────

/// Check whether a state transition is valid.
/// Returns 1 if valid, 0 if not.
pub export fn socks_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Initial (0) -> Authenticating (1)
    if (from == 0 and to == 1) return 1;
    // Authenticating (1) -> Authenticated (2)
    if (from == 1 and to == 2) return 1;
    // Authenticating (1) -> Closed (5) (auth failure)
    if (from == 1 and to == 5) return 1;
    // Authenticated (2) -> Connecting (3)
    if (from == 2 and to == 3) return 1;
    // Connecting (3) -> Established (4)
    if (from == 3 and to == 4) return 1;
    // Connecting (3) -> Closed (5) (connect failure)
    if (from == 3 and to == 5) return 1;
    // Established (4) -> Closed (5)
    if (from == 4 and to == 5) return 1;
    // Initial (0) -> Closed (5)
    if (from == 0 and to == 5) return 1;
    return 0;
}
