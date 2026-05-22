-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CalDAV Core Protocol Types (RFC 4791)
--
-- Defines calendar component types, request methods, scheduling states,
-- and error conditions as closed sum types with Show/Eq instances.
-- All constructors map to RFC 4791 and iCalendar (RFC 5545) sections.

module CalDAV.Types

%default total

-- ============================================================================
-- iCalendar Component Types (RFC 5545 Section 3.6)
-- ============================================================================

||| iCalendar component types supported by CalDAV.
public export
data ComponentType : Type where
  ||| VEVENT: calendar event with start/end time.
  VEvent    : ComponentType
  ||| VTODO: to-do item with optional due date.
  VTodo     : ComponentType
  ||| VJOURNAL: journal entry (no scheduling).
  VJournal  : ComponentType
  ||| VFREEBUSY: free/busy time information.
  VFreeBusy : ComponentType

public export
Eq ComponentType where
  VEvent    == VEvent    = True
  VTodo     == VTodo     = True
  VJournal  == VJournal  = True
  VFreeBusy == VFreeBusy = True
  _         == _         = False

public export
Show ComponentType where
  show VEvent    = "VEVENT"
  show VTodo     = "VTODO"
  show VJournal  = "VJOURNAL"
  show VFreeBusy = "VFREEBUSY"

-- ============================================================================
-- CalDAV Request Methods (RFC 4791 Section 5)
-- ============================================================================

||| CalDAV/WebDAV methods relevant to calendar operations.
public export
data CalMethod : Type where
  ||| GET: retrieve a calendar resource.
  CalGet       : CalMethod
  ||| PUT: create or update a calendar resource.
  CalPut       : CalMethod
  ||| DELETE: remove a calendar resource.
  CalDelete    : CalMethod
  ||| PROPFIND: retrieve properties of a resource.
  CalPropfind  : CalMethod
  ||| PROPPATCH: modify properties of a resource.
  CalProppatch : CalMethod
  ||| REPORT: execute a CalDAV report (e.g., calendar-query).
  CalReport    : CalMethod
  ||| MKCALENDAR: create a new calendar collection (RFC 4791 Section 5.3.1).
  CalMkcalendar : CalMethod

public export
Eq CalMethod where
  CalGet        == CalGet        = True
  CalPut        == CalPut        = True
  CalDelete     == CalDelete     = True
  CalPropfind   == CalPropfind   = True
  CalProppatch  == CalProppatch  = True
  CalReport     == CalReport     = True
  CalMkcalendar == CalMkcalendar = True
  _             == _             = False

public export
Show CalMethod where
  show CalGet        = "GET"
  show CalPut        = "PUT"
  show CalDelete     = "DELETE"
  show CalPropfind   = "PROPFIND"
  show CalProppatch  = "PROPPATCH"
  show CalReport     = "REPORT"
  show CalMkcalendar = "MKCALENDAR"

-- ============================================================================
-- Scheduling Status (RFC 6638)
-- ============================================================================

||| CalDAV scheduling status for attendee responses.
public export
data ScheduleStatus : Type where
  ||| Needs action: no response yet.
  NeedsAction : ScheduleStatus
  ||| Accepted: attendee accepted the invitation.
  Accepted    : ScheduleStatus
  ||| Declined: attendee declined the invitation.
  Declined    : ScheduleStatus
  ||| Tentative: attendee tentatively accepted.
  Tentative   : ScheduleStatus
  ||| Delegated: attendee delegated to another.
  Delegated   : ScheduleStatus

public export
Eq ScheduleStatus where
  NeedsAction == NeedsAction = True
  Accepted    == Accepted    = True
  Declined    == Declined    = True
  Tentative   == Tentative   = True
  Delegated   == Delegated   = True
  _           == _           = False

public export
Show ScheduleStatus where
  show NeedsAction = "NEEDS-ACTION"
  show Accepted    = "ACCEPTED"
  show Declined    = "DECLINED"
  show Tentative   = "TENTATIVE"
  show Delegated   = "DELEGATED"

-- ============================================================================
-- CalDAV Error Conditions (RFC 4791 Section 5.3)
-- ============================================================================

||| CalDAV-specific error conditions.
public export
data CalError : Type where
  ||| Valid calendar data required but not provided.
  ValidCalendarData          : CalError
  ||| Calendar collection cannot contain another collection.
  NoResourceTypeChange       : CalError
  ||| Supported component type mismatch.
  SupportedComponentMismatch : CalError
  ||| Maximum resource size exceeded.
  MaxResourceSize            : CalError
  ||| UID conflict (duplicate UID in collection).
  UIDConflict                : CalError
  ||| Precondition failed (If-Match / If-None-Match).
  PreconditionFailed         : CalError

public export
Eq CalError where
  ValidCalendarData          == ValidCalendarData          = True
  NoResourceTypeChange       == NoResourceTypeChange       = True
  SupportedComponentMismatch == SupportedComponentMismatch = True
  MaxResourceSize            == MaxResourceSize            = True
  UIDConflict                == UIDConflict                = True
  PreconditionFailed         == PreconditionFailed         = True
  _                          == _                          = False

public export
Show CalError where
  show ValidCalendarData          = "valid-calendar-data"
  show NoResourceTypeChange       = "no-resource-type-change"
  show SupportedComponentMismatch = "supported-component-mismatch"
  show MaxResourceSize            = "max-resource-size"
  show UIDConflict                = "uid-conflict"
  show PreconditionFailed         = "precondition-failed"
