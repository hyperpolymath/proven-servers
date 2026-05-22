// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

/** LeapIndicator matching the Idris2 ABI tags. */
export const LeapIndicator = Object.freeze({
  NO_WARNING: 0,
  LAST_MINUTE61: 1,
  LAST_MINUTE59: 2,
  UNSYNCHRONISED: 3,
});

/** NtpMode matching the Idris2 ABI tags. */
export const NtpMode = Object.freeze({
  RESERVED: 0,
  SYMMETRIC_ACTIVE: 1,
  SYMMETRIC_PASSIVE: 2,
  CLIENT: 3,
  SERVER: 4,
  BROADCAST: 5,
  CONTROL_MESSAGE: 6,
  PRIVATE: 7,
});

/** ExchangeState matching the Idris2 ABI tags. */
export const ExchangeState = Object.freeze({
  IDLE: 0,
  REQUEST_RECEIVED: 1,
  TIMESTAMP_CALCULATED: 2,
  RESPONSE_SENT: 3,
});

/** ClockDisciplineState matching the Idris2 ABI tags. */
export const ClockDisciplineState = Object.freeze({
  UNSET: 0,
  SPIKE: 1,
  FREQ: 2,
  SYNC: 3,
  PANIC: 4,
});

/** KissCode matching the Idris2 ABI tags. */
export const KissCode = Object.freeze({
  DENY: 0,
  RSTR: 1,
  RATE: 2,
  OTHER: 3,
});

/** NtpError matching the Idris2 ABI tags. */
export const NtpError = Object.freeze({
  OK: 0,
  INVALID_SLOT: 1,
  NOT_ACTIVE: 2,
  INVALID_PACKET: 3,
  KISS_OF_DEATH: 4,
  STRATUM_TOO_HIGH: 5,
});
