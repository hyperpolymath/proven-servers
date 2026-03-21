// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenBfd protocol bindings.

open ProvenBfd

let test_bfdState_roundtrip = () => {
  assert(bfdStateFromTag(0) == Some(AdminDown))
  assert(bfdStateFromTag(1) == Some(Down))
  assert(bfdStateFromTag(2) == Some(Init))
  assert(bfdStateFromTag(3) == Some(Up))
  assert(bfdStateFromTag(4) == None)
}

let test_bfdState_toTag = () => {
  assert(bfdStateToTag(AdminDown) == 0)
  assert(bfdStateToTag(Down) == 1)
  assert(bfdStateToTag(Init) == 2)
  assert(bfdStateToTag(Up) == 3)
}

let test_diagnostic_roundtrip = () => {
  assert(diagnosticFromTag(0) == Some(NoDiagnostic))
  assert(diagnosticFromTag(1) == Some(ControlDetectionTimeExpired))
  assert(diagnosticFromTag(2) == Some(EchoFunctionFailed))
  assert(diagnosticFromTag(3) == Some(NeighborSignaledSessionDown))
  assert(diagnosticFromTag(4) == Some(ForwardingPlaneReset))
  assert(diagnosticFromTag(5) == Some(PathDown))
  assert(diagnosticFromTag(6) == Some(ConcatenatedPathDown))
  assert(diagnosticFromTag(7) == Some(AdministrativelyDown))
  assert(diagnosticFromTag(8) == Some(ReverseConcatenatedPathDown))
  assert(diagnosticFromTag(9) == None)
}

let test_diagnostic_toTag = () => {
  assert(diagnosticToTag(NoDiagnostic) == 0)
  assert(diagnosticToTag(ControlDetectionTimeExpired) == 1)
  assert(diagnosticToTag(EchoFunctionFailed) == 2)
  assert(diagnosticToTag(NeighborSignaledSessionDown) == 3)
  assert(diagnosticToTag(ForwardingPlaneReset) == 4)
  assert(diagnosticToTag(PathDown) == 5)
  assert(diagnosticToTag(ConcatenatedPathDown) == 6)
  assert(diagnosticToTag(AdministrativelyDown) == 7)
  assert(diagnosticToTag(ReverseConcatenatedPathDown) == 8)
}

let test_sessionMode_roundtrip = () => {
  assert(sessionModeFromTag(0) == Some(AsyncMode))
  assert(sessionModeFromTag(1) == Some(DemandMode))
  assert(sessionModeFromTag(2) == None)
}

let test_sessionMode_toTag = () => {
  assert(sessionModeToTag(AsyncMode) == 0)
  assert(sessionModeToTag(DemandMode) == 1)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(SsDown))
  assert(sessionStateFromTag(2) == Some(Negotiating))
  assert(sessionStateFromTag(3) == Some(Established))
  assert(sessionStateFromTag(4) == Some(Teardown))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(SsDown) == 1)
  assert(sessionStateToTag(Negotiating) == 2)
  assert(sessionStateToTag(Established) == 3)
  assert(sessionStateToTag(Teardown) == 4)
}

// Run all tests
test_bfdState_roundtrip()
test_bfdState_toTag()
test_diagnostic_roundtrip()
test_diagnostic_toTag()
test_sessionMode_roundtrip()
test_sessionMode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
