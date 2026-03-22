// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

/** ComponentType matching the Idris2 ABI tags. */
export const ComponentType = Object.freeze({
  VEVENT: 0,
  VTODO: 1,
  VJOURNAL: 2,
  VFREEBUSY: 3,
});

/** CalMethod matching the Idris2 ABI tags. */
export const CalMethod = Object.freeze({
  GET: 0,
  PUT: 1,
  DELETE: 2,
  PROPFIND: 3,
  PROPPATCH: 4,
  REPORT: 5,
  MKCALENDAR: 6,
});

/** ScheduleStatus matching the Idris2 ABI tags. */
export const ScheduleStatus = Object.freeze({
  NEEDS_ACTION: 0,
  ACCEPTED: 1,
  DECLINED: 2,
  TENTATIVE: 3,
  DELEGATED: 4,
});

/** CalError matching the Idris2 ABI tags. */
export const CalError = Object.freeze({
  VALID_CALENDAR_DATA: 0,
  NO_RESOURCE_TYPE_CHANGE: 1,
  SUPPORTED_COMPONENT_MISMATCH: 2,
  MAX_RESOURCE_SIZE: 3,
  UID_CONFLICT: 4,
  PRECONDITION_FAILED: 5,
});

/** ServerState matching the Idris2 ABI tags. */
export const ServerState = Object.freeze({
  IDLE: 0,
  BOUND: 1,
  SERVING: 2,
  SCHEDULING: 3,
  SHUTDOWN: 4,
});
