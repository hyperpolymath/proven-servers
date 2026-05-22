// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

/** AuthScheme matching the Idris2 ABI tags. */
export const AuthScheme = Object.freeze({
  API_KEY: 0,
  BEARER: 1,
  BASIC: 2,
  O_AUTH2: 3,
  HMAC: 4,
  MTLS: 5,
});

/** RateLimitStrategy matching the Idris2 ABI tags. */
export const RateLimitStrategy = Object.freeze({
  FIXED_WINDOW: 0,
  SLIDING_WINDOW: 1,
  TOKEN_BUCKET: 2,
  LEAKY_BUCKET: 3,
});

/** ApiVersion matching the Idris2 ABI tags. */
export const ApiVersion = Object.freeze({
  V1: 0,
  V2: 1,
  V3: 2,
  LATEST: 3,
  DEPRECATED: 4,
});

/** ResponseFormat matching the Idris2 ABI tags. */
export const ResponseFormat = Object.freeze({
  JSON: 0,
  XML: 1,
  PROTOBUF: 2,
  MESSAGE_PACK: 3,
});

/** GatewayError matching the Idris2 ABI tags. */
export const GatewayError = Object.freeze({
  UNAUTHORIZED: 0,
  RATE_LIMITED: 1,
  NOT_FOUND: 2,
  BAD_REQUEST: 3,
  SERVICE_UNAVAILABLE: 4,
  CIRCUIT_OPEN: 5,
});
