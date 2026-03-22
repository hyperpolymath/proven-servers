<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** InferenceMode matching the Idris2 ABI tags. */
enum InferenceMode: int
{
    case Neural = 0;
    case Symbolic = 1;
    case Hybrid = 2;
    case Cascade = 3;
}

/** SymbolicOp matching the Idris2 ABI tags. */
enum SymbolicOp: int
{
    case Unify = 0;
    case Resolve = 1;
    case Rewrite = 2;
    case Prove = 3;
    case Search = 4;
    case Constrain = 5;
}

/** NeuralOp matching the Idris2 ABI tags. */
enum NeuralOp: int
{
    case Embed = 0;
    case Classify = 1;
    case Generate = 2;
    case Attend = 3;
    case Retrieve = 4;
    case Finetune = 5;
}

/** FusionStrategy matching the Idris2 ABI tags. */
enum FusionStrategy: int
{
    case NeuralThenSymbolic = 0;
    case SymbolicThenNeural = 1;
    case Parallel = 2;
    case Iterative = 3;
    case Gated = 4;
}

/** ConfidenceLevel matching the Idris2 ABI tags. */
enum ConfidenceLevel: int
{
    case Proven = 0;
    case HighConfidence = 1;
    case Moderate = 2;
    case LowConfidence = 3;
    case Uncertain = 4;
    case Contradicted = 5;
}

/** KnowledgeType matching the Idris2 ABI tags. */
enum KnowledgeType: int
{
    case Axiom = 0;
    case Learned = 1;
    case Inferred = 2;
    case Grounded = 3;
    case Hypothetical = 4;
    case Retracted = 5;
}

/** NeurosymState matching the Idris2 ABI tags. */
enum NeurosymState: int
{
    case Idle = 0;
    case Ready = 1;
    case Inferring = 2;
    case Reasoning = 3;
    case Fusing = 4;
    case Shutdown = 5;
}
