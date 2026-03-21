// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenHardened protocol bindings.

open ProvenHardened

let test_hardeningLevel_roundtrip = () => {
  assert(hardeningLevelFromTag(0) == Some(Minimal))
  assert(hardeningLevelFromTag(1) == Some(Standard))
  assert(hardeningLevelFromTag(2) == Some(High))
  assert(hardeningLevelFromTag(3) == Some(Maximum))
  assert(hardeningLevelFromTag(4) == None)
}

let test_hardeningLevel_toTag = () => {
  assert(hardeningLevelToTag(Minimal) == 0)
  assert(hardeningLevelToTag(Standard) == 1)
  assert(hardeningLevelToTag(High) == 2)
  assert(hardeningLevelToTag(Maximum) == 3)
}

let test_securityControl_roundtrip = () => {
  assert(securityControlFromTag(0) == Some(Aslr))
  assert(securityControlFromTag(1) == Some(Dep))
  assert(securityControlFromTag(2) == Some(StackCanary))
  assert(securityControlFromTag(3) == Some(Cfi))
  assert(securityControlFromTag(4) == Some(Sandboxing))
  assert(securityControlFromTag(5) == Some(SecureBoot))
  assert(securityControlFromTag(6) == Some(AuditLog))
  assert(securityControlFromTag(7) == None)
}

let test_securityControl_toTag = () => {
  assert(securityControlToTag(Aslr) == 0)
  assert(securityControlToTag(Dep) == 1)
  assert(securityControlToTag(StackCanary) == 2)
  assert(securityControlToTag(Cfi) == 3)
  assert(securityControlToTag(Sandboxing) == 4)
  assert(securityControlToTag(SecureBoot) == 5)
  assert(securityControlToTag(AuditLog) == 6)
}

let test_complianceStandard_roundtrip = () => {
  assert(complianceStandardFromTag(0) == Some(Cis))
  assert(complianceStandardFromTag(1) == Some(Stig))
  assert(complianceStandardFromTag(2) == Some(Nist80053))
  assert(complianceStandardFromTag(3) == Some(PciDss))
  assert(complianceStandardFromTag(4) == Some(Fips140))
  assert(complianceStandardFromTag(5) == None)
}

let test_complianceStandard_toTag = () => {
  assert(complianceStandardToTag(Cis) == 0)
  assert(complianceStandardToTag(Stig) == 1)
  assert(complianceStandardToTag(Nist80053) == 2)
  assert(complianceStandardToTag(PciDss) == 3)
  assert(complianceStandardToTag(Fips140) == 4)
}

let test_auditEvent_roundtrip = () => {
  assert(auditEventFromTag(0) == Some(ProcessStart))
  assert(auditEventFromTag(1) == Some(FileAccess))
  assert(auditEventFromTag(2) == Some(NetworkConn))
  assert(auditEventFromTag(3) == Some(PrivilegeEscalation))
  assert(auditEventFromTag(4) == Some(ConfigChange))
  assert(auditEventFromTag(5) == Some(AuthAttempt))
  assert(auditEventFromTag(6) == None)
}

let test_auditEvent_toTag = () => {
  assert(auditEventToTag(ProcessStart) == 0)
  assert(auditEventToTag(FileAccess) == 1)
  assert(auditEventToTag(NetworkConn) == 2)
  assert(auditEventToTag(PrivilegeEscalation) == 3)
  assert(auditEventToTag(ConfigChange) == 4)
  assert(auditEventToTag(AuthAttempt) == 5)
}

let test_hardenedHealthStatus_roundtrip = () => {
  assert(hardenedHealthStatusFromTag(0) == Some(Healthy))
  assert(hardenedHealthStatusFromTag(1) == Some(Degraded))
  assert(hardenedHealthStatusFromTag(2) == Some(Compromised))
  assert(hardenedHealthStatusFromTag(3) == Some(Unresponsive))
  assert(hardenedHealthStatusFromTag(4) == None)
}

let test_hardenedHealthStatus_toTag = () => {
  assert(hardenedHealthStatusToTag(Healthy) == 0)
  assert(hardenedHealthStatusToTag(Degraded) == 1)
  assert(hardenedHealthStatusToTag(Compromised) == 2)
  assert(hardenedHealthStatusToTag(Unresponsive) == 3)
}

let test_serverState_roundtrip = () => {
  assert(serverStateFromTag(0) == Some(Idle))
  assert(serverStateFromTag(1) == Some(Hardening))
  assert(serverStateFromTag(2) == Some(Active))
  assert(serverStateFromTag(3) == Some(Auditing))
  assert(serverStateFromTag(4) == Some(Shutdown))
  assert(serverStateFromTag(5) == None)
}

let test_serverState_toTag = () => {
  assert(serverStateToTag(Idle) == 0)
  assert(serverStateToTag(Hardening) == 1)
  assert(serverStateToTag(Active) == 2)
  assert(serverStateToTag(Auditing) == 3)
  assert(serverStateToTag(Shutdown) == 4)
}

// Run all tests
test_hardeningLevel_roundtrip()
test_hardeningLevel_toTag()
test_securityControl_roundtrip()
test_securityControl_toTag()
test_complianceStandard_roundtrip()
test_complianceStandard_toTag()
test_auditEvent_roundtrip()
test_auditEvent_toTag()
test_hardenedHealthStatus_roundtrip()
test_hardenedHealthStatus_toTag()
test_serverState_roundtrip()
test_serverState_toTag()
