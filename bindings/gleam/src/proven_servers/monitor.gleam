//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Monitoring protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `MonitorABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// CheckType
// ===========================================================================

/// Monitor check types.
/// 
/// Matches `CheckType` in `MonitorABI.Types`.
pub type CheckType {
  /// HTTP (tag 0).
  Http
  /// TCP (tag 1).
  Tcp
  /// UDP (tag 2).
  Udp
  /// ICMP (tag 3).
  Icmp
  /// DNS (tag 4).
  Dns
  /// Certificate (tag 5).
  Certificate
  /// Disk (tag 6).
  Disk
  /// CPU (tag 7).
  Cpu
  /// Memory (tag 8).
  Memory
  /// Process (tag 9).
  Process
  /// Custom (tag 10).
  Custom
}

/// Convert a `CheckType` to its C-ABI tag value.
pub fn check_type_to_int(value: CheckType) -> Int {
  case value {
    Http -> 0
    Tcp -> 1
    Udp -> 2
    Icmp -> 3
    Dns -> 4
    Certificate -> 5
    Disk -> 6
    Cpu -> 7
    Memory -> 8
    Process -> 9
    Custom -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn check_type_from_int(tag: Int) -> Result(CheckType, Nil) {
  case tag {
    0 -> Ok(Http)
    1 -> Ok(Tcp)
    2 -> Ok(Udp)
    3 -> Ok(Icmp)
    4 -> Ok(Dns)
    5 -> Ok(Certificate)
    6 -> Ok(Disk)
    7 -> Ok(Cpu)
    8 -> Ok(Memory)
    9 -> Ok(Process)
    10 -> Ok(Custom)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Status
// ===========================================================================

/// Monitor status values.
/// 
/// Matches `Status` in `MonitorABI.Types`.
pub type Status {
  /// Up (tag 0).
  Up
  /// Down (tag 1).
  Down
  /// Degraded (tag 2).
  Degraded
  /// Unknown (tag 3).
  Unknown
  /// Maintenance (tag 4).
  Maintenance
}

/// Convert a `Status` to its C-ABI tag value.
pub fn status_to_int(value: Status) -> Int {
  case value {
    Up -> 0
    Down -> 1
    Degraded -> 2
    Unknown -> 3
    Maintenance -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn status_from_int(tag: Int) -> Result(Status, Nil) {
  case tag {
    0 -> Ok(Up)
    1 -> Ok(Down)
    2 -> Ok(Degraded)
    3 -> Ok(Unknown)
    4 -> Ok(Maintenance)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AlertChannel
// ===========================================================================

/// Alert notification channels.
/// 
/// Matches `AlertChannel` in `MonitorABI.Types`.
pub type AlertChannel {
  /// Email (tag 0).
  Email
  /// SMS (tag 1).
  Sms
  /// Webhook (tag 2).
  Webhook
  /// Slack (tag 3).
  Slack
  /// PagerDuty (tag 4).
  PagerDuty
}

/// Convert a `AlertChannel` to its C-ABI tag value.
pub fn alert_channel_to_int(value: AlertChannel) -> Int {
  case value {
    Email -> 0
    Sms -> 1
    Webhook -> 2
    Slack -> 3
    PagerDuty -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_channel_from_int(tag: Int) -> Result(AlertChannel, Nil) {
  case tag {
    0 -> Ok(Email)
    1 -> Ok(Sms)
    2 -> Ok(Webhook)
    3 -> Ok(Slack)
    4 -> Ok(PagerDuty)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Severity
// ===========================================================================

/// Monitor severity levels.
/// 
/// Matches `Severity` in `MonitorABI.Types`.
pub type Severity {
  /// Info (tag 0).
  Info
  /// Warning (tag 1).
  Warning
  /// Error (tag 2).
  SeverityError
  /// Critical (tag 3).
  Critical
}

/// Convert a `Severity` to its C-ABI tag value.
pub fn severity_to_int(value: Severity) -> Int {
  case value {
    Info -> 0
    Warning -> 1
    SeverityError -> 2
    Critical -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn severity_from_int(tag: Int) -> Result(Severity, Nil) {
  case tag {
    0 -> Ok(Info)
    1 -> Ok(Warning)
    2 -> Ok(SeverityError)
    3 -> Ok(Critical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CheckState
// ===========================================================================

/// Monitor check execution states.
/// 
/// Matches `CheckState` in `MonitorABI.Types`.
pub type CheckState {
  /// Pending (tag 0).
  Pending
  /// Running (tag 1).
  CheckStateRunning
  /// Passed (tag 2).
  Passed
  /// Failed (tag 3).
  Failed
  /// Timeout (tag 4).
  Timeout
  /// Error (tag 5).
  CsError
}

/// Convert a `CheckState` to its C-ABI tag value.
pub fn check_state_to_int(value: CheckState) -> Int {
  case value {
    Pending -> 0
    CheckStateRunning -> 1
    Passed -> 2
    Failed -> 3
    Timeout -> 4
    CsError -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn check_state_from_int(tag: Int) -> Result(CheckState, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(CheckStateRunning)
    2 -> Ok(Passed)
    3 -> Ok(Failed)
    4 -> Ok(Timeout)
    5 -> Ok(CsError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MonitorState
// ===========================================================================

/// Monitor service states.
/// 
/// Matches `MonitorState` in `MonitorABI.Types`.
pub type MonitorState {
  /// Idle (tag 0).
  Idle
  /// Configured (tag 1).
  Configured
  /// Running (tag 2).
  MonitorStateRunning
  /// Paused (tag 3).
  MonPaused
  /// Alerting (tag 4).
  Alerting
  /// Shutdown (tag 5).
  Shutdown
}

/// Convert a `MonitorState` to its C-ABI tag value.
pub fn monitor_state_to_int(value: MonitorState) -> Int {
  case value {
    Idle -> 0
    Configured -> 1
    MonitorStateRunning -> 2
    MonPaused -> 3
    Alerting -> 4
    Shutdown -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn monitor_state_from_int(tag: Int) -> Result(MonitorState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Configured)
    2 -> Ok(MonitorStateRunning)
    3 -> Ok(MonPaused)
    4 -> Ok(Alerting)
    5 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

