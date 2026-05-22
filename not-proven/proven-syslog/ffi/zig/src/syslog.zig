// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// syslog.zig — Zig FFI implementation of proven-syslog.
//
// Implements the Syslog collector primitive (RFC 5424) with:
//   - Slot-based collector management (up to 64 concurrent collectors)
//   - Message ingestion with facility (0-23) and severity (0-7) tracking
//   - Priority computation (facility * 8 + severity)
//   - Transport protocol management (UDP/514, TCP/514, TLS/6514)
//   - Severity-based message filtering
//   - Message and drop counters
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)
//   - C header   (generated/abi/syslog.h)

const std = @import("std");

// ── Enums (matching Idris2 SyslogABI.Types tag assignments exactly) ─────

/// Severity — matches severityToTag (RFC 5424 Section 6.2.1)
pub const Severity = enum(u8) {
    emergency = 0,
    alert = 1,
    critical = 2,
    err = 3,
    warning = 4,
    notice = 5,
    informational = 6,
    debug = 7,
};

/// Facility — matches facilityToTag (RFC 5424 Section 6.2.1)
pub const Facility = enum(u8) {
    kern = 0,
    user = 1,
    mail = 2,
    daemon = 3,
    auth = 4,
    syslog_f = 5,
    lpr = 6,
    news = 7,
    uucp = 8,
    cron = 9,
    auth_priv = 10,
    ftp = 11,
    ntp = 12,
    audit = 13,
    alert_f = 14,
    clock = 15,
    local0 = 16,
    local1 = 17,
    local2 = 18,
    local3 = 19,
    local4 = 20,
    local5 = 21,
    local6 = 22,
    local7 = 23,
};

/// Transport — matches transportToTag
pub const Transport = enum(u8) {
    udp_514 = 0,
    tcp_514 = 1,
    tls_6514 = 2,
};

/// SyslogError — error codes for FFI operations
pub const SyslogError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_facility = 3,
    invalid_severity = 4,
    invalid_transport = 5,
    filtered = 6,
};

// ── Collector Context ───────────────────────────────────────────────────

const CollectorCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Transport protocol.
    transport: Transport,
    /// Total messages ingested (including filtered).
    message_count: u32,
    /// Messages dropped by severity filter.
    dropped_count: u32,
    /// Last facility tag (255 = none).
    last_facility: u8,
    /// Last severity tag (255 = none).
    last_severity: u8,
    /// Minimum severity filter (7 = Debug, accept all by default).
    min_severity: u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: CollectorCtx = .{
    .active = false,
    .transport = .udp_514,
    .message_count = 0,
    .dropped_count = 0,
    .last_facility = 255,
    .last_severity = 255,
    .min_severity = 7, // Accept all (Debug is least severe)
};

var contexts: [MAX_CONTEXTS]CollectorCtx = [_]CollectorCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*CollectorCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match SyslogABI.Foreign.abiVersion (currently 1).
pub export fn syslog_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new syslog collector context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn syslog_create(transport: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate transport (0-2)
    if (transport > 2) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.transport = @enumFromInt(transport);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a collector context, freeing its slot.
pub export fn syslog_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the Transport tag for a slot.
/// Returns UDP514 (0) for invalid/inactive slots.
pub export fn syslog_get_transport(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.transport);
}

/// Get the total number of messages ingested.
pub export fn syslog_get_message_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.message_count;
}

/// Get the last facility tag (255 = none).
pub export fn syslog_get_last_facility(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_facility;
}

/// Get the last severity tag (255 = none).
pub export fn syslog_get_last_severity(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_severity;
}

/// Get the last computed priority value (facility * 8 + severity).
/// Returns 0xFFFFFFFF for invalid/inactive slots or if no message ingested.
pub export fn syslog_get_last_priority(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0xFFFFFFFF;
    if (ctx.last_facility == 255 or ctx.last_severity == 255) return 0xFFFFFFFF;
    return @as(u32, ctx.last_facility) * 8 + @as(u32, ctx.last_severity);
}

/// Get the minimum severity filter tag.
pub export fn syslog_get_min_severity(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 7;
    return ctx.min_severity;
}

/// Get the count of messages dropped by severity filter.
pub export fn syslog_get_dropped_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.dropped_count;
}

// ── Operations ──────────────────────────────────────────────────────────

/// Set the transport protocol.
/// Returns SyslogError tag.
pub export fn syslog_set_transport(slot: c_int, t: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SyslogError.invalid_slot);

    if (t > 2) {
        return @intFromEnum(SyslogError.invalid_transport);
    }

    ctx.transport = @enumFromInt(t);
    return @intFromEnum(SyslogError.ok);
}

/// Set the minimum severity filter.
/// Messages with severity > min_severity (less severe) will be dropped.
/// Returns SyslogError tag.
pub export fn syslog_set_min_severity(slot: c_int, sev: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SyslogError.invalid_slot);

    if (sev > 7) {
        return @intFromEnum(SyslogError.invalid_severity);
    }

    ctx.min_severity = sev;
    return @intFromEnum(SyslogError.ok);
}

/// Ingest a syslog message with given facility and severity.
/// Messages less severe than min_severity are counted but marked as dropped.
/// Returns SyslogError tag (Filtered if dropped).
pub export fn syslog_ingest(slot: c_int, fac: u8, sev: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SyslogError.invalid_slot);

    if (fac > 23) {
        return @intFromEnum(SyslogError.invalid_facility);
    }

    if (sev > 7) {
        return @intFromEnum(SyslogError.invalid_severity);
    }

    ctx.last_facility = fac;
    ctx.last_severity = sev;
    ctx.message_count += 1;

    // Filter: lower numeric severity = more severe.
    // Drop if message severity > min_severity (less severe than threshold).
    if (sev > ctx.min_severity) {
        ctx.dropped_count += 1;
        return @intFromEnum(SyslogError.filtered);
    }

    return @intFromEnum(SyslogError.ok);
}

// ── Stateless priority computation ──────────────────────────────────────

/// Compute the syslog priority value: facility * 8 + severity.
/// Returns 0xFFFFFFFF for invalid facility or severity.
pub export fn syslog_compute_priority(fac: u8, sev: u8) callconv(.c) u32 {
    if (fac > 23 or sev > 7) return 0xFFFFFFFF;
    return @as(u32, fac) * 8 + @as(u32, sev);
}
