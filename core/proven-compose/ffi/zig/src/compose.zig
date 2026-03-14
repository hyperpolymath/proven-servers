// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// compose.zig — Zig FFI implementation of proven-compose.
//
// Implements verified composition pipeline management with:
//   - Slot-based pipeline session management (up to 64 concurrent)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Combinator-aware compatibility checking
//   - Thread-safe via mutex

const std = @import("std");

// ── Enums (matching ComposeABI.Layout.idr tag assignments) ──────────────

pub const Combinator = enum(u8) {
    chain = 0,
    parallel = 1,
    proxy = 2,
    relay = 3,
    mux = 4,
    demux = 5,
    filter = 6,
    transform = 7,
    tap = 8,
};

pub const Compatibility = enum(u8) {
    compatible = 0,
    incompatible_types = 1,
    incompatible_framing = 2,
    incompatible_security = 3,
    incompatible_direction = 4,
};

pub const Direction = enum(u8) {
    upstream = 0,
    downstream = 1,
    bidirectional = 2,
};

pub const CompositionError = enum(u8) {
    type_mismatch = 0,
    security_downgrade = 1,
    cycle_detected = 2,
    missing_dependency = 3,
    ambiguous_route = 4,
};

pub const PipelineStage = enum(u8) {
    ingress = 0,
    process = 1,
    egress = 2,
    error_handler = 3,
    audit = 4,
};

pub const PipelineState = enum(u8) {
    idle = 0,
    configured = 1,
    assembled = 2,
    running = 3,
    stopped = 4,
    failed = 5,
};

// ── Pipeline session ────────────────────────────────────────────────────

const MAX_STAGES: usize = 16;

const Session = struct {
    state: PipelineState,
    combinator: Combinator,
    direction: Direction,
    stages: [MAX_STAGES]PipelineStage,
    stage_count: u8,
    last_error: u8, // 255 = no error
    active: bool,
};

const MAX_SESSIONS: usize = 64;
var sessions: [MAX_SESSIONS]Session = [_]Session{.{
    .state = .idle,
    .combinator = .chain,
    .direction = .downstream,
    .stages = [_]PipelineStage{.ingress} ** MAX_STAGES,
    .stage_count = 0,
    .last_error = 255,
    .active = false,
}} ** MAX_SESSIONS;

var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// ── ABI version ─────────────────────────────────────────────────────────

pub export fn compose_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

pub export fn compose_create(combinator_tag: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (combinator_tag > 8) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .idle,
                .combinator = @enumFromInt(combinator_tag),
                .direction = .downstream,
                .stages = [_]PipelineStage{.ingress} ** MAX_STAGES,
                .stage_count = 0,
                .last_error = 255,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn compose_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

pub export fn compose_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn compose_combinator(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].combinator);
}

pub export fn compose_direction(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // downstream default
    return @intFromEnum(sessions[idx].direction);
}

pub export fn compose_set_direction(slot: c_int, dir_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (dir_tag > 2) return 1;
    // Can only set direction while idle or configured
    if (sessions[idx].state != .idle and sessions[idx].state != .configured) return 1;
    sessions[idx].direction = @enumFromInt(dir_tag);
    return 0;
}

pub export fn compose_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_error;
}

pub export fn compose_stage_count(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].stage_count;
}

// ── Stage management ────────────────────────────────────────────────────

pub export fn compose_add_stage(slot: c_int, stage_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (stage_tag > 4) return 1;
    // Can only add stages while idle or configured
    if (sessions[idx].state != .idle and sessions[idx].state != .configured) return 1;
    if (sessions[idx].stage_count >= MAX_STAGES) return 1;
    sessions[idx].stages[sessions[idx].stage_count] = @enumFromInt(stage_tag);
    sessions[idx].stage_count += 1;
    return 0;
}

// ── Transitions ─────────────────────────────────────────────────────────

pub export fn compose_configure(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .idle) {
        sessions[idx].state = .configured;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0; // invalid_transition
    return 1;
}

pub export fn compose_assemble(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .configured) {
        sessions[idx].state = .assembled;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

pub export fn compose_activate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .assembled) {
        sessions[idx].state = .running;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

pub export fn compose_deactivate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .running) {
        sessions[idx].state = .stopped;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

pub export fn compose_fail(slot: c_int, err_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const s = sessions[idx].state;
    if (s == .configured or s == .assembled or s == .running) {
        sessions[idx].state = .failed;
        sessions[idx].last_error = err_tag;
        return 0;
    }
    return 1;
}

pub export fn compose_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .failed) {
        sessions[idx].state = .idle;
        sessions[idx].stage_count = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    if (sessions[idx].state == .stopped) {
        sessions[idx].state = .idle;
        sessions[idx].stage_count = 0;
        sessions[idx].last_error = 255;
        return 0;
    }
    sessions[idx].last_error = 0;
    return 1;
}

// ── Stateless queries ───────────────────────────────────────────────────

pub export fn compose_check_compat(a_tag: u8, b_tag: u8) callconv(.c) u8 {
    // Basic compatibility: same combinator type is always compatible.
    // Different types have specific compatibility rules.
    if (a_tag > 8 or b_tag > 8) return @intFromEnum(Compatibility.incompatible_types);
    if (a_tag == b_tag) return @intFromEnum(Compatibility.compatible);
    // Chain + Filter/Transform/Tap are compatible (they compose sequentially)
    const a: Combinator = @enumFromInt(a_tag);
    const b: Combinator = @enumFromInt(b_tag);
    if ((a == .chain or a == .filter or a == .transform or a == .tap) and
        (b == .chain or b == .filter or b == .transform or b == .tap))
        return @intFromEnum(Compatibility.compatible);
    // Mux + Demux are compatible (they are inverses)
    if ((a == .mux and b == .demux) or (a == .demux and b == .mux))
        return @intFromEnum(Compatibility.compatible);
    // Proxy + Relay are compatible (forwarding patterns)
    if ((a == .proxy and b == .relay) or (a == .relay and b == .proxy))
        return @intFromEnum(Compatibility.compatible);
    // Everything else is incompatible by framing
    return @intFromEnum(Compatibility.incompatible_framing);
}

pub export fn compose_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validatePipelineTransition exactly
    if (from == 0 and to == 1) return 1; // Idle -> Configured
    if (from == 1 and to == 2) return 1; // Configured -> Assembled
    if (from == 2 and to == 3) return 1; // Assembled -> Running
    if (from == 3 and to == 4) return 1; // Running -> Stopped
    if (from == 1 and to == 5) return 1; // Configured -> Failed
    if (from == 2 and to == 5) return 1; // Assembled -> Failed
    if (from == 3 and to == 5) return 1; // Running -> Failed
    if (from == 5 and to == 0) return 1; // Failed -> Idle
    if (from == 4 and to == 0) return 1; // Stopped -> Idle
    return 0;
}
