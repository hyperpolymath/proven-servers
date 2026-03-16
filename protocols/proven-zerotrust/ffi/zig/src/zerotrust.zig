// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// zerotrust.zig -- Zig FFI implementation of proven-zerotrust.
//
// Implements verified Zero Trust access evaluation pipeline with:
//   - Slot-based session management (up to 64 concurrent)
//   - Evaluation phase state machine matching Idris2 Transitions.idr
//   - Identity confidence tracking (Unverified -> ContinuousAuth)
//   - Device trust scoring (Unknown -> Hardened)
//   - Context signal aggregation (Location, Time, Device, Behavior, Network)
//   - Trust score computation (weighted average, 0-1000)
//   - Policy engine with configurable policy types
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching ZeroTrustABI.Layout.idr tag assignments) ----------------

/// Policy enforcement strategies (4 constructors, tags 0-3).
pub const PolicyType = enum(u8) {
    always_verify = 0,
    never_trust = 1,
    least_privilege = 2,
    micro_segmentation = 3,
};

/// Identity confidence levels (5 constructors, tags 0-4).
pub const IdentityConfidence = enum(u8) {
    unverified = 0,
    basic_auth = 1,
    mfa_verified = 2,
    strong_auth = 3,
    continuous_auth = 4,
};

/// Device trust scores (5 constructors, tags 0-4).
pub const DeviceTrustScore = enum(u8) {
    device_unknown = 0,
    device_partial = 1,
    device_compliant = 2,
    device_managed = 3,
    device_hardened = 4,
};

/// Access decisions (4 constructors, tags 0-3).
pub const AccessDecision = enum(u8) {
    allow = 0,
    deny = 1,
    challenge = 2,
    step_up = 3,
};

/// Context signal kinds (5 constructors, tags 0-4).
pub const ContextSignalKind = enum(u8) {
    location = 0,
    time = 1,
    device = 2,
    behavior = 3,
    network = 4,
};

/// Authentication factors (6 constructors, tags 0-5).
pub const AuthFactor = enum(u8) {
    certificate = 0,
    token = 1,
    biometric = 2,
    fido2 = 3,
    totp = 4,
    push = 5,
};

/// Trust levels (5 constructors, tags 0-4).
pub const TrustLevel = enum(u8) {
    none = 0,
    low = 1,
    medium = 2,
    high = 3,
    full = 4,
};

/// Policy decisions (5 constructors, tags 0-4).
pub const PolicyDecision = enum(u8) {
    allow = 0,
    deny = 1,
    challenge = 2,
    step_up = 3,
    quarantine = 4,
};

/// Session states (5 constructors, tags 0-4).
pub const SessionState = enum(u8) {
    unauthenticated = 0,
    partial_auth = 1,
    authenticated = 2,
    elevated = 3,
    locked = 4,
};

/// Evaluation pipeline phases (6 constructors, tags 0-5).
pub const EvaluationPhase = enum(u8) {
    request_received = 0,
    identity_verified = 1,
    device_checked = 2,
    policy_evaluated = 3,
    access_granted = 4,
    access_denied = 5,
};

// -- Constants ----------------------------------------------------------------

/// Maximum number of concurrent evaluation sessions.
const MAX_CONTEXTS: usize = 64;

/// Number of distinct context signal kinds.
const NUM_SIGNALS: usize = 5;

// -- Context signal record ----------------------------------------------------

/// A context signal entry.
const SignalEntry = struct {
    /// Signal value (0-1000).
    value: u16,
    /// Whether this signal has been set.
    active: bool,
};

const DEFAULT_SIGNAL: SignalEntry = .{
    .value = 0,
    .active = false,
};

// -- Zero Trust evaluation context --------------------------------------------

/// A single Zero Trust access evaluation session.
const Context = struct {
    /// Current evaluation phase.
    phase: EvaluationPhase,
    /// Configured policy type.
    policy: u8,
    /// Identity confidence level after verification.
    identity_confidence: u8,
    /// Device trust score after device check.
    device_trust: u8,
    /// Final access decision (only valid after PolicyEvaluated/terminal).
    access_decision: u8,
    /// Context signals (indexed by ContextSignalKind tag).
    signals: [NUM_SIGNALS]SignalEntry,
    /// Whether this slot is in use.
    active: bool,
};

const DEFAULT_CONTEXT: Context = .{
    .phase = .request_received,
    .policy = 0,
    .identity_confidence = 0,
    .device_trust = 0,
    .access_decision = 1, // Deny by default
    .signals = [_]SignalEntry{DEFAULT_SIGNAL} ** NUM_SIGNALS,
    .active = false,
};

/// Pool of evaluation sessions.
var contexts: [MAX_CONTEXTS]Context = [_]Context{DEFAULT_CONTEXT} ** MAX_CONTEXTS;

/// Mutex protecting the context pool.
var mutex: std.Thread.Mutex = .{};

/// Validate a slot index and return it as usize if active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

/// Compute weighted average of all active signals.
fn computeTrustScore(ctx: *const Context) u16 {
    var total: u32 = 0;
    var count: u32 = 0;
    for (ctx.signals) |sig| {
        if (sig.active) {
            total += sig.value;
            count += 1;
        }
    }
    if (count == 0) return 0;
    return @intCast(total / count);
}

/// Map aggregate trust score to TrustLevel tag.
fn trustLevelFromScore(score: u16) u8 {
    if (score == 0) return 0; // None
    if (score < 250) return 1; // Low
    if (score < 500) return 2; // Medium
    if (score < 750) return 3; // High
    return 4; // Full
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match ZeroTrustABI.Foreign.abiVersion.
pub export fn zt_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new evaluation session with the given policy type.
/// Returns a non-negative slot index on success, or -1 on failure.
pub export fn zt_create(policy: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (policy > 3) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = DEFAULT_CONTEXT;
            ctx.active = true;
            ctx.phase = .request_received;
            ctx.policy = policy;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy an evaluation session.
pub export fn zt_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)] = DEFAULT_CONTEXT;
}

// -- State queries ------------------------------------------------------------

/// Returns the current evaluation phase tag. Returns 5 (AccessDenied) for invalid slots.
pub export fn zt_phase(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5;
    return @intFromEnum(contexts[idx].phase);
}

/// Returns the configured policy type tag. Returns 255 for invalid slots.
pub export fn zt_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].policy;
}

/// Returns the current identity confidence level tag. Returns 0 for invalid slots.
pub export fn zt_identity_confidence(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].identity_confidence;
}

/// Returns the current device trust score tag. Returns 0 for invalid slots.
pub export fn zt_device_trust(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].device_trust;
}

/// Returns the access decision tag. Returns 1 (Deny) for invalid slots.
pub export fn zt_access_decision(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    return contexts[idx].access_decision;
}

// -- Evaluation pipeline transitions ------------------------------------------

/// Verify identity with given confidence level.
/// RequestReceived -> IdentityVerified (confidence > 0) or AccessDenied (confidence == 0).
/// Returns 0=ok, 1=rejected.
pub export fn zt_verify_identity(slot: c_int, confidence: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .request_received) return 1;
    if (confidence > 4) return 1;

    contexts[idx].identity_confidence = confidence;
    if (confidence == 0) {
        // Unverified -> AccessDenied (DenyFromRequest)
        contexts[idx].phase = .access_denied;
        contexts[idx].access_decision = 1; // Deny
    } else {
        contexts[idx].phase = .identity_verified;
    }
    return 0;
}

/// Check device with given trust score.
/// IdentityVerified -> DeviceChecked (trust > 0) or AccessDenied (trust == 0).
/// Returns 0=ok, 1=rejected.
pub export fn zt_check_device(slot: c_int, trust: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .identity_verified) return 1;
    if (trust > 4) return 1;

    contexts[idx].device_trust = trust;
    if (trust == 0) {
        // DeviceUnknown -> AccessDenied (DenyFromIdentity)
        contexts[idx].phase = .access_denied;
        contexts[idx].access_decision = 1; // Deny
    } else {
        contexts[idx].phase = .device_checked;
    }
    return 0;
}

/// Evaluate all policies. DeviceChecked -> PolicyEvaluated.
/// Computes access decision based on trust score and policy.
/// Returns 0=ok, 1=rejected.
pub export fn zt_evaluate_policy(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .device_checked) return 1;

    // Compute trust score from signals.
    const score = computeTrustScore(&contexts[idx]);
    const level = trustLevelFromScore(score);

    // Determine access decision based on trust level and policy.
    const policy = contexts[idx].policy;
    if (policy == 1) {
        // NeverTrust: requires Full trust
        contexts[idx].access_decision = if (level >= 4) 0 else 1;
    } else if (policy == 0) {
        // AlwaysVerify: requires at least Medium trust
        contexts[idx].access_decision = if (level >= 2) 0 else 1;
    } else {
        // LeastPrivilege / MicroSegmentation: requires at least Low trust
        contexts[idx].access_decision = if (level >= 1) 0 else 1;
    }

    contexts[idx].phase = .policy_evaluated;
    return 0;
}

/// Grant access after policy evaluation.
/// PolicyEvaluated -> AccessGranted (if Allow) or AccessDenied (otherwise).
/// Returns 0=ok, 1=rejected.
pub export fn zt_grant_access(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .policy_evaluated) return 1;

    if (contexts[idx].access_decision == 0) {
        // Allow
        contexts[idx].phase = .access_granted;
    } else {
        // Deny / Challenge / StepUp
        contexts[idx].phase = .access_denied;
    }
    return 0;
}

// -- Signal management --------------------------------------------------------

/// Add a context signal with a 0-1000 score.
/// Can be called at any non-terminal phase.
/// Returns 0=ok, 1=rejected.
pub export fn zt_add_signal(slot: c_int, kind: u8, value: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (kind > 4) return 1;
    if (value > 1000) return 1;
    // Cannot add signals to terminal phases.
    const phase = contexts[idx].phase;
    if (phase == .access_granted or phase == .access_denied) return 1;

    contexts[idx].signals[@intCast(kind)] = .{
        .value = value,
        .active = true,
    };
    return 0;
}

/// Returns number of active context signals.
pub export fn zt_signal_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    var count: u32 = 0;
    for (contexts[idx].signals) |sig| {
        if (sig.active) count += 1;
    }
    return count;
}

/// Returns the value of a specific signal kind. Returns 0 if not set.
pub export fn zt_signal_value(slot: c_int, kind: u8) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (kind > 4) return 0;
    const sig = contexts[idx].signals[@intCast(kind)];
    return if (sig.active) sig.value else 0;
}

/// Compute aggregate trust score from all active signals (0-1000).
pub export fn zt_trust_score(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return computeTrustScore(&contexts[idx]);
}

/// Returns trust level derived from aggregate trust score.
pub export fn zt_trust_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const score = computeTrustScore(&contexts[idx]);
    return trustLevelFromScore(score);
}

// -- Stateless queries --------------------------------------------------------

/// Check whether an evaluation phase transition is valid.
/// Returns 1 if valid, 0 if not.
pub export fn zt_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // RequestReceived(0) -> IdentityVerified(1)
    if (from == 0 and to == 1) return 1;
    // IdentityVerified(1) -> DeviceChecked(2)
    if (from == 1 and to == 2) return 1;
    // DeviceChecked(2) -> PolicyEvaluated(3)
    if (from == 2 and to == 3) return 1;
    // PolicyEvaluated(3) -> AccessGranted(4)
    if (from == 3 and to == 4) return 1;
    // PolicyEvaluated(3) -> AccessDenied(5)
    if (from == 3 and to == 5) return 1;
    // RequestReceived(0) -> AccessDenied(5): DenyFromRequest
    if (from == 0 and to == 5) return 1;
    // IdentityVerified(1) -> AccessDenied(5): DenyFromIdentity
    if (from == 1 and to == 5) return 1;
    // DeviceChecked(2) -> AccessDenied(5): DenyFromDevice
    if (from == 2 and to == 5) return 1;
    return 0;
}

/// Check whether denial is possible from the given phase.
/// Returns 1=yes, 0=no.
pub export fn zt_can_deny(phase: u8) callconv(.c) u8 {
    // Non-terminal phases can deny: 0, 1, 2, 3
    if (phase <= 3) return 1;
    return 0;
}

/// Check whether granting is possible from the given phase.
/// Returns 1=yes, 0=no.
pub export fn zt_can_grant(phase: u8) callconv(.c) u8 {
    // Only PolicyEvaluated(3) can grant
    if (phase == 3) return 1;
    return 0;
}

/// Check whether a phase is terminal (AccessGranted or AccessDenied).
/// Returns 1=yes, 0=no.
pub export fn zt_is_terminal(phase: u8) callconv(.c) u8 {
    if (phase == 4 or phase == 5) return 1;
    return 0;
}
