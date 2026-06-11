// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  CONNECTING: 0,
  HANDSHAKING: 1,
  ESTABLISHED: 2,
  CLOSING: 3,
  CLOSED: 4,
});

/** PaddingStrategy matching the Idris2 ABI tags. */
export const PaddingStrategy = Object.freeze({
  NO_PADDING: 0,
  BLOCK_PADDING: 1,
  RANDOM_PADDING: 2,
});

/** ErrorReason matching the Idris2 ABI tags. */
export const ErrorReason = Object.freeze({
  HANDSHAKE_FAILED: 0,
  CERTIFICATE_INVALID: 1,
  TIMEOUT: 2,
  UPSTREAM_ERROR: 3,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  BOUND: 1,
  LISTENING: 2,
  PROCESSING: 3,
  SHUTDOWN: 4,
});
