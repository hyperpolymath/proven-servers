// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nesy_ffi.zig: C-compatible FFI for the proven-nesy protocol.
// Maps the Idris2 ABI type families to C-compatible enums and provides
// drift detection logic, confidence comparison, and merge strategy helpers.

const std = @import("std");

// -----------------------------------------------------------------------
// ReasoningMode — which reasoning paradigm to use
// Mirrors: NeSy.Types.ReasoningMode (6 variants)
// -----------------------------------------------------------------------

pub const ReasoningMode = enum(u8) {
    symbolic = 0,
    neural = 1,
    sym_to_neural = 2,
    neural_to_sym = 3,
    ensemble = 4,
    cascade = 5,

    /// Whether this mode involves the symbolic layer.
    pub fn usesSymbolic(self: ReasoningMode) bool {
        return switch (self) {
            .symbolic, .sym_to_neural, .neural_to_sym, .ensemble, .cascade => true,
            .neural => false,
        };
    }

    /// Whether this mode involves the neural layer.
    pub fn usesNeural(self: ReasoningMode) bool {
        return switch (self) {
            .neural, .sym_to_neural, .neural_to_sym, .ensemble, .cascade => true,
            .symbolic => false,
        };
    }

    /// Whether this is a hybrid mode (both layers active).
    pub fn isHybrid(self: ReasoningMode) bool {
        return self.usesSymbolic() and self.usesNeural();
    }

    pub fn label(self: ReasoningMode) [*:0]const u8 {
        return switch (self) {
            .symbolic => "Symbolic",
            .neural => "Neural",
            .sym_to_neural => "SymToNeural",
            .neural_to_sym => "NeuralToSym",
            .ensemble => "Ensemble",
            .cascade => "Cascade",
        };
    }
};

// -----------------------------------------------------------------------
// ProofStatus — lifecycle state of a proof obligation
// Mirrors: NeSy.Types.ProofStatus (6 variants)
// -----------------------------------------------------------------------

pub const ProofStatus = enum(u8) {
    pending = 0,
    attempting = 1,
    proved = 2,
    failed = 3,
    assumed = 4,
    vacuous = 5,

    /// Whether the proof is in a terminal (non-transitioning) state.
    pub fn isTerminal(self: ProofStatus) bool {
        return switch (self) {
            .proved, .failed, .assumed, .vacuous => true,
            .pending, .attempting => false,
        };
    }

    /// Whether the proof is trusted (proved, assumed, or vacuous).
    pub fn isTrusted(self: ProofStatus) bool {
        return switch (self) {
            .proved, .assumed, .vacuous => true,
            else => false,
        };
    }

    /// Whether the proof is formally verified (not just assumed).
    pub fn isVerified(self: ProofStatus) bool {
        return self == .proved or self == .vacuous;
    }

    pub fn label(self: ProofStatus) [*:0]const u8 {
        return switch (self) {
            .pending => "Pending",
            .attempting => "Attempting",
            .proved => "Proved",
            .failed => "Failed",
            .assumed => "Assumed",
            .vacuous => "Vacuous",
        };
    }
};

// -----------------------------------------------------------------------
// ConstraintKind — type of symbolic constraint
// Mirrors: NeSy.Types.ConstraintKind (8 variants)
// -----------------------------------------------------------------------

pub const ConstraintKind = enum(u8) {
    type_equality = 0,
    subtype = 1,
    linearity = 2,
    termination = 3,
    totality = 4,
    invariant = 5,
    refinement = 6,
    dependent_index = 7,

    /// Whether this constraint is a structural (type-level) constraint.
    pub fn isStructural(self: ConstraintKind) bool {
        return switch (self) {
            .type_equality, .subtype, .dependent_index => true,
            else => false,
        };
    }

    /// Whether this constraint is a behavioural (runtime) constraint.
    pub fn isBehavioural(self: ConstraintKind) bool {
        return switch (self) {
            .linearity, .termination, .totality, .invariant, .refinement => true,
            else => false,
        };
    }

    pub fn label(self: ConstraintKind) [*:0]const u8 {
        return switch (self) {
            .type_equality => "TypeEquality",
            .subtype => "Subtype",
            .linearity => "Linearity",
            .termination => "Termination",
            .totality => "Totality",
            .invariant => "Invariant",
            .refinement => "Refinement",
            .dependent_index => "DependentIndex",
        };
    }
};

// -----------------------------------------------------------------------
// NeuralBackend — which neural inference engine to use
// Mirrors: NeSy.Types.NeuralBackend (6 variants)
// -----------------------------------------------------------------------

pub const NeuralBackend = enum(u8) {
    local_model = 0,
    claude = 1,
    gemini = 2,
    mistral = 3,
    gpt = 4,
    custom_neural = 5,

    /// Whether this backend runs locally (no network call).
    pub fn isLocal(self: NeuralBackend) bool {
        return self == .local_model;
    }

    /// Whether this backend is a cloud API.
    pub fn isCloudApi(self: NeuralBackend) bool {
        return switch (self) {
            .claude, .gemini, .mistral, .gpt => true,
            .local_model, .custom_neural => false,
        };
    }

    pub fn label(self: NeuralBackend) [*:0]const u8 {
        return switch (self) {
            .local_model => "LocalModel",
            .claude => "Claude",
            .gemini => "Gemini",
            .mistral => "Mistral",
            .gpt => "GPT",
            .custom_neural => "CustomNeural",
        };
    }
};

// -----------------------------------------------------------------------
// Confidence — confidence level in a result
// Mirrors: NeSy.Types.Confidence (6 variants)
// -----------------------------------------------------------------------

pub const Confidence = enum(u8) {
    verified = 0,
    high_neural = 1,
    medium_neural = 2,
    low_neural = 3,
    unknown = 4,
    contradicted = 5,

    /// Numeric confidence score (0.0–1.0) for comparison.
    pub fn score(self: Confidence) f32 {
        return switch (self) {
            .verified => 1.0,
            .high_neural => 0.95,
            .medium_neural => 0.80,
            .low_neural => 0.50,
            .unknown => 0.0,
            .contradicted => 0.0,
        };
    }

    /// Whether this confidence level is actionable (safe to use).
    pub fn isActionable(self: Confidence) bool {
        return switch (self) {
            .verified, .high_neural, .medium_neural => true,
            .low_neural, .unknown, .contradicted => false,
        };
    }

    /// Compare two confidence levels. Returns the lower of the two
    /// (used for hybrid results that inherit worst-case confidence).
    pub fn min(a: Confidence, b: Confidence) Confidence {
        return if (@intFromEnum(a) > @intFromEnum(b)) a else b;
    }

    pub fn label(self: Confidence) [*:0]const u8 {
        return switch (self) {
            .verified => "Verified",
            .high_neural => "HighNeural",
            .medium_neural => "MediumNeural",
            .low_neural => "LowNeural",
            .unknown => "Unknown",
            .contradicted => "Contradicted",
        };
    }
};

// -----------------------------------------------------------------------
// DriftKind — how symbolic and neural results can diverge
// Mirrors: NeSy.Types.DriftKind (6 variants)
// -----------------------------------------------------------------------

pub const DriftKind = enum(u8) {
    no_drift = 0,
    semantic_drift = 1,
    confidence_drift = 2,
    factual_drift = 3,
    temporal_drift = 4,
    catastrophic_drift = 5,

    /// Severity level (0 = none, 5 = catastrophic).
    pub fn severity(self: DriftKind) u8 {
        return @intFromEnum(self);
    }

    /// Whether this drift level requires immediate action.
    pub fn isUrgent(self: DriftKind) bool {
        return switch (self) {
            .factual_drift, .catastrophic_drift => true,
            else => false,
        };
    }

    /// Whether this drift level is safe to ignore.
    pub fn isBenign(self: DriftKind) bool {
        return self == .no_drift or self == .semantic_drift;
    }

    pub fn label(self: DriftKind) [*:0]const u8 {
        return switch (self) {
            .no_drift => "NoDrift",
            .semantic_drift => "SemanticDrift",
            .confidence_drift => "ConfidenceDrift",
            .factual_drift => "FactualDrift",
            .temporal_drift => "TemporalDrift",
            .catastrophic_drift => "CatastrophicDrift",
        };
    }
};

// -----------------------------------------------------------------------
// MergeStrategy — how to combine symbolic and neural results
// Mirrors: NeSy.Integration.MergeStrategy (6 variants)
// -----------------------------------------------------------------------

pub const MergeStrategy = enum(u8) {
    symbolic_primacy = 0,
    neural_primacy = 1,
    confidence_weighted = 2,
    consensus = 3,
    dual_return = 4,
    constrained_generation = 5,

    /// Whether symbolic layer has veto power in this strategy.
    pub fn symbolicCanVeto(self: MergeStrategy) bool {
        return switch (self) {
            .symbolic_primacy, .consensus, .constrained_generation => true,
            else => false,
        };
    }

    pub fn label(self: MergeStrategy) [*:0]const u8 {
        return switch (self) {
            .symbolic_primacy => "SymbolicPrimacy",
            .neural_primacy => "NeuralPrimacy",
            .confidence_weighted => "ConfidenceWeighted",
            .consensus => "Consensus",
            .dual_return => "DualReturn",
            .constrained_generation => "ConstrainedGeneration",
        };
    }
};

// -----------------------------------------------------------------------
// DriftAction — what to do when drift is detected
// Mirrors: NeSy.Integration.DriftAction (6 variants)
// -----------------------------------------------------------------------

pub const DriftAction = enum(u8) {
    log_and_accept = 0,
    flag_for_review = 1,
    reject_neural = 2,
    retry_neural = 3,
    escalate = 4,
    halt = 5,

    /// Whether this action stops processing.
    pub fn stopsProcessing(self: DriftAction) bool {
        return self == .halt or self == .reject_neural;
    }

    pub fn label(self: DriftAction) [*:0]const u8 {
        return switch (self) {
            .log_and_accept => "LogAndAccept",
            .flag_for_review => "FlagForReview",
            .reject_neural => "RejectNeural",
            .retry_neural => "RetryNeural",
            .escalate => "Escalate",
            .halt => "Halt",
        };
    }
};

// -----------------------------------------------------------------------
// ReasoningPriority, CachePolicy, ProofRequirement, ResultDisposition
// Mirrors: NeSy.Reasoning.* types
// -----------------------------------------------------------------------

pub const ReasoningPriority = enum(u8) {
    background = 0,
    normal = 1,
    urgent = 2,
    critical = 3,

    pub fn label(self: ReasoningPriority) [*:0]const u8 {
        return switch (self) {
            .background => "Background",
            .normal => "Normal",
            .urgent => "Urgent",
            .critical => "Critical",
        };
    }
};

pub const CachePolicy = enum(u8) {
    allow_cache = 0,
    force_refresh = 1,
    sym_cache_only = 2,
    no_store = 3,

    pub fn allowsSymCache(self: CachePolicy) bool {
        return self == .allow_cache or self == .sym_cache_only;
    }

    pub fn label(self: CachePolicy) [*:0]const u8 {
        return switch (self) {
            .allow_cache => "AllowCache",
            .force_refresh => "ForceRefresh",
            .sym_cache_only => "SymCacheOnly",
            .no_store => "NoStore",
        };
    }
};

pub const ProofRequirement = enum(u8) {
    no_proof = 0,
    best_effort = 1,
    proof_required = 2,
    machine_checked = 3,

    pub fn label(self: ProofRequirement) [*:0]const u8 {
        return switch (self) {
            .no_proof => "NoProof",
            .best_effort => "BestEffort",
            .proof_required => "ProofRequired",
            .machine_checked => "MachineChecked",
        };
    }
};

pub const ResultDisposition = enum(u8) {
    completed = 0,
    timed_out = 1,
    cancelled = 2,
    internal_error = 3,
    rejected = 4,
    verification_failed = 5,

    pub fn isSuccess(self: ResultDisposition) bool {
        return self == .completed;
    }

    pub fn label(self: ResultDisposition) [*:0]const u8 {
        return switch (self) {
            .completed => "Completed",
            .timed_out => "TimedOut",
            .cancelled => "Cancelled",
            .internal_error => "InternalError",
            .rejected => "Rejected",
            .verification_failed => "VerificationFailed",
        };
    }
};

// -----------------------------------------------------------------------
// EmbeddingSpace, GroundingStatus
// Mirrors: NeSy.Integration.EmbeddingSpace, GroundingStatus
// -----------------------------------------------------------------------

pub const EmbeddingSpace = enum(u8) {
    dense_vector = 0,
    sparse_vector = 1,
    graph_embedding = 2,
    hyperbolic = 3,
    symbolic_encoding = 4,

    pub fn label(self: EmbeddingSpace) [*:0]const u8 {
        return switch (self) {
            .dense_vector => "DenseVector",
            .sparse_vector => "SparseVector",
            .graph_embedding => "GraphEmbedding",
            .hyperbolic => "Hyperbolic",
            .symbolic_encoding => "SymbolicEncoding",
        };
    }
};

pub const GroundingStatus = enum(u8) {
    fully_grounded = 0,
    partially_grounded = 1,
    ungrounded = 2,
    grounding_pending = 3,
    grounding_failed = 4,

    /// Whether the output can be trusted without further verification.
    pub fn isTrusted(self: GroundingStatus) bool {
        return self == .fully_grounded;
    }

    pub fn label(self: GroundingStatus) [*:0]const u8 {
        return switch (self) {
            .fully_grounded => "FullyGrounded",
            .partially_grounded => "PartiallyGrounded",
            .ungrounded => "Ungrounded",
            .grounding_pending => "GroundingPending",
            .grounding_failed => "GroundingFailed",
        };
    }
};

// -----------------------------------------------------------------------
// NeSyContext — runtime context for a reasoning session
// -----------------------------------------------------------------------

pub const NeSyContext = extern struct {
    mode: ReasoningMode,
    confidence: Confidence,
    drift: DriftKind,
    merge_strategy: MergeStrategy,
    proof_status: ProofStatus,
    grounding: GroundingStatus,
    priority: ReasoningPriority,
    cache_policy: CachePolicy,
    session_id: u32,
    _pad: [3]u8 = .{ 0, 0, 0 },
};

// -----------------------------------------------------------------------
// Drift detection — recommend action based on drift severity
// -----------------------------------------------------------------------

/// Given a drift kind, recommend the default action to take.
pub fn recommendDriftAction(drift: DriftKind) DriftAction {
    return switch (drift) {
        .no_drift => .log_and_accept,
        .semantic_drift => .log_and_accept,
        .confidence_drift => .flag_for_review,
        .factual_drift => .reject_neural,
        .temporal_drift => .retry_neural,
        .catastrophic_drift => .halt,
    };
}

// -----------------------------------------------------------------------
// C-exported API
// -----------------------------------------------------------------------

export fn nesy_reasoning_mode_label(m: ReasoningMode) [*:0]const u8 {
    return m.label();
}
export fn nesy_reasoning_mode_uses_symbolic(m: ReasoningMode) bool {
    return m.usesSymbolic();
}
export fn nesy_reasoning_mode_uses_neural(m: ReasoningMode) bool {
    return m.usesNeural();
}
export fn nesy_reasoning_mode_is_hybrid(m: ReasoningMode) bool {
    return m.isHybrid();
}

export fn nesy_proof_status_label(p: ProofStatus) [*:0]const u8 {
    return p.label();
}
export fn nesy_proof_status_is_terminal(p: ProofStatus) bool {
    return p.isTerminal();
}
export fn nesy_proof_status_is_trusted(p: ProofStatus) bool {
    return p.isTrusted();
}

export fn nesy_constraint_kind_label(c: ConstraintKind) [*:0]const u8 {
    return c.label();
}

export fn nesy_neural_backend_label(b: NeuralBackend) [*:0]const u8 {
    return b.label();
}
export fn nesy_neural_backend_is_local(b: NeuralBackend) bool {
    return b.isLocal();
}
export fn nesy_neural_backend_is_cloud(b: NeuralBackend) bool {
    return b.isCloudApi();
}

export fn nesy_confidence_label(c: Confidence) [*:0]const u8 {
    return c.label();
}
export fn nesy_confidence_score(c: Confidence) f32 {
    return c.score();
}
export fn nesy_confidence_is_actionable(c: Confidence) bool {
    return c.isActionable();
}
export fn nesy_confidence_min(a: Confidence, b: Confidence) Confidence {
    return Confidence.min(a, b);
}

export fn nesy_drift_kind_label(d: DriftKind) [*:0]const u8 {
    return d.label();
}
export fn nesy_drift_kind_severity(d: DriftKind) u8 {
    return d.severity();
}
export fn nesy_drift_kind_is_urgent(d: DriftKind) bool {
    return d.isUrgent();
}

export fn nesy_merge_strategy_label(m: MergeStrategy) [*:0]const u8 {
    return m.label();
}
export fn nesy_merge_strategy_symbolic_can_veto(m: MergeStrategy) bool {
    return m.symbolicCanVeto();
}

export fn nesy_drift_action_label(a: DriftAction) [*:0]const u8 {
    return a.label();
}

export fn nesy_recommend_drift_action(d: DriftKind) DriftAction {
    return recommendDriftAction(d);
}

export fn nesy_grounding_status_label(g: GroundingStatus) [*:0]const u8 {
    return g.label();
}
export fn nesy_grounding_status_is_trusted(g: GroundingStatus) bool {
    return g.isTrusted();
}

export fn nesy_context_create(session_id: u32) NeSyContext {
    return NeSyContext{
        .mode = .symbolic,
        .confidence = .unknown,
        .drift = .no_drift,
        .merge_strategy = .symbolic_primacy,
        .proof_status = .pending,
        .grounding = .ungrounded,
        .priority = .normal,
        .cache_policy = .allow_cache,
        .session_id = session_id,
    };
}

// -----------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------

test "ReasoningMode hybrid detection" {
    try std.testing.expect(!ReasoningMode.symbolic.isHybrid());
    try std.testing.expect(!ReasoningMode.neural.isHybrid());
    try std.testing.expect(ReasoningMode.sym_to_neural.isHybrid());
    try std.testing.expect(ReasoningMode.neural_to_sym.isHybrid());
    try std.testing.expect(ReasoningMode.ensemble.isHybrid());
    try std.testing.expect(ReasoningMode.cascade.isHybrid());
}

test "ProofStatus terminal and trust" {
    try std.testing.expect(!ProofStatus.pending.isTerminal());
    try std.testing.expect(!ProofStatus.attempting.isTerminal());
    try std.testing.expect(ProofStatus.proved.isTerminal());
    try std.testing.expect(ProofStatus.proved.isTrusted());
    try std.testing.expect(ProofStatus.assumed.isTrusted());
    try std.testing.expect(!ProofStatus.assumed.isVerified()); // assumed != verified
    try std.testing.expect(ProofStatus.proved.isVerified());
}

test "Confidence ordering" {
    try std.testing.expect(Confidence.verified.score() == 1.0);
    try std.testing.expect(Confidence.high_neural.score() > Confidence.medium_neural.score());
    try std.testing.expect(Confidence.min(.verified, .low_neural) == .low_neural);
    try std.testing.expect(Confidence.min(.high_neural, .medium_neural) == .medium_neural);
}

test "DriftKind severity and urgency" {
    try std.testing.expect(DriftKind.no_drift.severity() == 0);
    try std.testing.expect(DriftKind.catastrophic_drift.severity() == 5);
    try std.testing.expect(!DriftKind.semantic_drift.isUrgent());
    try std.testing.expect(DriftKind.factual_drift.isUrgent());
    try std.testing.expect(DriftKind.catastrophic_drift.isUrgent());
}

test "Drift action recommendations" {
    try std.testing.expect(recommendDriftAction(.no_drift) == .log_and_accept);
    try std.testing.expect(recommendDriftAction(.factual_drift) == .reject_neural);
    try std.testing.expect(recommendDriftAction(.catastrophic_drift) == .halt);
    try std.testing.expect(recommendDriftAction(.temporal_drift) == .retry_neural);
}

test "NeuralBackend locality" {
    try std.testing.expect(NeuralBackend.local_model.isLocal());
    try std.testing.expect(!NeuralBackend.claude.isLocal());
    try std.testing.expect(NeuralBackend.claude.isCloudApi());
    try std.testing.expect(!NeuralBackend.custom_neural.isCloudApi());
}

test "MergeStrategy veto power" {
    try std.testing.expect(MergeStrategy.symbolic_primacy.symbolicCanVeto());
    try std.testing.expect(MergeStrategy.consensus.symbolicCanVeto());
    try std.testing.expect(!MergeStrategy.neural_primacy.symbolicCanVeto());
    try std.testing.expect(!MergeStrategy.dual_return.symbolicCanVeto());
}
