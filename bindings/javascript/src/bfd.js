// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

/** BfdState matching the Idris2 ABI tags. */
export const BfdState = Object.freeze({
  ADMIN_DOWN: 0,
  DOWN: 1,
  INIT: 2,
  UP: 3,
});

/** Diagnostic matching the Idris2 ABI tags. */
export const Diagnostic = Object.freeze({
  NO_DIAGNOSTIC: 0,
  CONTROL_DETECTION_TIME_EXPIRED: 1,
  ECHO_FUNCTION_FAILED: 2,
  NEIGHBOR_SIGNALED_SESSION_DOWN: 3,
  FORWARDING_PLANE_RESET: 4,
  PATH_DOWN: 5,
  CONCATENATED_PATH_DOWN: 6,
  ADMINISTRATIVELY_DOWN: 7,
  REVERSE_CONCATENATED_PATH_DOWN: 8,
});

/** SessionMode matching the Idris2 ABI tags. */
export const SessionMode = Object.freeze({
  ASYNC_MODE: 0,
  DEMAND_MODE: 1,
});

/** SessionState matching the Idris2 ABI tags. */
export const SessionState = Object.freeze({
  IDLE: 0,
  SS_DOWN: 1,
  NEGOTIATING: 2,
  ESTABLISHED: 3,
  TEARDOWN: 4,
});
