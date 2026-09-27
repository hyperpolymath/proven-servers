// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ctlog.zig -- Zig FFI implementation of proven-ctlog.
//
// Implements a Certificate Transparency lifecycle model only, not an RFC 6962
// log. Entry submission, STH signing, and Merkle proof verification fail closed;
// no entry bytes are persisted and no Merkle hashes or signatures are produced.
// Remaining session/state transitions are in-memory model operations.
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CTLogABI.Types.idr exactly.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("ctlog_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (matching CTLogABI.Types.idr tag assignments)
// =========================================================================

/// CT Log entry types (ABI tags 0-1).
pub const LogEntryType = enum(u8) {
    x509_entry = 0,
    precert_entry = 1,
};

/// CT Log signature types (ABI tags 0-1).
pub const SignatureType = enum(u8) {
    certificate_timestamp = 0,
    tree_hash = 1,
};

/// Merkle leaf types (ABI tag 0).
pub const MerkleLeafType = enum(u8) {
    timestamped_entry = 0,
};

/// Submission status codes (ABI tags 0-5).
pub const SubmissionStatus = enum(u8) {
    accepted = 0,
    duplicate = 1,
    rate_limited = 2,
    rejected = 3,
    invalid_chain = 4,
    unknown_anchor = 5,
};

/// Verification result codes (ABI tags 0-3).
pub const VerificationResult = enum(u8) {
    valid_proof = 0,
    invalid_proof = 1,
    inconsistent_tree = 2,
    stale_sth = 3,
};

/// Server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    active = 1,
    merging = 2,
    signing = 3,
    shutdown = 4,
};

// ── ABI conformance guard ────────────────────────────────────────────────
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(LogEntryType.x509_entry) != gen.ENTRY_X509_ENTRY) @compileError("ABI drift: LogEntryType.x509_entry");
    if (@intFromEnum(LogEntryType.precert_entry) != gen.ENTRY_PRECERT_ENTRY) @compileError("ABI drift: LogEntryType.precert_entry");

    if (@intFromEnum(SignatureType.certificate_timestamp) != gen.SIG_CERTIFICATE_TIMESTAMP) @compileError("ABI drift: SignatureType.certificate_timestamp");
    if (@intFromEnum(SignatureType.tree_hash) != gen.SIG_TREE_HASH) @compileError("ABI drift: SignatureType.tree_hash");

    if (@intFromEnum(MerkleLeafType.timestamped_entry) != gen.LEAF_TIMESTAMPED_ENTRY) @compileError("ABI drift: MerkleLeafType.timestamped_entry");

    if (@intFromEnum(SubmissionStatus.accepted) != gen.SUBMIT_ACCEPTED) @compileError("ABI drift: SubmissionStatus.accepted");
    if (@intFromEnum(SubmissionStatus.duplicate) != gen.SUBMIT_DUPLICATE) @compileError("ABI drift: SubmissionStatus.duplicate");
    if (@intFromEnum(SubmissionStatus.rate_limited) != gen.SUBMIT_RATE_LIMITED) @compileError("ABI drift: SubmissionStatus.rate_limited");
    if (@intFromEnum(SubmissionStatus.rejected) != gen.SUBMIT_REJECTED) @compileError("ABI drift: SubmissionStatus.rejected");
    if (@intFromEnum(SubmissionStatus.invalid_chain) != gen.SUBMIT_INVALID_CHAIN) @compileError("ABI drift: SubmissionStatus.invalid_chain");
    if (@intFromEnum(SubmissionStatus.unknown_anchor) != gen.SUBMIT_UNKNOWN_ANCHOR) @compileError("ABI drift: SubmissionStatus.unknown_anchor");

    if (@intFromEnum(VerificationResult.valid_proof) != gen.VERIFY_VALID_PROOF) @compileError("ABI drift: VerificationResult.valid_proof");
    if (@intFromEnum(VerificationResult.invalid_proof) != gen.VERIFY_INVALID_PROOF) @compileError("ABI drift: VerificationResult.invalid_proof");
    if (@intFromEnum(VerificationResult.inconsistent_tree) != gen.VERIFY_INCONSISTENT_TREE) @compileError("ABI drift: VerificationResult.inconsistent_tree");
    if (@intFromEnum(VerificationResult.stale_sth) != gen.VERIFY_STALE_STH) @compileError("ABI drift: VerificationResult.stale_sth");

    if (@intFromEnum(ServerState.idle) != gen.STATE_IDLE) @compileError("ABI drift: ServerState.idle");
    if (@intFromEnum(ServerState.active) != gen.STATE_ACTIVE) @compileError("ABI drift: ServerState.active");
    if (@intFromEnum(ServerState.merging) != gen.STATE_MERGING) @compileError("ABI drift: ServerState.merging");
    if (@intFromEnum(ServerState.signing) != gen.STATE_SIGNING) @compileError("ABI drift: ServerState.signing");
    if (@intFromEnum(ServerState.shutdown) != gen.STATE_SHUTDOWN) @compileError("ABI drift: ServerState.shutdown");
}

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum log name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// Maximum entries per session.
const MAX_ENTRIES: usize = 4096;

/// An entry in the CT log.
const Entry = struct {
    /// Entry type (X.509 or precert).
    entry_type: LogEntryType,
    /// Whether this entry slot is active.
    active: bool,
    /// Whether this entry has been merged into the tree.
    merged: bool,
};

/// Default (empty) entry.
const empty_entry: Entry = .{
    .entry_type = .x509_entry,
    .active = false,
    .merged = false,
};

/// A CT Log session.
const Session = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Log name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Maximum entries allowed.
    max_entries: u32,
    /// Entries.
    entries: [MAX_ENTRIES]Entry,
    /// Total submitted entries.
    entry_count: u32,
    /// Current Merkle tree size (entries merged so far).
    tree_size: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .max_entries = MAX_ENTRIES,
    .entries = [_]Entry{empty_entry} ** MAX_ENTRIES,
    .entry_count = 0,
    .tree_size = 0,
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

// -- ABI version ----------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn ctlog_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ------------------------------------------------------------

/// Create a new CT Log session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Active state (Idle -> Active transition applied).
pub export fn ctlog_create(
    name_ptr: [*]const u8,
    name_len: u32,
    max_entries: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.max_entries = if (max_entries == 0 or max_entries > MAX_ENTRIES) MAX_ENTRIES else max_entries;
            s.state = .active; // Idle -> Active
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn ctlog_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries --------------------------------------------------------

/// Returns the current ServerState tag for a session.
pub export fn ctlog_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(sessions[idx].state);
}

/// Returns total submitted entries for a session.
pub export fn ctlog_entry_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].entry_count;
}

/// Returns current Merkle tree size (merged entries).
pub export fn ctlog_tree_size(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].tree_size;
}

// -- Submission -----------------------------------------------------------

/// Entry submission is unavailable: the model does not persist entry bytes or
/// build a Merkle tree. Always rejects so callers cannot mistake metadata for a
/// logged certificate.
pub export fn ctlog_submit(
    slot: c_int,
    entry_type: u8,
    data_ptr: [*]const u8,
    data_len: u32,
) callconv(.c) u8 {
    _ = slot;
    _ = entry_type;
    _ = data_ptr;
    _ = data_len;
    return @intFromEnum(SubmissionStatus.rejected);
}

// -- Merge / Sign lifecycle -----------------------------------------------

/// Begin merging pending entries into the Merkle tree.
/// Transitions Active -> Merging.
pub export fn ctlog_begin_merge(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    sessions[idx].state = .merging;
    return 0;
}

/// Finish the merge operation, integrating pending entries into the tree.
/// Transitions Merging -> Signing (entries were merged, need new STH).
pub export fn ctlog_finish_merge(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .merging) return 1;

    // Merge all pending entries into the tree
    for (&sessions[idx].entries) |*e| {
        if (e.active and !e.merged) {
            e.merged = true;
            sessions[idx].tree_size += 1;
        }
    }

    sessions[idx].state = .signing;
    return 0;
}

/// STH signing is unavailable because no signing key or cryptographic backend
/// is configured. Always rejects and leaves the session state unchanged.
pub export fn ctlog_sign_sth(slot: c_int) callconv(.c) u8 {
    _ = slot;
    return 1;
}

// -- Verification ---------------------------------------------------------

/// Inclusion verification is unavailable: this model has no Merkle hashes or
/// proof bytes. It never reports a proof as valid.
pub export fn ctlog_verify_inclusion(slot: c_int, index: u32) callconv(.c) u8 {
    _ = slot;
    _ = index;
    return @intFromEnum(VerificationResult.invalid_proof);
}

/// Consistency verification is unavailable: this model has no Merkle hashes,
/// signed tree heads, or proof bytes. It never reports a proof as valid.
pub export fn ctlog_verify_consistency(
    slot: c_int,
    old_size: u32,
    new_size: u32,
) callconv(.c) u8 {
    _ = slot;
    _ = old_size;
    _ = new_size;
    return @intFromEnum(VerificationResult.invalid_proof);
}

// -- Shutdown / Cleanup ---------------------------------------------------

/// Initiate graceful shutdown.
/// Transitions Active/Merging/Signing -> Shutdown.
pub export fn ctlog_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .active or state == .merging or state == .signing) {
        sessions[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown.
/// Transitions Shutdown -> Idle.
pub export fn ctlog_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].entries = [_]Entry{empty_entry} ** MAX_ENTRIES;
    sessions[idx].entry_count = 0;
    sessions[idx].tree_size = 0;

    return 0;
}

// -- Stateless transition table -------------------------------------------

/// Check if a server state transition is valid.
pub export fn ctlog_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Active
    if (from == 1 and to == 2) return 1; // Active -> Merging
    if (from == 2 and to == 1) return 1; // Merging -> Active
    if (from == 2 and to == 3) return 1; // Merging -> Signing
    if (from == 3 and to == 1) return 1; // Signing -> Active
    if (from == 1 and to == 4) return 1; // Active -> Shutdown
    if (from == 2 and to == 4) return 1; // Merging -> Shutdown
    if (from == 3 and to == 4) return 1; // Signing -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
