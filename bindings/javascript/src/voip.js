// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

/** Method matching the Idris2 ABI tags. */
export const Method = Object.freeze({
  INVITE: 0,
  ACK: 1,
  BYE: 2,
  CANCEL: 3,
  REGISTER: 4,
  OPTIONS: 5,
  INFO: 6,
  UPDATE: 7,
  SUBSCRIBE: 8,
  NOTIFY: 9,
  REFER: 10,
  MESSAGE: 11,
  PRACK: 12,
});

/** ResponseCode matching the Idris2 ABI tags. */
export const ResponseCode = Object.freeze({
  TRYING: 0,
  RINGING: 1,
  SESSION_PROGRESS: 2,
  OK: 3,
  MULTIPLE_CHOICES: 4,
  MOVED_PERMANENTLY: 5,
  MOVED_TEMPORARILY: 6,
  BAD_REQUEST: 7,
  UNAUTHORIZED: 8,
  FORBIDDEN: 9,
  NOT_FOUND: 10,
  METHOD_NOT_ALLOWED: 11,
  REQUEST_TIMEOUT: 12,
  BUSY_HERE: 13,
  DECLINE: 14,
  SERVER_INTERNAL_ERROR: 15,
  SERVICE_UNAVAILABLE: 16,
});

/** DialogState matching the Idris2 ABI tags. */
export const DialogState = Object.freeze({
  EARLY: 0,
  CONFIRMED: 1,
  TERMINATED: 2,
});
