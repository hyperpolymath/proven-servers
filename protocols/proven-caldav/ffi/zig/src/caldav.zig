// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// caldav.zig -- Zig FFI implementation of proven-caldav.
//
// Implements the CalDAV (RFC 4791) server state machine with:
//   - 64-slot mutex-protected server pool
//   - Calendar collection management (max 16 per server)
//   - Calendar resource storage per collection (max 64 per calendar)
//   - UID uniqueness enforcement per collection
//   - Supported component type bitmask filtering
//   - ETag tracking for conditional requests
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CalDAVABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching CalDAVABI.Types.idr tag assignments)
// =========================================================================

/// iCalendar component types (ABI tags 0-3).
pub const ComponentType = enum(u8) {
    vevent = 0,
    vtodo = 1,
    vjournal = 2,
    vfreebusy = 3,
};

/// CalDAV request methods (ABI tags 0-6).
pub const CalMethod = enum(u8) {
    get = 0,
    put = 1,
    delete = 2,
    propfind = 3,
    proppatch = 4,
    report = 5,
    mkcalendar = 6,
};

/// Scheduling status (ABI tags 0-4).
pub const ScheduleStatus = enum(u8) {
    needs_action = 0,
    accepted = 1,
    declined = 2,
    tentative = 3,
    delegated = 4,
};

/// CalDAV error conditions (ABI tags 0-5).
pub const CalError = enum(u8) {
    valid_calendar_data = 0,
    no_resource_type_change = 1,
    supported_component_mismatch = 2,
    max_resource_size = 3,
    uid_conflict = 4,
    precondition_failed = 5,
};

/// CalDAV server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    bound = 1,
    serving = 2,
    scheduling = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent servers.
const MAX_SERVERS: usize = 64;

/// Maximum calendars per server.
const MAX_CALENDARS: usize = 16;

/// Maximum resources per calendar.
const MAX_RESOURCES: usize = 32;

/// Maximum path/UID length in bytes.
const MAX_NAME_LEN: usize = 128;

/// A calendar resource (event, todo, etc.).
const CalResource = struct {
    /// Unique identifier (UID property from iCalendar).
    uid: [MAX_NAME_LEN]u8,
    uid_len: u32,
    /// Component type tag.
    component_type: u8,
    /// ETag for conditional requests.
    etag: u32,
    /// Whether this resource slot is active.
    active: bool,
};

/// A calendar collection.
const Calendar = struct {
    /// Collection path (e.g., "/calendars/personal").
    path: [MAX_NAME_LEN]u8,
    path_len: u32,
    /// Supported component types bitmask:
    /// bit0=VEVENT, bit1=VTODO, bit2=VJOURNAL, bit3=VFREEBUSY.
    supported_components: u8,
    /// Calendar resources.
    resources: [MAX_RESOURCES]CalResource,
    /// Number of active resources.
    resource_count: u32,
    /// Whether this calendar slot is active.
    active: bool,
};

/// A CalDAV server instance.
const Server = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Bound HTTP port.
    port: u16,
    /// Calendar collections.
    calendars: [MAX_CALENDARS]Calendar,
    /// Number of active calendars.
    calendar_count: u32,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) resource.
const empty_resource: CalResource = .{
    .uid = [_]u8{0} ** MAX_NAME_LEN,
    .uid_len = 0,
    .component_type = 0,
    .etag = 0,
    .active = false,
};

/// Default (empty) calendar.
const empty_calendar: Calendar = .{
    .path = [_]u8{0} ** MAX_NAME_LEN,
    .path_len = 0,
    .supported_components = 0x0F, // all types by default
    .resources = [_]CalResource{empty_resource} ** MAX_RESOURCES,
    .resource_count = 0,
    .active = false,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .idle,
    .port = 0,
    .calendars = [_]Calendar{empty_calendar} ** MAX_CALENDARS,
    .calendar_count = 0,
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

/// Find a calendar by path within a server.
fn findCalendar(idx: usize, path: []const u8) ?usize {
    for (&servers[idx].calendars, 0..) |*cal, i| {
        if (cal.active and cal.path_len == path.len and
            std.mem.eql(u8, cal.path[0..cal.path_len], path))
        {
            return i;
        }
    }
    return null;
}

/// Find a resource by UID within a calendar.
fn findResource(idx: usize, ci: usize, uid: []const u8) ?usize {
    for (&servers[idx].calendars[ci].resources, 0..) |*r, i| {
        if (r.active and r.uid_len == uid.len and
            std.mem.eql(u8, r.uid[0..r.uid_len], uid))
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
pub export fn caldav_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new CalDAV server. Returns slot index (>=0) or -1 on failure.
pub export fn caldav_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&servers, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_server;
            s.port = port;
            s.state = .bound; // Idle -> Bound
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn caldav_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

// -- State queries ------------------------------------------------------------

/// Returns the current ServerState tag.
pub export fn caldav_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(servers[idx].state);
}

/// Returns 1 if the server can serve requests, 0 otherwise.
pub export fn caldav_can_serve(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = servers[idx].state;
    return if (state == .serving or state == .scheduling) 1 else 0;
}

// -- Calendar management ------------------------------------------------------

/// Create a calendar collection. Returns 0 on success, 1 on rejection.
/// Transitions: Bound -> Serving, or stays Serving/Scheduling.
pub export fn caldav_create_calendar(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    supported_components: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .bound and state != .serving and state != .scheduling) return 1;
    if (path_len == 0 or path_len > MAX_NAME_LEN) return 1;
    if (supported_components == 0 or supported_components > 0x0F) return 1;

    const path = path_ptr[0..path_len];

    // Reject duplicate calendar path
    if (findCalendar(idx, path) != null) return 1;

    // Find a free calendar slot
    for (&servers[idx].calendars) |*cal| {
        if (!cal.active) {
            cal.* = empty_calendar;
            @memcpy(cal.path[0..path_len], path);
            cal.path_len = path_len;
            cal.supported_components = supported_components;
            cal.active = true;
            servers[idx].calendar_count += 1;
            if (servers[idx].state == .bound) {
                servers[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Delete a calendar collection. Returns 0 on success, 1 on rejection.
/// May transition Serving -> Bound if last calendar.
pub export fn caldav_delete_calendar(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_NAME_LEN) return 1;

    const path = path_ptr[0..path_len];
    const ci = findCalendar(idx, path) orelse return 1;

    servers[idx].calendars[ci] = empty_calendar;
    servers[idx].calendar_count -= 1;

    if (servers[idx].calendar_count == 0) {
        if (servers[idx].state == .serving or servers[idx].state == .scheduling) {
            servers[idx].state = .bound;
        }
    }

    return 0;
}

/// Returns the number of calendar collections.
pub export fn caldav_calendar_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].calendar_count;
}

// -- Resource management ------------------------------------------------------

/// Put (create/update) a calendar resource. Returns 0 on success, 1 on rejection.
/// Enforces UID uniqueness within a calendar collection.
/// Enforces supported component type bitmask.
pub export fn caldav_put_resource(
    slot: c_int,
    cal_path_ptr: [*]const u8,
    cal_path_len: u32,
    uid_ptr: [*]const u8,
    uid_len: u32,
    component_type: u8,
    etag: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .serving and state != .scheduling) return 1;
    if (cal_path_len == 0 or cal_path_len > MAX_NAME_LEN) return 1;
    if (uid_len == 0 or uid_len > MAX_NAME_LEN) return 1;
    if (component_type > 3) return 1;

    const cal_path = cal_path_ptr[0..cal_path_len];
    const ci = findCalendar(idx, cal_path) orelse return 1;

    // Check supported component type
    const component_bit = @as(u8, 1) << @intCast(component_type);
    if (servers[idx].calendars[ci].supported_components & component_bit == 0) return 1;

    const uid = uid_ptr[0..uid_len];

    // Check for existing resource with same UID (update case)
    if (findResource(idx, ci, uid)) |ri| {
        // Update existing resource
        servers[idx].calendars[ci].resources[ri].component_type = component_type;
        servers[idx].calendars[ci].resources[ri].etag = etag;
        return 0;
    }

    // Find a free resource slot (create case)
    for (&servers[idx].calendars[ci].resources) |*r| {
        if (!r.active) {
            @memcpy(r.uid[0..uid_len], uid);
            r.uid_len = uid_len;
            r.component_type = component_type;
            r.etag = etag;
            r.active = true;
            servers[idx].calendars[ci].resource_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Delete a calendar resource. Returns 0 on success, 1 on rejection.
pub export fn caldav_delete_resource(
    slot: c_int,
    cal_path_ptr: [*]const u8,
    cal_path_len: u32,
    uid_ptr: [*]const u8,
    uid_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (cal_path_len == 0 or cal_path_len > MAX_NAME_LEN) return 1;
    if (uid_len == 0 or uid_len > MAX_NAME_LEN) return 1;

    const cal_path = cal_path_ptr[0..cal_path_len];
    const ci = findCalendar(idx, cal_path) orelse return 1;

    const uid = uid_ptr[0..uid_len];
    const ri = findResource(idx, ci, uid) orelse return 1;

    servers[idx].calendars[ci].resources[ri] = empty_resource;
    servers[idx].calendars[ci].resource_count -= 1;

    return 0;
}

/// Returns the number of resources in a calendar.
pub export fn caldav_resource_count(
    slot: c_int,
    cal_path_ptr: [*]const u8,
    cal_path_len: u32,
) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (cal_path_len == 0 or cal_path_len > MAX_NAME_LEN) return 0;

    const cal_path = cal_path_ptr[0..cal_path_len];
    const ci = findCalendar(idx, cal_path) orelse return 0;

    return servers[idx].calendars[ci].resource_count;
}

/// Returns the ETag for a resource, or 0 if not found.
pub export fn caldav_get_etag(
    slot: c_int,
    cal_path_ptr: [*]const u8,
    cal_path_len: u32,
    uid_ptr: [*]const u8,
    uid_len: u32,
) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (cal_path_len == 0 or cal_path_len > MAX_NAME_LEN) return 0;
    if (uid_len == 0 or uid_len > MAX_NAME_LEN) return 0;

    const cal_path = cal_path_ptr[0..cal_path_len];
    const ci = findCalendar(idx, cal_path) orelse return 0;

    const uid = uid_ptr[0..uid_len];
    const ri = findResource(idx, ci, uid) orelse return 0;

    return servers[idx].calendars[ci].resources[ri].etag;
}

/// Returns total resources across all calendars.
pub export fn caldav_total_resources(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    var total: u32 = 0;
    for (&servers[idx].calendars) |*cal| {
        if (cal.active) {
            total += cal.resource_count;
        }
    }
    return total;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the server. Returns 0 on success, 1 on rejection.
pub export fn caldav_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state == .bound or state == .serving or state == .scheduling) {
        servers[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn caldav_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .shutdown) return 1;

    servers[idx].state = .idle;
    servers[idx].calendars = [_]Calendar{empty_calendar} ** MAX_CALENDARS;
    servers[idx].calendar_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a server state transition is valid.
pub export fn caldav_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Serving
    if (from == 2 and to == 2) return 1; // Serving -> Serving
    if (from == 2 and to == 1) return 1; // Serving -> Bound
    if (from == 2 and to == 3) return 1; // Serving -> Scheduling
    if (from == 3 and to == 3) return 1; // Scheduling -> Scheduling
    if (from == 3 and to == 2) return 1; // Scheduling -> Serving
    if (from == 1 and to == 4) return 1; // Bound -> Shutdown
    if (from == 2 and to == 4) return 1; // Serving -> Shutdown
    if (from == 3 and to == 4) return 1; // Scheduling -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
