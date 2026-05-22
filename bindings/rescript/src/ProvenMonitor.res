// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor types for the proven-servers ABI.
//
// Mirrors the Idris2 module MonitorABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// CheckType (tags 0-10)
// ===========================================================================

/// Monitor check types.
type checkType =
  | @as(0) Http
  | @as(1) Tcp
  | @as(2) Udp
  | @as(3) Icmp
  | @as(4) Dns
  | @as(5) Certificate
  | @as(6) Disk
  | @as(7) Cpu
  | @as(8) Memory
  | @as(9) Process
  | @as(10) Custom

/// Decode from the C-ABI tag value.
let checkTypeFromTag = (tag: int): option<checkType> =>
  switch tag {
  | 0 => Some(Http)
  | 1 => Some(Tcp)
  | 2 => Some(Udp)
  | 3 => Some(Icmp)
  | 4 => Some(Dns)
  | 5 => Some(Certificate)
  | 6 => Some(Disk)
  | 7 => Some(Cpu)
  | 8 => Some(Memory)
  | 9 => Some(Process)
  | 10 => Some(Custom)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let checkTypeToTag = (v: checkType): int =>
  switch v {
  | Http => 0
  | Tcp => 1
  | Udp => 2
  | Icmp => 3
  | Dns => 4
  | Certificate => 5
  | Disk => 6
  | Cpu => 7
  | Memory => 8
  | Process => 9
  | Custom => 10
  }

// ===========================================================================
// Status (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type status =
  | @as(0) Up
  | @as(1) Down
  | @as(2) Degraded
  | @as(3) Unknown
  | @as(4) Maintenance

/// Decode from the C-ABI tag value.
let statusFromTag = (tag: int): option<status> =>
  switch tag {
  | 0 => Some(Up)
  | 1 => Some(Down)
  | 2 => Some(Degraded)
  | 3 => Some(Unknown)
  | 4 => Some(Maintenance)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statusToTag = (v: status): int =>
  switch v {
  | Up => 0
  | Down => 1
  | Degraded => 2
  | Unknown => 3
  | Maintenance => 4
  }

// ===========================================================================
// AlertChannel (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type alertChannel =
  | @as(0) Email
  | @as(1) Sms
  | @as(2) Webhook
  | @as(3) Slack
  | @as(4) PagerDuty

/// Decode from the C-ABI tag value.
let alertChannelFromTag = (tag: int): option<alertChannel> =>
  switch tag {
  | 0 => Some(Email)
  | 1 => Some(Sms)
  | 2 => Some(Webhook)
  | 3 => Some(Slack)
  | 4 => Some(PagerDuty)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let alertChannelToTag = (v: alertChannel): int =>
  switch v {
  | Email => 0
  | Sms => 1
  | Webhook => 2
  | Slack => 3
  | PagerDuty => 4
  }

// ===========================================================================
// Severity (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type severity =
  | @as(0) Info
  | @as(1) Warning
  | @as(2) Error
  | @as(3) Critical

/// Decode from the C-ABI tag value.
let severityFromTag = (tag: int): option<severity> =>
  switch tag {
  | 0 => Some(Info)
  | 1 => Some(Warning)
  | 2 => Some(Error)
  | 3 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let severityToTag = (v: severity): int =>
  switch v {
  | Info => 0
  | Warning => 1
  | Error => 2
  | Critical => 3
  }

// ===========================================================================
// CheckState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type checkState =
  | @as(0) Pending
  | @as(1) Running
  | @as(2) Passed
  | @as(3) Failed
  | @as(4) Timeout
  | @as(5) CsError

/// Decode from the C-ABI tag value.
let checkStateFromTag = (tag: int): option<checkState> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Running)
  | 2 => Some(Passed)
  | 3 => Some(Failed)
  | 4 => Some(Timeout)
  | 5 => Some(CsError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let checkStateToTag = (v: checkState): int =>
  switch v {
  | Pending => 0
  | Running => 1
  | Passed => 2
  | Failed => 3
  | Timeout => 4
  | CsError => 5
  }

// ===========================================================================
// MonitorState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type monitorState =
  | @as(0) Idle
  | @as(1) Configured
  | @as(2) Running
  | @as(3) MonPaused
  | @as(4) Alerting
  | @as(5) Shutdown

/// Decode from the C-ABI tag value.
let monitorStateFromTag = (tag: int): option<monitorState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Configured)
  | 2 => Some(Running)
  | 3 => Some(MonPaused)
  | 4 => Some(Alerting)
  | 5 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let monitorStateToTag = (v: monitorState): int =>
  switch v {
  | Idle => 0
  | Configured => 1
  | Running => 2
  | MonPaused => 3
  | Alerting => 4
  | Shutdown => 5
  }

