// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mqtt.zig -- Zig FFI implementation of proven-mqtt.
//
// Implements the MQTT broker state machine with:
//   - 64-slot mutex-protected session pool
//   - Topic subscription tree (fixed array, max 256 subscriptions per session)
//   - QoS delivery tracking (packet ID -> QoSDeliveryState)
//   - Retained message store (fixed array, max 128 retained messages)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching MQTTABI.Layout.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching MQTTABI.Layout.idr tag assignments)
// =========================================================================

/// MQTT packet types (ABI tags 0-14, NOT wire codes).
pub const PacketType = enum(u8) {
    connect = 0,
    connack = 1,
    publish = 2,
    puback = 3,
    pubrec = 4,
    pubrel = 5,
    pubcomp = 6,
    subscribe = 7,
    suback = 8,
    unsubscribe = 9,
    unsuback = 10,
    pingreq = 11,
    pingresp = 12,
    disconnect = 13,
    auth = 14,
};

/// MQTT QoS levels (tags 0-2).
pub const QoS = enum(u8) {
    at_most_once = 0,
    at_least_once = 1,
    exactly_once = 2,
};

/// CONNACK return codes (tags 0-5).
pub const ConnAckCode = enum(u8) {
    connection_accepted = 0,
    unacceptable_protocol = 1,
    identifier_rejected = 2,
    server_unavailable = 3,
    bad_credentials = 4,
    not_authorised = 5,
};

/// MQTT protocol version (tags 0-1).
pub const MQTTVersion = enum(u8) {
    mqtt311 = 0,
    mqtt50 = 1,
};

/// Broker session lifecycle states (tags 0-4).
pub const BrokerState = enum(u8) {
    idle = 0,
    connected = 1,
    subscribed = 2,
    publishing = 3,
    disconnecting = 4,
};

/// QoS delivery flow states (tags 0-6).
pub const QoSDeliveryState = enum(u8) {
    qd_idle = 0,
    awaiting_puback = 1,
    awaiting_pubrec = 2,
    awaiting_pubrel = 3,
    awaiting_pubcomp = 4,
    qd_complete = 5,
    qd_failed = 6,
};

/// MQTTv5 property types (tags 0-9).
pub const PropertyType = enum(u8) {
    session_expiry_interval = 0,
    receive_maximum = 1,
    maximum_qos = 2,
    retain_available = 3,
    maximum_packet_size = 4,
    topic_alias_maximum = 5,
    wildcard_sub_available = 6,
    sub_id_available = 7,
    shared_sub_available = 8,
    server_keep_alive = 9,
};

/// Packet direction (tags 0-2).
pub const PacketDirection = enum(u8) {
    client_to_server = 0,
    server_to_client = 1,
    bidirectional = 2,
};

/// SUBACK return codes (tags 0-3).
pub const SubAckCode = enum(u8) {
    granted_qos0 = 0,
    granted_qos1 = 1,
    granted_qos2 = 2,
    sub_failure = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum subscriptions per session.
const MAX_SUBSCRIPTIONS: usize = 256;

/// Maximum in-flight QoS deliveries per session.
const MAX_INFLIGHT: usize = 64;

/// Maximum retained messages across all sessions.
const MAX_RETAINED: usize = 128;

/// Maximum topic length in bytes.
const MAX_TOPIC_LEN: usize = 256;

/// Maximum payload length for retained messages.
const MAX_PAYLOAD_LEN: usize = 4096;

/// A single topic subscription entry.
const Subscription = struct {
    /// Topic filter bytes (null-terminated within buffer).
    filter: [MAX_TOPIC_LEN]u8,
    /// Actual length of the filter string.
    filter_len: u32,
    /// Granted QoS level.
    qos: QoS,
    /// Whether this slot is in use.
    active: bool,
};

/// A single in-flight QoS delivery tracker.
const QoSTracker = struct {
    /// MQTT packet identifier.
    packet_id: u16,
    /// Current delivery state.
    state: QoSDeliveryState,
    /// QoS level of this delivery.
    qos_level: QoS,
    /// Whether this tracker slot is in use.
    active: bool,
};

/// A retained message.
const RetainedMessage = struct {
    /// Topic name.
    topic: [MAX_TOPIC_LEN]u8,
    /// Topic length.
    topic_len: u32,
    /// Payload data.
    payload: [MAX_PAYLOAD_LEN]u8,
    /// Payload length.
    payload_len: u32,
    /// QoS level of the retained message.
    qos: QoS,
    /// Whether this slot is in use.
    active: bool,
};

/// A broker session.
const Session = struct {
    /// Current broker lifecycle state.
    state: BrokerState,
    /// MQTT protocol version.
    version: MQTTVersion,
    /// Whether this is a clean session.
    clean_session: bool,
    /// Keep-alive interval in seconds.
    keep_alive: u16,
    /// Topic subscriptions (fixed array tree).
    subscriptions: [MAX_SUBSCRIPTIONS]Subscription,
    /// Number of active subscriptions.
    sub_count: u32,
    /// In-flight QoS delivery trackers.
    inflight: [MAX_INFLIGHT]QoSTracker,
    /// Whether this session slot is in use.
    active: bool,
    /// Whether subscriptions existed before entering Publishing state.
    had_subs_before_publish: bool,
};

/// Default (empty) subscription entry.
const empty_sub: Subscription = .{
    .filter = [_]u8{0} ** MAX_TOPIC_LEN,
    .filter_len = 0,
    .qos = .at_most_once,
    .active = false,
};

/// Default (empty) QoS tracker entry.
const empty_tracker: QoSTracker = .{
    .packet_id = 0,
    .state = .qd_idle,
    .qos_level = .at_most_once,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .version = .mqtt311,
    .clean_session = true,
    .keep_alive = 0,
    .subscriptions = [_]Subscription{empty_sub} ** MAX_SUBSCRIPTIONS,
    .sub_count = 0,
    .inflight = [_]QoSTracker{empty_tracker} ** MAX_INFLIGHT,
    .active = false,
    .had_subs_before_publish = false,
};

/// Default (empty) retained message.
const empty_retained: RetainedMessage = .{
    .topic = [_]u8{0} ** MAX_TOPIC_LEN,
    .topic_len = 0,
    .payload = [_]u8{0} ** MAX_PAYLOAD_LEN,
    .payload_len = 0,
    .qos = .at_most_once,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var retained: [MAX_RETAINED]RetainedMessage = [_]RetainedMessage{empty_retained} ** MAX_RETAINED;
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

/// Find an in-flight tracker by packet ID within a session.
fn findTracker(idx: usize, packet_id: u16) ?usize {
    for (&sessions[idx].inflight, 0..) |*t, i| {
        if (t.active and t.packet_id == packet_id) return i;
    }
    return null;
}

/// Allocate a new in-flight tracker slot.
fn allocTracker(idx: usize, packet_id: u16, qos_level: QoS) ?usize {
    for (&sessions[idx].inflight, 0..) |*t, i| {
        if (!t.active) {
            t.* = .{
                .packet_id = packet_id,
                .state = .qd_idle,
                .qos_level = qos_level,
                .active = true,
            };
            return i;
        }
    }
    return null;
}

/// Count active in-flight trackers for a session.
fn countInflight(idx: usize) u32 {
    var count: u32 = 0;
    for (&sessions[idx].inflight) |*t| {
        if (t.active and t.state != .qd_complete and t.state != .qd_failed) count += 1;
    }
    return count;
}

/// Check if a broker state allows publishing.
fn canPublishState(state: BrokerState) bool {
    return state == .connected or state == .subscribed;
}

/// Check if a broker state allows subscribing.
fn canSubscribeState(state: BrokerState) bool {
    return state == .connected or state == .subscribed;
}

/// Match a topic name against a topic filter (MQTT 3.1.1 Section 4.7).
/// Both are raw byte slices. Supports '+' (single level) and '#' (multi level).
fn matchTopic(topic: []const u8, filter: []const u8) bool {
    var ti: usize = 0;
    var fi: usize = 0;

    while (fi < filter.len) {
        if (filter[fi] == '#') {
            // '#' must be last character (optionally preceded by '/')
            return true;
        } else if (filter[fi] == '+') {
            // '+' matches exactly one topic level
            if (ti >= topic.len) return false;
            // Consume all characters in this topic level
            while (ti < topic.len and topic[ti] != '/') : (ti += 1) {}
            fi += 1;
        } else {
            // Literal match
            if (ti >= topic.len) return false;
            if (topic[ti] != filter[fi]) return false;
            ti += 1;
            fi += 1;
        }
    }

    return ti == topic.len;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn mqtt_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new MQTT session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Connected state (Idle -> Connected transition applied).
pub export fn mqtt_create(version: u8, clean_session: u8, keep_alive: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate version tag
    if (version > 1) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.version = @enumFromInt(version);
            s.clean_session = (clean_session != 0);
            s.keep_alive = keep_alive;
            s.state = .connected; // Idle -> Connected (ClientConnected)
            s.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

/// Destroy a session, releasing its slot.
pub export fn mqtt_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries ------------------------------------------------------------

/// Returns the current BrokerState tag for a session.
pub export fn mqtt_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle as fallback
    return @intFromEnum(sessions[idx].state);
}

/// Returns the MQTTVersion tag for a session.
pub export fn mqtt_version(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return @intFromEnum(sessions[idx].version);
}

/// Returns 1 if the session can publish, 0 otherwise.
pub export fn mqtt_can_publish(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (canPublishState(sessions[idx].state)) 1 else 0;
}

/// Returns 1 if the session can subscribe, 0 otherwise.
pub export fn mqtt_can_subscribe(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (canSubscribeState(sessions[idx].state)) 1 else 0;
}

/// Returns the number of active subscriptions for a session.
pub export fn mqtt_subscription_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].sub_count;
}

// -- Subscribe / Unsubscribe --------------------------------------------------

/// Subscribe to a topic filter. Returns 0 on success, 1 on rejection.
/// Transitions: Connected -> Subscribed, or Subscribed -> Subscribed.
pub export fn mqtt_subscribe(slot: c_int, topic_ptr: [*]const u8, topic_len: u32, qos: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (!canSubscribeState(sessions[idx].state)) return 1;
    if (qos > 2) return 1;
    if (topic_len == 0 or topic_len > MAX_TOPIC_LEN) return 1;

    // Find a free subscription slot
    for (&sessions[idx].subscriptions) |*sub| {
        if (!sub.active) {
            @memcpy(sub.filter[0..topic_len], topic_ptr[0..topic_len]);
            sub.filter_len = topic_len;
            sub.qos = @enumFromInt(qos);
            sub.active = true;
            sessions[idx].sub_count += 1;
            sessions[idx].state = .subscribed;
            return 0;
        }
    }
    return 1; // no free subscription slots
}

/// Unsubscribe from a topic filter. Returns 0 on success, 1 on rejection.
/// May transition Subscribed -> Connected if no subscriptions remain.
pub export fn mqtt_unsubscribe(slot: c_int, topic_ptr: [*]const u8, topic_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .subscribed and sessions[idx].state != .connected) return 1;
    if (topic_len == 0 or topic_len > MAX_TOPIC_LEN) return 1;

    const filter = topic_ptr[0..topic_len];

    for (&sessions[idx].subscriptions) |*sub| {
        if (sub.active and sub.filter_len == topic_len and
            std.mem.eql(u8, sub.filter[0..sub.filter_len], filter))
        {
            sub.active = false;
            sub.filter_len = 0;
            sessions[idx].sub_count -= 1;

            // If no subscriptions remain, transition Subscribed -> Connected
            if (sessions[idx].sub_count == 0 and sessions[idx].state == .subscribed) {
                sessions[idx].state = .connected;
            }
            return 0;
        }
    }
    return 1; // topic not found
}

// -- Publish ------------------------------------------------------------------

/// Publish a message. Returns 0 on success, 1 on rejection.
/// For QoS 0: fire-and-forget (no state change).
/// For QoS 1/2: begins delivery tracking.
/// If retain=1, stores/replaces the retained message for the topic.
pub export fn mqtt_publish(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
    payload_ptr: [*]const u8,
    payload_len: u32,
    qos: u8,
    retain: u8,
    packet_id: u16,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (!canPublishState(sessions[idx].state)) return 1;
    if (qos > 2) return 1;
    if (topic_len == 0 or topic_len > MAX_TOPIC_LEN) return 1;

    const qos_level: QoS = @enumFromInt(qos);

    // Handle retained message storage
    if (retain != 0 and payload_len <= MAX_PAYLOAD_LEN) {
        storeRetained(topic_ptr, topic_len, payload_ptr, payload_len, qos_level);
    }

    // QoS 0: fire and forget, no state machine needed
    if (qos_level == .at_most_once) return 0;

    // QoS 1/2: set up delivery tracking
    const ti = allocTracker(idx, packet_id, qos_level) orelse return 1;

    // Transition the tracker: Idle -> AwaitingPubAck (QoS 1) or Idle -> AwaitingPubRec (QoS 2)
    if (qos_level == .at_least_once) {
        sessions[idx].inflight[ti].state = .awaiting_puback;
    } else {
        sessions[idx].inflight[ti].state = .awaiting_pubrec;
    }

    // Track whether we had subscriptions before entering Publishing state
    sessions[idx].had_subs_before_publish = (sessions[idx].state == .subscribed);
    sessions[idx].state = .publishing;

    return 0;
}

/// Handle retained message storage (internal helper).
fn storeRetained(
    topic_ptr: [*]const u8,
    topic_len: u32,
    payload_ptr: [*]const u8,
    payload_len: u32,
    qos_level: QoS,
) void {
    const topic = topic_ptr[0..topic_len];

    // Look for existing retained message on this topic, or find a free slot
    var free_slot: ?usize = null;
    for (&retained, 0..) |*r, i| {
        if (r.active and r.topic_len == topic_len and
            std.mem.eql(u8, r.topic[0..r.topic_len], topic))
        {
            // Replace existing retained message
            if (payload_len == 0) {
                // Empty payload: delete retained message (MQTT 3.1.1 Section 3.3.1.3)
                r.active = false;
                r.topic_len = 0;
                r.payload_len = 0;
                return;
            }
            @memcpy(r.payload[0..payload_len], payload_ptr[0..payload_len]);
            r.payload_len = payload_len;
            r.qos = qos_level;
            return;
        }
        if (!r.active and free_slot == null) {
            free_slot = i;
        }
    }

    // Store new retained message (skip if payload is empty or no free slots)
    if (payload_len > 0) {
        if (free_slot) |fi| {
            @memcpy(retained[fi].topic[0..topic_len], topic);
            retained[fi].topic_len = topic_len;
            @memcpy(retained[fi].payload[0..payload_len], payload_ptr[0..payload_len]);
            retained[fi].payload_len = payload_len;
            retained[fi].qos = qos_level;
            retained[fi].active = true;
        }
    }
}

// -- QoS acknowledgement flow -------------------------------------------------

/// PUBACK: acknowledge QoS 1 delivery. Returns 0 on success, 1 on rejection.
pub export fn mqtt_puback(slot: c_int, packet_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ti = findTracker(idx, packet_id) orelse return 1;

    if (sessions[idx].inflight[ti].state != .awaiting_puback) return 1;
    if (sessions[idx].inflight[ti].qos_level != .at_least_once) return 1;

    sessions[idx].inflight[ti].state = .qd_complete;
    maybeExitPublishing(idx);
    return 0;
}

/// PUBREC: QoS 2 step 1. Returns 0 on success, 1 on rejection.
pub export fn mqtt_pubrec(slot: c_int, packet_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ti = findTracker(idx, packet_id) orelse return 1;

    if (sessions[idx].inflight[ti].state != .awaiting_pubrec) return 1;
    if (sessions[idx].inflight[ti].qos_level != .exactly_once) return 1;

    sessions[idx].inflight[ti].state = .awaiting_pubrel;
    return 0;
}

/// PUBREL: QoS 2 step 2. Returns 0 on success, 1 on rejection.
pub export fn mqtt_pubrel(slot: c_int, packet_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ti = findTracker(idx, packet_id) orelse return 1;

    if (sessions[idx].inflight[ti].state != .awaiting_pubrel) return 1;
    if (sessions[idx].inflight[ti].qos_level != .exactly_once) return 1;

    sessions[idx].inflight[ti].state = .awaiting_pubcomp;
    return 0;
}

/// PUBCOMP: QoS 2 step 3 (final). Returns 0 on success, 1 on rejection.
pub export fn mqtt_pubcomp(slot: c_int, packet_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const ti = findTracker(idx, packet_id) orelse return 1;

    if (sessions[idx].inflight[ti].state != .awaiting_pubcomp) return 1;
    if (sessions[idx].inflight[ti].qos_level != .exactly_once) return 1;

    sessions[idx].inflight[ti].state = .qd_complete;
    maybeExitPublishing(idx);
    return 0;
}

/// Returns the QoSDeliveryState tag for a given packet ID.
pub export fn mqtt_qos_state(slot: c_int, packet_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0; // idle fallback
    const ti = findTracker(idx, packet_id) orelse return 0;
    return @intFromEnum(sessions[idx].inflight[ti].state);
}

/// If all in-flight deliveries are complete/failed, exit Publishing state.
fn maybeExitPublishing(idx: usize) void {
    if (sessions[idx].state != .publishing) return;
    if (countInflight(idx) == 0) {
        if (sessions[idx].had_subs_before_publish) {
            sessions[idx].state = .subscribed;
        } else {
            sessions[idx].state = .connected;
        }
    }
}

// -- Disconnect / Cleanup -----------------------------------------------------

/// Disconnect the session. Returns 0 on success, 1 on rejection.
/// Transitions Connected/Subscribed/Publishing -> Disconnecting.
pub export fn mqtt_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .subscribed or state == .publishing) {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect. Returns 0 on success, 1 on rejection.
/// Transitions Disconnecting -> Idle. Clears session state if clean_session.
pub export fn mqtt_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;

    sessions[idx].state = .idle;

    if (sessions[idx].clean_session) {
        sessions[idx].subscriptions = [_]Subscription{empty_sub} ** MAX_SUBSCRIPTIONS;
        sessions[idx].sub_count = 0;
        sessions[idx].inflight = [_]QoSTracker{empty_tracker} ** MAX_INFLIGHT;
    }

    return 0;
}

// -- Retained message queries -------------------------------------------------

/// Returns the total number of retained messages.
pub export fn mqtt_retained_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&retained) |*r| {
        if (r.active) count += 1;
    }
    return count;
}

// -- Stateless transition tables ----------------------------------------------

/// Check if a broker state transition is valid (matches Transitions.idr).
pub export fn mqtt_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Subscribed
    if (from == 2 and to == 2) return 1; // Subscribed -> Subscribed
    if (from == 2 and to == 1) return 1; // Subscribed -> Connected (all unsubscribed)
    if (from == 1 and to == 3) return 1; // Connected -> Publishing
    if (from == 2 and to == 3) return 1; // Subscribed -> Publishing
    if (from == 3 and to == 1) return 1; // Publishing -> Connected (done, no subs)
    if (from == 3 and to == 2) return 1; // Publishing -> Subscribed (done, has subs)
    if (from == 1 and to == 4) return 1; // Connected -> Disconnecting
    if (from == 2 and to == 4) return 1; // Subscribed -> Disconnecting
    if (from == 3 and to == 4) return 1; // Publishing -> Disconnecting
    if (from == 4 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}

/// Check if a QoS delivery state transition is valid for a given QoS level.
/// qos_level: 0=QoS0, 1=QoS1, 2=QoS2.
pub export fn mqtt_qos_can_transition(qos_level: u8, from: u8, to: u8) callconv(.c) u8 {
    if (qos_level == 0) {
        // QoS 0: Idle(0) -> Complete(5)
        if (from == 0 and to == 5) return 1;
    } else if (qos_level == 1) {
        // QoS 1: Idle(0) -> AwaitingPubAck(1) -> Complete(5) | Failed(6)
        if (from == 0 and to == 1) return 1;
        if (from == 1 and to == 5) return 1;
        if (from == 1 and to == 6) return 1;
    } else if (qos_level == 2) {
        // QoS 2: Idle(0) -> AwaitingPubRec(2) -> AwaitingPubRel(3) -> AwaitingPubComp(4) -> Complete(5)
        // Each intermediate can also -> Failed(6)
        if (from == 0 and to == 2) return 1;
        if (from == 2 and to == 3) return 1;
        if (from == 3 and to == 4) return 1;
        if (from == 4 and to == 5) return 1;
        if (from == 2 and to == 6) return 1;
        if (from == 3 and to == 6) return 1;
        if (from == 4 and to == 6) return 1;
    }
    return 0;
}

/// Match a topic name against a topic filter (stateless).
/// Returns 1 if the topic matches the filter, 0 otherwise.
pub export fn mqtt_topic_matches(
    topic_ptr: [*]const u8,
    topic_len: u32,
    filter_ptr: [*]const u8,
    filter_len: u32,
) callconv(.c) u8 {
    if (topic_len == 0 or filter_len == 0) return 0;
    if (topic_len > MAX_TOPIC_LEN or filter_len > MAX_TOPIC_LEN) return 0;

    const topic = topic_ptr[0..topic_len];
    const filter = filter_ptr[0..filter_len];

    return if (matchTopic(topic, filter)) 1 else 0;
}
