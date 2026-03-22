// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

/** HardeningLevel matching the Idris2 ABI tags. */
export const HardeningLevel = Object.freeze({
  MINIMAL: 0,
  STANDARD: 1,
  HIGH: 2,
  MAXIMUM: 3,
});

/** SecurityControl matching the Idris2 ABI tags. */
export const SecurityControl = Object.freeze({
  ASLR: 0,
  DEP: 1,
  STACK_CANARY: 2,
  CFI: 3,
  SANDBOXING: 4,
  SECURE_BOOT: 5,
  AUDIT_LOG: 6,
});

/** ComplianceStandard matching the Idris2 ABI tags. */
export const ComplianceStandard = Object.freeze({
  CIS: 0,
  STIG: 1,
  NIST80053: 2,
  PCI_DSS: 3,
  FIPS140: 4,
});

/** AuditEvent matching the Idris2 ABI tags. */
export const AuditEvent = Object.freeze({
  PROCESS_START: 0,
  FILE_ACCESS: 1,
  NETWORK_CONN: 2,
  PRIVILEGE_ESCALATION: 3,
  CONFIG_CHANGE: 4,
  AUTH_ATTEMPT: 5,
});

/** HardenedHealthStatus matching the Idris2 ABI tags. */
export const HardenedHealthStatus = Object.freeze({
  HEALTHY: 0,
  DEGRADED: 1,
  COMPROMISED: 2,
  UNRESPONSIVE: 3,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  HARDENING: 1,
  ACTIVE: 2,
  AUDITING: 3,
  SHUTDOWN: 4,
});
