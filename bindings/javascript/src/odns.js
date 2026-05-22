// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

/** Role matching the Idris2 ABI tags. */
export const Role = Object.freeze({
  CLIENT: 0,
  PROXY: 1,
  TARGET: 2,
});

/** OdnsMessageType matching the Idris2 ABI tags. */
export const OdnsMessageType = Object.freeze({
  QUERY: 0,
  RESPONSE: 1,
});

/** OdnsErrorReason matching the Idris2 ABI tags. */
export const OdnsErrorReason = Object.freeze({
  PROXY_ERROR: 0,
  TARGET_ERROR: 1,
  DECRYPTION_FAILED: 2,
  INVALID_CONFIG: 3,
  PAYLOAD_TOO_LARGE: 4,
});

/** EncapsulationFormat matching the Idris2 ABI tags. */
export const EncapsulationFormat = Object.freeze({
  HPKE: 0,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  KEY_EXCHANGE: 1,
  READY: 2,
  PROCESSING: 3,
  CLOSING: 4,
});
