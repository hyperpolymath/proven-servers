// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// zerotrust_test.zig -- Integration tests for proven-zerotrust FFI.

const std = @import("std");
const zt = @import("zerotrust");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), zt.zt_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PolicyType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.PolicyType.always_verify));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.PolicyType.never_trust));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.PolicyType.least_privilege));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.PolicyType.micro_segmentation));
}

test "IdentityConfidence encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.IdentityConfidence.unverified));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.IdentityConfidence.basic_auth));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.IdentityConfidence.mfa_verified));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.IdentityConfidence.strong_auth));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.IdentityConfidence.continuous_auth));
}

test "DeviceTrustScore encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.DeviceTrustScore.device_unknown));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.DeviceTrustScore.device_partial));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.DeviceTrustScore.device_compliant));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.DeviceTrustScore.device_managed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.DeviceTrustScore.device_hardened));
}

test "AccessDecision encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.AccessDecision.allow));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.AccessDecision.deny));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.AccessDecision.challenge));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.AccessDecision.step_up));
}

test "ContextSignalKind encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.ContextSignalKind.location));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.ContextSignalKind.time));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.ContextSignalKind.device));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.ContextSignalKind.behavior));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.ContextSignalKind.network));
}

test "AuthFactor encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.AuthFactor.certificate));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.AuthFactor.token));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.AuthFactor.biometric));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.AuthFactor.fido2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.AuthFactor.totp));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(zt.AuthFactor.push));
}

test "TrustLevel encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.TrustLevel.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.TrustLevel.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.TrustLevel.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.TrustLevel.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.TrustLevel.full));
}

test "PolicyDecision encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.PolicyDecision.allow));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.PolicyDecision.deny));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.PolicyDecision.challenge));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.PolicyDecision.step_up));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.PolicyDecision.quarantine));
}

test "SessionState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.SessionState.unauthenticated));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.SessionState.partial_auth));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.SessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.SessionState.elevated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.SessionState.locked));
}

test "EvaluationPhase encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zt.EvaluationPhase.request_received));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zt.EvaluationPhase.identity_verified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zt.EvaluationPhase.device_checked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zt.EvaluationPhase.policy_evaluated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zt.EvaluationPhase.access_granted));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(zt.EvaluationPhase.access_denied));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = zt.zt_create(0); // AlwaysVerify
    try std.testing.expect(slot >= 0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), zt.zt_phase(slot)); // RequestReceived
    try std.testing.expectEqual(@as(u8, 0), zt.zt_policy(slot)); // AlwaysVerify
}

test "create rejects invalid policy type" {
    try std.testing.expectEqual(@as(c_int, -1), zt.zt_create(99));
}

test "destroy is safe with invalid slot" {
    zt.zt_destroy(-1);
    zt.zt_destroy(999);
}

// =========================================================================
// Full evaluation pipeline: happy path to AccessGranted
// =========================================================================

test "full pipeline: RequestReceived -> IdentityVerified -> DeviceChecked -> PolicyEvaluated -> AccessGranted" {
    const slot = zt.zt_create(2); // LeastPrivilege
    defer zt.zt_destroy(slot);

    // Add signals for good trust score before evaluation
    _ = zt.zt_add_signal(slot, 0, 800); // Location: 800
    _ = zt.zt_add_signal(slot, 1, 900); // Time: 900
    _ = zt.zt_add_signal(slot, 2, 700); // Device: 700

    // Verify identity with MFA
    try std.testing.expectEqual(@as(u8, 0), zt.zt_verify_identity(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_phase(slot)); // IdentityVerified
    try std.testing.expectEqual(@as(u8, 2), zt.zt_identity_confidence(slot)); // MFAVerified

    // Check device as Managed
    try std.testing.expectEqual(@as(u8, 0), zt.zt_check_device(slot, 3));
    try std.testing.expectEqual(@as(u8, 2), zt.zt_phase(slot)); // DeviceChecked
    try std.testing.expectEqual(@as(u8, 3), zt.zt_device_trust(slot)); // DeviceManaged

    // Evaluate policy
    try std.testing.expectEqual(@as(u8, 0), zt.zt_evaluate_policy(slot));
    try std.testing.expectEqual(@as(u8, 3), zt.zt_phase(slot)); // PolicyEvaluated
    try std.testing.expectEqual(@as(u8, 0), zt.zt_access_decision(slot)); // Allow

    // Grant access
    try std.testing.expectEqual(@as(u8, 0), zt.zt_grant_access(slot));
    try std.testing.expectEqual(@as(u8, 4), zt.zt_phase(slot)); // AccessGranted
}

// =========================================================================
// Early denial paths
// =========================================================================

test "early denial: identity verification fails (Unverified)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), zt.zt_verify_identity(slot, 0)); // Unverified
    try std.testing.expectEqual(@as(u8, 5), zt.zt_phase(slot)); // AccessDenied
}

test "early denial: device check fails (DeviceUnknown)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_verify_identity(slot, 2); // MFA
    try std.testing.expectEqual(@as(u8, 0), zt.zt_check_device(slot, 0)); // DeviceUnknown
    try std.testing.expectEqual(@as(u8, 5), zt.zt_phase(slot)); // AccessDenied
}

test "policy evaluation denies with low trust score" {
    const slot = zt.zt_create(1); // NeverTrust (requires Full)
    defer zt.zt_destroy(slot);

    // No signals added -- trust score will be 0
    _ = zt.zt_verify_identity(slot, 2);
    _ = zt.zt_check_device(slot, 2);
    _ = zt.zt_evaluate_policy(slot);

    try std.testing.expectEqual(@as(u8, 1), zt.zt_access_decision(slot)); // Deny
    _ = zt.zt_grant_access(slot);
    try std.testing.expectEqual(@as(u8, 5), zt.zt_phase(slot)); // AccessDenied
}

// =========================================================================
// Signal management
// =========================================================================

test "add and query signals" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    try std.testing.expectEqual(@as(u32, 0), zt.zt_signal_count(slot));

    // Add Location signal
    try std.testing.expectEqual(@as(u8, 0), zt.zt_add_signal(slot, 0, 500));
    try std.testing.expectEqual(@as(u32, 1), zt.zt_signal_count(slot));
    try std.testing.expectEqual(@as(u16, 500), zt.zt_signal_value(slot, 0));

    // Add Time signal
    try std.testing.expectEqual(@as(u8, 0), zt.zt_add_signal(slot, 1, 750));
    try std.testing.expectEqual(@as(u32, 2), zt.zt_signal_count(slot));
    try std.testing.expectEqual(@as(u16, 750), zt.zt_signal_value(slot, 1));

    // Unset signal returns 0
    try std.testing.expectEqual(@as(u16, 0), zt.zt_signal_value(slot, 3));
}

test "add_signal rejects invalid kind" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_add_signal(slot, 99, 500));
}

test "add_signal rejects value > 1000" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_add_signal(slot, 0, 1001));
}

test "add_signal rejects on terminal phase" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_verify_identity(slot, 0); // -> AccessDenied
    try std.testing.expectEqual(@as(u8, 1), zt.zt_add_signal(slot, 0, 500)); // rejected
}

// =========================================================================
// Trust score and trust level
// =========================================================================

test "trust_score computes weighted average" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_add_signal(slot, 0, 300); // Location
    _ = zt.zt_add_signal(slot, 1, 600); // Time
    // Average = (300 + 600) / 2 = 450
    try std.testing.expectEqual(@as(u16, 450), zt.zt_trust_score(slot));
}

test "trust_score returns 0 with no signals" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u16, 0), zt.zt_trust_score(slot));
}

test "trust_level maps score ranges correctly" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    // 0 -> None
    try std.testing.expectEqual(@as(u8, 0), zt.zt_trust_level(slot));

    // < 250 -> Low
    _ = zt.zt_add_signal(slot, 0, 100);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_trust_level(slot));

    // >= 250 < 500 -> Medium
    _ = zt.zt_add_signal(slot, 0, 400);
    try std.testing.expectEqual(@as(u8, 2), zt.zt_trust_level(slot));

    // >= 500 < 750 -> High
    _ = zt.zt_add_signal(slot, 0, 600);
    try std.testing.expectEqual(@as(u8, 3), zt.zt_trust_level(slot));

    // >= 750 -> Full
    _ = zt.zt_add_signal(slot, 0, 900);
    try std.testing.expectEqual(@as(u8, 4), zt.zt_trust_level(slot));
}

// =========================================================================
// Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "cannot skip to DeviceChecked (RequestReceived -> DeviceChecked)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_check_device(slot, 2)); // RequestReceived
}

test "cannot skip to PolicyEvaluated (RequestReceived -> PolicyEvaluated)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_evaluate_policy(slot)); // RequestReceived
}

test "cannot skip to AccessGranted (RequestReceived -> AccessGranted)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_grant_access(slot)); // RequestReceived
}

test "cannot grant from IdentityVerified (must check device first)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_verify_identity(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_grant_access(slot)); // IdentityVerified
}

test "cannot grant from DeviceChecked (must evaluate policy first)" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_verify_identity(slot, 2);
    _ = zt.zt_check_device(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_grant_access(slot)); // DeviceChecked
}

test "verify_identity rejects invalid confidence tag" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_verify_identity(slot, 99));
}

test "check_device rejects invalid trust tag" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);
    _ = zt.zt_verify_identity(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), zt.zt_check_device(slot, 99));
}

// =========================================================================
// Terminal state enforcement
// =========================================================================

test "AccessGranted is terminal: no further transitions" {
    const slot = zt.zt_create(2);
    defer zt.zt_destroy(slot);

    _ = zt.zt_add_signal(slot, 0, 800);
    _ = zt.zt_verify_identity(slot, 3);
    _ = zt.zt_check_device(slot, 3);
    _ = zt.zt_evaluate_policy(slot);
    _ = zt.zt_grant_access(slot);

    // All transitions should be rejected
    try std.testing.expectEqual(@as(u8, 1), zt.zt_verify_identity(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_check_device(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_evaluate_policy(slot));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_grant_access(slot));
}

test "AccessDenied is terminal: no further transitions" {
    const slot = zt.zt_create(0);
    defer zt.zt_destroy(slot);

    _ = zt.zt_verify_identity(slot, 0); // -> AccessDenied

    try std.testing.expectEqual(@as(u8, 1), zt.zt_verify_identity(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_check_device(slot, 2));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_evaluate_policy(slot));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_grant_access(slot));
}

// =========================================================================
// Stateless evaluation transition table
// =========================================================================

test "zt_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(0, 1)); // Request -> Identity
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(1, 2)); // Identity -> Device
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(2, 3)); // Device -> Policy
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(3, 4)); // Policy -> Granted
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(3, 5)); // Policy -> Denied
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(0, 5)); // Request -> Denied (early)
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(1, 5)); // Identity -> Denied (early)
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_transition(2, 5)); // Device -> Denied (early)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(0, 2)); // skip identity
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(0, 3)); // skip to policy
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(0, 4)); // skip to granted
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(1, 3)); // skip device
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(1, 4)); // skip to granted
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(2, 4)); // skip policy
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(4, 0)); // Granted terminal
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(5, 0)); // Denied terminal
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(4, 5)); // Granted -> Denied
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_transition(5, 4)); // Denied -> Granted
}

// =========================================================================
// Stateless capability queries
// =========================================================================

test "zt_can_deny matches Transitions.idr CanDeny" {
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_deny(0)); // RequestReceived
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_deny(1)); // IdentityVerified
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_deny(2)); // DeviceChecked
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_deny(3)); // PolicyEvaluated
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_deny(4)); // AccessGranted (terminal)
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_deny(5)); // AccessDenied (terminal)
}

test "zt_can_grant matches Transitions.idr CanGrant" {
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_grant(0)); // RequestReceived
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_grant(1)); // IdentityVerified
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_grant(2)); // DeviceChecked
    try std.testing.expectEqual(@as(u8, 1), zt.zt_can_grant(3)); // PolicyEvaluated (only one)
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_grant(4)); // AccessGranted
    try std.testing.expectEqual(@as(u8, 0), zt.zt_can_grant(5)); // AccessDenied
}

test "zt_is_terminal matches terminal phases" {
    try std.testing.expectEqual(@as(u8, 0), zt.zt_is_terminal(0));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_is_terminal(1));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_is_terminal(2));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_is_terminal(3));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_is_terminal(4)); // AccessGranted
    try std.testing.expectEqual(@as(u8, 1), zt.zt_is_terminal(5)); // AccessDenied
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 5), zt.zt_phase(-1)); // AccessDenied fallback
    try std.testing.expectEqual(@as(u8, 255), zt.zt_policy(-1));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_identity_confidence(-1));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_device_trust(-1));
    try std.testing.expectEqual(@as(u8, 1), zt.zt_access_decision(-1)); // Deny fallback
    try std.testing.expectEqual(@as(u32, 0), zt.zt_signal_count(-1));
    try std.testing.expectEqual(@as(u16, 0), zt.zt_signal_value(-1, 0));
    try std.testing.expectEqual(@as(u16, 0), zt.zt_trust_score(-1));
    try std.testing.expectEqual(@as(u8, 0), zt.zt_trust_level(-1));
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    for (&slots) |*s| {
        s.* = zt.zt_create(0);
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| zt.zt_destroy(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), zt.zt_create(0));
}
