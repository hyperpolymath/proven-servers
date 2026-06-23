// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// cache.zig -- Zig FFI implementation of proven-cache.
//
// Implements a key/value cache session manager with:
//   - 64-slot session pool
//   - Per-session eviction policy and replication mode
//   - Command dispatch with error codes
//   - Hit/miss statistics tracking
//   - Thread-safe via mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CacheABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching CacheABI.Types.idr tag assignments)
// =========================================================================

/// Cache commands (tags 0-12).
pub const Command = enum(u8) {
    get = 0,
    set = 1,
    delete = 2,
    exists = 3,
    expire = 4,
    ttl = 5,
    keys = 6,
    flush = 7,
    incr = 8,
    decr = 9,
    append = 10,
    prepend = 11,
    cas = 12,
};

/// Eviction policies (tags 0-4).
pub const EvictionPolicy = enum(u8) {
    lru = 0,
    lfu = 1,
    random = 2,
    evict_ttl = 3,
    no_eviction = 4,
};

/// Value data types (tags 0-4).
pub const DataType = enum(u8) {
    string_val = 0,
    int_val = 1,
    list_val = 2,
    set_val = 3,
    hash_val = 4,
};

/// Error codes (tags 0-5).
pub const ErrorCode = enum(u8) {
    not_found = 0,
    type_mismatch = 1,
    out_of_memory = 2,
    key_too_long = 3,
    value_too_large = 4,
    cas_conflict = 5,
};

/// Replication modes (tags 0-3).
pub const ReplicationMode = enum(u8) {
    none = 0,
    primary = 1,
    replica = 2,
    sentinel = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent cache sessions.
const MAX_SESSIONS: usize = 64;

/// A cache session.
const Session = struct {
    /// Eviction policy for this session.
    eviction: EvictionPolicy,
    /// Replication mode for this session.
    replication: ReplicationMode,
    /// Maximum number of keys allowed.
    max_keys: u32,
    /// Current number of keys stored.
    key_count: u32,
    /// Cache hit counter.
    hits: u32,
    /// Cache miss counter.
    misses: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .eviction = .lru,
    .replication = .none,
    .max_keys = 0,
    .key_count = 0,
    .hits = 0,
    .misses = 0,
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

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn cache_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new cache session. Returns slot index (>=0) or -1.
pub export fn cache_create(eviction: u8, replication: u8, max_keys: u32) callconv(.c) c_int {
    if (eviction > 4 or replication > 3) return -1;

    mutex.lock();
    defer mutex.unlock();

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.eviction = @enumFromInt(eviction);
            s.replication = @enumFromInt(replication);
            s.max_keys = max_keys;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn cache_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Execute a command. Returns 0 on success, or an ErrorCode+1 on failure.
/// Simplified model: Get increments hits/misses, Set/Delete modify key_count,
/// Flush clears keys.
pub export fn cache_execute(slot: c_int, cmd: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1; // not_found + 1 as generic error
    if (cmd > 12) return 1;

    const command: Command = @enumFromInt(cmd);

    switch (command) {
        .get => {
            if (sessions[idx].key_count > 0) {
                sessions[idx].hits += 1;
            } else {
                sessions[idx].misses += 1;
            }
        },
        .set => {
            if (sessions[idx].eviction == .no_eviction and
                sessions[idx].key_count >= sessions[idx].max_keys and
                sessions[idx].max_keys > 0)
            {
                return @intFromEnum(ErrorCode.out_of_memory) + 1;
            }
            sessions[idx].key_count += 1;
        },
        .delete => {
            if (sessions[idx].key_count == 0) {
                return @intFromEnum(ErrorCode.not_found) + 1;
            }
            sessions[idx].key_count -= 1;
        },
        .exists => {
            // Query only, no state change
        },
        .expire => {
            // TTL management, no key count change
        },
        .ttl => {
            // Query only
        },
        .keys => {
            // Query only
        },
        .flush => {
            sessions[idx].key_count = 0;
        },
        .incr, .decr => {
            if (sessions[idx].key_count == 0) {
                return @intFromEnum(ErrorCode.not_found) + 1;
            }
        },
        .append, .prepend => {
            if (sessions[idx].key_count == 0) {
                return @intFromEnum(ErrorCode.not_found) + 1;
            }
        },
        .cas => {
            if (sessions[idx].key_count == 0) {
                return @intFromEnum(ErrorCode.not_found) + 1;
            }
        },
    }
    return 0;
}

/// Returns the eviction policy tag for a session.
pub export fn cache_eviction_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].eviction);
}

/// Returns the replication mode tag for a session.
pub export fn cache_replication_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].replication);
}

/// Returns the number of keys stored.
pub export fn cache_key_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].key_count;
}

/// Returns the maximum key capacity.
pub export fn cache_max_keys(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].max_keys;
}

/// Returns the cache hit count.
pub export fn cache_hits(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].hits;
}

/// Returns the cache miss count.
pub export fn cache_misses(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].misses;
}

/// Returns 1 if the cache has reached max_keys, 0 otherwise.
pub export fn cache_is_full(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (sessions[idx].max_keys == 0) return 0; // unlimited
    return if (sessions[idx].key_count >= sessions[idx].max_keys) 1 else 0;
}

/// Change eviction policy. Returns 0 on success, 1 on invalid tag.
pub export fn cache_set_eviction(slot: c_int, policy: u8) callconv(.c) u8 {
    if (policy > 4) return 1;

    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    sessions[idx].eviction = @enumFromInt(policy);
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
