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

// Generated from the proven Idris ABI encoders (EpistemicABI.{Types,Foreign})
// by tools/gen-abi.sh. The comptime guard below pins every enum tag to these,
// so any drift from the proofs is a COMPILE error -- not a runtime surprise.
const gen = @import("epistemic_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// =========================================================================
// Enums (tags pinned to the generated/proven values by the comptime guard)
// =========================================================================

pub const Tier = enum(u8) { band = 0, relational = 1, full = 2 };
pub const Revealingness = enum(u8) { innocuous = 0, contextual = 1, sensitive = 2 };
pub const Purpose = enum(u8) { identification = 0, eligibility = 1, compatibility = 2, contractual = 3, audit = 4 };
pub const SessionPhase = enum(u8) { initiated = 0, tiers_agreed = 1, disclosing = 2, closed = 3 };

/// Raw disclosure errors. Tags match EpistemicABI.Types.errorToTag exactly.
pub const DisclosureError = enum(u8) {
    tier_exceeded = 0,
    unknown_field = 1,
    no_active_session = 2,
    session_already_closed = 3,
    ill_governed = 4,
};

/// Wire result of epistemic_disclose: 0 = disclosed, else raw error tag + 1.
/// UnknownField is absent here -- field lookup is a higher-layer concern.
pub const DiscloseResult = enum(u8) {
    disclosed = 0,
    tier_exceeded = @intFromEnum(DisclosureError.tier_exceeded) + 1, // 1
    no_active_session = @intFromEnum(DisclosureError.no_active_session) + 1, // 3
    session_closed = @intFromEnum(DisclosureError.session_already_closed) + 1, // 4
    ill_governed = @intFromEnum(DisclosureError.ill_governed) + 1, // 5
};

// =========================================================================
// ABI conformance guard -- "type safety through Zig's particularity".
// Every enum tag MUST equal the generated (= proven Idris) value. A mismatch
// fails `zig build` with the named symbol, before any test runs. Regenerate
// the constants with `bash tools/gen-abi.sh` if the proofs intentionally change.
// =========================================================================
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version (regenerate: tools/gen-abi.sh)");

    if (@intFromEnum(Tier.band) != gen.TIER_BAND) @compileError("ABI drift: Tier.band");
    if (@intFromEnum(Tier.relational) != gen.TIER_RELATIONAL) @compileError("ABI drift: Tier.relational");
    if (@intFromEnum(Tier.full) != gen.TIER_FULL) @compileError("ABI drift: Tier.full");

    if (@intFromEnum(Revealingness.innocuous) != gen.REVEAL_INNOCUOUS) @compileError("ABI drift: Revealingness.innocuous");
    if (@intFromEnum(Revealingness.contextual) != gen.REVEAL_CONTEXTUAL) @compileError("ABI drift: Revealingness.contextual");
    if (@intFromEnum(Revealingness.sensitive) != gen.REVEAL_SENSITIVE) @compileError("ABI drift: Revealingness.sensitive");

    if (@intFromEnum(Purpose.identification) != gen.PURPOSE_IDENTIFICATION) @compileError("ABI drift: Purpose.identification");
    if (@intFromEnum(Purpose.eligibility) != gen.PURPOSE_ELIGIBILITY) @compileError("ABI drift: Purpose.eligibility");
    if (@intFromEnum(Purpose.compatibility) != gen.PURPOSE_COMPATIBILITY) @compileError("ABI drift: Purpose.compatibility");
    if (@intFromEnum(Purpose.contractual) != gen.PURPOSE_CONTRACTUAL) @compileError("ABI drift: Purpose.contractual");
    if (@intFromEnum(Purpose.audit) != gen.PURPOSE_AUDIT) @compileError("ABI drift: Purpose.audit");

    if (@intFromEnum(SessionPhase.initiated) != gen.PHASE_INITIATED) @compileError("ABI drift: SessionPhase.initiated");
    if (@intFromEnum(SessionPhase.tiers_agreed) != gen.PHASE_TIERS_AGREED) @compileError("ABI drift: SessionPhase.tiers_agreed");
    if (@intFromEnum(SessionPhase.disclosing) != gen.PHASE_DISCLOSING) @compileError("ABI drift: SessionPhase.disclosing");
    if (@intFromEnum(SessionPhase.closed) != gen.PHASE_CLOSED) @compileError("ABI drift: SessionPhase.closed");

    if (@intFromEnum(DisclosureError.tier_exceeded) != gen.ERR_TIER_EXCEEDED) @compileError("ABI drift: DisclosureError.tier_exceeded");
    if (@intFromEnum(DisclosureError.unknown_field) != gen.ERR_UNKNOWN_FIELD) @compileError("ABI drift: DisclosureError.unknown_field");
    if (@intFromEnum(DisclosureError.no_active_session) != gen.ERR_NO_ACTIVE_SESSION) @compileError("ABI drift: DisclosureError.no_active_session");
    if (@intFromEnum(DisclosureError.session_already_closed) != gen.ERR_SESSION_ALREADY_CLOSED) @compileError("ABI drift: DisclosureError.session_already_closed");
    if (@intFromEnum(DisclosureError.ill_governed) != gen.ERR_ILL_GOVERNED) @compileError("ABI drift: DisclosureError.ill_governed");

    // Offset law: each wire code (except disclosed=0) is the raw error tag + 1.
    if (@intFromEnum(DiscloseResult.tier_exceeded) != @intFromEnum(DisclosureError.tier_exceeded) + 1) @compileError("ABI drift: disclose offset tier_exceeded");
    if (@intFromEnum(DiscloseResult.no_active_session) != @intFromEnum(DisclosureError.no_active_session) + 1) @compileError("ABI drift: disclose offset no_active_session");
    if (@intFromEnum(DiscloseResult.session_closed) != @intFromEnum(DisclosureError.session_already_closed) + 1) @compileError("ABI drift: disclose offset session_closed");
    if (@intFromEnum(DiscloseResult.ill_governed) != @intFromEnum(DisclosureError.ill_governed) + 1) @compileError("ABI drift: disclose offset ill_governed");
}

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

/// ABI version. Must match EpistemicABI.Foreign.abiVersion (guarded above).
pub export fn epistemic_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
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
    const idx = validSlot(slot) orelse return @intFromEnum(DiscloseResult.no_active_session);
    const s = &sessions[idx];
    if (s.phase == .closed) return @intFromEnum(DiscloseResult.session_closed);
    if (s.phase != .disclosing) return @intFromEnum(DiscloseResult.no_active_session);
    if (min_tier > 2 or revealingness > 2) return @intFromEnum(DiscloseResult.ill_governed);
    // Well-governedness: a Sensitive field must be governed at Full.
    if (epistemic_well_governed(revealingness, min_tier) == 0) return @intFromEnum(DiscloseResult.ill_governed);
    // Gate: minTier <= effective tier (chain order).
    if (min_tier <= @intFromEnum(s.eff_tier)) return @intFromEnum(DiscloseResult.disclosed);
    return @intFromEnum(DiscloseResult.tier_exceeded);
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
