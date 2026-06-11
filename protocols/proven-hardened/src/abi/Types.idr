-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
module HardenedABI.Types
import Hardened.Types
%default total

public export
hardeningLevelToTag : HardeningLevel -> Bits8
hardeningLevelToTag Minimal  = 0
hardeningLevelToTag Standard = 1
hardeningLevelToTag High     = 2
hardeningLevelToTag Maximum  = 3

public export
tagToHardeningLevel : Bits8 -> Maybe HardeningLevel
tagToHardeningLevel 0 = Just Minimal
tagToHardeningLevel 1 = Just Standard
tagToHardeningLevel 2 = Just High
tagToHardeningLevel 3 = Just Maximum
tagToHardeningLevel _ = Nothing

public export
hardeningLevelRoundtrip : (h : HardeningLevel) -> tagToHardeningLevel (hardeningLevelToTag h) = Just h
hardeningLevelRoundtrip Minimal  = Refl
hardeningLevelRoundtrip Standard = Refl
hardeningLevelRoundtrip High     = Refl
hardeningLevelRoundtrip Maximum  = Refl

public export
securityControlToTag : SecurityControl -> Bits8
securityControlToTag ASLR        = 0
securityControlToTag DEP         = 1
securityControlToTag StackCanary = 2
securityControlToTag CFI         = 3
securityControlToTag Sandboxing  = 4
securityControlToTag SecureBoot  = 5
securityControlToTag AuditLog    = 6

public export
tagToSecurityControl : Bits8 -> Maybe SecurityControl
tagToSecurityControl 0 = Just ASLR
tagToSecurityControl 1 = Just DEP
tagToSecurityControl 2 = Just StackCanary
tagToSecurityControl 3 = Just CFI
tagToSecurityControl 4 = Just Sandboxing
tagToSecurityControl 5 = Just SecureBoot
tagToSecurityControl 6 = Just AuditLog
tagToSecurityControl _ = Nothing

public export
securityControlRoundtrip : (s : SecurityControl) -> tagToSecurityControl (securityControlToTag s) = Just s
securityControlRoundtrip ASLR        = Refl
securityControlRoundtrip DEP         = Refl
securityControlRoundtrip StackCanary = Refl
securityControlRoundtrip CFI         = Refl
securityControlRoundtrip Sandboxing  = Refl
securityControlRoundtrip SecureBoot  = Refl
securityControlRoundtrip AuditLog    = Refl

public export
complianceStandardToTag : ComplianceStandard -> Bits8
complianceStandardToTag CIS       = 0
complianceStandardToTag STIG      = 1
complianceStandardToTag NIST80053 = 2
complianceStandardToTag PCI_DSS   = 3
complianceStandardToTag FIPS140   = 4

public export
tagToComplianceStandard : Bits8 -> Maybe ComplianceStandard
tagToComplianceStandard 0 = Just CIS
tagToComplianceStandard 1 = Just STIG
tagToComplianceStandard 2 = Just NIST80053
tagToComplianceStandard 3 = Just PCI_DSS
tagToComplianceStandard 4 = Just FIPS140
tagToComplianceStandard _ = Nothing

public export
complianceStandardRoundtrip : (c : ComplianceStandard) -> tagToComplianceStandard (complianceStandardToTag c) = Just c
complianceStandardRoundtrip CIS       = Refl
complianceStandardRoundtrip STIG      = Refl
complianceStandardRoundtrip NIST80053 = Refl
complianceStandardRoundtrip PCI_DSS   = Refl
complianceStandardRoundtrip FIPS140   = Refl

public export
auditEventToTag : AuditEvent -> Bits8
auditEventToTag ProcessStart        = 0
auditEventToTag FileAccess          = 1
auditEventToTag NetworkConn         = 2
auditEventToTag PrivilegeEscalation = 3
auditEventToTag ConfigChange        = 4
auditEventToTag AuthAttempt         = 5

public export
tagToAuditEvent : Bits8 -> Maybe AuditEvent
tagToAuditEvent 0 = Just ProcessStart
tagToAuditEvent 1 = Just FileAccess
tagToAuditEvent 2 = Just NetworkConn
tagToAuditEvent 3 = Just PrivilegeEscalation
tagToAuditEvent 4 = Just ConfigChange
tagToAuditEvent 5 = Just AuthAttempt
tagToAuditEvent _ = Nothing

public export
auditEventRoundtrip : (a : AuditEvent) -> tagToAuditEvent (auditEventToTag a) = Just a
auditEventRoundtrip ProcessStart        = Refl
auditEventRoundtrip FileAccess          = Refl
auditEventRoundtrip NetworkConn         = Refl
auditEventRoundtrip PrivilegeEscalation = Refl
auditEventRoundtrip ConfigChange        = Refl
auditEventRoundtrip AuthAttempt         = Refl

public export
healthStatusToTag : HealthStatus -> Bits8
healthStatusToTag Healthy      = 0
healthStatusToTag Degraded     = 1
healthStatusToTag Compromised  = 2
healthStatusToTag Unresponsive = 3

public export
tagToHealthStatus : Bits8 -> Maybe HealthStatus
tagToHealthStatus 0 = Just Healthy
tagToHealthStatus 1 = Just Degraded
tagToHealthStatus 2 = Just Compromised
tagToHealthStatus 3 = Just Unresponsive
tagToHealthStatus _ = Nothing

public export
healthStatusRoundtrip : (h : HealthStatus) -> tagToHealthStatus (healthStatusToTag h) = Just h
healthStatusRoundtrip Healthy      = Refl
healthStatusRoundtrip Degraded     = Refl
healthStatusRoundtrip Compromised  = Refl
healthStatusRoundtrip Unresponsive = Refl

public export
data ServerState : Type where
  HSIdle : ServerState
  HSHardening : ServerState
  HSActive : ServerState
  HSAuditing : ServerState
  HSShutdown : ServerState

public export
Eq ServerState where
  HSIdle == HSIdle = True; HSHardening == HSHardening = True; HSActive == HSActive = True
  HSAuditing == HSAuditing = True; HSShutdown == HSShutdown = True; _ == _ = False

public export
Show ServerState where
  show HSIdle = "Idle"; show HSHardening = "Hardening"; show HSActive = "Active"
  show HSAuditing = "Auditing"; show HSShutdown = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag HSIdle = 0; serverStateToTag HSHardening = 1; serverStateToTag HSActive = 2
serverStateToTag HSAuditing = 3; serverStateToTag HSShutdown = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just HSIdle; tagToServerState 1 = Just HSHardening
tagToServerState 2 = Just HSActive; tagToServerState 3 = Just HSAuditing
tagToServerState 4 = Just HSShutdown; tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip HSIdle = Refl; serverStateRoundtrip HSHardening = Refl
serverStateRoundtrip HSActive = Refl; serverStateRoundtrip HSAuditing = Refl
serverStateRoundtrip HSShutdown = Refl
