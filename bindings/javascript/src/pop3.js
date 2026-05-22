// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

/** Command matching the Idris2 ABI tags. */
export const Command = Object.freeze({
  USER: 0,
  PASS: 1,
  STAT: 2,
  LIST: 3,
  RETR: 4,
  DELE: 5,
  NOOP: 6,
  RSET: 7,
  QUIT: 8,
  TOP: 9,
  UIDL: 10,
});

/** State matching the Idris2 ABI tags. */
export const State = Object.freeze({
  AUTHORIZATION: 0,
  TRANSACTION: 1,
  UPDATE: 2,
});

/** Response matching the Idris2 ABI tags. */
export const Response = Object.freeze({
  RESPONSE_OK: 0,
  ERR: 1,
});

/** Pop3Error matching the Idris2 ABI tags. */
export const Pop3Error = Object.freeze({
  POP3_ERROR_OK: 0,
  INVALID_SLOT: 1,
  NOT_ACTIVE: 2,
  INVALID_TRANSITION: 3,
  INVALID_COMMAND: 4,
  AUTH_FAILED: 5,
});
