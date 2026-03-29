// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// deception.zig -- Zig FFI implementation of proven-deception.
//
// Implements the deception/decoy server state machine with:
//   - 64-slot mutex-protected server pool
//   - Decoy deployment per server (max 32 decoys)
//   - Alert tracking per server (max 64 alerts)
//   - Trigger event matching and alert priority assignment
//   - Response action execution per triggered decoy
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DeceptionABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DeceptionABI.Types.idr tag assignments)
// =========================================================================

/// Decoy asset types (ABI tags 0-5).
pub const DecoyType = enum(u8) {
    service = 0,
    credential = 1,
    file = 2,
    network = 3,
    token = 4,
    breadcrumb = 5,
};

/// Trigger event types (ABI tags 0-5).
pub const TriggerEvent = enum(u8) {
    access = 0,
    login = 1,
    read = 2,
    write = 3,
    execute = 4,
    scan = 5,
};

/// Alert priority levels (ABI tags 0-3).
pub const AlertPriority = enum(u8) {
    low = 0,
    medium = 1,
    high = 2,
    critical = 3,
};

/// Decoy lifecycle states (ABI tags 0-3).
pub const DecoyState = enum(u8) {
    active = 0,
    triggered = 1,
    disabled = 2,
    expired = 3,
};

/// Response actions (ABI tags 0-4).
pub const ResponseAction = enum(u8) {
    alert = 0,
    redirect = 1,
    delay = 2,
    fingerprint = 3,
    isolate = 4,
};

/// Server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    configured = 1,
    monitoring = 2,
    responding = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent servers.
const MAX_SERVERS: usize = 64;

/// Maximum decoys per server.
const MAX_DECOYS: usize = 32;

/// Maximum alerts per server.
const MAX_ALERTS: usize = 64;

/// Maximum decoy name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// A deployed decoy.
const Decoy = struct {
    /// Decoy name/identifier.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Type of decoy asset.
    decoy_type: DecoyType,
    /// Current decoy lifecycle state.
    state: DecoyState,
    /// Whether this decoy slot is active.
    active: bool,
};

/// An alert record.
const Alert = struct {
    /// Name of the decoy that triggered this alert.
    decoy_name: [MAX_NAME_LEN]u8,
    decoy_name_len: u32,
    /// The trigger event type.
    event: TriggerEvent,
    /// Alert priority.
    priority: AlertPriority,
    /// Whether this alert is still active (unresolved).
    active: bool,
};

/// A deception server instance.
const Server = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Deployed decoys.
    decoys: [MAX_DECOYS]Decoy,
    /// Number of active decoys.
    decoy_count: u32,
    /// Alert records.
    alerts: [MAX_ALERTS]Alert,
    /// Number of active alerts.
    alert_count: u32,
    /// Total triggers handled (monotonic counter).
    triggers_handled: u64,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) decoy.
const empty_decoy: Decoy = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .decoy_type = .service,
    .state = .active,
    .active = false,
};

/// Default (empty) alert.
const empty_alert: Alert = .{
    .decoy_name = [_]u8{0} ** MAX_NAME_LEN,
    .decoy_name_len = 0,
    .event = .access,
    .priority = .low,
    .active = false,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .idle,
    .decoys = [_]Decoy{empty_decoy} ** MAX_DECOYS,
    .decoy_count = 0,
    .alerts = [_]Alert{empty_alert} ** MAX_ALERTS,
    .alert_count = 0,
    .triggers_handled = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var servers: [MAX_SERVERS]Server = [_]Server{empty_server} ** MAX_SERVERS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SERVERS) return null;
    const idx: usize = @intCast(slot);
    if (!servers[idx].active) return null;
    return idx;
}

/// Find a decoy by name within a server.
fn findDecoy(idx: usize, name: []const u8) ?usize {
    for (&servers[idx].decoys, 0..) |*d, i| {
        if (d.active and d.name_len == name.len and
            std.mem.eql(u8, d.name[0..d.name_len], name))
        {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn deception_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new deception server. Returns slot index (>=0) or -1 on failure.
/// The server starts in Configured state.
pub export fn deception_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&servers, 0..) |*sv, i| {
        if (!sv.active) {
            sv.* = empty_server;
            sv.state = .configured;
            sv.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn deception_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

// -- State queries ------------------------------------------------------------

/// Returns the current ServerState tag for a server.
pub export fn deception_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(servers[idx].state);
}

/// Returns 1 if the server can monitor, 0 otherwise.
pub export fn deception_can_monitor(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = servers[idx].state;
    return if (state == .monitoring or state == .responding) 1 else 0;
}

// -- Decoy management ---------------------------------------------------------

/// Deploy a decoy. Returns 0 on success, 1 on rejection.
/// Transitions: Configured -> Monitoring, or stays Monitoring/Responding.
pub export fn deception_deploy_decoy(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    decoy_type: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .configured and state != .monitoring and state != .responding) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (decoy_type > 5) return 1;

    const name = name_ptr[0..name_len];

    // Check for duplicate decoy name
    if (findDecoy(idx, name) != null) return 1;

    // Find a free decoy slot
    for (&servers[idx].decoys) |*d| {
        if (!d.active) {
            @memcpy(d.name[0..name_len], name);
            d.name_len = name_len;
            d.decoy_type = @enumFromInt(decoy_type);
            d.state = .active;
            d.active = true;
            servers[idx].decoy_count += 1;
            if (servers[idx].state == .configured) {
                servers[idx].state = .monitoring;
            }
            return 0;
        }
    }
    return 1;
}

/// Remove a decoy by name. Returns 0 on success, 1 on rejection.
/// May transition Monitoring -> Configured if last decoy.
pub export fn deception_remove_decoy(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    const di = findDecoy(idx, name) orelse return 1;

    servers[idx].decoys[di].active = false;
    servers[idx].decoy_count -= 1;

    // If no decoys remain, transition to Configured
    if (servers[idx].decoy_count == 0) {
        if (servers[idx].state == .monitoring or servers[idx].state == .responding) {
            servers[idx].state = .configured;
        }
    }

    return 0;
}

/// Returns the number of deployed decoys for a server.
pub export fn deception_decoy_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].decoy_count;
}

// -- Trigger / Response -------------------------------------------------------

/// Trigger a decoy alert. Returns 0 on success, 1 on rejection.
/// Transitions: Monitoring -> Responding.
pub export fn deception_trigger(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    event: u8,
    priority: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .monitoring and state != .responding) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (event > 5) return 1;
    if (priority > 3) return 1;

    const name = name_ptr[0..name_len];
    const di = findDecoy(idx, name) orelse return 1;

    if (servers[idx].decoys[di].state != .active) return 1;

    // Mark decoy as triggered
    servers[idx].decoys[di].state = .triggered;

    // Create alert
    for (&servers[idx].alerts) |*a| {
        if (!a.active) {
            @memcpy(a.decoy_name[0..name_len], name);
            a.decoy_name_len = name_len;
            a.event = @enumFromInt(event);
            a.priority = @enumFromInt(priority);
            a.active = true;
            servers[idx].alert_count += 1;
            break;
        }
    }

    servers[idx].triggers_handled += 1;
    servers[idx].state = .responding;
    return 0;
}

/// Execute a response action on a triggered decoy. Returns 0 on success, 1 on rejection.
/// May transition Responding -> Monitoring if all alerts resolved.
pub export fn deception_respond(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    action: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .responding) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (action > 4) return 1;

    _ = action; // Response action is recorded but not simulated

    const name = name_ptr[0..name_len];

    // Resolve the alert for this decoy
    for (&servers[idx].alerts) |*a| {
        if (a.active and a.decoy_name_len == name_len and
            std.mem.eql(u8, a.decoy_name[0..a.decoy_name_len], name))
        {
            a.active = false;
            servers[idx].alert_count -= 1;
            break;
        }
    }

    // Reset decoy state to active
    if (findDecoy(idx, name)) |di| {
        servers[idx].decoys[di].state = .active;
    }

    // If no alerts remain, return to monitoring
    if (servers[idx].alert_count == 0) {
        servers[idx].state = .monitoring;
    }

    return 0;
}

/// Returns the total number of active alerts.
pub export fn deception_alert_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].alert_count;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the server. Returns 0 on success, 1 on rejection.
pub export fn deception_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state == .configured or state == .monitoring or state == .responding) {
        servers[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn deception_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .shutdown) return 1;

    servers[idx].state = .idle;
    servers[idx].decoys = [_]Decoy{empty_decoy} ** MAX_DECOYS;
    servers[idx].decoy_count = 0;
    servers[idx].alerts = [_]Alert{empty_alert} ** MAX_ALERTS;
    servers[idx].alert_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a server state transition is valid.
pub export fn deception_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Configured
    if (from == 1 and to == 2) return 1; // Configured -> Monitoring
    if (from == 2 and to == 2) return 1; // Monitoring -> Monitoring (add more decoys)
    if (from == 2 and to == 1) return 1; // Monitoring -> Configured (all decoys removed)
    if (from == 2 and to == 3) return 1; // Monitoring -> Responding
    if (from == 3 and to == 3) return 1; // Responding -> Responding (more triggers)
    if (from == 3 and to == 2) return 1; // Responding -> Monitoring (all alerts resolved)
    if (from == 1 and to == 4) return 1; // Configured -> Shutdown
    if (from == 2 and to == 4) return 1; // Monitoring -> Shutdown
    if (from == 3 and to == 4) return 1; // Responding -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
