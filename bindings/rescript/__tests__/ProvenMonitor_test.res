// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMonitor protocol bindings.

open ProvenMonitor

let test_checkType_roundtrip = () => {
  assert(checkTypeFromTag(0) == Some(Http))
  assert(checkTypeFromTag(1) == Some(Tcp))
  assert(checkTypeFromTag(2) == Some(Udp))
  assert(checkTypeFromTag(3) == Some(Icmp))
  assert(checkTypeFromTag(4) == Some(Dns))
  assert(checkTypeFromTag(5) == Some(Certificate))
  assert(checkTypeFromTag(6) == Some(Disk))
  assert(checkTypeFromTag(7) == Some(Cpu))
  assert(checkTypeFromTag(8) == Some(Memory))
  assert(checkTypeFromTag(9) == Some(Process))
  assert(checkTypeFromTag(10) == Some(Custom))
  assert(checkTypeFromTag(11) == None)
}

let test_checkType_toTag = () => {
  assert(checkTypeToTag(Http) == 0)
  assert(checkTypeToTag(Tcp) == 1)
  assert(checkTypeToTag(Udp) == 2)
  assert(checkTypeToTag(Icmp) == 3)
  assert(checkTypeToTag(Dns) == 4)
  assert(checkTypeToTag(Certificate) == 5)
  assert(checkTypeToTag(Disk) == 6)
  assert(checkTypeToTag(Cpu) == 7)
  assert(checkTypeToTag(Memory) == 8)
  assert(checkTypeToTag(Process) == 9)
  assert(checkTypeToTag(Custom) == 10)
}

let test_status_roundtrip = () => {
  assert(statusFromTag(0) == Some(Up))
  assert(statusFromTag(1) == Some(Down))
  assert(statusFromTag(2) == Some(Degraded))
  assert(statusFromTag(3) == Some(Unknown))
  assert(statusFromTag(4) == Some(Maintenance))
  assert(statusFromTag(5) == None)
}

let test_status_toTag = () => {
  assert(statusToTag(Up) == 0)
  assert(statusToTag(Down) == 1)
  assert(statusToTag(Degraded) == 2)
  assert(statusToTag(Unknown) == 3)
  assert(statusToTag(Maintenance) == 4)
}

let test_alertChannel_roundtrip = () => {
  assert(alertChannelFromTag(0) == Some(Email))
  assert(alertChannelFromTag(1) == Some(Sms))
  assert(alertChannelFromTag(2) == Some(Webhook))
  assert(alertChannelFromTag(3) == Some(Slack))
  assert(alertChannelFromTag(4) == Some(PagerDuty))
  assert(alertChannelFromTag(5) == None)
}

let test_alertChannel_toTag = () => {
  assert(alertChannelToTag(Email) == 0)
  assert(alertChannelToTag(Sms) == 1)
  assert(alertChannelToTag(Webhook) == 2)
  assert(alertChannelToTag(Slack) == 3)
  assert(alertChannelToTag(PagerDuty) == 4)
}

let test_severity_roundtrip = () => {
  assert(severityFromTag(0) == Some(Info))
  assert(severityFromTag(1) == Some(Warning))
  assert(severityFromTag(2) == Some(Error))
  assert(severityFromTag(3) == Some(Critical))
  assert(severityFromTag(4) == None)
}

let test_severity_toTag = () => {
  assert(severityToTag(Info) == 0)
  assert(severityToTag(Warning) == 1)
  assert(severityToTag(Error) == 2)
  assert(severityToTag(Critical) == 3)
}

let test_checkState_roundtrip = () => {
  assert(checkStateFromTag(0) == Some(Pending))
  assert(checkStateFromTag(1) == Some(Running))
  assert(checkStateFromTag(2) == Some(Passed))
  assert(checkStateFromTag(3) == Some(Failed))
  assert(checkStateFromTag(4) == Some(Timeout))
  assert(checkStateFromTag(5) == Some(CsError))
  assert(checkStateFromTag(6) == None)
}

let test_checkState_toTag = () => {
  assert(checkStateToTag(Pending) == 0)
  assert(checkStateToTag(Running) == 1)
  assert(checkStateToTag(Passed) == 2)
  assert(checkStateToTag(Failed) == 3)
  assert(checkStateToTag(Timeout) == 4)
  assert(checkStateToTag(CsError) == 5)
}

let test_monitorState_roundtrip = () => {
  assert(monitorStateFromTag(0) == Some(Idle))
  assert(monitorStateFromTag(1) == Some(Configured))
  assert(monitorStateFromTag(2) == Some(Running))
  assert(monitorStateFromTag(3) == Some(MonPaused))
  assert(monitorStateFromTag(4) == Some(Alerting))
  assert(monitorStateFromTag(5) == Some(Shutdown))
  assert(monitorStateFromTag(6) == None)
}

let test_monitorState_toTag = () => {
  assert(monitorStateToTag(Idle) == 0)
  assert(monitorStateToTag(Configured) == 1)
  assert(monitorStateToTag(Running) == 2)
  assert(monitorStateToTag(MonPaused) == 3)
  assert(monitorStateToTag(Alerting) == 4)
  assert(monitorStateToTag(Shutdown) == 5)
}

// Run all tests
test_checkType_roundtrip()
test_checkType_toTag()
test_status_roundtrip()
test_status_toTag()
test_alertChannel_roundtrip()
test_alertChannel_toTag()
test_severity_roundtrip()
test_severity_toTag()
test_checkState_roundtrip()
test_checkState_toTag()
test_monitorState_roundtrip()
test_monitorState_toTag()
