//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Hardened Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `HardenedABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// HardeningLevel
// ===========================================================================

/// System hardening levels.
/// 
/// Matches `HardeningLevel` in `HardenedABI.Types`.
pub type HardeningLevel {
  /// Minimal (tag 0).
  Minimal
  /// Standard (tag 1).
  Standard
  /// High (tag 2).
  High
  /// Maximum (tag 3).
  Maximum
}

/// Convert a `HardeningLevel` to its C-ABI tag value.
pub fn hardening_level_to_int(value: HardeningLevel) -> Int {
  case value {
    Minimal -> 0
    Standard -> 1
    High -> 2
    Maximum -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn hardening_level_from_int(tag: Int) -> Result(HardeningLevel, Nil) {
  case tag {
    0 -> Ok(Minimal)
    1 -> Ok(Standard)
    2 -> Ok(High)
    3 -> Ok(Maximum)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SecurityControl
// ===========================================================================

/// Security controls.
/// 
/// Matches `SecurityControl` in `HardenedABI.Types`.
pub type SecurityControl {
  /// ASLR (tag 0).
  Aslr
  /// DEP (tag 1).
  Dep
  /// StackCanary (tag 2).
  StackCanary
  /// CFI (tag 3).
  Cfi
  /// Sandboxing (tag 4).
  Sandboxing
  /// SecureBoot (tag 5).
  SecureBoot
  /// AuditLog (tag 6).
  AuditLog
}

/// Convert a `SecurityControl` to its C-ABI tag value.
pub fn security_control_to_int(value: SecurityControl) -> Int {
  case value {
    Aslr -> 0
    Dep -> 1
    StackCanary -> 2
    Cfi -> 3
    Sandboxing -> 4
    SecureBoot -> 5
    AuditLog -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn security_control_from_int(tag: Int) -> Result(SecurityControl, Nil) {
  case tag {
    0 -> Ok(Aslr)
    1 -> Ok(Dep)
    2 -> Ok(StackCanary)
    3 -> Ok(Cfi)
    4 -> Ok(Sandboxing)
    5 -> Ok(SecureBoot)
    6 -> Ok(AuditLog)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ComplianceStandard
// ===========================================================================

/// Security compliance standards.
/// 
/// Matches `ComplianceStandard` in `HardenedABI.Types`.
pub type ComplianceStandard {
  /// CIS Benchmark (tag 0).
  Cis
  /// DISA STIG (tag 1).
  Stig
  /// NIST 800-53 (tag 2).
  Nist80053
  /// PCI-DSS (tag 3).
  PciDss
  /// FIPS 140 (tag 4).
  Fips140
}

/// Convert a `ComplianceStandard` to its C-ABI tag value.
pub fn compliance_standard_to_int(value: ComplianceStandard) -> Int {
  case value {
    Cis -> 0
    Stig -> 1
    Nist80053 -> 2
    PciDss -> 3
    Fips140 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn compliance_standard_from_int(tag: Int) -> Result(ComplianceStandard, Nil) {
  case tag {
    0 -> Ok(Cis)
    1 -> Ok(Stig)
    2 -> Ok(Nist80053)
    3 -> Ok(PciDss)
    4 -> Ok(Fips140)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuditEvent
// ===========================================================================

/// Audit event types.
/// 
/// Matches `AuditEvent` in `HardenedABI.Types`.
pub type AuditEvent {
  /// ProcessStart (tag 0).
  ProcessStart
  /// FileAccess (tag 1).
  FileAccess
  /// NetworkConn (tag 2).
  NetworkConn
  /// PrivilegeEscalation (tag 3).
  PrivilegeEscalation
  /// ConfigChange (tag 4).
  ConfigChange
  /// AuthAttempt (tag 5).
  AuthAttempt
}

/// Convert a `AuditEvent` to its C-ABI tag value.
pub fn audit_event_to_int(value: AuditEvent) -> Int {
  case value {
    ProcessStart -> 0
    FileAccess -> 1
    NetworkConn -> 2
    PrivilegeEscalation -> 3
    ConfigChange -> 4
    AuthAttempt -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn audit_event_from_int(tag: Int) -> Result(AuditEvent, Nil) {
  case tag {
    0 -> Ok(ProcessStart)
    1 -> Ok(FileAccess)
    2 -> Ok(NetworkConn)
    3 -> Ok(PrivilegeEscalation)
    4 -> Ok(ConfigChange)
    5 -> Ok(AuthAttempt)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HardenedHealthStatus
// ===========================================================================

/// Hardened system health.
/// 
/// Matches `HardenedHealthStatus` in `HardenedABI.Types`.
pub type HardenedHealthStatus {
  /// Healthy (tag 0).
  Healthy
  /// Degraded (tag 1).
  Degraded
  /// Compromised (tag 2).
  Compromised
  /// Unresponsive (tag 3).
  Unresponsive
}

/// Convert a `HardenedHealthStatus` to its C-ABI tag value.
pub fn hardened_health_status_to_int(value: HardenedHealthStatus) -> Int {
  case value {
    Healthy -> 0
    Degraded -> 1
    Compromised -> 2
    Unresponsive -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn hardened_health_status_from_int(tag: Int) -> Result(HardenedHealthStatus, Nil) {
  case tag {
    0 -> Ok(Healthy)
    1 -> Ok(Degraded)
    2 -> Ok(Compromised)
    3 -> Ok(Unresponsive)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// Hardened server states.
/// 
/// Matches `ServerState` in `HardenedABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Hardening (tag 1).
  Hardening
  /// Active (tag 2).
  Active
  /// Auditing (tag 3).
  Auditing
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Hardening -> 1
    Active -> 2
    Auditing -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Hardening)
    2 -> Ok(Active)
    3 -> Ok(Auditing)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

