// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenHoneypot protocol bindings.

open ProvenHoneypot

let test_serviceEmulation_roundtrip = () => {
  assert(serviceEmulationFromTag(0) == Some(Ssh))
  assert(serviceEmulationFromTag(1) == Some(Http))
  assert(serviceEmulationFromTag(2) == Some(Ftp))
  assert(serviceEmulationFromTag(3) == Some(Smtp))
  assert(serviceEmulationFromTag(4) == Some(Telnet))
  assert(serviceEmulationFromTag(5) == Some(Mysql))
  assert(serviceEmulationFromTag(6) == Some(Rdp))
  assert(serviceEmulationFromTag(7) == None)
}

let test_serviceEmulation_toTag = () => {
  assert(serviceEmulationToTag(Ssh) == 0)
  assert(serviceEmulationToTag(Http) == 1)
  assert(serviceEmulationToTag(Ftp) == 2)
  assert(serviceEmulationToTag(Smtp) == 3)
  assert(serviceEmulationToTag(Telnet) == 4)
  assert(serviceEmulationToTag(Mysql) == 5)
  assert(serviceEmulationToTag(Rdp) == 6)
}

let test_interactionLevel_roundtrip = () => {
  assert(interactionLevelFromTag(0) == Some(Low))
  assert(interactionLevelFromTag(1) == Some(Medium))
  assert(interactionLevelFromTag(2) == Some(High))
  assert(interactionLevelFromTag(3) == None)
}

let test_interactionLevel_toTag = () => {
  assert(interactionLevelToTag(Low) == 0)
  assert(interactionLevelToTag(Medium) == 1)
  assert(interactionLevelToTag(High) == 2)
}

let test_honeypotAlertSeverity_roundtrip = () => {
  assert(honeypotAlertSeverityFromTag(0) == Some(Info))
  assert(honeypotAlertSeverityFromTag(1) == Some(AsLow))
  assert(honeypotAlertSeverityFromTag(2) == Some(AsMedium))
  assert(honeypotAlertSeverityFromTag(3) == Some(AsHigh))
  assert(honeypotAlertSeverityFromTag(4) == Some(Critical))
  assert(honeypotAlertSeverityFromTag(5) == None)
}

let test_honeypotAlertSeverity_toTag = () => {
  assert(honeypotAlertSeverityToTag(Info) == 0)
  assert(honeypotAlertSeverityToTag(AsLow) == 1)
  assert(honeypotAlertSeverityToTag(AsMedium) == 2)
  assert(honeypotAlertSeverityToTag(AsHigh) == 3)
  assert(honeypotAlertSeverityToTag(Critical) == 4)
}

let test_attackerAction_roundtrip = () => {
  assert(attackerActionFromTag(0) == Some(Scan))
  assert(attackerActionFromTag(1) == Some(BruteForce))
  assert(attackerActionFromTag(2) == Some(Exploit))
  assert(attackerActionFromTag(3) == Some(Payload))
  assert(attackerActionFromTag(4) == Some(Lateral))
  assert(attackerActionFromTag(5) == Some(Exfiltration))
  assert(attackerActionFromTag(6) == None)
}

let test_attackerAction_toTag = () => {
  assert(attackerActionToTag(Scan) == 0)
  assert(attackerActionToTag(BruteForce) == 1)
  assert(attackerActionToTag(Exploit) == 2)
  assert(attackerActionToTag(Payload) == 3)
  assert(attackerActionToTag(Lateral) == 4)
  assert(attackerActionToTag(Exfiltration) == 5)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Deployed))
  assert(serverStateFromTag(2) == Some(Engaged))
  assert(serverStateFromTag(3) == Some(Shutdown))
  assert(serverStateFromTag(4) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Deployed) == 1)
  assert(serverStateToTag(Engaged) == 2)
  assert(serverStateToTag(Shutdown) == 3)
}

// Run all tests
test_serviceEmulation_roundtrip()
test_serviceEmulation_toTag()
test_interactionLevel_roundtrip()
test_interactionLevel_toTag()
test_honeypotAlertSeverity_roundtrip()
test_honeypotAlertSeverity_toTag()
test_attackerAction_roundtrip()
test_attackerAction_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
