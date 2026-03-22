// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

/** RecordType matching the Idris2 ABI tags. */
export const RecordType = Object.freeze({
  END_OF_MESSAGE: 0,
  NEXT_PROTOCOL: 1,
  ERROR: 2,
  WARNING: 3,
  AEAD_ALGORITHM: 4,
  COOKIE: 5,
  COOKIE_PLACEHOLDER: 6,
  NTSKE_SERVER: 7,
  NTSKE_PORT: 8,
});

/** ErrorCode matching the Idris2 ABI tags. */
export const ErrorCode = Object.freeze({
  UNRECOGNIZED_CRITICAL: 0,
  BAD_REQUEST: 1,
  INTERNAL_ERROR: 2,
});

/** AeadAlgorithm matching the Idris2 ABI tags. */
export const AeadAlgorithm = Object.freeze({
  AEAD_AES128_GCM: 0,
  AEAD_AES256_GCM: 1,
  AEAD_AES_SIV_CMAC256: 2,
});

/** HandshakeState matching the Idris2 ABI tags. */
export const HandshakeState = Object.freeze({
  INITIAL: 0,
  HANDSHAKE_STATE_NEGOTIATING: 1,
  HANDSHAKE_STATE_ESTABLISHED: 2,
  FAILED: 3,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  HANDSHAKING: 1,
  SESSION_STATE_NEGOTIATING: 2,
  SESSION_STATE_ESTABLISHED: 3,
  CLOSING: 4,
});
