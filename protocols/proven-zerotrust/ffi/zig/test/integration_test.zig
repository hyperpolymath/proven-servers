// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-zerotrust FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const zerotrust = @import("zerotrust");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), zerotrust.zt_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PolicyType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.PolicyType.always_verify));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.PolicyType.never_trust));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.PolicyType.least_privilege));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.PolicyType.micro_segmentation));
}

test "IdentityConfidence encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.IdentityConfidence.unverified));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.IdentityConfidence.basic_auth));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.IdentityConfidence.mfa_verified));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.IdentityConfidence.strong_auth));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.IdentityConfidence.continuous_auth));
}

test "DeviceTrustScore encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.DeviceTrustScore.device_unknown));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.DeviceTrustScore.device_partial));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.DeviceTrustScore.device_compliant));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.DeviceTrustScore.device_managed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.DeviceTrustScore.device_hardened));
}

test "AccessDecision encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.AccessDecision.allow));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.AccessDecision.deny));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.AccessDecision.challenge));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.AccessDecision.step_up));
}

test "ContextSignalKind encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.ContextSignalKind.location));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.ContextSignalKind.time));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.ContextSignalKind.device));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.ContextSignalKind.behavior));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.ContextSignalKind.network));
}

test "AuthFactor encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.AuthFactor.certificate));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.AuthFactor.token));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.AuthFactor.biometric));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.AuthFactor.fido2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.AuthFactor.totp));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(zerotrust.AuthFactor.push));
}

test "TrustLevel encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.TrustLevel.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.TrustLevel.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.TrustLevel.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.TrustLevel.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.TrustLevel.full));
}

test "PolicyDecision encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.PolicyDecision.allow));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.PolicyDecision.deny));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.PolicyDecision.challenge));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.PolicyDecision.step_up));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.PolicyDecision.quarantine));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.SessionState.unauthenticated));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.SessionState.partial_auth));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.SessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.SessionState.elevated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.SessionState.locked));
}

test "EvaluationPhase encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(zerotrust.EvaluationPhase.request_received));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(zerotrust.EvaluationPhase.identity_verified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(zerotrust.EvaluationPhase.device_checked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(zerotrust.EvaluationPhase.policy_evaluated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(zerotrust.EvaluationPhase.access_granted));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(zerotrust.EvaluationPhase.access_denied));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = zerotrust.zt_create(0);
    try std.testing.expect(slot >= 0);
    defer zerotrust.zt_destroy(slot);
}

test "destroy is safe with invalid slot" {
    zerotrust.zt_destroy(-1);
    zerotrust.zt_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), zerotrust.zt_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), zerotrust.zt_can_transition(0, 0)); // self-loop
}

