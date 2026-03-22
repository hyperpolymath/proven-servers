// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

/** ServiceType matching the Idris2 ABI tags. */
export const ServiceType = Object.freeze({
  READ: 0,
  WRITE: 1,
  BROWSE: 2,
  SUBSCRIBE: 3,
  PUBLISH: 4,
  CALL: 5,
  CREATE_SESSION: 6,
  ACTIVATE_SESSION: 7,
  CLOSE_SESSION: 8,
  CREATE_SUBSCRIPTION: 9,
  DELETE_SUBSCRIPTION: 10,
});

/** NodeClass matching the Idris2 ABI tags. */
export const NodeClass = Object.freeze({
  OBJECT: 0,
  VARIABLE: 1,
  METHOD: 2,
  OBJECT_TYPE: 3,
  VARIABLE_TYPE: 4,
  REFERENCE_TYPE: 5,
  DATA_TYPE: 6,
  VIEW: 7,
});

/** StatusCode matching the Idris2 ABI tags. */
export const StatusCode = Object.freeze({
  GOOD: 0,
  UNCERTAIN: 1,
  BAD: 2,
  BAD_NODE_ID_UNKNOWN: 3,
  BAD_ATTRIBUTE_ID_INVALID: 4,
  BAD_NOT_READABLE: 5,
  BAD_NOT_WRITABLE: 6,
  BAD_OUT_OF_RANGE: 7,
  BAD_TYPE_MISMATCH: 8,
  BAD_SESSION_ID_INVALID: 9,
  BAD_SUBSCRIPTION_ID_INVALID: 10,
  BAD_TIMEOUT: 11,
});

/** SecurityMode matching the Idris2 ABI tags. */
export const SecurityMode = Object.freeze({
  NONE: 0,
  SIGN: 1,
  SIGN_AND_ENCRYPT: 2,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  CONNECTED: 1,
  CREATED: 2,
  ACTIVATED: 3,
  MONITORING: 4,
  CLOSING: 5,
});
