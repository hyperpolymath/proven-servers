// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

/** PqcAlgorithm matching the Idris2 ABI tags. */
export const PqcAlgorithm = Object.freeze({
  CRYSTALS_KYBER: 0,
  CRYSTALS_DILITHIUM: 1,
  FALCON: 2,
  SPHINCS_PLUS: 3,
  CLASSIC_MCELIECE: 4,
  BIKE: 5,
  HQC: 6,
  FRODOKEM: 7,
});

/** NistLevel matching the Idris2 ABI tags. */
export const NistLevel = Object.freeze({
  NIST1: 0,
  NIST2: 1,
  NIST3: 2,
  NIST4: 3,
  NIST5: 4,
});

/** Operation matching the Idris2 ABI tags. */
export const Operation = Object.freeze({
  KEYGEN: 0,
  ENCAPSULATE: 1,
  DECAPSULATE: 2,
  SIGN: 3,
  VERIFY: 4,
});

/** HybridMode matching the Idris2 ABI tags. */
export const HybridMode = Object.freeze({
  CLASSICAL_ONLY: 0,
  PQC_ONLY: 1,
  HYBRID: 2,
});

/** AlgorithmCategory matching the Idris2 ABI tags. */
export const AlgorithmCategory = Object.freeze({
  KEM: 0,
  SIGNATURE: 1,
});

/** KeyState matching the Idris2 ABI tags. */
export const KeyState = Object.freeze({
  EMPTY: 0,
  GENERATING: 1,
  GENERATED: 2,
  ACTIVE: 3,
  EXPIRED: 4,
  COMPROMISED: 5,
});
