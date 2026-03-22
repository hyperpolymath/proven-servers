// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

/** AlertSeverity matching the Idris2 ABI tags. */
export const AlertSeverity = Object.freeze({
  ALERT_SEVERITY_LOW: 0,
  ALERT_SEVERITY_MEDIUM: 1,
  ALERT_SEVERITY_HIGH: 2,
  ALERT_SEVERITY_CRITICAL: 3,
});

/** DetectionMethod matching the Idris2 ABI tags. */
export const DetectionMethod = Object.freeze({
  SIGNATURE: 0,
  ANOMALY: 1,
  STATEFUL: 2,
  HEURISTIC: 3,
});

/** IdsProtocol matching the Idris2 ABI tags. */
export const IdsProtocol = Object.freeze({
  TCP: 0,
  UDP: 1,
  ICMP: 2,
  DNS: 3,
  HTTP: 4,
  TLS: 5,
  SSH: 6,
});

/** IdsAction matching the Idris2 ABI tags. */
export const IdsAction = Object.freeze({
  ALERT: 0,
  DROP: 1,
  LOG: 2,
  BLOCK: 3,
  PASS: 4,
});

/** Direction matching the Idris2 ABI tags. */
export const Direction = Object.freeze({
  INBOUND: 0,
  OUTBOUND: 1,
  BOTH: 2,
});

/** ThreatLevel matching the Idris2 ABI tags. */
export const ThreatLevel = Object.freeze({
  INFO: 0,
  THREAT_LEVEL_LOW: 1,
  THREAT_LEVEL_MEDIUM: 2,
  THREAT_LEVEL_HIGH: 3,
  THREAT_LEVEL_CRITICAL: 4,
});
