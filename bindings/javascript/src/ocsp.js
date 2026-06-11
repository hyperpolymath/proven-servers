// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

/** CertStatus matching the Idris2 ABI tags. */
export const CertStatus = Object.freeze({
  GOOD: 0,
  REVOKED: 1,
  UNKNOWN: 2,
});

/** ResponseStatus matching the Idris2 ABI tags. */
export const ResponseStatus = Object.freeze({
  SUCCESSFUL: 0,
  MALFORMED_REQUEST: 1,
  INTERNAL_ERROR: 2,
  TRY_LATER: 3,
  SIG_REQUIRED: 4,
  UNAUTHORIZED: 5,
});

/** HashAlgorithm matching the Idris2 ABI tags. */
export const HashAlgorithm = Object.freeze({
  SHA1: 0,
  SHA256: 1,
  SHA384: 2,
  SHA512: 3,
});

/** ResponderState matching the Idris2 ABI tags. */
export const ResponderState = Object.freeze({
  IDLE: 0,
  READY: 1,
  PROCESSING: 2,
  SIGNING: 3,
  CLOSING: 4,
});
