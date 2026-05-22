// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

/** NetconfOperation matching the Idris2 ABI tags. */
export const NetconfOperation = Object.freeze({
  GET: 0,
  GET_CONFIG: 1,
  EDIT_CONFIG: 2,
  COPY_CONFIG: 3,
  DELETE_CONFIG: 4,
  LOCK: 5,
  UNLOCK: 6,
  CLOSE_SESSION: 7,
  KILL_SESSION: 8,
  COMMIT: 9,
  VALIDATE: 10,
  DISCARD_CHANGES: 11,
});

/** Datastore matching the Idris2 ABI tags. */
export const Datastore = Object.freeze({
  RUNNING: 0,
  STARTUP: 1,
  CANDIDATE: 2,
});

/** EditOperation matching the Idris2 ABI tags. */
export const EditOperation = Object.freeze({
  MERGE: 0,
  REPLACE: 1,
  CREATE: 2,
  DELETE: 3,
  REMOVE: 4,
});

/** NetconfErrorType matching the Idris2 ABI tags. */
export const NetconfErrorType = Object.freeze({
  TRANSPORT: 0,
  RPC: 1,
  PROTOCOL: 2,
  APPLICATION: 3,
});

/** ErrorSeverity matching the Idris2 ABI tags. */
export const ErrorSeverity = Object.freeze({
  ERROR: 0,
  WARNING: 1,
});

/** NetconfState matching the Idris2 ABI tags. */
export const NetconfState = Object.freeze({
  IDLE: 0,
  CONNECTED: 1,
  LOCKED: 2,
  EDITING: 3,
  CLOSING: 4,
  TERMINATED: 5,
});
