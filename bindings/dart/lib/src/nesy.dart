// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

/// ReasoningMode matching the Idris2 ABI tags.
enum ReasoningMode {
  symbolic(0),
  neural(1),
  symToNeural(2),
  neuralToSym(3),
  ensemble(4),
  cascade(5);

  const ReasoningMode(this.tag);
  final int tag;

  static ReasoningMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ProofStatus matching the Idris2 ABI tags.
enum ProofStatus {
  pending(0),
  attempting(1),
  proved(2),
  failed(3),
  assumed(4),
  vacuous(5);

  const ProofStatus(this.tag);
  final int tag;

  static ProofStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ConstraintKind matching the Idris2 ABI tags.
enum ConstraintKind {
  typeEquality(0),
  subtype(1),
  linearity(2),
  termination(3),
  totality(4),
  invariant(5),
  refinement(6),
  dependentIndex(7);

  const ConstraintKind(this.tag);
  final int tag;

  static ConstraintKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NeuralBackend matching the Idris2 ABI tags.
enum NeuralBackend {
  localModel(0),
  claude(1),
  gemini(2),
  mistral(3),
  gpt(4),
  customNeural(5);

  const NeuralBackend(this.tag);
  final int tag;

  static NeuralBackend? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Confidence matching the Idris2 ABI tags.
enum Confidence {
  verified(0),
  highNeural(1),
  mediumNeural(2),
  lowNeural(3),
  unknown(4),
  contradicted(5);

  const Confidence(this.tag);
  final int tag;

  static Confidence? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DriftKind matching the Idris2 ABI tags.
enum DriftKind {
  noDrift(0),
  semanticDrift(1),
  confidenceDrift(2),
  factualDrift(3),
  temporalDrift(4),
  catastrophicDrift(5);

  const DriftKind(this.tag);
  final int tag;

  static DriftKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NeSyState matching the Idris2 ABI tags.
enum NeSyState {
  idle(0),
  ready(1),
  reasoning(2),
  verifying(3),
  drift(4),
  shutdown(5);

  const NeSyState(this.tag);
  final int tag;

  static NeSyState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
