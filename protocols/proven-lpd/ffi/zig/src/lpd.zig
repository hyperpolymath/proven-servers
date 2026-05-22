// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// lpd.zig — Zig FFI implementation of proven-lpd.
//
// Implements the RFC 1179 Line Printer Daemon protocol primitive with:
//   - Slot-based print queue management (up to 64 concurrent queues)
//   - Job lifecycle: Pending -> Printing -> Complete/Failed
//   - Bounded FIFO queue with configurable depth and job size limits
//   - Queue pause/resume for administrative control
//   - Command code parsing (0x01-0x05 per RFC 1179)
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/LPDABI/Layout.idr)
//   - C header   (generated/abi/lpd.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// CommandCode — matches commandCodeToTag (RFC 1179 codes 1-5)
pub const CommandCode = enum(u8) {
    print_job = 1,
    receive_job = 2,
    short_queue = 3,
    long_queue = 4,
    remove_jobs = 5,
};

/// SubCommandCode — matches subCommandCodeToTag (RFC 1179 sub-commands 1-3)
pub const SubCommandCode = enum(u8) {
    abort_job = 1,
    control_file = 2,
    data_file = 3,
};

/// JobStatusTag — matches jobStatusTagToTag
pub const JobStatusTag = enum(u8) {
    pending = 0,
    printing = 1,
    complete = 2,
    failed = 3,
};

/// LPDError — matches lpdErrorToTag
pub const LPDError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    queue_full = 3,
    not_accepting = 4,
    job_not_found = 5,
    invalid_param = 6,
};

// ── Job and Queue instances ─────────────────────────────────────────────

const MAX_JOBS: usize = 256;

const Job = struct {
    active: bool,
    job_id: u32,
    status: JobStatusTag,
    data_size: u32,
};

const empty_job: Job = .{
    .active = false,
    .job_id = 0,
    .status = .pending,
    .data_size = 0,
};

const QueueCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Maximum number of jobs allowed.
    max_depth: u32,
    /// Maximum size of a single job in bytes.
    max_job_size: u32,
    /// Whether the queue is accepting new jobs.
    accepting: bool,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Next job number to assign (wraps at 999 per RFC 1179).
    next_job_num: u32,
    /// Total jobs submitted.
    total_submitted: u32,
    /// Total jobs completed.
    total_completed: u32,
    /// Number of active jobs in the queue.
    job_count: u32,
    /// Job array (FIFO).
    jobs: [MAX_JOBS]Job,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: QueueCtx = .{
    .active = false,
    .max_depth = 100,
    .max_job_size = 104857600, // 100 MiB
    .accepting = true,
    .last_error = 255,
    .next_job_num = 1,
    .total_submitted = 0,
    .total_completed = 0,
    .job_count = 0,
    .jobs = [_]Job{empty_job} ** MAX_JOBS,
};

var contexts: [MAX_CONTEXTS]QueueCtx = [_]QueueCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

fn getActive(slot: c_int) ?*QueueCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

/// Find a job by ID in the queue.
fn findJob(ctx: *QueueCtx, job_id: u32) ?*Job {
    for (ctx.jobs[0..ctx.job_count]) |*j| {
        if (j.active and j.job_id == job_id) return j;
    }
    return null;
}

// ── ABI version ─────────────────────────────────────────────────────────

pub export fn lpd_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new print queue.
pub export fn lpd_create(max_depth: u32, max_job_size: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (max_depth == 0 or max_depth > MAX_JOBS) return -1;
    if (max_job_size == 0) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.max_depth = max_depth;
            ctx.max_job_size = max_job_size;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a print queue.
pub export fn lpd_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

pub export fn lpd_get_job_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.job_count;
}

pub export fn lpd_get_max_depth(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.max_depth;
}

pub export fn lpd_get_total_submitted(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.total_submitted;
}

pub export fn lpd_get_total_completed(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.total_completed;
}

pub export fn lpd_is_accepting(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return if (ctx.accepting) 1 else 0;
}

pub export fn lpd_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Job management ──────────────────────────────────────────────────────

/// Enqueue a new job. Returns job ID (0-999) or -1 on error.
pub export fn lpd_enqueue(slot: c_int, data_size: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return -1;

    if (!ctx.accepting) {
        ctx.last_error = @intFromEnum(LPDError.not_accepting);
        return -1;
    }

    if (ctx.job_count >= ctx.max_depth) {
        ctx.last_error = @intFromEnum(LPDError.queue_full);
        return -1;
    }

    if (data_size > ctx.max_job_size) {
        ctx.last_error = @intFromEnum(LPDError.invalid_param);
        return -1;
    }

    const job_id = ctx.next_job_num;
    ctx.jobs[ctx.job_count] = .{
        .active = true,
        .job_id = job_id,
        .status = .pending,
        .data_size = data_size,
    };
    ctx.job_count += 1;
    ctx.next_job_num = if (ctx.next_job_num >= 999) 0 else ctx.next_job_num + 1;
    ctx.total_submitted += 1;
    ctx.last_error = 255;
    return @intCast(job_id);
}

/// Dequeue the next pending job for printing.
/// Returns job ID or -1 if no pending jobs.
pub export fn lpd_dequeue(slot: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return -1;

    for (ctx.jobs[0..ctx.job_count]) |*j| {
        if (j.active and j.status == .pending) {
            j.status = .printing;
            ctx.last_error = 255;
            return @intCast(j.job_id);
        }
    }
    ctx.last_error = @intFromEnum(LPDError.job_not_found);
    return -1;
}

/// Get the status of a job by ID.
/// Returns JobStatusTag or 255 if not found.
pub export fn lpd_get_job_status(slot: c_int, job_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    const job = findJob(ctx, job_id) orelse return 255;
    return @intFromEnum(job.status);
}

/// Mark a job as complete. Returns LPDError tag.
pub export fn lpd_complete_job(slot: c_int, job_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LPDError.invalid_slot);

    const job = findJob(ctx, job_id) orelse {
        ctx.last_error = @intFromEnum(LPDError.job_not_found);
        return @intFromEnum(LPDError.job_not_found);
    };

    job.status = .complete;
    ctx.total_completed += 1;
    ctx.last_error = 255;
    return @intFromEnum(LPDError.ok);
}

/// Mark a job as failed. Returns LPDError tag.
pub export fn lpd_fail_job(slot: c_int, job_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LPDError.invalid_slot);

    const job = findJob(ctx, job_id) orelse {
        ctx.last_error = @intFromEnum(LPDError.job_not_found);
        return @intFromEnum(LPDError.job_not_found);
    };

    job.status = .failed;
    ctx.last_error = 255;
    return @intFromEnum(LPDError.ok);
}

// ── Queue control ───────────────────────────────────────────────────────

/// Pause the queue (stop accepting new jobs).
pub export fn lpd_pause_queue(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LPDError.invalid_slot);
    ctx.accepting = false;
    ctx.last_error = 255;
    return @intFromEnum(LPDError.ok);
}

/// Resume the queue (start accepting new jobs).
pub export fn lpd_resume_queue(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LPDError.invalid_slot);
    ctx.accepting = true;
    ctx.last_error = 255;
    return @intFromEnum(LPDError.ok);
}

// ── Command parsing ─────────────────────────────────────────────────────

/// Parse a command byte code (RFC 1179).
/// Returns the CommandCode tag (1-5) if valid, or 255 if unknown.
pub export fn lpd_parse_command(code: u8) callconv(.c) u8 {
    if (code >= 1 and code <= 5) return code;
    return 255;
}
