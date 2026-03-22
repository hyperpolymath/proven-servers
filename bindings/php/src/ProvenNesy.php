<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ReasoningMode matching the Idris2 ABI tags. */
enum ReasoningMode: int
{
    case Symbolic = 0;
    case Neural = 1;
    case SymToNeural = 2;
    case NeuralToSym = 3;
    case Ensemble = 4;
    case Cascade = 5;
}

/** ProofStatus matching the Idris2 ABI tags. */
enum ProofStatus: int
{
    case Pending = 0;
    case Attempting = 1;
    case Proved = 2;
    case Failed = 3;
    case Assumed = 4;
    case Vacuous = 5;
}

/** ConstraintKind matching the Idris2 ABI tags. */
enum ConstraintKind: int
{
    case TypeEquality = 0;
    case Subtype = 1;
    case Linearity = 2;
    case Termination = 3;
    case Totality = 4;
    case Invariant = 5;
    case Refinement = 6;
    case DependentIndex = 7;
}

/** NeuralBackend matching the Idris2 ABI tags. */
enum NeuralBackend: int
{
    case LocalModel = 0;
    case Claude = 1;
    case Gemini = 2;
    case Mistral = 3;
    case Gpt = 4;
    case CustomNeural = 5;
}

/** Confidence matching the Idris2 ABI tags. */
enum Confidence: int
{
    case Verified = 0;
    case HighNeural = 1;
    case MediumNeural = 2;
    case LowNeural = 3;
    case Unknown = 4;
    case Contradicted = 5;
}

/** DriftKind matching the Idris2 ABI tags. */
enum DriftKind: int
{
    case NoDrift = 0;
    case SemanticDrift = 1;
    case ConfidenceDrift = 2;
    case FactualDrift = 3;
    case TemporalDrift = 4;
    case CatastrophicDrift = 5;
}

/** NeSyState matching the Idris2 ABI tags. */
enum NeSyState: int
{
    case Idle = 0;
    case Ready = 1;
    case Reasoning = 2;
    case Verifying = 3;
    case Drift = 4;
    case Shutdown = 5;
}
