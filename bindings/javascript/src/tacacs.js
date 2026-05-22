// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

/** PacketType matching the Idris2 ABI tags. */
export const PacketType = Object.freeze({
  AUTHENTICATION: 0,
  AUTHORIZATION: 1,
  ACCOUNTING: 2,
});

/** AuthenType matching the Idris2 ABI tags. */
export const AuthenType = Object.freeze({
  ASCII: 0,
  PAP: 1,
  CHAP: 2,
  MS_CHAP_V1: 3,
  MS_CHAP_V2: 4,
});

/** AuthenAction matching the Idris2 ABI tags. */
export const AuthenAction = Object.freeze({
  LOGIN: 0,
  CHANGE_PASS: 1,
  SEND_AUTH: 2,
});

/** AuthenStatus matching the Idris2 ABI tags. */
export const AuthenStatus = Object.freeze({
  PASS: 0,
  AUTHEN_STATUS_FAIL: 1,
  GET_DATA: 2,
  GET_USER: 3,
  GET_PASS: 4,
  RESTART: 5,
  AUTHEN_STATUS_ERROR: 6,
  AUTHEN_STATUS_FOLLOW: 7,
});

/** AuthorStatus matching the Idris2 ABI tags. */
export const AuthorStatus = Object.freeze({
  PASS_ADD: 0,
  PASS_REPL: 1,
  AUTHOR_STATUS_FAIL: 2,
  AUTHOR_STATUS_ERROR: 3,
  AUTHOR_STATUS_FOLLOW: 4,
});

/** AcctStatus matching the Idris2 ABI tags. */
export const AcctStatus = Object.freeze({
  SUCCESS: 0,
  ACCT_STATUS_ERROR: 1,
  ACCT_STATUS_FOLLOW: 2,
});

/** AcctFlag matching the Idris2 ABI tags. */
export const AcctFlag = Object.freeze({
  START: 0,
  STOP: 1,
  WATCHDOG: 2,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  AUTHENTICATING: 1,
  AUTHORIZING: 2,
  ACTIVE: 3,
  CLOSING: 4,
});
