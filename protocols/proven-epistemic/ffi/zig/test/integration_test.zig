// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-epistemic FFI.
//
// Covers: ABI version, enum tag parity, the tier lattice meet + well-
// governedness, the session state machine, and gated disclosure (including
// the non-amplification and Sensitive-requires-Full guarantees).

const std = @import("std");
const e = @import("epistemic");

const BAND: u8 = 0;
const RELATIONAL: u8 = 1;
const FULL: u8 = 2;
const INNOCUOUS: u8 = 0;
const SENSITIVE: u8 = 2;

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), e.epistemic_abi_version());
}

test "enum tags match EpistemicABI.Types.idr" {
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(e.Tier.full));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(e.Revealingness.sensitive));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(e.Purpose.audit));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(e.SessionPhase.closed));
}

// =========================================================================
// Lattice
// =========================================================================

test "meet is the chain minimum, with Band absorbing" {
    try std.testing.expectEqual(BAND, e.epistemic_meet(BAND, FULL)); // bandAbsorbs
    try std.testing.expectEqual(BAND, e.epistemic_meet(FULL, BAND));
    try std.testing.expectEqual(RELATIONAL, e.epistemic_meet(FULL, RELATIONAL)); // never above either grant
    try std.testing.expectEqual(FULL, e.epistemic_meet(FULL, FULL)); // idempotent
    try std.testing.expectEqual(RELATIONAL, e.epistemic_meet(RELATIONAL, RELATIONAL));
}

test "meet is symmetric over all pairs (reciprocity)" {
    var a: u8 = 0;
    while (a <= 2) : (a += 1) {
        var b: u8 = 0;
        while (b <= 2) : (b += 1) {
            try std.testing.expectEqual(e.epistemic_meet(a, b), e.epistemic_meet(b, a));
        }
    }
}

test "well-governed: Sensitive requires Full" {
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_well_governed(SENSITIVE, BAND));
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_well_governed(SENSITIVE, RELATIONAL));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_well_governed(SENSITIVE, FULL));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_well_governed(INNOCUOUS, BAND));
}

// =========================================================================
// Session state machine
// =========================================================================

test "session walks Initiated -> TiersAgreed -> Disclosing -> Closed" {
    const slot = e.epistemic_create();
    defer e.epistemic_destroy(slot);
    try std.testing.expect(slot >= 0);
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_phase(slot)); // Initiated

    try std.testing.expectEqual(@as(u8, 0), e.epistemic_agree_tiers(slot, FULL, RELATIONAL));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_phase(slot)); // TiersAgreed
    try std.testing.expectEqual(RELATIONAL, e.epistemic_effective_tier(slot)); // meet(Full,Relational)

    try std.testing.expectEqual(@as(u8, 0), e.epistemic_begin_disclosure(slot));
    try std.testing.expectEqual(@as(u8, 2), e.epistemic_phase(slot)); // Disclosing
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_close(slot));
    try std.testing.expectEqual(@as(u8, 3), e.epistemic_phase(slot)); // Closed
}

test "cannot skip agreement or act after close" {
    const slot = e.epistemic_create();
    defer e.epistemic_destroy(slot);
    // begin_disclosure before tiers agreed is rejected.
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_begin_disclosure(slot));
    _ = e.epistemic_agree_tiers(slot, FULL, FULL);
    _ = e.epistemic_begin_disclosure(slot);
    _ = e.epistemic_close(slot);
    // closed is terminal.
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_close(slot));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_begin_disclosure(slot));
}

test "can_transition mirrors ValidSessionTransition" {
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_can_transition(0, 1));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_can_transition(1, 2));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_can_transition(2, 3));
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_can_transition(0, 2)); // cannot skip agreement
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_can_transition(3, 2)); // closed terminal
}

// =========================================================================
// Gated disclosure (non-amplification)
// =========================================================================

test "disclosure is gated by the effective tier" {
    const slot = e.epistemic_create();
    defer e.epistemic_destroy(slot);
    _ = e.epistemic_agree_tiers(slot, FULL, RELATIONAL); // eff = Relational
    _ = e.epistemic_begin_disclosure(slot);

    // A Band/Relational field discloses; a Full field is refused (TierExceeded=1).
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_disclose(slot, BAND, INNOCUOUS));
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_disclose(slot, RELATIONAL, INNOCUOUS));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_disclose(slot, FULL, INNOCUOUS));
}

test "disclosure refused outside the Disclosing phase" {
    const slot = e.epistemic_create();
    defer e.epistemic_destroy(slot);
    // Initiated -> NoActiveSession (3).
    try std.testing.expectEqual(@as(u8, 3), e.epistemic_disclose(slot, BAND, INNOCUOUS));
    _ = e.epistemic_agree_tiers(slot, FULL, FULL);
    _ = e.epistemic_begin_disclosure(slot);
    _ = e.epistemic_close(slot);
    // Closed -> SessionAlreadyClosed (4).
    try std.testing.expectEqual(@as(u8, 4), e.epistemic_disclose(slot, BAND, INNOCUOUS));
}

test "a Sensitive field at less than Full is ill-governed, never disclosed" {
    const slot = e.epistemic_create();
    defer e.epistemic_destroy(slot);
    _ = e.epistemic_agree_tiers(slot, FULL, FULL); // eff = Full
    _ = e.epistemic_begin_disclosure(slot);
    // Sensitive governed at Relational -> IllGoverned (5), even though eff=Full.
    try std.testing.expectEqual(@as(u8, 5), e.epistemic_disclose(slot, RELATIONAL, SENSITIVE));
    // Sensitive governed at Full, eff=Full -> disclosed.
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_disclose(slot, FULL, SENSITIVE));
}

test "operations are safe on invalid slots" {
    try std.testing.expectEqual(@as(u8, 0), e.epistemic_phase(-1));
    try std.testing.expectEqual(@as(u8, 1), e.epistemic_agree_tiers(-1, 0, 0));
    try std.testing.expectEqual(@as(u8, 3), e.epistemic_disclose(999, 0, 0));
}
