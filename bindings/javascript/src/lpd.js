// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

/** CommandCode matching the Idris2 ABI tags. */
export const CommandCode = Object.freeze({
  PRINT_JOB: 1,
  RECEIVE_JOB: 2,
  SHORT_QUEUE: 3,
  LONG_QUEUE: 4,
  REMOVE_JOBS: 5,
});

/** SubCommandCode matching the Idris2 ABI tags. */
export const SubCommandCode = Object.freeze({
  ABORT_JOB: 1,
  CONTROL_FILE: 2,
  DATA_FILE: 3,
});

/** JobStatus matching the Idris2 ABI tags. */
export const JobStatus = Object.freeze({
  PENDING: 0,
  PRINTING: 1,
  COMPLETE: 2,
  FAILED: 3,
});
