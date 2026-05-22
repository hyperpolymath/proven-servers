// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

namespace Proven;

/// <summary>InferenceMode matching the Idris2 ABI tags (0-3).</summary>
public enum InferenceMode : byte
{
    Neural = 0,
    Symbolic = 1,
    Hybrid = 2,
    Cascade = 3
}

/// <summary>SymbolicOp matching the Idris2 ABI tags (0-5).</summary>
public enum SymbolicOp : byte
{
    Unify = 0,
    Resolve = 1,
    Rewrite = 2,
    Prove = 3,
    Search = 4,
    Constrain = 5
}

/// <summary>NeuralOp matching the Idris2 ABI tags (0-5).</summary>
public enum NeuralOp : byte
{
    Embed = 0,
    Classify = 1,
    Generate = 2,
    Attend = 3,
    Retrieve = 4,
    Finetune = 5
}

/// <summary>FusionStrategy matching the Idris2 ABI tags (0-4).</summary>
public enum FusionStrategy : byte
{
    NeuralThenSymbolic = 0,
    SymbolicThenNeural = 1,
    Parallel = 2,
    Iterative = 3,
    Gated = 4
}

/// <summary>ConfidenceLevel matching the Idris2 ABI tags (0-5).</summary>
public enum ConfidenceLevel : byte
{
    Proven = 0,
    HighConfidence = 1,
    Moderate = 2,
    LowConfidence = 3,
    Uncertain = 4,
    Contradicted = 5
}

/// <summary>KnowledgeType matching the Idris2 ABI tags (0-5).</summary>
public enum KnowledgeType : byte
{
    Axiom = 0,
    Learned = 1,
    Inferred = 2,
    Grounded = 3,
    Hypothetical = 4,
    Retracted = 5
}

/// <summary>NeurosymState matching the Idris2 ABI tags (0-5).</summary>
public enum NeurosymState : byte
{
    Idle = 0,
    Ready = 1,
    Inferring = 2,
    Reasoning = 3,
    Fusing = 4,
    Shutdown = 5
}
