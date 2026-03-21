// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCaldav protocol bindings.

open ProvenCaldav

let test_componentType_roundtrip = () => {
  assert(componentTypeFromTag(0) == Some(Vevent))
  assert(componentTypeFromTag(1) == Some(Vtodo))
  assert(componentTypeFromTag(2) == Some(Vjournal))
  assert(componentTypeFromTag(3) == Some(Vfreebusy))
  assert(componentTypeFromTag(4) == None)
}

let test_componentType_toTag = () => {
  assert(componentTypeToTag(Vevent) == 0)
  assert(componentTypeToTag(Vtodo) == 1)
  assert(componentTypeToTag(Vjournal) == 2)
  assert(componentTypeToTag(Vfreebusy) == 3)
}

let test_calMethod_roundtrip = () => {
  assert(calMethodFromTag(0) == Some(Get))
  assert(calMethodFromTag(1) == Some(Put))
  assert(calMethodFromTag(2) == Some(Delete))
  assert(calMethodFromTag(3) == Some(Propfind))
  assert(calMethodFromTag(4) == Some(Proppatch))
  assert(calMethodFromTag(5) == Some(Report))
  assert(calMethodFromTag(6) == Some(Mkcalendar))
  assert(calMethodFromTag(7) == None)
}

let test_calMethod_toTag = () => {
  assert(calMethodToTag(Get) == 0)
  assert(calMethodToTag(Put) == 1)
  assert(calMethodToTag(Delete) == 2)
  assert(calMethodToTag(Propfind) == 3)
  assert(calMethodToTag(Proppatch) == 4)
  assert(calMethodToTag(Report) == 5)
  assert(calMethodToTag(Mkcalendar) == 6)
}

let test_scheduleStatus_roundtrip = () => {
  assert(scheduleStatusFromTag(0) == Some(NeedsAction))
  assert(scheduleStatusFromTag(1) == Some(Accepted))
  assert(scheduleStatusFromTag(2) == Some(Declined))
  assert(scheduleStatusFromTag(3) == Some(Tentative))
  assert(scheduleStatusFromTag(4) == Some(Delegated))
  assert(scheduleStatusFromTag(5) == None)
}

let test_scheduleStatus_toTag = () => {
  assert(scheduleStatusToTag(NeedsAction) == 0)
  assert(scheduleStatusToTag(Accepted) == 1)
  assert(scheduleStatusToTag(Declined) == 2)
  assert(scheduleStatusToTag(Tentative) == 3)
  assert(scheduleStatusToTag(Delegated) == 4)
}

let test_calError_roundtrip = () => {
  assert(calErrorFromTag(0) == Some(ValidCalendarData))
  assert(calErrorFromTag(1) == Some(NoResourceTypeChange))
  assert(calErrorFromTag(2) == Some(SupportedComponentMismatch))
  assert(calErrorFromTag(3) == Some(MaxResourceSize))
  assert(calErrorFromTag(4) == Some(UidConflict))
  assert(calErrorFromTag(5) == Some(PreconditionFailed))
  assert(calErrorFromTag(6) == None)
}

let test_calError_toTag = () => {
  assert(calErrorToTag(ValidCalendarData) == 0)
  assert(calErrorToTag(NoResourceTypeChange) == 1)
  assert(calErrorToTag(SupportedComponentMismatch) == 2)
  assert(calErrorToTag(MaxResourceSize) == 3)
  assert(calErrorToTag(UidConflict) == 4)
  assert(calErrorToTag(PreconditionFailed) == 5)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Bound))
  assert(serverStateFromTag(2) == Some(Serving))
  assert(serverStateFromTag(3) == Some(Scheduling))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Bound) == 1)
  assert(serverStateToTag(Serving) == 2)
  assert(serverStateToTag(Scheduling) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_componentType_roundtrip()
test_componentType_toTag()
test_calMethod_roundtrip()
test_calMethod_toTag()
test_scheduleStatus_roundtrip()
test_scheduleStatus_toTag()
test_calError_roundtrip()
test_calError_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
