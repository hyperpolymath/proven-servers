// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// config.zig — Zig FFI implementation of proven-config.
//
// Implements configuration lifecycle management with:
//   - Slot-based session management (up to 64 concurrent)
//   - State machine enforcement matching Idris2 Transitions.idr proofs
//   - Security policy / override level tracking
//   - Downgrade prevention (cannot weaken security policy)
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/ConfigABI/Layout.idr, src/ConfigABI/Transitions.idr)
//   - C header   (generated/abi/config.h)

const std = @import("std");

// ── Enums (matching ConfigABI.Layout.idr tag assignments exactly) ────────

/// ConfigSource — matches configSourceToTag
pub const ConfigSource = enum(u8) {
    file = 0,
    environment = 1,
    command_line = 2,
    default = 3,
    remote = 4,
};

/// ValidationResult — matches validationResultToTag
pub const ValidationResult = enum(u8) {
    valid = 0,
    invalid_value = 1,
    missing_required = 2,
    security_violation = 3,
    type_mismatch = 4,
    out_of_range = 5,
};

/// SecurityPolicy — matches securityPolicyToTag
pub const SecurityPolicy = enum(u8) {
    require_tls = 0,
    require_auth = 1,
    require_encryption = 2,
    allow_plaintext = 3,
    allow_anonymous = 4,
};

/// OverrideLevel — matches overrideLevelToTag
pub const OverrideLevel = enum(u8) {
    default = 0,
    user = 1,
    admin = 2,
    emergency = 3,
};

/// ConfigError — matches configErrorToTag
pub const ConfigError = enum(u8) {
    parse_error = 0,
    schema_violation = 1,
    security_downgrade = 2,
    conflicting_values = 3,
    unknown_key = 4,
};

/// ConfigState — matches configStateToTag in Transitions.idr
pub const ConfigState = enum(u8) {
    uninitialised = 0,
    loading = 1,
    validating = 2,
    active = 3,
    frozen = 4,
    invalid = 5,
    errored = 6,
};

// ── Config session ───────────────────────────────────────────────────────

const Session = struct {
    state: ConfigState,
    source: ConfigSource,
    policy: SecurityPolicy,
    override_level: OverrideLevel,
    last_error: u8, // 255 = no error
    active: bool,
};

const MAX_SESSIONS: usize = 64;
var sessions: [MAX_SESSIONS]Session = [_]Session{.{
    .state = .uninitialised,
    .source = .default,
    .policy = .require_tls,
    .override_level = .default,
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

/// ABI version — must match ConfigABI.Foreign.abiVersion (currently 1).
pub export fn config_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new config session in Uninitialised state.
/// source: ConfigSource tag (0-4).
/// Returns slot index (0-63) or -1 if no slots available or invalid source.
pub export fn config_create(source: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (source > 4) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .uninitialised,
                .source = @enumFromInt(source),
                .policy = .require_tls, // secure default
                .override_level = .default,
                .last_error = 255,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a config session, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn config_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current ConfigState tag for a slot.
/// Returns Uninitialised (0) for invalid/inactive slots.
pub export fn config_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Get the ConfigSource tag for a slot.
/// Returns Default (3) for invalid/inactive slots.
pub export fn config_source(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3;
    return @intFromEnum(sessions[idx].source);
}

/// Get the SecurityPolicy tag for a slot.
/// Returns RequireTLS (0) for invalid/inactive slots.
pub export fn config_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].policy);
}

/// Get the OverrideLevel tag for a slot.
/// Returns Default (0) for invalid/inactive slots.
pub export fn config_override_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].override_level);
}

/// Get the last ConfigError tag, or 255 if no error.
pub export fn config_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_error;
}

// ── Transitions (matching Transitions.idr ValidConfigTransition) ────────

/// Load: Uninitialised -> Loading.
/// Returns 0=ok, 1=rejected.
pub export fn config_load(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .uninitialised) {
        sessions[idx].state = .loading;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Validate: Loading -> Validating.
/// Returns 0=ok, 1=rejected.
pub export fn config_validate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .loading) {
        sessions[idx].state = .validating;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Accept: Validating -> Active.
/// Returns 0=ok, 1=rejected.
pub export fn config_accept(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .validating) {
        sessions[idx].state = .active;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Reject: Validating -> Invalid with error tag.
/// Returns 0=ok, 1=rejected.
pub export fn config_reject(slot: c_int, err_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .validating) {
        sessions[idx].state = .invalid;
        sessions[idx].last_error = err_tag;
        return 0;
    }
    return 1;
}

/// Reload: Active -> Loading (hot-reload).
/// Returns 0=ok, 1=rejected.
pub export fn config_reload(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .active) {
        sessions[idx].state = .loading;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Lock: Active -> Frozen (read-only).
/// Returns 0=ok, 1=rejected.
pub export fn config_lock(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .active) {
        sessions[idx].state = .frozen;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Unlock: Frozen -> Active.
/// Returns 0=ok, 1=rejected.
pub export fn config_unlock(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .frozen) {
        sessions[idx].state = .active;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Reset: Invalid|Errored -> Uninitialised.
/// Returns 0=ok, 1=rejected.
pub export fn config_reset(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .invalid or sessions[idx].state == .errored) {
        sessions[idx].state = .uninitialised;
        sessions[idx].last_error = 255;
        return 0;
    }
    return 1;
}

/// Error: Loading|Validating|Active -> Errored with error tag.
/// Returns 0=ok, 1=rejected.
pub export fn config_error(slot: c_int, err_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const st = sessions[idx].state;
    if (st == .loading or st == .validating or st == .active) {
        sessions[idx].state = .errored;
        sessions[idx].last_error = err_tag;
        return 0;
    }
    return 1;
}

// ── Setters (Active state only) ─────────────────────────────────────────

/// Set security policy. Only allowed in Active state.
/// Prevents security downgrade: cannot set a permissive policy if current
/// policy is restrictive (unless override level is Emergency).
/// Returns 0=ok, 1=rejected.
pub export fn config_set_policy(slot: c_int, policy_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (policy_tag > 4) return 1;
    const new_policy: SecurityPolicy = @enumFromInt(policy_tag);
    // Downgrade prevention: restrictive -> permissive blocked unless Emergency
    const cur_restrictive = isRestrictiveInternal(sessions[idx].policy);
    const new_permissive = !isRestrictiveInternal(new_policy);
    if (cur_restrictive and new_permissive and sessions[idx].override_level != .emergency) {
        sessions[idx].last_error = @intFromEnum(ConfigError.security_downgrade);
        return 1;
    }
    sessions[idx].policy = new_policy;
    sessions[idx].last_error = 255;
    return 0;
}

/// Set override level. Only allowed in Active state.
/// Returns 0=ok, 1=rejected.
pub export fn config_set_override(slot: c_int, level_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .active) return 1;
    if (level_tag > 3) return 1;
    sessions[idx].override_level = @enumFromInt(level_tag);
    sessions[idx].last_error = 255;
    return 0;
}

// ── Internal helpers ────────────────────────────────────────────────────

fn isRestrictiveInternal(policy: SecurityPolicy) bool {
    return switch (policy) {
        .require_tls, .require_auth, .require_encryption => true,
        .allow_plaintext, .allow_anonymous => false,
    };
}

fn overridePrecedenceInternal(level: OverrideLevel) u8 {
    return switch (level) {
        .default => 0,
        .user => 1,
        .admin => 2,
        .emergency => 3,
    };
}

// ── Stateless queries ───────────────────────────────────────────────────

/// Check whether a config state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateConfigTransition exactly.
pub export fn config_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Uninitialised -> Loading
    if (from == 0 and to == 1) return 1;
    // Loading -> Validating
    if (from == 1 and to == 2) return 1;
    // Validating -> Active
    if (from == 2 and to == 3) return 1;
    // Validating -> Invalid
    if (from == 2 and to == 5) return 1;
    // Active -> Loading (reload)
    if (from == 3 and to == 1) return 1;
    // Active -> Frozen (lock)
    if (from == 3 and to == 4) return 1;
    // Frozen -> Active (unlock)
    if (from == 4 and to == 3) return 1;
    // Invalid -> Uninitialised (reset)
    if (from == 5 and to == 0) return 1;
    // Loading -> Errored
    if (from == 1 and to == 6) return 1;
    // Validating -> Errored
    if (from == 2 and to == 6) return 1;
    // Active -> Errored
    if (from == 3 and to == 6) return 1;
    // Errored -> Uninitialised (reset)
    if (from == 6 and to == 0) return 1;
    return 0;
}

/// Check whether a security policy is restrictive.
/// Returns 1 if restrictive, 0 if permissive, 0 for invalid tags.
pub export fn config_is_restrictive(policy_tag: u8) callconv(.c) u8 {
    return switch (policy_tag) {
        0, 1, 2 => 1, // require_tls, require_auth, require_encryption
        3, 4 => 0,     // allow_plaintext, allow_anonymous
        else => 0,
    };
}

/// Check whether override level a dominates override level b.
/// Returns 1 if a > b, 0 otherwise. Invalid tags return 0.
pub export fn config_override_dominates(a: u8, b: u8) callconv(.c) u8 {
    if (a > 3 or b > 3) return 0;
    const pa = overridePrecedenceInternal(@enumFromInt(a));
    const pb = overridePrecedenceInternal(@enumFromInt(b));
    return if (pa > pb) 1 else 0;
}
