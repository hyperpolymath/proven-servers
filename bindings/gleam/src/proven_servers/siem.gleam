//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SIEM protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SiemABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// EventSeverity
// ===========================================================================

/// Security event severity.
/// 
/// Matches `EventSeverity` in `SiemABI.Types`.
pub type EventSeverity {
  /// Info (tag 0).
  Info
  /// Low (tag 1).
  Low
  /// Medium (tag 2).
  Medium
  /// High (tag 3).
  High
  /// Critical (tag 4).
  Critical
}

/// Convert a `EventSeverity` to its C-ABI tag value.
pub fn event_severity_to_int(value: EventSeverity) -> Int {
  case value {
    Info -> 0
    Low -> 1
    Medium -> 2
    High -> 3
    Critical -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn event_severity_from_int(tag: Int) -> Result(EventSeverity, Nil) {
  case tag {
    0 -> Ok(Info)
    1 -> Ok(Low)
    2 -> Ok(Medium)
    3 -> Ok(High)
    4 -> Ok(Critical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EventCategory
// ===========================================================================

/// Security event categories.
/// 
/// Matches `EventCategory` in `SiemABI.Types`.
pub type EventCategory {
  /// Authentication (tag 0).
  Authentication
  /// NetworkTraffic (tag 1).
  NetworkTraffic
  /// FileActivity (tag 2).
  FileActivity
  /// ProcessExecution (tag 3).
  ProcessExecution
  /// PolicyViolation (tag 4).
  PolicyViolation
  /// Malware (tag 5).
  Malware
  /// DataExfiltration (tag 6).
  DataExfiltration
}

/// Convert a `EventCategory` to its C-ABI tag value.
pub fn event_category_to_int(value: EventCategory) -> Int {
  case value {
    Authentication -> 0
    NetworkTraffic -> 1
    FileActivity -> 2
    ProcessExecution -> 3
    PolicyViolation -> 4
    Malware -> 5
    DataExfiltration -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn event_category_from_int(tag: Int) -> Result(EventCategory, Nil) {
  case tag {
    0 -> Ok(Authentication)
    1 -> Ok(NetworkTraffic)
    2 -> Ok(FileActivity)
    3 -> Ok(ProcessExecution)
    4 -> Ok(PolicyViolation)
    5 -> Ok(Malware)
    6 -> Ok(DataExfiltration)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CorrelationRule
// ===========================================================================

/// Event correlation rule types.
/// 
/// Matches `CorrelationRule` in `SiemABI.Types`.
pub type CorrelationRule {
  /// Threshold (tag 0).
  Threshold
  /// Sequence (tag 1).
  Sequence
  /// Aggregation (tag 2).
  Aggregation
  /// Absence (tag 3).
  Absence
  /// Statistical (tag 4).
  Statistical
}

/// Convert a `CorrelationRule` to its C-ABI tag value.
pub fn correlation_rule_to_int(value: CorrelationRule) -> Int {
  case value {
    Threshold -> 0
    Sequence -> 1
    Aggregation -> 2
    Absence -> 3
    Statistical -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn correlation_rule_from_int(tag: Int) -> Result(CorrelationRule, Nil) {
  case tag {
    0 -> Ok(Threshold)
    1 -> Ok(Sequence)
    2 -> Ok(Aggregation)
    3 -> Ok(Absence)
    4 -> Ok(Statistical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AlertState
// ===========================================================================

/// SIEM alert states.
/// 
/// Matches `AlertState` in `SiemABI.Types`.
pub type AlertState {
  /// New (tag 0).
  New
  /// Acknowledged (tag 1).
  Acknowledged
  /// InProgress (tag 2).
  InProgress
  /// Resolved (tag 3).
  Resolved
  /// FalsePositive (tag 4).
  FalsePositive
}

/// Convert a `AlertState` to its C-ABI tag value.
pub fn alert_state_to_int(value: AlertState) -> Int {
  case value {
    New -> 0
    Acknowledged -> 1
    InProgress -> 2
    Resolved -> 3
    FalsePositive -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_state_from_int(tag: Int) -> Result(AlertState, Nil) {
  case tag {
    0 -> Ok(New)
    1 -> Ok(Acknowledged)
    2 -> Ok(InProgress)
    3 -> Ok(Resolved)
    4 -> Ok(FalsePositive)
    _ -> Error(Nil)
  }
}

