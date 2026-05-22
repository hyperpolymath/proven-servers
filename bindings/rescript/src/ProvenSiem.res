// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM types for the proven-servers ABI.
//
// Mirrors the Idris2 module SiemABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// EventSeverity (tags 0-4)
// ===========================================================================

/// Security event severity.
type eventSeverity =
  | @as(0) Info
  | @as(1) Low
  | @as(2) Medium
  | @as(3) High
  | @as(4) Critical

/// Decode from the C-ABI tag value.
let eventSeverityFromTag = (tag: int): option<eventSeverity> =>
  switch tag {
  | 0 => Some(Info)
  | 1 => Some(Low)
  | 2 => Some(Medium)
  | 3 => Some(High)
  | 4 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let eventSeverityToTag = (v: eventSeverity): int =>
  switch v {
  | Info => 0
  | Low => 1
  | Medium => 2
  | High => 3
  | Critical => 4
  }

// ===========================================================================
// EventCategory (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type eventCategory =
  | @as(0) Authentication
  | @as(1) NetworkTraffic
  | @as(2) FileActivity
  | @as(3) ProcessExecution
  | @as(4) PolicyViolation
  | @as(5) Malware
  | @as(6) DataExfiltration

/// Decode from the C-ABI tag value.
let eventCategoryFromTag = (tag: int): option<eventCategory> =>
  switch tag {
  | 0 => Some(Authentication)
  | 1 => Some(NetworkTraffic)
  | 2 => Some(FileActivity)
  | 3 => Some(ProcessExecution)
  | 4 => Some(PolicyViolation)
  | 5 => Some(Malware)
  | 6 => Some(DataExfiltration)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let eventCategoryToTag = (v: eventCategory): int =>
  switch v {
  | Authentication => 0
  | NetworkTraffic => 1
  | FileActivity => 2
  | ProcessExecution => 3
  | PolicyViolation => 4
  | Malware => 5
  | DataExfiltration => 6
  }

// ===========================================================================
// CorrelationRule (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type correlationRule =
  | @as(0) Threshold
  | @as(1) Sequence
  | @as(2) Aggregation
  | @as(3) Absence
  | @as(4) Statistical

/// Decode from the C-ABI tag value.
let correlationRuleFromTag = (tag: int): option<correlationRule> =>
  switch tag {
  | 0 => Some(Threshold)
  | 1 => Some(Sequence)
  | 2 => Some(Aggregation)
  | 3 => Some(Absence)
  | 4 => Some(Statistical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let correlationRuleToTag = (v: correlationRule): int =>
  switch v {
  | Threshold => 0
  | Sequence => 1
  | Aggregation => 2
  | Absence => 3
  | Statistical => 4
  }

// ===========================================================================
// AlertState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type alertState =
  | @as(0) New
  | @as(1) Acknowledged
  | @as(2) InProgress
  | @as(3) Resolved
  | @as(4) FalsePositive

/// Decode from the C-ABI tag value.
let alertStateFromTag = (tag: int): option<alertState> =>
  switch tag {
  | 0 => Some(New)
  | 1 => Some(Acknowledged)
  | 2 => Some(InProgress)
  | 3 => Some(Resolved)
  | 4 => Some(FalsePositive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let alertStateToTag = (v: alertState): int =>
  switch v {
  | New => 0
  | Acknowledged => 1
  | InProgress => 2
  | Resolved => 3
  | FalsePositive => 4
  }

