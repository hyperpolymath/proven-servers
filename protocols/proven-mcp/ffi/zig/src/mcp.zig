// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mcp.zig -- Zig FFI implementation of proven-mcp.
//
// Implements the MCP (Model Context Protocol) server state machine with:
//   - 64-slot mutex-protected session pool
//   - Per-session capability bitmask (Tools, Resources, Prompts, Logging, Sampling)
//   - Per-session pending request tracking (max 32 in-flight)
//   - Transport selection per session (Stdio, SSE, WebSocket, StreamableHTTP)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching abi.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching abi.Types.idr tag assignments)
// =========================================================================

/// MCP message types (ABI tags 0-13).
pub const MessageType = enum(u8) {
    initialize = 0,
    initialized = 1,
    ping = 2,
    call_tool = 3,
    tool_result = 4,
    list_tools = 5,
    list_resources = 6,
    read_resource = 7,
    list_prompts = 8,
    get_prompt = 9,
    subscribe = 10,
    unsubscribe = 11,
    notification = 12,
    cancel = 13,
};

/// MCP transport types (ABI tags 0-3).
pub const Transport = enum(u8) {
    stdio = 0,
    sse = 1,
    websocket = 2,
    streamable_http = 3,
};

/// MCP content types (ABI tags 0-3).
pub const ContentType = enum(u8) {
    text = 0,
    image = 1,
    resource = 2,
    embedding = 3,
};

/// MCP error codes (ABI tags 0-5).
pub const ErrorCode = enum(u8) {
    parse_error = 0,
    invalid_request = 1,
    method_not_found = 2,
    invalid_params = 3,
    internal_error = 4,
    timeout = 5,
};

/// MCP server capabilities (ABI tags 0-4).
pub const Capability = enum(u8) {
    tools = 0,
    resources = 1,
    prompts = 2,
    logging = 3,
    sampling = 4,
};

/// MCP session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    connecting = 1,
    ready = 2,
    processing = 3,
    disconnecting = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum pending requests per session.
const MAX_PENDING: usize = 32;

/// Maximum name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// Maximum server name length.
const MAX_SERVER_NAME_LEN: usize = 128;

/// Number of capability bits.
const NUM_CAPABILITIES: usize = 5;

/// A pending request entry.
const PendingRequest = struct {
    /// Request ID.
    req_id: u32,
    /// Tool/method name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Whether this slot is active.
    active: bool,
};

/// Default (empty) pending request.
const empty_pending: PendingRequest = .{
    .req_id = 0,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .active = false,
};

/// An MCP server session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// Transport type.
    transport: Transport,
    /// Server name.
    server_name: [MAX_SERVER_NAME_LEN]u8,
    server_name_len: u32,
    /// Capability bitmask (bit N = capability N enabled).
    capabilities: u8,
    /// Pending requests.
    pending: [MAX_PENDING]PendingRequest,
    /// Number of active pending requests.
    pending_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .transport = .stdio,
    .server_name = [_]u8{0} ** MAX_SERVER_NAME_LEN,
    .server_name_len = 0,
    .capabilities = 0,
    .pending = [_]PendingRequest{empty_pending} ** MAX_PENDING,
    .pending_count = 0,
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
pub export fn mcp_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new MCP session. Returns slot index (>=0) or -1 on failure.
pub export fn mcp_create(
    transport: u8,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (transport > 3) return -1;
    if (name_len == 0 or name_len > MAX_SERVER_NAME_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.transport = @enumFromInt(transport);
            @memcpy(s.server_name[0..name_len], name_ptr[0..name_len]);
            s.server_name_len = name_len;
            s.state = .connecting; // Idle -> Connecting
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn mcp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag for a session.
pub export fn mcp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Initialize session with capabilities bitmask. Transitions Connecting -> Ready.
pub export fn mcp_initialize(slot: c_int, caps_bitmask: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connecting) return 1;

    sessions[idx].capabilities = caps_bitmask;
    sessions[idx].state = .ready;
    return 0;
}

/// Add a single capability. Returns 0 on success, 1 on rejection.
pub export fn mcp_add_capability(slot: c_int, cap: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (cap >= NUM_CAPABILITIES) return 1;

    sessions[idx].capabilities |= (@as(u8, 1) << @intCast(cap));
    return 0;
}

/// Check if a capability is enabled. Returns 1 if yes, 0 if no.
pub export fn mcp_has_capability(slot: c_int, cap: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (cap >= NUM_CAPABILITIES) return 0;

    return if ((sessions[idx].capabilities & (@as(u8, 1) << @intCast(cap))) != 0) 1 else 0;
}

/// Call a tool. Transitions Ready -> Processing. Returns 0 on success.
pub export fn mcp_call_tool(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    req_id: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .processing) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].pending_count >= MAX_PENDING) return 1;

    // Find a free pending slot
    for (&sessions[idx].pending) |*p| {
        if (!p.active) {
            p.req_id = req_id;
            @memcpy(p.name[0..name_len], name_ptr[0..name_len]);
            p.name_len = name_len;
            p.active = true;
            sessions[idx].pending_count += 1;
            sessions[idx].state = .processing;
            return 0;
        }
    }
    return 1;
}

/// Complete a pending request. May transition Processing -> Ready.
pub export fn mcp_complete_request(slot: c_int, req_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;

    for (&sessions[idx].pending) |*p| {
        if (p.active and p.req_id == req_id) {
            p.active = false;
            p.name_len = 0;
            sessions[idx].pending_count -= 1;

            if (sessions[idx].pending_count == 0 and
                sessions[idx].state == .processing)
            {
                sessions[idx].state = .ready;
            }
            return 0;
        }
    }
    return 1;
}

/// Cancel a pending request. Returns 0 on success, 1 on rejection.
pub export fn mcp_cancel_request(slot: c_int, req_id: u32) callconv(.c) u8 {
    // Same logic as complete — just removes the pending entry
    return mcp_complete_request(slot, req_id);
}

/// Returns the number of pending requests.
pub export fn mcp_pending_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].pending_count;
}

/// Disconnect the session. Returns 0 on success, 1 on rejection.
pub export fn mcp_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connecting or state == .ready or state == .processing) {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

/// Complete cleanup. Transitions Disconnecting -> Idle.
pub export fn mcp_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;

    sessions[idx].state = .idle;
    sessions[idx].pending = [_]PendingRequest{empty_pending} ** MAX_PENDING;
    sessions[idx].pending_count = 0;
    sessions[idx].capabilities = 0;

    return 0;
}

/// Returns the transport tag for a session.
pub export fn mcp_transport(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].transport);
}

/// Send a keepalive ping. Only valid from Ready or Processing.
pub export fn mcp_ping(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .processing) return 1;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn mcp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connecting
    if (from == 1 and to == 2) return 1; // Connecting -> Ready
    if (from == 2 and to == 3) return 1; // Ready -> Processing
    if (from == 3 and to == 3) return 1; // Processing -> Processing
    if (from == 3 and to == 2) return 1; // Processing -> Ready
    if (from == 1 and to == 4) return 1; // Connecting -> Disconnecting
    if (from == 2 and to == 4) return 1; // Ready -> Disconnecting
    if (from == 3 and to == 4) return 1; // Processing -> Disconnecting
    if (from == 4 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}
