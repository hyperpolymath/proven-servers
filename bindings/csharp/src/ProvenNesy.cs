// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

namespace Proven;

/// <summary>ReasoningMode matching the Idris2 ABI tags (0-5).</summary>
public enum ReasoningMode : byte
{
    Symbolic = 0,
    Neural = 1,
    SymToNeural = 2,
    NeuralToSym = 3,
    Ensemble = 4,
    Cascade = 5
}

/// <summary>ProofStatus matching the Idris2 ABI tags (0-5).</summary>
public enum ProofStatus : byte
{
    Pending = 0,
    Attempting = 1,
    Proved = 2,
    Failed = 3,
    Assumed = 4,
    Vacuous = 5
}

/// <summary>ConstraintKind matching the Idris2 ABI tags (0-7).</summary>
public enum ConstraintKind : byte
{
    TypeEquality = 0,
    Subtype = 1,
    Linearity = 2,
    Termination = 3,
    Totality = 4,
    Invariant = 5,
    Refinement = 6,
    DependentIndex = 7
}

/// <summary>NeuralBackend matching the Idris2 ABI tags (0-5).</summary>
public enum NeuralBackend : byte
{
    LocalModel = 0,
    Claude = 1,
    Gemini = 2,
    Mistral = 3,
    Gpt = 4,
    CustomNeural = 5
}

/// <summary>Confidence matching the Idris2 ABI tags (0-5).</summary>
public enum Confidence : byte
{
    Verified = 0,
    HighNeural = 1,
    MediumNeural = 2,
    LowNeural = 3,
    Unknown = 4,
    Contradicted = 5
}

/// <summary>DriftKind matching the Idris2 ABI tags (0-5).</summary>
public enum DriftKind : byte
{
    NoDrift = 0,
    SemanticDrift = 1,
    ConfidenceDrift = 2,
    FactualDrift = 3,
    TemporalDrift = 4,
    CatastrophicDrift = 5
}

/// <summary>NeSyState matching the Idris2 ABI tags (0-5).</summary>
public enum NeSyState : byte
{
    Idle = 0,
    Ready = 1,
    Reasoning = 2,
    Verifying = 3,
    Drift = 4,
    Shutdown = 5
}
