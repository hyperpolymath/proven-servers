// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module HardenedABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// HardeningLevel (tags 0-3)
// ===========================================================================

/// System hardening levels.
type hardeningLevel =
  | @as(0) Minimal
  | @as(1) Standard
  | @as(2) High
  | @as(3) Maximum

/// Decode from the C-ABI tag value.
let hardeningLevelFromTag = (tag: int): option<hardeningLevel> =>
  switch tag {
  | 0 => Some(Minimal)
  | 1 => Some(Standard)
  | 2 => Some(High)
  | 3 => Some(Maximum)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hardeningLevelToTag = (v: hardeningLevel): int =>
  switch v {
  | Minimal => 0
  | Standard => 1
  | High => 2
  | Maximum => 3
  }

// ===========================================================================
// SecurityControl (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type securityControl =
  | @as(0) Aslr
  | @as(1) Dep
  | @as(2) StackCanary
  | @as(3) Cfi
  | @as(4) Sandboxing
  | @as(5) SecureBoot
  | @as(6) AuditLog

/// Decode from the C-ABI tag value.
let securityControlFromTag = (tag: int): option<securityControl> =>
  switch tag {
  | 0 => Some(Aslr)
  | 1 => Some(Dep)
  | 2 => Some(StackCanary)
  | 3 => Some(Cfi)
  | 4 => Some(Sandboxing)
  | 5 => Some(SecureBoot)
  | 6 => Some(AuditLog)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let securityControlToTag = (v: securityControl): int =>
  switch v {
  | Aslr => 0
  | Dep => 1
  | StackCanary => 2
  | Cfi => 3
  | Sandboxing => 4
  | SecureBoot => 5
  | AuditLog => 6
  }

// ===========================================================================
// ComplianceStandard (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type complianceStandard =
  | @as(0) Cis
  | @as(1) Stig
  | @as(2) Nist80053
  | @as(3) PciDss
  | @as(4) Fips140

/// Decode from the C-ABI tag value.
let complianceStandardFromTag = (tag: int): option<complianceStandard> =>
  switch tag {
  | 0 => Some(Cis)
  | 1 => Some(Stig)
  | 2 => Some(Nist80053)
  | 3 => Some(PciDss)
  | 4 => Some(Fips140)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let complianceStandardToTag = (v: complianceStandard): int =>
  switch v {
  | Cis => 0
  | Stig => 1
  | Nist80053 => 2
  | PciDss => 3
  | Fips140 => 4
  }

// ===========================================================================
// AuditEvent (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type auditEvent =
  | @as(0) ProcessStart
  | @as(1) FileAccess
  | @as(2) NetworkConn
  | @as(3) PrivilegeEscalation
  | @as(4) ConfigChange
  | @as(5) AuthAttempt

/// Decode from the C-ABI tag value.
let auditEventFromTag = (tag: int): option<auditEvent> =>
  switch tag {
  | 0 => Some(ProcessStart)
  | 1 => Some(FileAccess)
  | 2 => Some(NetworkConn)
  | 3 => Some(PrivilegeEscalation)
  | 4 => Some(ConfigChange)
  | 5 => Some(AuthAttempt)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let auditEventToTag = (v: auditEvent): int =>
  switch v {
  | ProcessStart => 0
  | FileAccess => 1
  | NetworkConn => 2
  | PrivilegeEscalation => 3
  | ConfigChange => 4
  | AuthAttempt => 5
  }

// ===========================================================================
// HardenedHealthStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type hardenedHealthStatus =
  | @as(0) Healthy
  | @as(1) Degraded
  | @as(2) Compromised
  | @as(3) Unresponsive

/// Decode from the C-ABI tag value.
let hardenedHealthStatusFromTag = (tag: int): option<hardenedHealthStatus> =>
  switch tag {
  | 0 => Some(Healthy)
  | 1 => Some(Degraded)
  | 2 => Some(Compromised)
  | 3 => Some(Unresponsive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hardenedHealthStatusToTag = (v: hardenedHealthStatus): int =>
  switch v {
  | Healthy => 0
  | Degraded => 1
  | Compromised => 2
  | Unresponsive => 3
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Hardening
  | @as(2) Active
  | @as(3) Auditing
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Hardening)
  | 2 => Some(Active)
  | 3 => Some(Auditing)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Hardening => 1
  | Active => 2
  | Auditing => 3
  | Shutdown => 4
  }

