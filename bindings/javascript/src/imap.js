// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

/** Command matching the Idris2 ABI tags. */
export const Command = Object.freeze({
  LOGIN: 0,
  COMMAND_LOGOUT: 1,
  SELECT: 2,
  EXAMINE: 3,
  CREATE: 4,
  DELETE: 5,
  RENAME: 6,
  LIST: 7,
  FETCH: 8,
  STORE: 9,
  SEARCH: 10,
  COPY: 11,
  NOOP: 12,
  CAPABILITY: 13,
});

/** State matching the Idris2 ABI tags. */
export const State = Object.freeze({
  NOT_AUTHENTICATED: 0,
  AUTHENTICATED: 1,
  SELECTED: 2,
  STATE_LOGOUT: 3,
});

/** Flag matching the Idris2 ABI tags. */
export const Flag = Object.freeze({
  SEEN: 0,
  ANSWERED: 1,
  FLAGGED: 2,
  DELETED: 3,
  DRAFT: 4,
  RECENT: 5,
});
