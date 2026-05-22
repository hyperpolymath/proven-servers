// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

/** ServiceEmulation matching the Idris2 ABI tags. */
export const ServiceEmulation = Object.freeze({
  SSH: 0,
  HTTP: 1,
  FTP: 2,
  SMTP: 3,
  TELNET: 4,
  MYSQL: 5,
  RDP: 6,
});

/** InteractionLevel matching the Idris2 ABI tags. */
export const InteractionLevel = Object.freeze({
  LOW: 0,
  MEDIUM: 1,
  HIGH: 2,
});

/** HoneypotAlertSeverity matching the Idris2 ABI tags. */
export const HoneypotAlertSeverity = Object.freeze({
  INFO: 0,
  AS_LOW: 1,
  AS_MEDIUM: 2,
  AS_HIGH: 3,
  CRITICAL: 4,
});

/** AttackerAction matching the Idris2 ABI tags. */
export const AttackerAction = Object.freeze({
  SCAN: 0,
  BRUTE_FORCE: 1,
  EXPLOIT: 2,
  PAYLOAD: 3,
  LATERAL: 4,
  EXFILTRATION: 5,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  DEPLOYED: 1,
  ENGAGED: 2,
  SHUTDOWN: 3,
});
