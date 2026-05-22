// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDeception protocol bindings.

open ProvenDeception

let test_decoyType_roundtrip = () => {
  assert(decoyTypeFromTag(0) == Some(Service))
  assert(decoyTypeFromTag(1) == Some(Credential))
  assert(decoyTypeFromTag(2) == Some(File))
  assert(decoyTypeFromTag(3) == Some(Network))
  assert(decoyTypeFromTag(4) == Some(Token))
  assert(decoyTypeFromTag(5) == Some(Breadcrumb))
  assert(decoyTypeFromTag(6) == None)
}

let test_decoyType_toTag = () => {
  assert(decoyTypeToTag(Service) == 0)
  assert(decoyTypeToTag(Credential) == 1)
  assert(decoyTypeToTag(File) == 2)
  assert(decoyTypeToTag(Network) == 3)
  assert(decoyTypeToTag(Token) == 4)
  assert(decoyTypeToTag(Breadcrumb) == 5)
}

let test_triggerEvent_roundtrip = () => {
  assert(triggerEventFromTag(0) == Some(Access))
  assert(triggerEventFromTag(1) == Some(Login))
  assert(triggerEventFromTag(2) == Some(Read))
  assert(triggerEventFromTag(3) == Some(Write))
  assert(triggerEventFromTag(4) == Some(Execute))
  assert(triggerEventFromTag(5) == Some(Scan))
  assert(triggerEventFromTag(6) == None)
}

let test_triggerEvent_toTag = () => {
  assert(triggerEventToTag(Access) == 0)
  assert(triggerEventToTag(Login) == 1)
  assert(triggerEventToTag(Read) == 2)
  assert(triggerEventToTag(Write) == 3)
  assert(triggerEventToTag(Execute) == 4)
  assert(triggerEventToTag(Scan) == 5)
}

let test_alertPriority_roundtrip = () => {
  assert(alertPriorityFromTag(0) == Some(Low))
  assert(alertPriorityFromTag(1) == Some(Medium))
  assert(alertPriorityFromTag(2) == Some(High))
  assert(alertPriorityFromTag(3) == Some(Critical))
  assert(alertPriorityFromTag(4) == None)
}

let test_alertPriority_toTag = () => {
  assert(alertPriorityToTag(Low) == 0)
  assert(alertPriorityToTag(Medium) == 1)
  assert(alertPriorityToTag(High) == 2)
  assert(alertPriorityToTag(Critical) == 3)
}

let test_decoyState_roundtrip = () => {
  assert(decoyStateFromTag(0) == Some(Active))
  assert(decoyStateFromTag(1) == Some(Triggered))
  assert(decoyStateFromTag(2) == Some(Disabled))
  assert(decoyStateFromTag(3) == Some(Expired))
  assert(decoyStateFromTag(4) == None)
}

let test_decoyState_toTag = () => {
  assert(decoyStateToTag(Active) == 0)
  assert(decoyStateToTag(Triggered) == 1)
  assert(decoyStateToTag(Disabled) == 2)
  assert(decoyStateToTag(Expired) == 3)
}

let test_responseAction_roundtrip = () => {
  assert(responseActionFromTag(0) == Some(Alert))
  assert(responseActionFromTag(1) == Some(Redirect))
  assert(responseActionFromTag(2) == Some(Delay))
  assert(responseActionFromTag(3) == Some(Fingerprint))
  assert(responseActionFromTag(4) == Some(Isolate))
  assert(responseActionFromTag(5) == None)
}

let test_responseAction_toTag = () => {
  assert(responseActionToTag(Alert) == 0)
  assert(responseActionToTag(Redirect) == 1)
  assert(responseActionToTag(Delay) == 2)
  assert(responseActionToTag(Fingerprint) == 3)
  assert(responseActionToTag(Isolate) == 4)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Configured))
  assert(serverStateFromTag(2) == Some(Monitoring))
  assert(serverStateFromTag(3) == Some(Responding))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Configured) == 1)
  assert(serverStateToTag(Monitoring) == 2)
  assert(serverStateToTag(Responding) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_decoyType_roundtrip()
test_decoyType_toTag()
test_triggerEvent_roundtrip()
test_triggerEvent_toTag()
test_alertPriority_roundtrip()
test_alertPriority_toTag()
test_decoyState_roundtrip()
test_decoyState_toTag()
test_responseAction_roundtrip()
test_responseAction_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
