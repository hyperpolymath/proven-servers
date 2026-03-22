// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

/** Version matching the Idris2 ABI tags. */
export const Version = Object.freeze({
  V1: 0,
  V2C: 1,
  V3: 2,
});

/** PduType matching the Idris2 ABI tags. */
export const PduType = Object.freeze({
  GET_REQUEST: 0,
  GET_NEXT_REQUEST: 1,
  GET_RESPONSE: 2,
  SET_REQUEST: 3,
  GET_BULK_REQUEST: 4,
  INFORM_REQUEST: 5,
  SNMP_V2_TRAP: 6,
});

/** ErrorStatus matching the Idris2 ABI tags. */
export const ErrorStatus = Object.freeze({
  NO_ERROR: 0,
  TOO_BIG: 1,
  NO_SUCH_NAME: 2,
  BAD_VALUE: 3,
  READ_ONLY: 4,
  GEN_ERR: 5,
  NO_ACCESS: 6,
  WRONG_TYPE: 7,
  WRONG_LENGTH: 8,
  WRONG_VALUE: 9,
  NO_CREATION: 10,
  INCONSISTENT_VALUE: 11,
  RESOURCE_UNAVAILABLE: 12,
  COMMIT_FAILED: 13,
  UNDO_FAILED: 14,
  AUTHORIZATION_ERROR: 15,
});
