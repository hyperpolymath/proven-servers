// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// config_test.zig — Integration tests for proven-config FFI.

const std = @import("std");
const config = @import("config");

// ═══════════════════════════════════════════════════════════════════════
// ABI version
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), config.config_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams
// ═══════════════════════════════════════════════════════════════════════

test "ConfigSource encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.ConfigSource.file));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.ConfigSource.environment));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.ConfigSource.command_line));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.ConfigSource.default));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(config.ConfigSource.remote));
}

test "ValidationResult encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.ValidationResult.valid));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.ValidationResult.invalid_value));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.ValidationResult.missing_required));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.ValidationResult.security_violation));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(config.ValidationResult.type_mismatch));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(config.ValidationResult.out_of_range));
}

test "SecurityPolicy encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.SecurityPolicy.require_tls));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.SecurityPolicy.require_auth));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.SecurityPolicy.require_encryption));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.SecurityPolicy.allow_plaintext));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(config.SecurityPolicy.allow_anonymous));
}

test "OverrideLevel encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.OverrideLevel.default));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.OverrideLevel.user));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.OverrideLevel.admin));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.OverrideLevel.emergency));
}

test "ConfigError encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.ConfigError.parse_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.ConfigError.schema_violation));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.ConfigError.security_downgrade));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.ConfigError.conflicting_values));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(config.ConfigError.unknown_key));
}

test "ConfigState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(config.ConfigState.uninitialised));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(config.ConfigState.loading));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(config.ConfigState.validating));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(config.ConfigState.active));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(config.ConfigState.frozen));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(config.ConfigState.invalid));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(config.ConfigState.errored));
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = config.config_create(0); // file source
    try std.testing.expect(slot >= 0);
    defer config.config_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), config.config_state(slot)); // uninitialised
}

test "create with each source type" {
    var slots: [5]c_int = undefined;
    for (0..5) |i| {
        slots[i] = config.config_create(@intCast(i));
        try std.testing.expect(slots[i] >= 0);
        try std.testing.expectEqual(@as(u8, @intCast(i)), config.config_source(slots[i]));
    }
    for (&slots) |s| config.config_destroy(s);
}

test "create rejects invalid source" {
    try std.testing.expectEqual(@as(c_int, -1), config.config_create(99));
}

test "destroy is safe with invalid slot" {
    config.config_destroy(-1);
    config.config_destroy(999);
}

// ═══════════════════════════════════════════════════════════════════════
// Full happy path: Uninit -> Loading -> Validating -> Active
// ═══════════════════════════════════════════════════════════════════════

test "full lifecycle: load -> validate -> accept" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    // Uninitialised -> Loading
    try std.testing.expectEqual(@as(u8, 0), config.config_load(slot));
    try std.testing.expectEqual(@as(u8, 1), config.config_state(slot));

    // Loading -> Validating
    try std.testing.expectEqual(@as(u8, 0), config.config_validate(slot));
    try std.testing.expectEqual(@as(u8, 2), config.config_state(slot));

    // Validating -> Active
    try std.testing.expectEqual(@as(u8, 0), config.config_accept(slot));
    try std.testing.expectEqual(@as(u8, 3), config.config_state(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Rejection path: Validating -> Invalid -> Reset -> Uninit
// ═══════════════════════════════════════════════════════════════════════

test "reject and reset path" {
    const slot = config.config_create(1);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);

    // Validating -> Invalid with schema_violation
    try std.testing.expectEqual(@as(u8, 0), config.config_reject(slot, 1));
    try std.testing.expectEqual(@as(u8, 5), config.config_state(slot)); // invalid
    try std.testing.expectEqual(@as(u8, 1), config.config_last_error(slot)); // schema_violation

    // Invalid -> Uninitialised
    try std.testing.expectEqual(@as(u8, 0), config.config_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), config.config_state(slot)); // uninitialised
}

// ═══════════════════════════════════════════════════════════════════════
// Hot-reload: Active -> Loading -> Validating -> Active
// ═══════════════════════════════════════════════════════════════════════

test "hot-reload: active -> loading -> validating -> active" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    // Active -> Loading (reload)
    try std.testing.expectEqual(@as(u8, 0), config.config_reload(slot));
    try std.testing.expectEqual(@as(u8, 1), config.config_state(slot)); // loading

    // Loading -> Validating -> Active again
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);
    try std.testing.expectEqual(@as(u8, 3), config.config_state(slot)); // active
}

// ═══════════════════════════════════════════════════════════════════════
// Lock/Unlock: Active -> Frozen -> Active
// ═══════════════════════════════════════════════════════════════════════

test "lock and unlock" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    // Active -> Frozen
    try std.testing.expectEqual(@as(u8, 0), config.config_lock(slot));
    try std.testing.expectEqual(@as(u8, 4), config.config_state(slot)); // frozen

    // Frozen -> Active
    try std.testing.expectEqual(@as(u8, 0), config.config_unlock(slot));
    try std.testing.expectEqual(@as(u8, 3), config.config_state(slot)); // active
}

// ═══════════════════════════════════════════════════════════════════════
// Error transitions
// ═══════════════════════════════════════════════════════════════════════

test "error from loading" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);

    // Loading -> Errored
    try std.testing.expectEqual(@as(u8, 0), config.config_error(slot, 0)); // parse_error
    try std.testing.expectEqual(@as(u8, 6), config.config_state(slot)); // errored
    try std.testing.expectEqual(@as(u8, 0), config.config_last_error(slot)); // parse_error

    // Errored -> Uninitialised
    try std.testing.expectEqual(@as(u8, 0), config.config_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), config.config_state(slot));
}

test "error from validating" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);

    try std.testing.expectEqual(@as(u8, 0), config.config_error(slot, 1)); // schema_violation
    try std.testing.expectEqual(@as(u8, 6), config.config_state(slot)); // errored
}

test "error from active" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    try std.testing.expectEqual(@as(u8, 0), config.config_error(slot, 3)); // conflicting_values
    try std.testing.expectEqual(@as(u8, 6), config.config_state(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid transitions (impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "cannot skip validation: loading cannot go to active" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    try std.testing.expectEqual(@as(u8, 1), config.config_accept(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 1), config.config_state(slot)); // still loading
}

test "cannot reload from frozen: must unlock first" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);
    _ = config.config_lock(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_reload(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 4), config.config_state(slot)); // still frozen
}

test "cannot lock uninitialised config" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_lock(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 0), config.config_state(slot)); // still uninitialised
}

test "cannot reset from active — must error or go through invalid" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_reset(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 3), config.config_state(slot)); // still active
}

test "invalid cannot activate directly" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_reject(slot, 0);

    try std.testing.expectEqual(@as(u8, 1), config.config_accept(slot)); // rejected
    try std.testing.expectEqual(@as(u8, 5), config.config_state(slot)); // still invalid
}

// ═══════════════════════════════════════════════════════════════════════
// Security policy management
// ═══════════════════════════════════════════════════════════════════════

test "set policy in active state" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    // Default is require_tls (0); change to require_auth (1) — both restrictive, ok
    try std.testing.expectEqual(@as(u8, 0), config.config_set_policy(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), config.config_policy(slot));
}

test "cannot set policy when not active" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    // Uninitialised state
    try std.testing.expectEqual(@as(u8, 1), config.config_set_policy(slot, 1)); // rejected
}

test "security downgrade prevention" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    // Default policy is require_tls (restrictive). Try to set allow_plaintext (permissive).
    try std.testing.expectEqual(@as(u8, 1), config.config_set_policy(slot, 3)); // rejected
    try std.testing.expectEqual(@as(u8, 2), config.config_last_error(slot)); // security_downgrade
    try std.testing.expectEqual(@as(u8, 0), config.config_policy(slot)); // still require_tls
}

test "emergency override bypasses downgrade prevention" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    // Elevate to emergency override
    try std.testing.expectEqual(@as(u8, 0), config.config_set_override(slot, 3)); // emergency
    try std.testing.expectEqual(@as(u8, 3), config.config_override_level(slot));

    // Now downgrade is allowed
    try std.testing.expectEqual(@as(u8, 0), config.config_set_policy(slot, 3)); // allow_plaintext
    try std.testing.expectEqual(@as(u8, 3), config.config_policy(slot));
}

test "set override level" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    try std.testing.expectEqual(@as(u8, 0), config.config_override_level(slot)); // default
    try std.testing.expectEqual(@as(u8, 0), config.config_set_override(slot, 2)); // admin
    try std.testing.expectEqual(@as(u8, 2), config.config_override_level(slot)); // admin
}

test "cannot set override when not active" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_set_override(slot, 1)); // rejected
}

test "reject invalid policy tag" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_set_policy(slot, 99)); // rejected
}

test "reject invalid override tag" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_set_override(slot, 99)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless queries
// ═══════════════════════════════════════════════════════════════════════

test "config_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(0, 1)); // Uninit -> Loading
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(1, 2)); // Loading -> Validating
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(2, 3)); // Validating -> Active
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(2, 5)); // Validating -> Invalid
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(3, 1)); // Active -> Loading
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(3, 4)); // Active -> Frozen
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(4, 3)); // Frozen -> Active
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(5, 0)); // Invalid -> Uninit
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(1, 6)); // Loading -> Errored
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(2, 6)); // Validating -> Errored
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(3, 6)); // Active -> Errored
    try std.testing.expectEqual(@as(u8, 1), config.config_can_transition(6, 0)); // Errored -> Uninit

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), config.config_can_transition(0, 3)); // Uninit -/-> Active
    try std.testing.expectEqual(@as(u8, 0), config.config_can_transition(4, 1)); // Frozen -/-> Loading
    try std.testing.expectEqual(@as(u8, 0), config.config_can_transition(1, 3)); // Loading -/-> Active
    try std.testing.expectEqual(@as(u8, 0), config.config_can_transition(5, 3)); // Invalid -/-> Active
    try std.testing.expectEqual(@as(u8, 0), config.config_can_transition(0, 4)); // Uninit -/-> Frozen
}

test "config_is_restrictive matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 1), config.config_is_restrictive(0)); // require_tls
    try std.testing.expectEqual(@as(u8, 1), config.config_is_restrictive(1)); // require_auth
    try std.testing.expectEqual(@as(u8, 1), config.config_is_restrictive(2)); // require_encryption
    try std.testing.expectEqual(@as(u8, 0), config.config_is_restrictive(3)); // allow_plaintext
    try std.testing.expectEqual(@as(u8, 0), config.config_is_restrictive(4)); // allow_anonymous
    try std.testing.expectEqual(@as(u8, 0), config.config_is_restrictive(99)); // invalid
}

test "config_override_dominates matches Layout.idr" {
    // Emergency > Admin > User > Default
    try std.testing.expectEqual(@as(u8, 1), config.config_override_dominates(3, 0)); // emergency > default
    try std.testing.expectEqual(@as(u8, 1), config.config_override_dominates(2, 1)); // admin > user
    try std.testing.expectEqual(@as(u8, 1), config.config_override_dominates(1, 0)); // user > default
    try std.testing.expectEqual(@as(u8, 0), config.config_override_dominates(0, 3)); // default < emergency
    try std.testing.expectEqual(@as(u8, 0), config.config_override_dominates(1, 1)); // user == user
    try std.testing.expectEqual(@as(u8, 0), config.config_override_dominates(99, 0)); // invalid
}

// ═══════════════════════════════════════════════════════════════════════
// Slot exhaustion
// ═══════════════════════════════════════════════════════════════════════

test "slot exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    for (&slots, 0..) |*s, i| {
        s.* = config.config_create(0);
        // Allow some tests above to have consumed slots; just verify we get
        // valid ones while available.
        if (s.* < 0) {
            // Already exhausted earlier than expected — clean up what we have
            for (slots[0..i]) |prev| config.config_destroy(prev);
            return;
        }
    }
    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), config.config_create(0));
    for (&slots) |s| config.config_destroy(s);
}

// ═══════════════════════════════════════════════════════════════════════
// Error in frozen state is rejected
// ═══════════════════════════════════════════════════════════════════════

test "cannot error from frozen state" {
    const slot = config.config_create(0);
    defer config.config_destroy(slot);

    _ = config.config_load(slot);
    _ = config.config_validate(slot);
    _ = config.config_accept(slot);
    _ = config.config_lock(slot);

    try std.testing.expectEqual(@as(u8, 1), config.config_error(slot, 0)); // rejected
    try std.testing.expectEqual(@as(u8, 4), config.config_state(slot)); // still frozen
}
