// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV types for the proven-servers ABI.
//
// Mirrors the Idris2 module CaldavABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard CalDAV HTTPS port.
let caldavPort = 443

// ===========================================================================
// ComponentType (tags 0-3)
// ===========================================================================

/// Standard CalDAV HTTPS port.
type componentType =
  | @as(0) Vevent
  | @as(1) Vtodo
  | @as(2) Vjournal
  | @as(3) Vfreebusy

/// Decode from the C-ABI tag value.
let componentTypeFromTag = (tag: int): option<componentType> =>
  switch tag {
  | 0 => Some(Vevent)
  | 1 => Some(Vtodo)
  | 2 => Some(Vjournal)
  | 3 => Some(Vfreebusy)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let componentTypeToTag = (v: componentType): int =>
  switch v {
  | Vevent => 0
  | Vtodo => 1
  | Vjournal => 2
  | Vfreebusy => 3
  }

// ===========================================================================
// CalMethod (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type calMethod =
  | @as(0) Get
  | @as(1) Put
  | @as(2) Delete
  | @as(3) Propfind
  | @as(4) Proppatch
  | @as(5) Report
  | @as(6) Mkcalendar

/// Decode from the C-ABI tag value.
let calMethodFromTag = (tag: int): option<calMethod> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Put)
  | 2 => Some(Delete)
  | 3 => Some(Propfind)
  | 4 => Some(Proppatch)
  | 5 => Some(Report)
  | 6 => Some(Mkcalendar)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let calMethodToTag = (v: calMethod): int =>
  switch v {
  | Get => 0
  | Put => 1
  | Delete => 2
  | Propfind => 3
  | Proppatch => 4
  | Report => 5
  | Mkcalendar => 6
  }

// ===========================================================================
// ScheduleStatus (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type scheduleStatus =
  | @as(0) NeedsAction
  | @as(1) Accepted
  | @as(2) Declined
  | @as(3) Tentative
  | @as(4) Delegated

/// Decode from the C-ABI tag value.
let scheduleStatusFromTag = (tag: int): option<scheduleStatus> =>
  switch tag {
  | 0 => Some(NeedsAction)
  | 1 => Some(Accepted)
  | 2 => Some(Declined)
  | 3 => Some(Tentative)
  | 4 => Some(Delegated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let scheduleStatusToTag = (v: scheduleStatus): int =>
  switch v {
  | NeedsAction => 0
  | Accepted => 1
  | Declined => 2
  | Tentative => 3
  | Delegated => 4
  }

// ===========================================================================
// CalError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type calError =
  | @as(0) ValidCalendarData
  | @as(1) NoResourceTypeChange
  | @as(2) SupportedComponentMismatch
  | @as(3) MaxResourceSize
  | @as(4) UidConflict
  | @as(5) PreconditionFailed

/// Decode from the C-ABI tag value.
let calErrorFromTag = (tag: int): option<calError> =>
  switch tag {
  | 0 => Some(ValidCalendarData)
  | 1 => Some(NoResourceTypeChange)
  | 2 => Some(SupportedComponentMismatch)
  | 3 => Some(MaxResourceSize)
  | 4 => Some(UidConflict)
  | 5 => Some(PreconditionFailed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let calErrorToTag = (v: calError): int =>
  switch v {
  | ValidCalendarData => 0
  | NoResourceTypeChange => 1
  | SupportedComponentMismatch => 2
  | MaxResourceSize => 3
  | UidConflict => 4
  | PreconditionFailed => 5
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Bound
  | @as(2) Serving
  | @as(3) Scheduling
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Bound)
  | 2 => Some(Serving)
  | 3 => Some(Scheduling)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Bound => 1
  | Serving => 2
  | Scheduling => 3
  | Shutdown => 4
  }

