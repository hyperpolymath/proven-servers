// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// neurosym.zig -- Zig FFI implementation of proven-neurosym.
//
// Implements the neurosymbolic inference server state machine with:
//   - 64-slot mutex-protected session pool
//   - Neural inference dispatch
//   - Symbolic reasoning dispatch
//   - Fusion strategy execution
//   - Knowledge base tracking (max 32 entries per session)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching NeurosymABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching NeurosymABI.Types.idr tag assignments)
// =========================================================================

/// Inference modes (ABI tags 0-3).
pub const InferenceMode = enum(u8) {
    neural = 0,
    symbolic = 1,
    hybrid = 2,
    cascade = 3,
};

/// Symbolic operations (ABI tags 0-5).
pub const SymbolicOp = enum(u8) {
    unify = 0,
    resolve = 1,
    rewrite = 2,
    prove = 3,
    search = 4,
    constrain = 5,
};

/// Neural operations (ABI tags 0-5).
pub const NeuralOp = enum(u8) {
    embed = 0,
    classify = 1,
    generate = 2,
    attend = 3,
    retrieve = 4,
    finetune = 5,
};

/// Fusion strategies (ABI tags 0-4).
pub const FusionStrategy = enum(u8) {
    neural_then_symbolic = 0,
    symbolic_then_neural = 1,
    parallel = 2,
    iterative = 3,
    gated = 4,
};

/// Confidence levels (ABI tags 0-5).
pub const ConfidenceLevel = enum(u8) {
    proven = 0,
    high_confidence = 1,
    moderate = 2,
    low_confidence = 3,
    uncertain = 4,
    contradicted = 5,
};

/// Knowledge types (ABI tags 0-5).
pub const KnowledgeType = enum(u8) {
    axiom = 0,
    learned = 1,
    inferred = 2,
    grounded = 3,
    hypothetical = 4,
    retracted = 5,
};

/// Neurosym server lifecycle states (ABI tags 0-5).
pub const NeurosymState = enum(u8) {
    idle = 0,
    ready = 1,
    inferring = 2,
    reasoning = 3,
    fusing = 4,
    shutdown = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum knowledge base entries per session.
const MAX_KNOWLEDGE: usize = 32;

/// Maximum text length in bytes.
const MAX_TEXT_LEN: usize = 1024;

/// A knowledge base entry.
const KnowledgeEntry = struct {
    /// Type of knowledge.
    kind: KnowledgeType,
    /// Knowledge content.
    data: [MAX_TEXT_LEN]u8,
    data_len: u32,
    /// Whether this slot is active.
    active: bool,
};

/// A neurosymbolic inference session.
const Session = struct {
    /// Current lifecycle state.
    state: NeurosymState,
    /// Configured fusion strategy.
    strategy: FusionStrategy,
    /// Current input (if inferring/reasoning).
    input: [MAX_TEXT_LEN]u8,
    input_len: u32,
    /// Last confidence assessment.
    last_confidence: ConfidenceLevel,
    /// Knowledge base entries.
    knowledge: [MAX_KNOWLEDGE]KnowledgeEntry,
    /// Number of active knowledge entries.
    knowledge_count: u32,
    /// Total operations processed.
    op_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) knowledge entry.
const empty_knowledge: KnowledgeEntry = .{
    .kind = .axiom,
    .data = [_]u8{0} ** MAX_TEXT_LEN,
    .data_len = 0,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .strategy = .parallel,
    .input = [_]u8{0} ** MAX_TEXT_LEN,
    .input_len = 0,
    .last_confidence = .uncertain,
    .knowledge = [_]KnowledgeEntry{empty_knowledge} ** MAX_KNOWLEDGE,
    .knowledge_count = 0,
    .op_count = 0,
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
pub export fn neurosym_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new neurosym session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Ready state.
pub export fn neurosym_create(strategy: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (strategy > 4) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.strategy = @enumFromInt(strategy);
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn neurosym_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current NeurosymState tag for a session.
pub export fn neurosym_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Start neural inference. Ready -> Inferring.
pub export fn neurosym_infer(
    slot: c_int,
    mode: u8,
    input_ptr: [*]const u8,
    input_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (mode > 3) return 1;
    if (input_len == 0 or input_len > MAX_TEXT_LEN) return 1;

    @memcpy(sessions[idx].input[0..input_len], input_ptr[0..input_len]);
    sessions[idx].input_len = input_len;
    sessions[idx].state = .inferring;
    sessions[idx].op_count += 1;
    return 0;
}

/// Start symbolic reasoning. Ready -> Reasoning.
pub export fn neurosym_reason(
    slot: c_int,
    op: u8,
    input_ptr: [*]const u8,
    input_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (op > 5) return 1;
    if (input_len == 0 or input_len > MAX_TEXT_LEN) return 1;

    @memcpy(sessions[idx].input[0..input_len], input_ptr[0..input_len]);
    sessions[idx].input_len = input_len;
    sessions[idx].state = .reasoning;
    sessions[idx].op_count += 1;
    return 0;
}

/// Fuse neural and symbolic results. Inferring/Reasoning -> Fusing.
pub export fn neurosym_fuse(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .inferring and sessions[idx].state != .reasoning) return 1;

    sessions[idx].state = .fusing;
    return 0;
}

/// Complete processing with confidence. Inferring/Reasoning/Fusing -> Ready.
pub export fn neurosym_complete(slot: c_int, confidence: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .inferring and state != .reasoning and state != .fusing) return 1;
    if (confidence > 5) return 1;

    sessions[idx].last_confidence = @enumFromInt(confidence);
    sessions[idx].state = .ready;
    return 0;
}

/// Add a knowledge base entry. Returns 0 on success, 1 on rejection.
pub export fn neurosym_add_knowledge(
    slot: c_int,
    kind: u8,
    data_ptr: [*]const u8,
    data_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .idle or sessions[idx].state == .shutdown) return 1;
    if (kind > 5) return 1;
    if (data_len == 0 or data_len > MAX_TEXT_LEN) return 1;
    if (sessions[idx].knowledge_count >= MAX_KNOWLEDGE) return 1;

    for (&sessions[idx].knowledge) |*k| {
        if (!k.active) {
            k.kind = @enumFromInt(kind);
            @memcpy(k.data[0..data_len], data_ptr[0..data_len]);
            k.data_len = data_len;
            k.active = true;
            sessions[idx].knowledge_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active knowledge base entries.
pub export fn neurosym_knowledge_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].knowledge_count;
}

/// Shutdown. Any non-Idle/Shutdown -> Shutdown.
pub export fn neurosym_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .shutdown) return 1;
    sessions[idx].state = .shutdown;
    return 0;
}

/// Complete cleanup. Shutdown -> Idle.
pub export fn neurosym_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].knowledge = [_]KnowledgeEntry{empty_knowledge} ** MAX_KNOWLEDGE;
    sessions[idx].knowledge_count = 0;
    sessions[idx].op_count = 0;
    sessions[idx].last_confidence = .uncertain;
    return 0;
}

/// Check if a neurosym state transition is valid (stateless).
pub export fn neurosym_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Inferring
    if (from == 1 and to == 3) return 1; // Ready -> Reasoning
    if (from == 2 and to == 1) return 1; // Inferring -> Ready (complete)
    if (from == 3 and to == 1) return 1; // Reasoning -> Ready (complete)
    if (from == 2 and to == 4) return 1; // Inferring -> Fusing
    if (from == 3 and to == 4) return 1; // Reasoning -> Fusing
    if (from == 4 and to == 1) return 1; // Fusing -> Ready (complete)
    if (from == 1 and to == 5) return 1; // Ready -> Shutdown
    if (from == 2 and to == 5) return 1; // Inferring -> Shutdown
    if (from == 3 and to == 5) return 1; // Reasoning -> Shutdown
    if (from == 4 and to == 5) return 1; // Fusing -> Shutdown
    if (from == 5 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
