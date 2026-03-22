// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

/// PqcAlgorithm matching the Idris2 ABI tags.
enum PqcAlgorithm {
  crystalsKyber(0),
  crystalsDilithium(1),
  falcon(2),
  sphincsPlus(3),
  classicMceliece(4),
  bike(5),
  hqc(6),
  frodokem(7);

  const PqcAlgorithm(this.tag);
  final int tag;

  static PqcAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NistLevel matching the Idris2 ABI tags.
enum NistLevel {
  nist1(0),
  nist2(1),
  nist3(2),
  nist4(3),
  nist5(4);

  const NistLevel(this.tag);
  final int tag;

  static NistLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Operation matching the Idris2 ABI tags.
enum Operation {
  keygen(0),
  encapsulate(1),
  decapsulate(2),
  sign(3),
  verify(4);

  const Operation(this.tag);
  final int tag;

  static Operation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HybridMode matching the Idris2 ABI tags.
enum HybridMode {
  classicalOnly(0),
  pqcOnly(1),
  hybrid(2);

  const HybridMode(this.tag);
  final int tag;

  static HybridMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AlgorithmCategory matching the Idris2 ABI tags.
enum AlgorithmCategory {
  kem(0),
  signature(1);

  const AlgorithmCategory(this.tag);
  final int tag;

  static AlgorithmCategory? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KeyState matching the Idris2 ABI tags.
enum KeyState {
  empty(0),
  generating(1),
  generated(2),
  active(3),
  expired(4),
  compromised(5);

  const KeyState(this.tag);
  final int tag;

  static KeyState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
