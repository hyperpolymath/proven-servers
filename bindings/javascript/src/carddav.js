// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

/** PropertyType matching the Idris2 ABI tags. */
export const PropertyType = Object.freeze({
  FN_NAME: 0,
  N: 1,
  EMAIL: 2,
  TEL: 3,
  ADR: 4,
  ORG: 5,
  PHOTO: 6,
  URL: 7,
  NOTE: 8,
});

/** CardMethod matching the Idris2 ABI tags. */
export const CardMethod = Object.freeze({
  GET: 0,
  PUT: 1,
  DELETE: 2,
  PROPFIND: 3,
  PROPPATCH: 4,
  REPORT: 5,
  MKCOL: 6,
});

/** VCardVersion matching the Idris2 ABI tags. */
export const VCardVersion = Object.freeze({
  VCARD3: 0,
  VCARD4: 1,
});

/** CardError matching the Idris2 ABI tags. */
export const CardError = Object.freeze({
  VALID_ADDRESS_DATA: 0,
  NO_RESOURCE_TYPE: 1,
  MAX_RESOURCE_SIZE: 2,
  UID_CONFLICT: 3,
  SUPPORTED_ADDRESS_DATA: 4,
  PRECONDITION_FAILED: 5,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  BOUND: 1,
  SERVING: 2,
  SHUTDOWN: 3,
});
