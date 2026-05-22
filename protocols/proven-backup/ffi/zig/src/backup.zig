// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// backup.zig -- Zig FFI implementation of proven-backup.
//
// Implements the backup server state machine with:
//   - 64-slot mutex-protected backup job pool
//   - Per-job configuration (type, schedule, compression, encryption)
//   - Job lifecycle: Idle -> Running -> Verifying -> Complete
//   - Failure and cancellation paths
//   - Retention policy per job
//   - Byte counter for progress tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching BackupABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching BackupABI.Types.idr tag assignments)
// =========================================================================

/// Backup types (ABI tags 0-4).
pub const BackupType = enum(u8) {
    full = 0,
    incremental = 1,
    differential = 2,
    snapshot = 3,
    mirror = 4,
};

/// Schedule frequencies (ABI tags 0-4).
pub const ScheduleFreq = enum(u8) {
    hourly = 0,
    daily = 1,
    weekly = 2,
    monthly = 3,
    on_demand = 4,
};

/// Compression algorithms (ABI tags 0-4).
pub const CompressionAlg = enum(u8) {
    none = 0,
    gzip = 1,
    zstd = 2,
    lz4 = 3,
    xz = 4,
};

/// Encryption algorithms (ABI tags 0-2).
pub const EncryptionAlg = enum(u8) {
    no_encryption = 0,
    aes256gcm = 1,
    chacha20poly1305 = 2,
};

/// Backup job lifecycle states (ABI tags 0-5).
pub const BackupState = enum(u8) {
    idle = 0,
    running = 1,
    verifying = 2,
    complete = 3,
    failed = 4,
    cancelled = 5,
};

/// Retention policies (ABI tags 0-4).
pub const RetentionPolicy = enum(u8) {
    keep_all = 0,
    keep_last = 1,
    keep_daily = 2,
    keep_weekly = 3,
    keep_monthly = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent backup jobs.
const MAX_JOBS: usize = 64;

/// A backup job.
const Job = struct {
    /// Current job lifecycle state.
    state: BackupState,
    /// Type of backup.
    backup_type: BackupType,
    /// Schedule frequency.
    schedule: ScheduleFreq,
    /// Compression algorithm.
    compression: CompressionAlg,
    /// Encryption algorithm.
    encryption: EncryptionAlg,
    /// Retention policy.
    retention: RetentionPolicy,
    /// Bytes processed so far.
    bytes_processed: u64,
    /// Whether this job slot is in use.
    active: bool,
};

/// Default (empty) job.
const empty_job: Job = .{
    .state = .idle,
    .backup_type = .full,
    .schedule = .on_demand,
    .compression = .none,
    .encryption = .no_encryption,
    .retention = .keep_all,
    .bytes_processed = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var jobs: [MAX_JOBS]Job = [_]Job{empty_job} ** MAX_JOBS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_JOBS) return null;
    const idx: usize = @intCast(slot);
    if (!jobs[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn backup_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new backup job. Returns slot index (>=0) or -1 on failure.
/// The job starts in Idle state.
pub export fn backup_create(
    backup_type: u8,
    schedule: u8,
    compression: u8,
    encryption: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (backup_type > 4) return -1;
    if (schedule > 4) return -1;
    if (compression > 4) return -1;
    if (encryption > 2) return -1;

    for (&jobs, 0..) |*j, i| {
        if (!j.active) {
            j.* = empty_job;
            j.backup_type = @enumFromInt(backup_type);
            j.schedule = @enumFromInt(schedule);
            j.compression = @enumFromInt(compression);
            j.encryption = @enumFromInt(encryption);
            j.state = .idle;
            j.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a backup job, releasing its slot.
pub export fn backup_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_JOBS) return;
    jobs[@intCast(slot)] = empty_job;
}

// -- State queries ------------------------------------------------------------

/// Returns the current BackupState tag.
pub export fn backup_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(jobs[idx].state);
}

// -- Job lifecycle transitions ------------------------------------------------

/// Start a backup job. Returns 0 on success, 1 on rejection.
/// Transitions: Idle -> Running.
pub export fn backup_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (jobs[idx].state != .idle) return 1;

    jobs[idx].state = .running;
    jobs[idx].bytes_processed = 0;
    return 0;
}

/// Begin verification. Returns 0 on success, 1 on rejection.
/// Transitions: Running -> Verifying.
pub export fn backup_verify(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (jobs[idx].state != .running) return 1;

    jobs[idx].state = .verifying;
    return 0;
}

/// Complete the backup. Returns 0 on success, 1 on rejection.
/// Transitions: Verifying -> Complete.
pub export fn backup_complete(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (jobs[idx].state != .verifying) return 1;

    jobs[idx].state = .complete;
    return 0;
}

/// Fail the backup. Returns 0 on success, 1 on rejection.
/// Transitions: Running/Verifying -> Failed.
pub export fn backup_fail(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = jobs[idx].state;
    if (state != .running and state != .verifying) return 1;

    jobs[idx].state = .failed;
    return 0;
}

/// Cancel the backup. Returns 0 on success, 1 on rejection.
/// Transitions: Running -> Cancelled.
pub export fn backup_cancel(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (jobs[idx].state != .running) return 1;

    jobs[idx].state = .cancelled;
    return 0;
}

// -- Retention policy ---------------------------------------------------------

/// Set retention policy. Returns 0 on success, 1 on rejection.
pub export fn backup_set_retention(slot: c_int, policy: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (policy > 4) return 1;

    jobs[idx].retention = @enumFromInt(policy);
    return 0;
}

/// Returns the current RetentionPolicy tag.
pub export fn backup_retention(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // keep_all fallback
    return @intFromEnum(jobs[idx].retention);
}

// -- Progress tracking --------------------------------------------------------

/// Returns bytes processed so far.
pub export fn backup_bytes_processed(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return jobs[idx].bytes_processed;
}

// -- Reset --------------------------------------------------------------------

/// Reset a completed/failed/cancelled job to Idle. Returns 0 on success, 1 on rejection.
/// Transitions: Complete/Failed/Cancelled -> Idle.
pub export fn backup_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = jobs[idx].state;
    if (state != .complete and state != .failed and state != .cancelled) return 1;

    jobs[idx].state = .idle;
    jobs[idx].bytes_processed = 0;
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a job state transition is valid.
pub export fn backup_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Running
    if (from == 1 and to == 2) return 1; // Running -> Verifying
    if (from == 2 and to == 3) return 1; // Verifying -> Complete
    if (from == 1 and to == 4) return 1; // Running -> Failed
    if (from == 2 and to == 4) return 1; // Verifying -> Failed
    if (from == 1 and to == 5) return 1; // Running -> Cancelled
    if (from == 3 and to == 0) return 1; // Complete -> Idle (reset)
    if (from == 4 and to == 0) return 1; // Failed -> Idle (reset)
    if (from == 5 and to == 0) return 1; // Cancelled -> Idle (reset)
    return 0;
}
