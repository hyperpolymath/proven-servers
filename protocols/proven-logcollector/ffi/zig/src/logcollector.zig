// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// logcollector.zig — Zig FFI implementation of proven-logcollector.
//
// Implements the structured log collection pipeline primitive with:
//   - Slot-based pipeline management (up to 64 concurrent pipelines)
//   - Pipeline stage state machine (Input -> Parse -> Filter -> Transform -> Output)
//   - Log level filtering with configurable minimum threshold
//   - Entry ingestion with level-based filtering
//   - Filter operation tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/LogcollectorABI/Layout.idr)
//   - C header   (generated/abi/logcollector.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// LogLevel — matches logLevelToTag
pub const LogLevel = enum(u8) {
    trace = 0,
    debug = 1,
    info = 2,
    warn = 3,
    err = 4,
    fatal = 5,
};

/// InputFormat — matches inputFormatToTag
pub const InputFormat = enum(u8) {
    json = 0,
    logfmt = 1,
    syslog = 2,
    cef = 3,
    gelf = 4,
    raw = 5,
};

/// OutputTarget — matches outputTargetToTag
pub const OutputTarget = enum(u8) {
    file = 0,
    elasticsearch = 1,
    s3 = 2,
    kafka = 3,
    stdout = 4,
};

/// FilterOp — matches filterOpToTag
pub const FilterOp = enum(u8) {
    include = 0,
    exclude = 1,
    transform = 2,
    redact = 3,
    sample = 4,
};

/// PipelineStage — matches pipelineStageToTag
pub const PipelineStage = enum(u8) {
    input = 0,
    parse = 1,
    filter = 2,
    pipeline_transform = 3,
    output = 4,
};

/// LogcollectorError — matches logcollectorErrorToTag
pub const LogcollectorError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    below_threshold = 4,
    capacity_exhausted = 5,
    invalid_param = 6,
};

// ── Pipeline Context instance ───────────────────────────────────────────

const PipelineCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Input format for this pipeline.
    input_format: InputFormat,
    /// Output destination.
    output_target: OutputTarget,
    /// Minimum log level to accept (entries below are dropped).
    min_level: LogLevel,
    /// Current pipeline stage.
    current_stage: PipelineStage,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of log entries successfully processed.
    entries_processed: u32,
    /// Number of log entries dropped (below threshold or filtered).
    entries_dropped: u32,
    /// Number of filter operations applied.
    filters_applied: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: PipelineCtx = .{
    .active = false,
    .input_format = .json,
    .output_target = .stdout,
    .min_level = .trace,
    .current_stage = .input,
    .last_error = 255,
    .entries_processed = 0,
    .entries_dropped = 0,
    .filters_applied = 0,
};

var contexts: [MAX_CONTEXTS]PipelineCtx = [_]PipelineCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

fn getActive(slot: c_int) ?*PipelineCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

pub export fn lc_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new log collection pipeline.
pub export fn lc_create(input_fmt: u8, output_target: u8, min_level: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (input_fmt > 5) return -1;
    if (output_target > 4) return -1;
    if (min_level > 5) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.input_format = @enumFromInt(input_fmt);
            ctx.output_target = @enumFromInt(output_target);
            ctx.min_level = @enumFromInt(min_level);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a log collection pipeline.
pub export fn lc_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

pub export fn lc_get_input_format(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.input_format);
}

pub export fn lc_get_output_target(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.output_target);
}

pub export fn lc_get_min_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.min_level);
}

pub export fn lc_get_current_stage(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.current_stage);
}

pub export fn lc_get_entries_processed(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.entries_processed;
}

pub export fn lc_get_entries_dropped(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.entries_dropped;
}

pub export fn lc_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Log ingestion ───────────────────────────────────────────────────────

/// Ingest a log entry with the given level.
/// Returns LogcollectorError tag.
/// Entries below min_level are dropped (BelowThreshold).
pub export fn lc_ingest(slot: c_int, level: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LogcollectorError.invalid_slot);

    if (level > 5) {
        ctx.last_error = @intFromEnum(LogcollectorError.invalid_param);
        return @intFromEnum(LogcollectorError.invalid_param);
    }

    // Check against minimum level threshold
    if (level < @intFromEnum(ctx.min_level)) {
        ctx.entries_dropped += 1;
        ctx.last_error = @intFromEnum(LogcollectorError.below_threshold);
        return @intFromEnum(LogcollectorError.below_threshold);
    }

    ctx.entries_processed += 1;
    ctx.last_error = 255;
    return @intFromEnum(LogcollectorError.ok);
}

// ── Filter operations ───────────────────────────────────────────────────

/// Apply a filter operation to the pipeline.
/// Returns LogcollectorError tag.
pub export fn lc_apply_filter(slot: c_int, filter_op: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LogcollectorError.invalid_slot);

    if (filter_op > 4) {
        ctx.last_error = @intFromEnum(LogcollectorError.invalid_param);
        return @intFromEnum(LogcollectorError.invalid_param);
    }

    ctx.filters_applied += 1;
    ctx.last_error = 255;
    return @intFromEnum(LogcollectorError.ok);
}

// ── Pipeline stage advancement ──────────────────────────────────────────

/// Advance the pipeline to the next stage.
/// Stages must advance in order: Input -> Parse -> Filter -> Transform -> Output.
/// Returns LogcollectorError tag.
pub export fn lc_advance_stage(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LogcollectorError.invalid_slot);

    const current = @intFromEnum(ctx.current_stage);
    if (current >= 4) {
        // Already at Output, cannot advance further
        ctx.last_error = @intFromEnum(LogcollectorError.invalid_transition);
        return @intFromEnum(LogcollectorError.invalid_transition);
    }

    ctx.current_stage = @enumFromInt(current + 1);
    ctx.last_error = 255;
    return @intFromEnum(LogcollectorError.ok);
}

// ── Configuration setters ───────────────────────────────────────────────

/// Set the minimum log level for filtering.
pub export fn lc_set_min_level(slot: c_int, level: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LogcollectorError.invalid_slot);

    if (level > 5) {
        ctx.last_error = @intFromEnum(LogcollectorError.invalid_param);
        return @intFromEnum(LogcollectorError.invalid_param);
    }

    ctx.min_level = @enumFromInt(level);
    ctx.last_error = 255;
    return @intFromEnum(LogcollectorError.ok);
}
