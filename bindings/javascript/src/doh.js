// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

/** ContentType matching the Idris2 ABI tags. */
export const ContentType = Object.freeze({
  DNS_MESSAGE: 0,
  DNS_JSON: 1,
});

/** RequestMethod matching the Idris2 ABI tags. */
export const RequestMethod = Object.freeze({
  GET: 0,
  POST: 1,
});

/** WireFormat matching the Idris2 ABI tags. */
export const WireFormat = Object.freeze({
  BINARY: 0,
  JSON: 1,
});

/** ErrorReason matching the Idris2 ABI tags. */
export const ErrorReason = Object.freeze({
  BAD_CONTENT_TYPE: 0,
  BAD_METHOD: 1,
  PAYLOAD_TOO_LARGE: 2,
  UPSTREAM_TIMEOUT: 3,
  UPSTREAM_ERROR: 4,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  BOUND: 1,
  SERVING: 2,
  RESOLVING: 3,
  SHUTDOWN: 4,
});
