// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

/** LogEntryType matching the Idris2 ABI tags. */
export const LogEntryType = Object.freeze({
  X509_ENTRY: 0,
  PRECERT_ENTRY: 1,
});

/** SignatureType matching the Idris2 ABI tags. */
export const SignatureType = Object.freeze({
  CERTIFICATE_TIMESTAMP: 0,
  TREE_HASH: 1,
});

/** MerkleLeafType matching the Idris2 ABI tags. */
export const MerkleLeafType = Object.freeze({
  TIMESTAMPED_ENTRY: 0,
});

/** SubmissionStatus matching the Idris2 ABI tags. */
export const SubmissionStatus = Object.freeze({
  ACCEPTED: 0,
  DUPLICATE: 1,
  RATE_LIMITED: 2,
  REJECTED: 3,
  INVALID_CHAIN: 4,
  UNKNOWN_ANCHOR: 5,
});

/** VerificationResult matching the Idris2 ABI tags. */
export const VerificationResult = Object.freeze({
  VALID_PROOF: 0,
  INVALID_PROOF: 1,
  INCONSISTENT_TREE: 2,
  STALE_STH: 3,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  ACTIVE: 1,
  MERGING: 2,
  SIGNING: 3,
  SHUTDOWN: 4,
});
