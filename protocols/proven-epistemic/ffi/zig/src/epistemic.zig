// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// epistemic.zig -- Zig FFI engine for proven-epistemic.
//
// Governs tiered disclosure between two parties (Denning-style information
// flow). A pool of sessions each runs the SessionPhase state machine; the
// effective tier is the lattice meet of the two parties' grants (chain
// Band < Relational < Full, so meet = minimum); every disclosure is gated by
// `minTier <= effective tier`, and a well-governed Sensitive field demands
// Full. This mirrors the proven Idris core (Epistemic.Lattice / .Transitions)
// exactly; enum values cross the C ABI as u8 tags matching EpistemicABI.Types.

const std = @import("std");

// =========================================================================
// Enums (tags must match EpistemicABI.Types.idr)
// =========================================================================

pub const Tier = enum(u8) { band = 0, relational = 1, full = 2 };
pub const Revealingness = enum(u8) { innocuous = 0, contextual = 1, sensitive = 2 };
pub const Purpose = enum(u8) { identification = 0, eligibility = 1, compatibility = 2, contractual = 3, audit = 4 };
pub const SessionPhase = enum(u8) { initiated = 0, tiers_agreed = 1, disclosing = 2, closed = 3 };

// epistemic_disclose result: 0 = disclosed, else DisclosureError tag + 1.
const DiscloseResult = struct {
    const disclosed: u8 = 0;
    const tier_exceeded: u8 = 1; // DisclosureError.TierExceeded (0) + 1
    const no_active_session: u8 = 3; // NoActiveSession (2) + 1
    const session_closed: u8 = 4; // SessionAlreadyClosed (3) + 1
    const ill_governed: u8 = 5; // IllGoverned (4) + 1
};

// =========================================================================
// Lattice (mirrors Epistemic.Lattice)
// =========================================================================

/// Meet of two tier grants = the effective tier. Chain order, so minimum.
pub export fn epistemic_meet(a: u8, b: u8) callconv(.c) u8 {
    if (a > 2 or b > 2) return @intFromEnum(Tier.band); // defensive: deny by default
    return if (a < b) a else b;
}

/// 1 iff a governance entry is well-formed: Sensitive revealingness implies a
/// Full minimum tier (mirrors Epistemic.Transitions.WellGoverned).
pub export fn epistemic_well_governed(revealingness: u8, min_tier: u8) callconv(.c) u8 {
    if (revealingness > 2 or min_tier > 2) return 0;
    if (revealingness == @intFromEnum(Revealingness.sensitive)) {
        return if (min_tier == @intFromEnum(Tier.full)) 1 else 0;
    }
    return 1;
}

// =========================================================================
// Session pool
// =========================================================================

const MAX_SESSIONS: usize = 64;

const Session = struct {
    active: bool,
    phase: SessionPhase,
    eff_tier: Tier,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{.{ .active = false, .phase = .initiated, .eff_tier = .band }} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

/// ABI version. Must match EpistemicABI.Foreign.abiVersion.
pub export fn epistemic_abi_version() callconv(.c) u32 {
    return 1;
}

/// Open a disclosure session in the Initiated phase. Returns slot or -1.
pub export fn epistemic_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.active = true;
            s.phase = .initiated;
            s.eff_tier = .band; // deny-by-default until tiers agreed
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn epistemic_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = .{ .active = false, .phase = .initiated, .eff_tier = .band };
}

pub export fn epistemic_phase(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(SessionPhase.initiated);
    return @intFromEnum(sessions[idx].phase);
}

pub export fn epistemic_effective_tier(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(Tier.band);
    return @intFromEnum(sessions[idx].eff_tier);
}

/// Stateless transition table (mirrors Epistemic.Transitions.ValidSessionTransition).
pub export fn epistemic_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Initiated -> TiersAgreed
    if (from == 1 and to == 2) return 1; // TiersAgreed -> Disclosing
    if (from == 0 and to == 3) return 1; // Initiated -> Closed
    if (from == 1 and to == 3) return 1; // TiersAgreed -> Closed
    if (from == 2 and to == 3) return 1; // Disclosing -> Closed
    return 0;
}

/// Initiated -> TiersAgreed; stores the effective tier = meet(granted, theirs).
/// Returns 0 on success, 1 if rejected (bad tier or wrong phase).
pub export fn epistemic_agree_tiers(slot: c_int, granted: u8, theirs: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (granted > 2 or theirs > 2) return 1;
    if (sessions[idx].phase != .initiated) return 1;
    sessions[idx].eff_tier = @enumFromInt(epistemic_meet(granted, theirs));
    sessions[idx].phase = .tiers_agreed;
    return 0;
}

/// TiersAgreed -> Disclosing (opens the gate). Returns 0 on success, 1 if rejected.
pub export fn epistemic_begin_disclosure(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].phase != .tiers_agreed) return 1;
    sessions[idx].phase = .disclosing;
    return 0;
}

/// Close the session. Legal from any non-closed phase. Returns 0 / 1.
pub export fn epistemic_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].phase == .closed) return 1;
    sessions[idx].phase = .closed;
    return 0;
}

/// Gated disclosure of a field with the given minimum tier and revealingness.
/// 0 = disclosed; otherwise a DisclosureError tag + 1 (see Foreign.idr).
/// An over-tier or ill-governed disclosure is refused — never performed.
pub export fn epistemic_disclose(slot: c_int, min_tier: u8, revealingness: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return DiscloseResult.no_active_session;
    const s = &sessions[idx];
    if (s.phase == .closed) return DiscloseResult.session_closed;
    if (s.phase != .disclosing) return DiscloseResult.no_active_session;
    if (min_tier > 2 or revealingness > 2) return DiscloseResult.ill_governed;
    // Well-governedness: a Sensitive field must be governed at Full.
    if (epistemic_well_governed(revealingness, min_tier) == 0) return DiscloseResult.ill_governed;
    // Gate: minTier <= effective tier (chain order).
    if (min_tier <= @intFromEnum(s.eff_tier)) return DiscloseResult.disclosed;
    return DiscloseResult.tier_exceeded;
}
