// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

/** StreamType matching the Idris2 ABI tags. */
export const StreamType = Object.freeze({
  UNIDIRECTIONAL: 0,
  BIDIRECTIONAL: 1,
});

/** ErrorCode matching the Idris2 ABI tags. */
export const ErrorCode = Object.freeze({
  NO_ERROR: 0,
  INTERNAL_ERROR: 1,
  EXCESSIVE_LOAD: 2,
  PROTOCOL_ERROR: 3,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  INITIAL: 0,
  HANDSHAKING: 1,
  READY: 2,
  DRAINING: 3,
  CLOSED: 4,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  BOUND: 1,
  LISTENING: 2,
  PROCESSING: 3,
  SHUTDOWN: 4,
});
