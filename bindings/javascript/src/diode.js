// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

/** Direction matching the Idris2 ABI tags. */
export const Direction = Object.freeze({
  HIGH_TO_LOW: 0,
  LOW_TO_HIGH: 1,
});

/** DiodeProtocol matching the Idris2 ABI tags. */
export const DiodeProtocol = Object.freeze({
  UDP: 0,
  TCP: 1,
  FILE_TRANSFER: 2,
  SYSLOG: 3,
  SNMP: 4,
});

/** TransferState matching the Idris2 ABI tags. */
export const TransferState = Object.freeze({
  QUEUED: 0,
  SENDING: 1,
  CONFIRMING: 2,
  COMPLETE: 3,
  FAILED: 4,
});

/** ValidationResult matching the Idris2 ABI tags. */
export const ValidationResult = Object.freeze({
  PASSED: 0,
  FORMAT_ERROR: 1,
  SIZE_EXCEEDED: 2,
  POLICY_BLOCKED: 3,
});

/** IntegrityCheck matching the Idris2 ABI tags. */
export const IntegrityCheck = Object.freeze({
  CRC32: 0,
  SHA256: 1,
  HMAC: 2,
});

/** GatewayState matching the Idris2 ABI tags. */
export const GatewayState = Object.freeze({
  IDLE: 0,
  CONFIGURED: 1,
  TRANSFERRING: 2,
  VALIDATING: 3,
  SHUTDOWN: 4,
});
