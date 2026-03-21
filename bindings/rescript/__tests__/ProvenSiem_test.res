// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSiem protocol bindings.

open ProvenSiem

let test_eventSeverity_roundtrip = () => {
  assert(eventSeverityFromTag(0) == Some(Info))
  assert(eventSeverityFromTag(1) == Some(Low))
  assert(eventSeverityFromTag(2) == Some(Medium))
  assert(eventSeverityFromTag(3) == Some(High))
  assert(eventSeverityFromTag(4) == Some(Critical))
  assert(eventSeverityFromTag(5) == None)
}

let test_eventSeverity_toTag = () => {
  assert(eventSeverityToTag(Info) == 0)
  assert(eventSeverityToTag(Low) == 1)
  assert(eventSeverityToTag(Medium) == 2)
  assert(eventSeverityToTag(High) == 3)
  assert(eventSeverityToTag(Critical) == 4)
}

let test_eventCategory_roundtrip = () => {
  assert(eventCategoryFromTag(0) == Some(Authentication))
  assert(eventCategoryFromTag(1) == Some(NetworkTraffic))
  assert(eventCategoryFromTag(2) == Some(FileActivity))
  assert(eventCategoryFromTag(3) == Some(ProcessExecution))
  assert(eventCategoryFromTag(4) == Some(PolicyViolation))
  assert(eventCategoryFromTag(5) == Some(Malware))
  assert(eventCategoryFromTag(6) == Some(DataExfiltration))
  assert(eventCategoryFromTag(7) == None)
}

let test_eventCategory_toTag = () => {
  assert(eventCategoryToTag(Authentication) == 0)
  assert(eventCategoryToTag(NetworkTraffic) == 1)
  assert(eventCategoryToTag(FileActivity) == 2)
  assert(eventCategoryToTag(ProcessExecution) == 3)
  assert(eventCategoryToTag(PolicyViolation) == 4)
  assert(eventCategoryToTag(Malware) == 5)
  assert(eventCategoryToTag(DataExfiltration) == 6)
}

let test_correlationRule_roundtrip = () => {
  assert(correlationRuleFromTag(0) == Some(Threshold))
  assert(correlationRuleFromTag(1) == Some(Sequence))
  assert(correlationRuleFromTag(2) == Some(Aggregation))
  assert(correlationRuleFromTag(3) == Some(Absence))
  assert(correlationRuleFromTag(4) == Some(Statistical))
  assert(correlationRuleFromTag(5) == None)
}

let test_correlationRule_toTag = () => {
  assert(correlationRuleToTag(Threshold) == 0)
  assert(correlationRuleToTag(Sequence) == 1)
  assert(correlationRuleToTag(Aggregation) == 2)
  assert(correlationRuleToTag(Absence) == 3)
  assert(correlationRuleToTag(Statistical) == 4)
}

let test_alertState_roundtrip = () => {
  assert(alertStateFromTag(0) == Some(New))
  assert(alertStateFromTag(1) == Some(Acknowledged))
  assert(alertStateFromTag(2) == Some(InProgress))
  assert(alertStateFromTag(3) == Some(Resolved))
  assert(alertStateFromTag(4) == Some(FalsePositive))
  assert(alertStateFromTag(5) == None)
}

let test_alertState_toTag = () => {
  assert(alertStateToTag(New) == 0)
  assert(alertStateToTag(Acknowledged) == 1)
  assert(alertStateToTag(InProgress) == 2)
  assert(alertStateToTag(Resolved) == 3)
  assert(alertStateToTag(FalsePositive) == 4)
}

// Run all tests
test_eventSeverity_roundtrip()
test_eventSeverity_toTag()
test_eventCategory_roundtrip()
test_eventCategory_toTag()
test_correlationRule_roundtrip()
test_correlationRule_toTag()
test_alertState_roundtrip()
test_alertState_toTag()
