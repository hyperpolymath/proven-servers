// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// federation.zig -- Zig FFI implementation of proven-federation.
//
// Implements the ActivityPub/federation server state machine with:
//   - 64-slot mutex-protected session pool
//   - Actor registration and trust level management
//   - Activity submission and delivery tracking
//   - Delivery queue with status tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching FederationABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching FederationABI.Types.idr tag assignments)
// =========================================================================

/// Activity types (ABI tags 0-10).
pub const ActivityType = enum(u8) {
    create = 0,
    update = 1,
    delete = 2,
    follow = 3,
    accept = 4,
    reject = 5,
    announce = 6,
    like = 7,
    undo = 8,
    block = 9,
    flag = 10,
};

/// Actor types (ABI tags 0-4).
pub const ActorType = enum(u8) {
    person = 0,
    service = 1,
    application = 2,
    group = 3,
    organization = 4,
};

/// Delivery status codes (ABI tags 0-4).
pub const DeliveryStatus = enum(u8) {
    pending = 0,
    delivered = 1,
    failed = 2,
    rejected = 3,
    deferred = 4,
};

/// Trust levels (ABI tags 0-4).
pub const TrustLevel = enum(u8) {
    self_signed = 0,
    peer_verified = 1,
    federation_trusted = 2,
    revoked = 3,
    unknown = 4,
};

/// Object types (ABI tags 0-8).
pub const ObjectType = enum(u8) {
    note = 0,
    article = 1,
    image = 2,
    video = 3,
    audio = 4,
    document = 5,
    event = 6,
    collection = 7,
    ordered_collection = 8,
};

/// Server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    active = 1,
    processing = 2,
    delivering = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum domain name length.
const MAX_NAME_LEN: usize = 256;

/// Maximum actors per session.
const MAX_ACTORS: usize = 128;

/// Maximum activities per session.
const MAX_ACTIVITIES: usize = 256;

/// An actor entry.
const Actor = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    actor_type: ActorType,
    trust: TrustLevel,
    active: bool,
};

/// Default (empty) actor.
const empty_actor: Actor = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .actor_type = .person,
    .trust = .unknown,
    .active = false,
};

/// An activity entry.
const Activity = struct {
    activity_type: ActivityType,
    actor_idx: u32,
    object_type: ObjectType,
    delivery_status: DeliveryStatus,
    active: bool,
};

/// Default (empty) activity.
const empty_activity: Activity = .{
    .activity_type = .create,
    .actor_idx = 0,
    .object_type = .note,
    .delivery_status = .pending,
    .active = false,
};

/// A federation session.
const Session = struct {
    state: ServerState,
    domain: [MAX_NAME_LEN]u8,
    domain_len: u32,
    actors: [MAX_ACTORS]Actor,
    actor_count: u32,
    activities: [MAX_ACTIVITIES]Activity,
    activity_count: u32,
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .domain = [_]u8{0} ** MAX_NAME_LEN,
    .domain_len = 0,
    .actors = [_]Actor{empty_actor} ** MAX_ACTORS,
    .actor_count = 0,
    .activities = [_]Activity{empty_activity} ** MAX_ACTIVITIES,
    .activity_count = 0,
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

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn fed_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new federation session. Returns slot (>=0) or -1.
/// Starts in Active state.
pub export fn fed_create(
    domain_ptr: [*]const u8,
    domain_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (domain_len == 0 or domain_len > MAX_NAME_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.domain[0..domain_len], domain_ptr[0..domain_len]);
            s.domain_len = domain_len;
            s.state = .active;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn fed_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn fed_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

// -- Actor management -----------------------------------------------------

/// Register an actor. Returns 0 on success, 1 on rejection.
pub export fn fed_register_actor(
    slot: c_int,
    actor_type: u8,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (actor_type > 4) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    for (&sessions[idx].actors) |*a| {
        if (!a.active) {
            @memcpy(a.name[0..name_len], name_ptr[0..name_len]);
            a.name_len = name_len;
            a.actor_type = @enumFromInt(actor_type);
            a.trust = .unknown;
            a.active = true;
            sessions[idx].actor_count += 1;
            return 0;
        }
    }
    return 1;
}

pub export fn fed_actor_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].actor_count;
}

// -- Activity submission --------------------------------------------------

/// Submit an activity. Returns 0 on success, 1 on rejection.
/// Transitions Active -> Processing -> Active (simulated immediate).
pub export fn fed_submit_activity(
    slot: c_int,
    activity_type: u8,
    actor_idx: u32,
    object_type: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (activity_type > 10) return 1;
    if (object_type > 8) return 1;
    if (actor_idx >= sessions[idx].actor_count) return 1;

    for (&sessions[idx].activities) |*act| {
        if (!act.active) {
            act.activity_type = @enumFromInt(activity_type);
            act.actor_idx = actor_idx;
            act.object_type = @enumFromInt(object_type);
            act.delivery_status = .pending;
            act.active = true;
            sessions[idx].activity_count += 1;
            return 0;
        }
    }
    return 1;
}

pub export fn fed_activity_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].activity_count;
}

// -- Delivery lifecycle ---------------------------------------------------

/// Begin delivery of pending activities.
/// Transitions Active -> Processing -> Delivering.
pub export fn fed_begin_delivery(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    sessions[idx].state = .delivering;
    return 0;
}

/// Finish delivery, marking all pending activities with given status.
/// Transitions Delivering -> Active.
pub export fn fed_finish_delivery(slot: c_int, status: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .delivering) return 1;
    if (status > 4) return 1;

    for (&sessions[idx].activities) |*act| {
        if (act.active and act.delivery_status == .pending) {
            act.delivery_status = @enumFromInt(status);
        }
    }
    sessions[idx].state = .active;
    return 0;
}

// -- Trust management -----------------------------------------------------

/// Set trust level for an actor. Returns 0 on success, 1 on rejection.
pub export fn fed_set_trust(slot: c_int, actor_idx: u32, trust: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (trust > 4) return 1;

    // Find the actor by index
    var count: u32 = 0;
    for (&sessions[idx].actors) |*a| {
        if (a.active) {
            if (count == actor_idx) {
                a.trust = @enumFromInt(trust);
                return 0;
            }
            count += 1;
        }
    }
    return 1;
}

/// Get trust level for an actor. Returns TrustLevel tag.
pub export fn fed_get_trust(slot: c_int, actor_idx: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(TrustLevel.unknown);

    var count: u32 = 0;
    for (&sessions[idx].actors) |*a| {
        if (a.active) {
            if (count == actor_idx) {
                return @intFromEnum(a.trust);
            }
            count += 1;
        }
    }
    return @intFromEnum(TrustLevel.unknown);
}

// -- Shutdown / Cleanup ---------------------------------------------------

pub export fn fed_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .active or state == .processing or state == .delivering) {
        sessions[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

pub export fn fed_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].actors = [_]Actor{empty_actor} ** MAX_ACTORS;
    sessions[idx].actor_count = 0;
    sessions[idx].activities = [_]Activity{empty_activity} ** MAX_ACTIVITIES;
    sessions[idx].activity_count = 0;

    return 0;
}

// -- Stateless transition table -------------------------------------------

pub export fn fed_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Active
    if (from == 1 and to == 2) return 1; // Active -> Processing
    if (from == 2 and to == 1) return 1; // Processing -> Active
    if (from == 2 and to == 3) return 1; // Processing -> Delivering
    if (from == 3 and to == 1) return 1; // Delivering -> Active
    if (from == 1 and to == 4) return 1; // Active -> Shutdown
    if (from == 2 and to == 4) return 1; // Processing -> Shutdown
    if (from == 3 and to == 4) return 1; // Delivering -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
