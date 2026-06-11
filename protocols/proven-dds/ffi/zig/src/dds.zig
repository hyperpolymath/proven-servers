// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// dds.zig -- Zig FFI implementation of proven-dds.
//
// Implements the DDS (OMG Data Distribution Service) participant state machine with:
//   - 64-slot mutex-protected participant pool
//   - Topic registration per participant (max 32 topics)
//   - DataWriter management (max 16 writers per participant)
//   - DataReader management (max 16 readers per participant)
//   - QoS policy tracking per topic (reliability, durability, history)
//   - Sample count tracking per writer
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DDSABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DDSABI.Types.idr tag assignments)
// =========================================================================

/// DDS reliability kinds (ABI tags 0-1).
pub const ReliabilityKind = enum(u8) {
    best_effort = 0,
    reliable = 1,
};

/// DDS durability kinds (ABI tags 0-3).
pub const DurabilityKind = enum(u8) {
    @"volatile" = 0,
    transient_local = 1,
    transient = 2,
    persistent = 3,
};

/// DDS history kinds (ABI tags 0-1).
pub const HistoryKind = enum(u8) {
    keep_last = 0,
    keep_all = 1,
};

/// DDS ownership kinds (ABI tags 0-1).
pub const OwnershipKind = enum(u8) {
    shared = 0,
    exclusive = 1,
};

/// DDS entity types (ABI tags 0-5).
pub const EntityType = enum(u8) {
    participant = 0,
    publisher = 1,
    subscriber = 2,
    topic = 3,
    data_writer = 4,
    data_reader = 5,
};

/// DDS participant lifecycle states (ABI tags 0-4).
pub const ParticipantState = enum(u8) {
    idle = 0,
    joined = 1,
    publishing = 2,
    subscribing = 3,
    leaving = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent participants.
const MAX_PARTICIPANTS: usize = 64;

/// Maximum topics per participant.
const MAX_TOPICS: usize = 32;

/// Maximum DataWriters per participant.
const MAX_WRITERS: usize = 16;

/// Maximum DataReaders per participant.
const MAX_READERS: usize = 16;

/// Maximum topic name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// A DDS Topic.
const Topic = struct {
    /// Topic name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Reliability QoS.
    reliability: u8,
    /// Durability QoS.
    durability: u8,
    /// History QoS.
    history: u8,
    /// Whether this topic slot is active.
    active: bool,
};

/// A DataWriter entry.
const Writer = struct {
    /// Topic name this writer publishes to.
    topic_name: [MAX_NAME_LEN]u8,
    topic_len: u32,
    /// Number of samples written.
    samples_written: u64,
    /// Whether this writer slot is active.
    active: bool,
};

/// A DataReader entry.
const Reader = struct {
    /// Topic name this reader subscribes to.
    topic_name: [MAX_NAME_LEN]u8,
    topic_len: u32,
    /// Whether this reader slot is active.
    active: bool,
};

/// A DDS DomainParticipant.
const Participant = struct {
    /// Current lifecycle state.
    state: ParticipantState,
    /// Domain ID.
    domain_id: u32,
    /// Topics.
    topics: [MAX_TOPICS]Topic,
    /// Number of active topics.
    topic_count: u32,
    /// DataWriters.
    writers: [MAX_WRITERS]Writer,
    /// Number of active writers.
    writer_count: u32,
    /// DataReaders.
    readers: [MAX_READERS]Reader,
    /// Number of active readers.
    reader_count: u32,
    /// Total samples written across all writers.
    total_samples: u64,
    /// Whether this participant slot is in use.
    active: bool,
};

/// Default (empty) topic.
const empty_topic: Topic = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .reliability = 0,
    .durability = 0,
    .history = 0,
    .active = false,
};

/// Default (empty) writer.
const empty_writer: Writer = .{
    .topic_name = [_]u8{0} ** MAX_NAME_LEN,
    .topic_len = 0,
    .samples_written = 0,
    .active = false,
};

/// Default (empty) reader.
const empty_reader: Reader = .{
    .topic_name = [_]u8{0} ** MAX_NAME_LEN,
    .topic_len = 0,
    .active = false,
};

/// Default (empty) participant.
const empty_participant: Participant = .{
    .state = .idle,
    .domain_id = 0,
    .topics = [_]Topic{empty_topic} ** MAX_TOPICS,
    .topic_count = 0,
    .writers = [_]Writer{empty_writer} ** MAX_WRITERS,
    .writer_count = 0,
    .readers = [_]Reader{empty_reader} ** MAX_READERS,
    .reader_count = 0,
    .total_samples = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var participants: [MAX_PARTICIPANTS]Participant = [_]Participant{empty_participant} ** MAX_PARTICIPANTS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_PARTICIPANTS) return null;
    const idx: usize = @intCast(slot);
    if (!participants[idx].active) return null;
    return idx;
}

/// Find a topic by name within a participant.
fn findTopic(idx: usize, name: []const u8) ?usize {
    for (&participants[idx].topics, 0..) |*t, i| {
        if (t.active and t.name_len == name.len and
            std.mem.eql(u8, t.name[0..t.name_len], name))
        {
            return i;
        }
    }
    return null;
}

/// Find a writer by topic name.
fn findWriter(idx: usize, topic: []const u8) ?usize {
    for (&participants[idx].writers, 0..) |*w, i| {
        if (w.active and w.topic_len == topic.len and
            std.mem.eql(u8, w.topic_name[0..w.topic_len], topic))
        {
            return i;
        }
    }
    return null;
}

/// Find a reader by topic name.
fn findReader(idx: usize, topic: []const u8) ?usize {
    for (&participants[idx].readers, 0..) |*r, i| {
        if (r.active and r.topic_len == topic.len and
            std.mem.eql(u8, r.topic_name[0..r.topic_len], topic))
        {
            return i;
        }
    }
    return null;
}

/// Recompute participant state based on writer/reader counts.
fn recomputeState(idx: usize) void {
    if (participants[idx].writer_count > 0 and participants[idx].reader_count > 0) {
        // Both writers and readers -- prefer Publishing
        participants[idx].state = .publishing;
    } else if (participants[idx].writer_count > 0) {
        participants[idx].state = .publishing;
    } else if (participants[idx].reader_count > 0) {
        participants[idx].state = .subscribing;
    } else {
        participants[idx].state = .joined;
    }
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn dds_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new DDS DomainParticipant. Returns slot index (>=0) or -1 on failure.
pub export fn dds_create(domain_id: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&participants, 0..) |*p, i| {
        if (!p.active) {
            p.* = empty_participant;
            p.domain_id = domain_id;
            p.state = .joined; // Idle -> Joined
            p.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a participant, releasing its slot.
pub export fn dds_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_PARTICIPANTS) return;
    participants[@intCast(slot)] = empty_participant;
}

/// Returns the current ParticipantState tag.
pub export fn dds_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(participants[idx].state);
}

// -- Topic management ---------------------------------------------------------

/// Create a topic. Returns 0 on success, 1 on rejection.
pub export fn dds_create_topic(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
    reliability: u8,
    durability: u8,
    history: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = participants[idx].state;
    if (state == .idle or state == .leaving) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (reliability > 1) return 1;
    if (durability > 3) return 1;
    if (history > 1) return 1;

    const name = name_ptr[0..name_len];
    if (findTopic(idx, name) != null) return 1; // duplicate

    for (&participants[idx].topics) |*t| {
        if (!t.active) {
            @memcpy(t.name[0..name_len], name);
            t.name_len = name_len;
            t.reliability = reliability;
            t.durability = durability;
            t.history = history;
            t.active = true;
            participants[idx].topic_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Delete a topic. Returns 0 on success, 1 on rejection.
/// Rejects if writers or readers reference this topic.
pub export fn dds_delete_topic(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;

    const name = name_ptr[0..name_len];
    const ti = findTopic(idx, name) orelse return 1;

    // Reject if writers or readers reference this topic
    if (findWriter(idx, name) != null) return 1;
    if (findReader(idx, name) != null) return 1;

    participants[idx].topics[ti].active = false;
    participants[idx].topic_count -= 1;

    return 0;
}

/// Returns the number of topics.
pub export fn dds_topic_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return participants[idx].topic_count;
}

// -- Writer management --------------------------------------------------------

/// Create a DataWriter for a topic. Returns 0 on success, 1 on rejection.
/// Topic must exist. Transitions Joined -> Publishing.
pub export fn dds_create_writer(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = participants[idx].state;
    if (state == .idle or state == .leaving) return 1;
    if (topic_len == 0 or topic_len > MAX_NAME_LEN) return 1;

    const topic = topic_ptr[0..topic_len];
    if (findTopic(idx, topic) == null) return 1; // topic must exist
    if (findWriter(idx, topic) != null) return 1; // one writer per topic

    for (&participants[idx].writers) |*w| {
        if (!w.active) {
            @memcpy(w.topic_name[0..topic_len], topic);
            w.topic_len = topic_len;
            w.samples_written = 0;
            w.active = true;
            participants[idx].writer_count += 1;
            recomputeState(idx);
            return 0;
        }
    }
    return 1;
}

/// Delete a DataWriter. Returns 0 on success, 1 on rejection.
pub export fn dds_delete_writer(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (topic_len == 0 or topic_len > MAX_NAME_LEN) return 1;

    const topic = topic_ptr[0..topic_len];
    const wi = findWriter(idx, topic) orelse return 1;

    participants[idx].writers[wi] = empty_writer;
    participants[idx].writer_count -= 1;
    recomputeState(idx);

    return 0;
}

/// Returns the number of DataWriters.
pub export fn dds_writer_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return participants[idx].writer_count;
}

// -- Reader management --------------------------------------------------------

/// Create a DataReader for a topic. Returns 0 on success, 1 on rejection.
/// Topic must exist. Transitions Joined -> Subscribing.
pub export fn dds_create_reader(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = participants[idx].state;
    if (state == .idle or state == .leaving) return 1;
    if (topic_len == 0 or topic_len > MAX_NAME_LEN) return 1;

    const topic = topic_ptr[0..topic_len];
    if (findTopic(idx, topic) == null) return 1; // topic must exist
    if (findReader(idx, topic) != null) return 1; // one reader per topic

    for (&participants[idx].readers) |*r| {
        if (!r.active) {
            @memcpy(r.topic_name[0..topic_len], topic);
            r.topic_len = topic_len;
            r.active = true;
            participants[idx].reader_count += 1;
            recomputeState(idx);
            return 0;
        }
    }
    return 1;
}

/// Delete a DataReader. Returns 0 on success, 1 on rejection.
pub export fn dds_delete_reader(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (topic_len == 0 or topic_len > MAX_NAME_LEN) return 1;

    const topic = topic_ptr[0..topic_len];
    const ri = findReader(idx, topic) orelse return 1;

    participants[idx].readers[ri] = empty_reader;
    participants[idx].reader_count -= 1;
    recomputeState(idx);

    return 0;
}

/// Returns the number of DataReaders.
pub export fn dds_reader_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return participants[idx].reader_count;
}

// -- Write samples ------------------------------------------------------------

/// Write a sample to a topic's DataWriter. Returns 0 on success, 1 on rejection.
pub export fn dds_write_sample(
    slot: c_int,
    topic_ptr: [*]const u8,
    topic_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (participants[idx].state != .publishing) return 1;
    if (topic_len == 0 or topic_len > MAX_NAME_LEN) return 1;

    const topic = topic_ptr[0..topic_len];
    const wi = findWriter(idx, topic) orelse return 1;

    participants[idx].writers[wi].samples_written += 1;
    participants[idx].total_samples += 1;

    return 0;
}

/// Returns total samples written across all writers.
pub export fn dds_samples_written(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return participants[idx].total_samples;
}

// -- Leave / Cleanup ----------------------------------------------------------

/// Leave the domain. Returns 0 on success, 1 on rejection.
pub export fn dds_leave(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = participants[idx].state;
    if (state == .joined or state == .publishing or state == .subscribing) {
        participants[idx].state = .leaving;
        return 0;
    }
    return 1;
}

/// Complete cleanup after leaving. Returns 0 on success, 1 on rejection.
pub export fn dds_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (participants[idx].state != .leaving) return 1;

    participants[idx].state = .idle;
    participants[idx].topics = [_]Topic{empty_topic} ** MAX_TOPICS;
    participants[idx].topic_count = 0;
    participants[idx].writers = [_]Writer{empty_writer} ** MAX_WRITERS;
    participants[idx].writer_count = 0;
    participants[idx].readers = [_]Reader{empty_reader} ** MAX_READERS;
    participants[idx].reader_count = 0;
    participants[idx].total_samples = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a participant state transition is valid.
pub export fn dds_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Joined
    if (from == 1 and to == 2) return 1; // Joined -> Publishing
    if (from == 1 and to == 3) return 1; // Joined -> Subscribing
    if (from == 2 and to == 2) return 1; // Publishing -> Publishing (more writers)
    if (from == 2 and to == 1) return 1; // Publishing -> Joined (all writers removed)
    if (from == 3 and to == 3) return 1; // Subscribing -> Subscribing (more readers)
    if (from == 3 and to == 1) return 1; // Subscribing -> Joined (all readers removed)
    if (from == 2 and to == 3) return 1; // Publishing -> Subscribing (add reader, remove writers)
    if (from == 3 and to == 2) return 1; // Subscribing -> Publishing (add writer, remove readers)
    if (from == 1 and to == 4) return 1; // Joined -> Leaving
    if (from == 2 and to == 4) return 1; // Publishing -> Leaving
    if (from == 3 and to == 4) return 1; // Subscribing -> Leaving
    if (from == 4 and to == 0) return 1; // Leaving -> Idle
    return 0;
}
