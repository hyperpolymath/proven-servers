// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// timestamp.zig -- Zig FFI engine for proven-timestamp.
//
// Implements the real evidence-timestamping core:
//   - a mutex-protected pool of append-only receipt logs
//   - content hashing (SHA-256, SHA-512/256, SHA3-256, SHAKE256)
//   - receipt creation with a frozen canonical pre-image
//   - a tamper-evident hash chain (each receipt links to the previous)
//   - chain verification (re-derive every hash + check every link)
//   - content verification (re-hash supplied bytes vs stored content_hash)
//   - a small lifecycle state machine (Idle/Active/Sealed/Shutdown)
//
// It NEVER stores document contents: callers submit a content hash to
// ts_append; ts_hash / ts_verify_content hash transient bytes and discard
// them.  All exported functions use the C calling convention and exchange
// enum values as u8 tags matching TimestampABI.Types.idr exactly.

const std = @import("std");
const builtin = @import("builtin");

// =========================================================================
// Enums (tags must match TimestampABI.Types.idr)
// =========================================================================

/// Hash algorithms (ABI tags 0-3).
pub const HashAlgo = enum(u8) {
    sha256 = 0,
    sha512_256 = 1,
    sha3_256 = 2,
    shake256 = 3,
};

/// Timestamp authority source (ABI tags 0-2).
pub const TimestampSource = enum(u8) {
    internal = 0,
    rfc3161 = 1,
    anchored = 2,
};

/// Verification outcomes (ABI tags 0-3).
pub const VerificationResult = enum(u8) {
    verified = 0,
    content_mismatch = 1,
    chain_broken = 2,
    not_found = 3,
};

/// Log lifecycle states (ABI tags 0-3).
pub const ServerState = enum(u8) {
    idle = 0,
    active = 1,
    sealed = 2,
    shutdown = 3,
};

/// ts_append status codes.
const AppendStatus = struct {
    const ok: u8 = 0;
    const rejected: u8 = 1;
    const full: u8 = 2;
};

// =========================================================================
// Canonical names (must match `Show` in Timestamp.Types.idr)
// =========================================================================

fn algoName(a: HashAlgo) []const u8 {
    return switch (a) {
        .sha256 => "sha-256",
        .sha512_256 => "sha-512-256",
        .sha3_256 => "sha3-256",
        .shake256 => "shake-256",
    };
}

fn sourceName(s: TimestampSource) []const u8 {
    return switch (s) {
        .internal => "internal",
        .rfc3161 => "rfc3161",
        .anchored => "anchored",
    };
}

// =========================================================================
// Sizes
// =========================================================================

// In-memory prototype limits.  The append-only log lives entirely in RAM, so
// the pool is bounded and modest; persistence and larger capacity are future
// work (see README).  Total fixed footprint ~= MAX_SESSIONS * MAX_ENTRIES *
// sizeof(Entry) and must stay well under the process stack/heap budget.
const MAX_SESSIONS: usize = 16;
const MAX_NAME_LEN: usize = 256;
const MAX_ENTRIES: usize = 1024;
const HEX_LEN: usize = 64; // 32-byte digest as lowercase hex
const MAX_CREATED: usize = 32;
const MAX_LABEL: usize = 128;
const MAX_REF: usize = 128;
const PREIMAGE_CAP: usize = 1024;

/// 64 hex zeros — predecessor of the first receipt (matches genesisHash).
const GENESIS: *const [HEX_LEN]u8 = "0000000000000000000000000000000000000000000000000000000000000000";

// =========================================================================
// Hashing helpers
// =========================================================================

fn toHex(digest: *const [32]u8, out: *[HEX_LEN]u8) void {
    const hc = "0123456789abcdef";
    var i: usize = 0;
    while (i < 32) : (i += 1) {
        out[2 * i] = hc[digest[i] >> 4];
        out[2 * i + 1] = hc[digest[i] & 0x0f];
    }
}

/// Hash `data` with `algo` and write a 64-char lowercase hex digest.
fn hashHex(algo: HashAlgo, data: []const u8, out: *[HEX_LEN]u8) void {
    var d: [32]u8 = undefined;
    switch (algo) {
        .sha256 => std.crypto.hash.sha2.Sha256.hash(data, &d, .{}),
        .sha512_256 => std.crypto.hash.sha2.Sha512_256.hash(data, &d, .{}),
        .sha3_256 => std.crypto.hash.sha3.Sha3_256.hash(data, &d, .{}),
        .shake256 => {
            var sh = std.crypto.hash.sha3.Shake256.init(.{});
            sh.update(data);
            sh.squeeze(&d);
        },
    }
    toHex(&d, out);
}

/// Build the canonical pre-image.  MUST stay byte-for-byte identical to
/// `canonicalPreimage` in Timestamp.Receipt.idr: nine newline-separated
/// fields, no trailing newline.
fn buildPreimage(
    buf: []u8,
    id: []const u8,
    created: []const u8,
    source: TimestampSource,
    algo: HashAlgo,
    content_hash: []const u8,
    label: []const u8,
    reference: []const u8,
    prev: []const u8,
) ?[]const u8 {
    return std.fmt.bufPrint(
        buf,
        "proven-timestamp.receipt.v1\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}\n{s}",
        .{ id, created, sourceName(source), algoName(algo), content_hash, label, reference, prev },
    ) catch null;
}

// =========================================================================
// Data structures
// =========================================================================

const Entry = struct {
    active: bool,
    algo: HashAlgo,
    source: TimestampSource,
    content_hash: [HEX_LEN]u8,
    prev_hash: [HEX_LEN]u8,
    receipt_hash: [HEX_LEN]u8,
    created_at: [MAX_CREATED]u8,
    created_len: u8,
    label: [MAX_LABEL]u8,
    label_len: u8,
    reference: [MAX_REF]u8,
    ref_len: u8,
};

const empty_entry: Entry = .{
    .active = false,
    .algo = .sha3_256,
    .source = .internal,
    .content_hash = [_]u8{0} ** HEX_LEN,
    .prev_hash = [_]u8{0} ** HEX_LEN,
    .receipt_hash = [_]u8{0} ** HEX_LEN,
    .created_at = [_]u8{0} ** MAX_CREATED,
    .created_len = 0,
    .label = [_]u8{0} ** MAX_LABEL,
    .label_len = 0,
    .reference = [_]u8{0} ** MAX_REF,
    .ref_len = 0,
};

const Session = struct {
    state: ServerState,
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    entries: [MAX_ENTRIES]Entry,
    count: u32,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .entries = [_]Entry{empty_entry} ** MAX_ENTRIES,
    .count = 0,
    .active = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

/// Recompute and store entry[idx of session].receipt_hash from its fields.
/// Returns false if the pre-image could not be built.
fn computeReceiptHash(e: *Entry, id: []const u8, out: *[HEX_LEN]u8) bool {
    var buf: [PREIMAGE_CAP]u8 = undefined;
    const pre = buildPreimage(
        &buf,
        id,
        e.created_at[0..e.created_len],
        e.source,
        e.algo,
        e.content_hash[0..],
        e.label[0..e.label_len],
        e.reference[0..e.ref_len],
        e.prev_hash[0..],
    ) orelse return false;
    hashHex(e.algo, pre, out);
    return true;
}

// =========================================================================
// Exported C ABI
// =========================================================================

/// ABI version. Must match TimestampABI.Foreign.abiVersion.
pub export fn ts_abi_version() callconv(.c) u32 {
    return 1;
}

/// Hash `data` with `algo`; write lowercase hex to out_hex. Returns the hex
/// length (64) or -1 on bad arguments. Content is hashed, never stored.
pub export fn ts_hash(
    algo: u8,
    data: [*]const u8,
    len: usize,
    out_hex: [*]u8,
    cap: usize,
) callconv(.c) i32 {
    if (algo > 3 or cap < HEX_LEN) return -1;
    var hex: [HEX_LEN]u8 = undefined;
    hashHex(@enumFromInt(algo), data[0..len], &hex);
    @memcpy(out_hex[0..HEX_LEN], &hex);
    return @intCast(HEX_LEN);
}

/// Current UTC time as ISO-8601 ("YYYY-MM-DDТHH:MM:SSZ"). Returns length or -1.
pub export fn ts_now_iso8601(out: [*]u8, cap: usize) callconv(.c) i32 {
    var buf: [MAX_CREATED]u8 = undefined;
    const n = formatNowIso(&buf) orelse return -1;
    if (cap < n) return -1;
    @memcpy(out[0..n], buf[0..n]);
    return @intCast(n);
}

fn formatNowIso(buf: []u8) ?usize {
    const now = std.time.timestamp();
    if (now < 0) return null;
    const secs: u64 = @intCast(now);
    const es = std.time.epoch.EpochSeconds{ .secs = secs };
    const ed = es.getEpochDay();
    const yd = ed.calculateYearDay();
    const md = yd.calculateMonthDay();
    const ds = es.getDaySeconds();
    const s = std.fmt.bufPrint(buf, "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}Z", .{
        yd.year,
        md.month.numeric(),
        md.day_index + 1,
        ds.getHoursIntoDay(),
        ds.getMinutesIntoHour(),
        ds.getSecondsIntoMinute(),
    }) catch return null;
    return s.len;
}

/// Create a new append-only log. Returns slot (>=0) in Active state, or -1.
pub export fn ts_create(name_ptr: [*]const u8, name_len: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.state = .active; // Idle -> Active
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Release a log slot.
pub export fn ts_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Current lifecycle state tag.
pub export fn ts_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(ServerState.idle);
    return @intFromEnum(sessions[idx].state);
}

/// Number of receipts in the log.
pub export fn ts_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].count;
}

/// Append a receipt for an already-computed content hash. Links to the
/// previous receipt (or genesis), computes receipt_hash over the canonical
/// pre-image, stores only hashes + metadata, and returns id + receipt hash.
/// Returns 0=ok, 1=rejected, 2=full.
pub export fn ts_append(
    slot: c_int,
    algo: u8,
    content_hash_ptr: [*]const u8,
    content_hash_len: u32,
    created_ptr: [*]const u8,
    created_len: u32,
    label_ptr: [*]const u8,
    label_len: u32,
    reference_ptr: [*]const u8,
    reference_len: u32,
    out_id: *u64,
    out_receipt_hex: [*]u8,
    out_cap: usize,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return AppendStatus.rejected;
    var s = &sessions[idx];
    if (s.state != .active) return AppendStatus.rejected;
    if (algo > 3) return AppendStatus.rejected;
    if (content_hash_len != HEX_LEN) return AppendStatus.rejected;
    if (created_len > MAX_CREATED) return AppendStatus.rejected;
    if (label_len > MAX_LABEL or reference_len > MAX_REF) return AppendStatus.rejected;
    if (out_cap < HEX_LEN) return AppendStatus.rejected;
    if (s.count >= MAX_ENTRIES) return AppendStatus.full;

    const i: usize = s.count;
    var e = &s.entries[i];
    e.* = empty_entry;
    e.algo = @enumFromInt(algo);
    e.source = .internal; // v1: internal only. TODO(rfc3161): select source.
    @memcpy(e.content_hash[0..], content_hash_ptr[0..HEX_LEN]);

    // created_at: use supplied value, else fill with current UTC.
    if (created_len == 0) {
        const n = formatNowIso(e.created_at[0..]) orelse return AppendStatus.rejected;
        e.created_len = @intCast(n);
    } else {
        @memcpy(e.created_at[0..created_len], created_ptr[0..created_len]);
        e.created_len = @intCast(created_len);
    }
    @memcpy(e.label[0..label_len], label_ptr[0..label_len]);
    e.label_len = @intCast(label_len);
    @memcpy(e.reference[0..reference_len], reference_ptr[0..reference_len]);
    e.ref_len = @intCast(reference_len);

    // Link: previous receipt's hash, or genesis for the first.
    if (i == 0) {
        @memcpy(e.prev_hash[0..], GENESIS);
    } else {
        @memcpy(e.prev_hash[0..], s.entries[i - 1].receipt_hash[0..]);
    }

    // receipt id = decimal index.
    var id_buf: [20]u8 = undefined;
    const id_str = std.fmt.bufPrint(&id_buf, "{d}", .{i}) catch return AppendStatus.rejected;

    var rh: [HEX_LEN]u8 = undefined;
    if (!computeReceiptHash(e, id_str, &rh)) return AppendStatus.rejected;
    @memcpy(e.receipt_hash[0..], &rh);

    e.active = true;
    s.count += 1;

    out_id.* = @intCast(i);
    @memcpy(out_receipt_hex[0..HEX_LEN], &rh);
    return AppendStatus.ok;
}

fn copyField(field: []const u8, out: [*]u8, cap: usize) i32 {
    if (cap < field.len) return -1;
    @memcpy(out[0..field.len], field);
    return @intCast(field.len);
}

/// Copy receipt_hash of receipt `index` as hex. Returns length or -1.
pub export fn ts_get_receipt_hash(slot: c_int, index: u32, out: [*]u8, cap: usize) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    if (index >= sessions[idx].count) return -1;
    return copyField(sessions[idx].entries[index].receipt_hash[0..], out, cap);
}

/// Copy previous_receipt_hash of receipt `index` as hex. Returns length or -1.
pub export fn ts_get_prev_hash(slot: c_int, index: u32, out: [*]u8, cap: usize) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    if (index >= sessions[idx].count) return -1;
    return copyField(sessions[idx].entries[index].prev_hash[0..], out, cap);
}

/// Copy content_hash of receipt `index` as hex. Returns length or -1.
pub export fn ts_get_content_hash(slot: c_int, index: u32, out: [*]u8, cap: usize) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return -1;
    if (index >= sessions[idx].count) return -1;
    return copyField(sessions[idx].entries[index].content_hash[0..], out, cap);
}

/// Verify the whole chain: re-derive every receipt_hash from stored fields
/// and confirm each link. Returns a VerificationResult tag.
pub export fn ts_verify_chain(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(VerificationResult.not_found);
    var s = &sessions[idx];

    var i: usize = 0;
    while (i < s.count) : (i += 1) {
        var e = &s.entries[i];

        // Link check.
        const expected_prev: []const u8 = if (i == 0) GENESIS[0..] else s.entries[i - 1].receipt_hash[0..];
        if (!std.mem.eql(u8, e.prev_hash[0..], expected_prev)) {
            return @intFromEnum(VerificationResult.chain_broken);
        }

        // Tamper check: re-derive the receipt hash from the stored fields.
        var id_buf: [20]u8 = undefined;
        const id_str = std.fmt.bufPrint(&id_buf, "{d}", .{i}) catch return @intFromEnum(VerificationResult.chain_broken);
        var rh: [HEX_LEN]u8 = undefined;
        if (!computeReceiptHash(e, id_str, &rh)) return @intFromEnum(VerificationResult.chain_broken);
        if (!std.mem.eql(u8, e.receipt_hash[0..], &rh)) {
            return @intFromEnum(VerificationResult.chain_broken);
        }
    }
    return @intFromEnum(VerificationResult.verified);
}

/// Re-hash supplied content and compare to receipt `index`'s content_hash.
/// Returns a VerificationResult tag. Content is hashed, never stored.
pub export fn ts_verify_content(
    slot: c_int,
    index: u32,
    algo: u8,
    data: [*]const u8,
    len: usize,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    if (algo > 3) return @intFromEnum(VerificationResult.content_mismatch);
    const idx = validSlot(slot) orelse return @intFromEnum(VerificationResult.not_found);
    if (index >= sessions[idx].count) return @intFromEnum(VerificationResult.not_found);

    var hex: [HEX_LEN]u8 = undefined;
    hashHex(@enumFromInt(algo), data[0..len], &hex);
    if (std.mem.eql(u8, sessions[idx].entries[index].content_hash[0..], &hex)) {
        return @intFromEnum(VerificationResult.verified);
    }
    return @intFromEnum(VerificationResult.content_mismatch);
}

// -- Lifecycle ------------------------------------------------------------

/// Active -> Sealed. Returns 0=ok, 1=rejected.
pub export fn ts_seal(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    sessions[idx].state = .sealed;
    return 0;
}

/// Sealed -> Active. Returns 0=ok, 1=rejected.
pub export fn ts_reopen(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .sealed) return 1;
    sessions[idx].state = .active;
    return 0;
}

/// Active/Sealed -> Shutdown. Returns 0=ok, 1=rejected.
pub export fn ts_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const st = sessions[idx].state;
    if (st == .active or st == .sealed) {
        sessions[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Shutdown -> Idle, clearing the in-memory log. Returns 0=ok, 1=rejected.
/// NOTE: a production deployment persists the append-only log before cleanup;
/// this prototype keeps the log in memory only.
pub export fn ts_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;
    sessions[idx].state = .idle;
    sessions[idx].entries = [_]Entry{empty_entry} ** MAX_ENTRIES;
    sessions[idx].count = 0;
    return 0;
}

/// Test-only helper: flip a byte of a stored content hash to exercise
/// tamper detection in ts_verify_chain.  Not part of the C ABI and compiled
/// to a no-op outside `zig build test`.
pub fn testTamperContentHash(slot: c_int, index: u32) void {
    if (!builtin.is_test) return;
    const idx = validSlot(slot) orelse return;
    if (index >= sessions[idx].count) return;
    sessions[idx].entries[index].content_hash[0] ^= 0x01;
}

/// Stateless transition table (mirrors ValidServerTransition).
pub export fn ts_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Active
    if (from == 1 and to == 2) return 1; // Active -> Sealed
    if (from == 2 and to == 1) return 1; // Sealed -> Active
    if (from == 1 and to == 3) return 1; // Active -> Shutdown
    if (from == 2 and to == 3) return 1; // Sealed -> Shutdown
    if (from == 3 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
