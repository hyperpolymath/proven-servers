// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ntp.zig — Zig FFI implementation of proven-ntp.
//
// Implements the NTP protocol primitive with:
//   - Slot-based context management (up to 64 concurrent NTP contexts)
//   - NTP timestamp arithmetic (64-bit: 32 seconds + 32 fraction)
//   - Clock offset and round-trip delay calculation (RFC 5905 Section 8)
//   - Exchange lifecycle state machine (Idle -> RequestReceived ->
//     TimestampCalculated -> ResponseSent -> Idle)
//   - Clock discipline state tracking
//   - Stratum tracking with validation
//   - Kiss-o'-Death detection
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/NTPABI/Layout.idr)
//   - C header   (generated/abi/ntp.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// LeapIndicator — matches leapIndicatorToTag
pub const LeapIndicator = enum(u8) {
    no_warning = 0,
    last_minute_61 = 1,
    last_minute_59 = 2,
    unsynchronised = 3,
};

/// NTPMode — matches ntpModeToTag
pub const NTPMode = enum(u8) {
    reserved = 0,
    symmetric_active = 1,
    symmetric_passive = 2,
    client = 3,
    server = 4,
    broadcast = 5,
    control_message = 6,
    private = 7,
};

/// ExchangeState — matches exchangeStateToTag
pub const ExchangeState = enum(u8) {
    idle = 0,
    request_received = 1,
    timestamp_calculated = 2,
    response_sent = 3,
};

/// ClockDisciplineState — matches clockDisciplineStateToTag
pub const ClockDisciplineState = enum(u8) {
    unset = 0,
    spike = 1,
    freq = 2,
    sync = 3,
    panic = 4,
};

/// KissCodeABI — matches kissCodeToTag
pub const KissCode = enum(u8) {
    deny = 0,
    rstr = 1,
    rate = 2,
    other = 3,
};

/// NtpError — matches ntpErrorToTag
pub const NtpError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_packet = 3,
    kiss_of_death = 4,
    stratum_too_high = 5,
};

// ── NTP Timestamp (64-bit: 32 seconds + 32 fraction) ────────────────────

/// NTP timestamp as defined in RFC 5905 Section 6.
/// 32 bits of seconds since the NTP epoch (1900-01-01 00:00:00 UTC)
/// plus 32 bits of fractional seconds (resolution ~233 picoseconds).
pub const NtpTimestamp = struct {
    seconds: u32,
    fraction: u32,

    /// The zero/null timestamp.
    pub const zero: NtpTimestamp = .{ .seconds = 0, .fraction = 0 };

    /// Check if this timestamp is null (all zeros).
    pub fn isNull(self: NtpTimestamp) bool {
        return self.seconds == 0 and self.fraction == 0;
    }

    /// Add two timestamps with fractional carry.
    pub fn add(a: NtpTimestamp, b: NtpTimestamp) NtpTimestamp {
        const frac_sum: u64 = @as(u64, a.fraction) + @as(u64, b.fraction);
        const carry: u32 = if (frac_sum >= 0x1_0000_0000) 1 else 0;
        return .{
            .seconds = a.seconds +% b.seconds +% carry,
            .fraction = @truncate(frac_sum),
        };
    }

    /// Subtract timestamp b from a with fractional borrow.
    /// Clamps to zero on underflow (safe arithmetic).
    pub fn sub(a: NtpTimestamp, b: NtpTimestamp) NtpTimestamp {
        const borrow: u32 = if (a.fraction < b.fraction) 1 else 0;
        const new_frac: u32 = if (a.fraction >= b.fraction)
            a.fraction - b.fraction
        else
            a.fraction +% (~b.fraction +% 1); // wrapping subtraction for fraction

        const new_secs: u32 = if (a.seconds >= b.seconds +% borrow)
            a.seconds - b.seconds - borrow
        else
            0; // underflow protection: clamp to zero

        return .{ .seconds = new_secs, .fraction = new_frac };
    }

    /// Divide timestamp by 2 (used in clock offset calculation).
    pub fn half(self: NtpTimestamp) NtpTimestamp {
        const carry_frac: u32 = if (self.seconds & 1 == 1) 0x8000_0000 else 0;
        return .{
            .seconds = self.seconds >> 1,
            .fraction = (self.fraction >> 1) + carry_frac,
        };
    }

    /// Compare two timestamps: -1, 0, or 1.
    pub fn compare(a: NtpTimestamp, b: NtpTimestamp) i8 {
        if (a.seconds < b.seconds) return -1;
        if (a.seconds > b.seconds) return 1;
        if (a.fraction < b.fraction) return -1;
        if (a.fraction > b.fraction) return 1;
        return 0;
    }

    /// Convert fractional part to approximate milliseconds.
    pub fn fractionToMillis(self: NtpTimestamp) u32 {
        // fraction * 1000 / 2^32
        const frac64: u64 = @as(u64, self.fraction);
        return @truncate((frac64 * 1000) >> 32);
    }
};

/// Calculate round-trip delay: (t4 - t1) - (t3 - t2)
/// where t1 = client transmit, t2 = server receive,
///       t3 = server transmit, t4 = client receive.
pub fn roundTripDelay(t1: NtpTimestamp, t2: NtpTimestamp, t3: NtpTimestamp, t4: NtpTimestamp) NtpTimestamp {
    const client_span = NtpTimestamp.sub(t4, t1);
    const server_span = NtpTimestamp.sub(t3, t2);
    return NtpTimestamp.sub(client_span, server_span);
}

/// Calculate clock offset: ((t2 - t1) + (t3 - t4)) / 2
/// Positive offset means the server is ahead of the client.
pub fn clockOffset(t1: NtpTimestamp, t2: NtpTimestamp, t3: NtpTimestamp, t4: NtpTimestamp) NtpTimestamp {
    const diff1 = NtpTimestamp.sub(t2, t1);
    const diff2 = NtpTimestamp.sub(t3, t4);
    const sum = NtpTimestamp.add(diff1, diff2);
    return NtpTimestamp.half(sum);
}

// ── NTP Context instance ────────────────────────────────────────────────

const NtpCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// NTP version (3 or 4).
    version: u8,
    /// Association mode.
    mode: NTPMode,
    /// Current stratum level (0-16).
    stratum: u8,
    /// Leap indicator.
    leap: LeapIndicator,
    /// Exchange lifecycle state.
    exchange_state: ExchangeState,
    /// Clock discipline state.
    discipline_state: ClockDisciplineState,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of completed exchanges.
    exchange_count: u32,
    /// Last kiss-o'-death code (255 = none).
    last_kiss: u8,

    // Timestamps for the current exchange:
    /// t1: client transmit time.
    t1: NtpTimestamp,
    /// t2: server receive time.
    t2: NtpTimestamp,
    /// t3: server transmit time.
    t3: NtpTimestamp,

    // Calculated values (valid after TimestampCalculated):
    /// Computed clock offset.
    offset: NtpTimestamp,
    /// Computed round-trip delay.
    delay: NtpTimestamp,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: NtpCtx = .{
    .active = false,
    .version = 4,
    .mode = .reserved,
    .stratum = 16,
    .leap = .no_warning,
    .exchange_state = .idle,
    .discipline_state = .unset,
    .last_error = 255,
    .exchange_count = 0,
    .last_kiss = 255,
    .t1 = NtpTimestamp.zero,
    .t2 = NtpTimestamp.zero,
    .t3 = NtpTimestamp.zero,
    .offset = NtpTimestamp.zero,
    .delay = NtpTimestamp.zero,
};

var contexts: [MAX_CONTEXTS]NtpCtx = [_]NtpCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*NtpCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match NTPABI.Foreign.abiVersion (currently 1).
pub export fn ntp_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new NTP context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn ntp_create(version: u8, mode: u8, stratum: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate version (only 3 and 4 accepted)
    if (version != 3 and version != 4) return -1;
    // Validate mode (0-7)
    if (mode > 7) return -1;
    // Validate stratum (0-16)
    if (stratum > 16) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.version = version;
            ctx.mode = @enumFromInt(mode);
            ctx.stratum = stratum;
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy an NTP context, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn ntp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current ExchangeState tag for a slot.
/// Returns Idle (0) for invalid/inactive slots.
pub export fn ntp_get_exchange_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.exchange_state);
}

/// Get the current ClockDisciplineState tag for a slot.
/// Returns Unset (0) for invalid/inactive slots.
pub export fn ntp_get_discipline_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.discipline_state);
}

/// Get the current stratum value.
/// Returns 16 (Unsynchronised) for invalid/inactive slots.
pub export fn ntp_get_stratum(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 16;
    return ctx.stratum;
}

/// Get the current NTPMode tag.
/// Returns 0 (Reserved) for invalid/inactive slots.
pub export fn ntp_get_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.mode);
}

/// Get the last NtpError tag, or 255 if no error.
pub export fn ntp_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

/// Get the number of completed exchanges.
pub export fn ntp_get_exchange_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.exchange_count;
}

// ── Exchange lifecycle transitions ──────────────────────────────────────

/// Receive a client request: Idle -> RequestReceived.
/// Records client transmit (t1) and server receive (t2) timestamps.
/// Returns NtpError tag.
pub export fn ntp_receive_request(
    slot: c_int,
    t1_secs: u32,
    t1_frac: u32,
    t2_secs: u32,
    t2_frac: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state != .idle) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    ctx.t1 = .{ .seconds = t1_secs, .fraction = t1_frac };
    ctx.t2 = .{ .seconds = t2_secs, .fraction = t2_frac };
    ctx.exchange_state = .request_received;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

/// Calculate timestamps: RequestReceived -> TimestampCalculated.
/// Records server transmit time (t3) and computes offset/delay.
/// Returns NtpError tag.
pub export fn ntp_calculate(
    slot: c_int,
    t3_secs: u32,
    t3_frac: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state != .request_received) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    ctx.t3 = .{ .seconds = t3_secs, .fraction = t3_frac };

    // For offset/delay we need t4 (client receive), but in a server context
    // we compute what the client will calculate. Use t3 as a proxy for now;
    // the client will compute the real values once it receives our response.
    // Here we store t3 - t2 as the server processing time component.
    ctx.offset = NtpTimestamp.sub(ctx.t2, ctx.t1);
    ctx.delay = NtpTimestamp.sub(ctx.t3, ctx.t2);

    ctx.exchange_state = .timestamp_calculated;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

/// Send response: TimestampCalculated -> ResponseSent.
/// Returns NtpError tag.
pub export fn ntp_send_response(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state != .timestamp_calculated) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    ctx.exchange_state = .response_sent;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

/// Reset exchange: ResponseSent -> Idle.
/// Increments the exchange counter.
/// Returns NtpError tag.
pub export fn ntp_reset_exchange(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state != .response_sent) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    ctx.exchange_state = .idle;
    ctx.exchange_count += 1;
    ctx.t1 = NtpTimestamp.zero;
    ctx.t2 = NtpTimestamp.zero;
    ctx.t3 = NtpTimestamp.zero;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

// ── Timestamp getters ───────────────────────────────────────────────────

/// Read the calculated clock offset.
/// Writes to out_secs and out_frac pointers.
/// Only valid after TimestampCalculated state.
/// Returns NtpError tag.
pub export fn ntp_get_offset(
    slot: c_int,
    out_secs: ?*u32,
    out_frac: ?*u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state == .idle) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    if (out_secs) |p| p.* = ctx.offset.seconds;
    if (out_frac) |p| p.* = ctx.offset.fraction;
    return @intFromEnum(NtpError.ok);
}

/// Read the calculated round-trip delay.
/// Writes to out_secs and out_frac pointers.
/// Only valid after TimestampCalculated state.
/// Returns NtpError tag.
pub export fn ntp_get_delay(
    slot: c_int,
    out_secs: ?*u32,
    out_frac: ?*u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    if (ctx.exchange_state == .idle) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    if (out_secs) |p| p.* = ctx.delay.seconds;
    if (out_frac) |p| p.* = ctx.delay.fraction;
    return @intFromEnum(NtpError.ok);
}

// ── Leap indicator ──────────────────────────────────────────────────────

/// Set the leap indicator for a context.
/// Returns NtpError tag.
pub export fn ntp_set_leap(slot: c_int, leap: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);
    if (leap > 3) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }
    ctx.leap = @enumFromInt(leap);
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

/// Get the current leap indicator tag.
/// Returns 0 (no_warning) for invalid slots.
pub export fn ntp_get_leap(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.leap);
}

// ── Kiss-o'-Death ───────────────────────────────────────────────────────

/// Check if the last exchange was a Kiss-o'-Death.
/// Returns KissCodeABI tag, or 255 if not a KoD.
pub export fn ntp_check_kiss(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_kiss;
}

/// Set the kiss-o'-death code for a context (used when receiving a KoD).
/// Returns NtpError tag.
pub export fn ntp_set_kiss(slot: c_int, kiss: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);
    if (kiss > 3) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }
    ctx.last_kiss = kiss;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

// ── Discipline state management ─────────────────────────────────────────

/// Advance the clock discipline state.
/// Validates the transition against the schema defined in Transitions.idr.
/// Returns NtpError tag.
pub export fn ntp_advance_discipline(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);

    const from = @intFromEnum(ctx.discipline_state);
    if (ntp_can_discipline_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(NtpError.invalid_packet);
        return @intFromEnum(NtpError.invalid_packet);
    }

    ctx.discipline_state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}

// ── Stateless validation ────────────────────────────────────────────────

/// Check whether an exchange state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateExchangeTransition exactly.
pub export fn ntp_can_exchange_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle -> RequestReceived
    if (from == 0 and to == 1) return 1;
    // RequestReceived -> TimestampCalculated
    if (from == 1 and to == 2) return 1;
    // TimestampCalculated -> ResponseSent
    if (from == 2 and to == 3) return 1;
    // ResponseSent -> Idle
    if (from == 3 and to == 0) return 1;
    return 0;
}

/// Check whether a clock discipline state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateDisciplineTransition exactly.
pub export fn ntp_can_discipline_transition(from: u8, to: u8) callconv(.c) u8 {
    // Unset -> Spike (FirstSample)
    if (from == 0 and to == 1) return 1;
    // Spike -> Freq (Stabilise)
    if (from == 1 and to == 2) return 1;
    // Freq -> Sync (Lock)
    if (from == 2 and to == 3) return 1;
    // Unset -> Panic (PanicFromUnset)
    if (from == 0 and to == 4) return 1;
    // Spike -> Panic (PanicFromSpike)
    if (from == 1 and to == 4) return 1;
    // Freq -> Panic (PanicFromFreq)
    if (from == 2 and to == 4) return 1;
    // Sync -> Panic (PanicFromSync)
    if (from == 3 and to == 4) return 1;
    // Panic -> Unset (Recovery)
    if (from == 4 and to == 0) return 1;
    // Sync -> Freq (LostLock)
    if (from == 3 and to == 2) return 1;
    return 0;
}

/// Set stratum level for a context.
/// Returns NtpError tag.
pub export fn ntp_set_stratum(slot: c_int, stratum: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(NtpError.invalid_slot);
    if (stratum > 16) {
        ctx.last_error = @intFromEnum(NtpError.stratum_too_high);
        return @intFromEnum(NtpError.stratum_too_high);
    }
    ctx.stratum = stratum;
    ctx.last_error = 255;
    return @intFromEnum(NtpError.ok);
}
