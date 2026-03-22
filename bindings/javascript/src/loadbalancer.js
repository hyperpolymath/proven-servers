// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

/** Algorithm matching the Idris2 ABI tags. */
export const Algorithm = Object.freeze({
  ROUND_ROBIN: 0,
  LEAST_CONNECTIONS: 1,
  IP_HASH: 2,
  RANDOM: 3,
  WEIGHTED_ROUND_ROBIN: 4,
  LEAST_RESPONSE_TIME: 5,
});

/** HealthCheckType matching the Idris2 ABI tags. */
export const HealthCheckType = Object.freeze({
  HEALTH_CHECK_TYPE_HTTP: 0,
  HEALTH_CHECK_TYPE_TCP: 1,
  HEALTH_CHECK_TYPE_GRPC: 2,
  SCRIPT: 3,
});

/** BackendState matching the Idris2 ABI tags. */
export const BackendState = Object.freeze({
  HEALTHY: 0,
  UNHEALTHY: 1,
  DRAINING: 2,
  DISABLED: 3,
});

/** SessionPersistence matching the Idris2 ABI tags. */
export const SessionPersistence = Object.freeze({
  NONE: 0,
  COOKIE: 1,
  SOURCE_IP: 2,
  HEADER: 3,
});

/** LbProtocol matching the Idris2 ABI tags. */
export const LbProtocol = Object.freeze({
  LB_PROTOCOL_HTTP: 0,
  HTTPS: 1,
  LB_PROTOCOL_TCP: 2,
  UDP: 3,
  LB_PROTOCOL_GRPC: 4,
});
