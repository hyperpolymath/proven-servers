// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

/// InferenceMode matching the Idris2 ABI tags.
enum InferenceMode {
  neural(0),
  symbolic(1),
  hybrid(2),
  cascade(3);

  const InferenceMode(this.tag);
  final int tag;

  static InferenceMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SymbolicOp matching the Idris2 ABI tags.
enum SymbolicOp {
  unify(0),
  resolve(1),
  rewrite(2),
  prove(3),
  search(4),
  constrain(5);

  const SymbolicOp(this.tag);
  final int tag;

  static SymbolicOp? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NeuralOp matching the Idris2 ABI tags.
enum NeuralOp {
  embed(0),
  classify(1),
  generate(2),
  attend(3),
  retrieve(4),
  finetune(5);

  const NeuralOp(this.tag);
  final int tag;

  static NeuralOp? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FusionStrategy matching the Idris2 ABI tags.
enum FusionStrategy {
  neuralThenSymbolic(0),
  symbolicThenNeural(1),
  parallel(2),
  iterative(3),
  gated(4);

  const FusionStrategy(this.tag);
  final int tag;

  static FusionStrategy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ConfidenceLevel matching the Idris2 ABI tags.
enum ConfidenceLevel {
  proven(0),
  highConfidence(1),
  moderate(2),
  lowConfidence(3),
  uncertain(4),
  contradicted(5);

  const ConfidenceLevel(this.tag);
  final int tag;

  static ConfidenceLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KnowledgeType matching the Idris2 ABI tags.
enum KnowledgeType {
  axiom(0),
  learned(1),
  inferred(2),
  grounded(3),
  hypothetical(4),
  retracted(5);

  const KnowledgeType(this.tag);
  final int tag;

  static KnowledgeType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NeurosymState matching the Idris2 ABI tags.
enum NeurosymState {
  idle(0),
  ready(1),
  inferring(2),
  reasoning(3),
  fusing(4),
  shutdown(5);

  const NeurosymState(this.tag);
  final int tag;

  static NeurosymState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
