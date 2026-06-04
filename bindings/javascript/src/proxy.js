// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

/** ProxyMode matching the Idris2 ABI tags. */
export const ProxyMode = Object.freeze({
  FORWARD: 0,
  REVERSE: 1,
});

/** HopByHopHeader matching the Idris2 ABI tags. */
export const HopByHopHeader = Object.freeze({
  CONNECTION: 0,
  KEEP_ALIVE: 1,
  PROXY_AUTH: 2,
  PROXY_AUTHZ: 3,
  TE: 4,
  TRAILERS: 5,
  TRANSFER_ENCODING: 6,
  UPGRADE: 7,
});

/** CacheDirective matching the Idris2 ABI tags. */
export const CacheDirective = Object.freeze({
  NO_CACHE: 0,
  NO_STORE: 1,
  MAX_AGE: 2,
  PUBLIC: 3,
  PRIVATE: 4,
  MUST_REVALIDATE: 5,
});

/** ProxyError matching the Idris2 ABI tags. */
export const ProxyError = Object.freeze({
  BAD_GATEWAY: 0,
  GATEWAY_TIMEOUT: 1,
  UPSTREAM_REFUSED: 2,
  UPSTREAM_TLS: 3,
});
