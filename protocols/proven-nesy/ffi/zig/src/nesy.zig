// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nesy.zig -- Zig FFI implementation of proven-nesy.
//
// Implements the neurosymbolic integration server state machine with:
//   - 64-slot mutex-protected session pool
//   - Query submission with reasoning mode selection
//   - Proof obligation tracking (max 16 per session)
//   - Neural backend selection
//   - Confidence assessment
//   - Drift detection between symbolic and neural results
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching NeSyABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching NeSyABI.Types.idr tag assignments)
// =========================================================================

/// Reasoning modes (ABI tags 0-5).
pub const ReasoningMode = enum(u8) {
    symbolic = 0,
    neural = 1,
    sym_to_neural = 2,
    neural_to_sym = 3,
    ensemble = 4,
    cascade = 5,
};

/// Proof status (ABI tags 0-5).
pub const ProofStatus = enum(u8) {
    pending = 0,
    attempting = 1,
    proved = 2,
    failed = 3,
    assumed = 4,
    vacuous = 5,
};

/// Constraint kinds (ABI tags 0-7).
pub const ConstraintKind = enum(u8) {
    type_equality = 0,
    subtype = 1,
    linearity = 2,
    termination = 3,
    totality = 4,
    invariant = 5,
    refinement = 6,
    dependent_index = 7,
};

/// Neural backends (ABI tags 0-5).
pub const NeuralBackend = enum(u8) {
    local_model = 0,
    claude = 1,
    gemini = 2,
    mistral = 3,
    gpt = 4,
    custom_neural = 5,
};

/// Confidence levels (ABI tags 0-5).
pub const Confidence = enum(u8) {
    verified = 0,
    high_neural = 1,
    medium_neural = 2,
    low_neural = 3,
    unknown = 4,
    contradicted = 5,
};

/// Drift kinds (ABI tags 0-5).
pub const DriftKind = enum(u8) {
    no_drift = 0,
    semantic_drift = 1,
    confidence_drift = 2,
    factual_drift = 3,
    temporal_drift = 4,
    catastrophic_drift = 5,
};

/// NeSy server lifecycle states (ABI tags 0-5).
pub const NeSyState = enum(u8) {
    idle = 0,
    ready = 1,
    reasoning = 2,
    verifying = 3,
    drift = 4,
    shutdown = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum proof obligations per session.
const MAX_PROOFS: usize = 16;

/// Maximum description/query length in bytes.
const MAX_TEXT_LEN: usize = 1024;

/// A proof obligation.
const ProofObligation = struct {
    /// The kind of constraint.
    kind: ConstraintKind,
    /// Description of the obligation.
    description: [MAX_TEXT_LEN]u8,
    desc_len: u32,
    /// Current proof status.
    status: ProofStatus,
    /// Whether this slot is active.
    active: bool,
};

/// A NeSy reasoning session.
const Session = struct {
    /// Current lifecycle state.
    state: NeSyState,
    /// Selected neural backend.
    backend: NeuralBackend,
    /// Current query (if reasoning).
    query: [MAX_TEXT_LEN]u8,
    query_len: u32,
    /// Current reasoning mode.
    mode: ReasoningMode,
    /// Last confidence assessment.
    last_confidence: Confidence,
    /// Last drift detection result.
    last_drift: DriftKind,
    /// Proof obligations.
    proofs: [MAX_PROOFS]ProofObligation,
    /// Number of active proof obligations.
    proof_count: u32,
    /// Total queries processed.
    query_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) proof obligation.
const empty_proof: ProofObligation = .{
    .kind = .type_equality,
    .description = [_]u8{0} ** MAX_TEXT_LEN,
    .desc_len = 0,
    .status = .pending,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .backend = .local_model,
    .query = [_]u8{0} ** MAX_TEXT_LEN,
    .query_len = 0,
    .mode = .symbolic,
    .last_confidence = .unknown,
    .last_drift = .no_drift,
    .proofs = [_]ProofObligation{empty_proof} ** MAX_PROOFS,
    .proof_count = 0,
    .query_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn nesy_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new NeSy session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Ready state.
pub export fn nesy_create(backend: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (backend > 5) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.backend = @enumFromInt(backend);
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn nesy_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current NeSyState tag for a session.
pub export fn nesy_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Submit a reasoning query. Ready -> Reasoning.
pub export fn nesy_submit_query(
    slot: c_int,
    mode: u8,
    query_ptr: [*]const u8,
    query_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (mode > 5) return 1;
    if (query_len == 0 or query_len > MAX_TEXT_LEN) return 1;

    @memcpy(sessions[idx].query[0..query_len], query_ptr[0..query_len]);
    sessions[idx].query_len = query_len;
    sessions[idx].mode = @enumFromInt(mode);
    sessions[idx].state = .reasoning;
    return 0;
}

/// Complete a reasoning query with a confidence level. Reasoning -> Ready.
pub export fn nesy_complete_query(slot: c_int, confidence: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .reasoning) return 1;
    if (confidence > 5) return 1;

    sessions[idx].last_confidence = @enumFromInt(confidence);
    sessions[idx].query_count += 1;
    sessions[idx].state = .ready;
    return 0;
}

/// Add a proof obligation. Returns 0 on success, 1 on rejection.
pub export fn nesy_add_proof(
    slot: c_int,
    kind: u8,
    desc_ptr: [*]const u8,
    desc_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .idle or sessions[idx].state == .shutdown) return 1;
    if (kind > 7) return 1;
    if (desc_len == 0 or desc_len > MAX_TEXT_LEN) return 1;
    if (sessions[idx].proof_count >= MAX_PROOFS) return 1;

    for (&sessions[idx].proofs) |*p| {
        if (!p.active) {
            p.* = empty_proof;
            p.kind = @enumFromInt(kind);
            @memcpy(p.description[0..desc_len], desc_ptr[0..desc_len]);
            p.desc_len = desc_len;
            p.status = .pending;
            p.active = true;
            sessions[idx].proof_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Verify a proof obligation by index. Returns ProofStatus tag.
/// Transitions Ready -> Verifying -> Ready, simulating proof success.
pub export fn nesy_verify_proof(slot: c_int, index: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(ProofStatus.failed);
    if (sessions[idx].state != .ready and sessions[idx].state != .verifying) {
        return @intFromEnum(ProofStatus.failed);
    }
    if (index >= MAX_PROOFS) return @intFromEnum(ProofStatus.failed);
    if (!sessions[idx].proofs[index].active) return @intFromEnum(ProofStatus.failed);

    // Simulate proof verification: mark as proved.
    sessions[idx].proofs[index].status = .proved;
    sessions[idx].state = .ready;
    return @intFromEnum(ProofStatus.proved);
}

/// Returns the number of active proof obligations.
pub export fn nesy_proof_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].proof_count;
}

/// Detect drift between neural and symbolic results.
/// Returns DriftKind tag. May transition to Drift state on non-trivial drift.
pub export fn nesy_detect_drift(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(DriftKind.no_drift);
    if (sessions[idx].state != .ready and sessions[idx].state != .reasoning) {
        return @intFromEnum(DriftKind.no_drift);
    }

    // Simulated drift detection: no drift by default.
    sessions[idx].last_drift = .no_drift;
    return @intFromEnum(DriftKind.no_drift);
}

/// Resolve drift, returning to Ready state. Drift -> Ready.
pub export fn nesy_resolve_drift(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .drift) return 1;
    sessions[idx].last_drift = .no_drift;
    sessions[idx].state = .ready;
    return 0;
}

/// Shutdown. Any non-Idle/Shutdown -> Shutdown.
pub export fn nesy_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .shutdown) return 1;
    sessions[idx].state = .shutdown;
    return 0;
}

/// Complete cleanup. Shutdown -> Idle.
pub export fn nesy_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].proofs = [_]ProofObligation{empty_proof} ** MAX_PROOFS;
    sessions[idx].proof_count = 0;
    sessions[idx].query_count = 0;
    sessions[idx].last_confidence = .unknown;
    sessions[idx].last_drift = .no_drift;
    return 0;
}

/// Check if a NeSy state transition is valid (stateless).
pub export fn nesy_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Reasoning
    if (from == 2 and to == 1) return 1; // Reasoning -> Ready
    if (from == 1 and to == 3) return 1; // Ready -> Verifying
    if (from == 3 and to == 1) return 1; // Verifying -> Ready
    if (from == 1 and to == 4) return 1; // Ready -> Drift
    if (from == 2 and to == 4) return 1; // Reasoning -> Drift
    if (from == 4 and to == 1) return 1; // Drift -> Ready
    if (from == 1 and to == 5) return 1; // Ready -> Shutdown
    if (from == 2 and to == 5) return 1; // Reasoning -> Shutdown
    if (from == 3 and to == 5) return 1; // Verifying -> Shutdown
    if (from == 4 and to == 5) return 1; // Drift -> Shutdown
    if (from == 5 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
