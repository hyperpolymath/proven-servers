// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

/** DecoyType matching the Idris2 ABI tags. */
export const DecoyType = Object.freeze({
  SERVICE: 0,
  CREDENTIAL: 1,
  FILE: 2,
  NETWORK: 3,
  TOKEN: 4,
  BREADCRUMB: 5,
});

/** TriggerEvent matching the Idris2 ABI tags. */
export const TriggerEvent = Object.freeze({
  ACCESS: 0,
  LOGIN: 1,
  READ: 2,
  WRITE: 3,
  EXECUTE: 4,
  SCAN: 5,
});

/** AlertPriority matching the Idris2 ABI tags. */
export const AlertPriority = Object.freeze({
  LOW: 0,
  MEDIUM: 1,
  HIGH: 2,
  CRITICAL: 3,
});

/** DecoyState matching the Idris2 ABI tags. */
export const DecoyState = Object.freeze({
  ACTIVE: 0,
  TRIGGERED: 1,
  DISABLED: 2,
  EXPIRED: 3,
});

/** ResponseAction matching the Idris2 ABI tags. */
export const ResponseAction = Object.freeze({
  ALERT: 0,
  REDIRECT: 1,
  DELAY: 2,
  FINGERPRINT: 3,
  ISOLATE: 4,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  CONFIGURED: 1,
  MONITORING: 2,
  RESPONDING: 3,
  SHUTDOWN: 4,
});
