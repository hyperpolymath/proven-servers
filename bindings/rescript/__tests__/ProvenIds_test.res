// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenIds protocol bindings.

open ProvenIds

let test_alertSeverity_roundtrip = () => {
  assert(alertSeverityFromTag(0) == Some(Low))
  assert(alertSeverityFromTag(1) == Some(Medium))
  assert(alertSeverityFromTag(2) == Some(High))
  assert(alertSeverityFromTag(3) == Some(Critical))
  assert(alertSeverityFromTag(4) == None)
}

let test_alertSeverity_toTag = () => {
  assert(alertSeverityToTag(Low) == 0)
  assert(alertSeverityToTag(Medium) == 1)
  assert(alertSeverityToTag(High) == 2)
  assert(alertSeverityToTag(Critical) == 3)
}

let test_detectionMethod_roundtrip = () => {
  assert(detectionMethodFromTag(0) == Some(Signature))
  assert(detectionMethodFromTag(1) == Some(Anomaly))
  assert(detectionMethodFromTag(2) == Some(Stateful))
  assert(detectionMethodFromTag(3) == Some(Heuristic))
  assert(detectionMethodFromTag(4) == None)
}

let test_detectionMethod_toTag = () => {
  assert(detectionMethodToTag(Signature) == 0)
  assert(detectionMethodToTag(Anomaly) == 1)
  assert(detectionMethodToTag(Stateful) == 2)
  assert(detectionMethodToTag(Heuristic) == 3)
}

let test_idsProtocol_roundtrip = () => {
  assert(idsProtocolFromTag(0) == Some(Tcp))
  assert(idsProtocolFromTag(1) == Some(Udp))
  assert(idsProtocolFromTag(2) == Some(Icmp))
  assert(idsProtocolFromTag(3) == Some(Dns))
  assert(idsProtocolFromTag(4) == Some(Http))
  assert(idsProtocolFromTag(5) == Some(Tls))
  assert(idsProtocolFromTag(6) == Some(Ssh))
  assert(idsProtocolFromTag(7) == None)
}

let test_idsProtocol_toTag = () => {
  assert(idsProtocolToTag(Tcp) == 0)
  assert(idsProtocolToTag(Udp) == 1)
  assert(idsProtocolToTag(Icmp) == 2)
  assert(idsProtocolToTag(Dns) == 3)
  assert(idsProtocolToTag(Http) == 4)
  assert(idsProtocolToTag(Tls) == 5)
  assert(idsProtocolToTag(Ssh) == 6)
}

let test_idsAction_roundtrip = () => {
  assert(idsActionFromTag(0) == Some(Alert))
  assert(idsActionFromTag(1) == Some(Drop))
  assert(idsActionFromTag(2) == Some(Log))
  assert(idsActionFromTag(3) == Some(Block))
  assert(idsActionFromTag(4) == Some(Pass))
  assert(idsActionFromTag(5) == None)
}

let test_idsAction_toTag = () => {
  assert(idsActionToTag(Alert) == 0)
  assert(idsActionToTag(Drop) == 1)
  assert(idsActionToTag(Log) == 2)
  assert(idsActionToTag(Block) == 3)
  assert(idsActionToTag(Pass) == 4)
}

let test_direction_roundtrip = () => {
  assert(directionFromTag(0) == Some(Inbound))
  assert(directionFromTag(1) == Some(Outbound))
  assert(directionFromTag(2) == Some(Both))
  assert(directionFromTag(3) == None)
}

let test_direction_toTag = () => {
  assert(directionToTag(Inbound) == 0)
  assert(directionToTag(Outbound) == 1)
  assert(directionToTag(Both) == 2)
}

let test_threatLevel_roundtrip = () => {
  assert(threatLevelFromTag(0) == Some(Info))
  assert(threatLevelFromTag(1) == Some(Low))
  assert(threatLevelFromTag(2) == Some(Medium))
  assert(threatLevelFromTag(3) == Some(High))
  assert(threatLevelFromTag(4) == Some(Critical))
  assert(threatLevelFromTag(5) == None)
}

let test_threatLevel_toTag = () => {
  assert(threatLevelToTag(Info) == 0)
  assert(threatLevelToTag(Low) == 1)
  assert(threatLevelToTag(Medium) == 2)
  assert(threatLevelToTag(High) == 3)
  assert(threatLevelToTag(Critical) == 4)
}

// Run all tests
test_alertSeverity_roundtrip()
test_alertSeverity_toTag()
test_detectionMethod_roundtrip()
test_detectionMethod_toTag()
test_idsProtocol_roundtrip()
test_idsProtocol_toTag()
test_idsAction_roundtrip()
test_idsAction_toTag()
test_direction_roundtrip()
test_direction_toTag()
test_threatLevel_roundtrip()
test_threatLevel_toTag()
