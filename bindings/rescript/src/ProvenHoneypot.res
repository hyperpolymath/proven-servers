// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot types for the proven-servers ABI.
//
// Mirrors the Idris2 module HoneypotABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ServiceEmulation (tags 0-6)
// ===========================================================================

/// Emulated service types.
type serviceEmulation =
  | @as(0) Ssh
  | @as(1) Http
  | @as(2) Ftp
  | @as(3) Smtp
  | @as(4) Telnet
  | @as(5) Mysql
  | @as(6) Rdp

/// Decode from the C-ABI tag value.
let serviceEmulationFromTag = (tag: int): option<serviceEmulation> =>
  switch tag {
  | 0 => Some(Ssh)
  | 1 => Some(Http)
  | 2 => Some(Ftp)
  | 3 => Some(Smtp)
  | 4 => Some(Telnet)
  | 5 => Some(Mysql)
  | 6 => Some(Rdp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serviceEmulationToTag = (v: serviceEmulation): int =>
  switch v {
  | Ssh => 0
  | Http => 1
  | Ftp => 2
  | Smtp => 3
  | Telnet => 4
  | Mysql => 5
  | Rdp => 6
  }

// ===========================================================================
// InteractionLevel (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type interactionLevel =
  | @as(0) Low
  | @as(1) Medium
  | @as(2) High

/// Decode from the C-ABI tag value.
let interactionLevelFromTag = (tag: int): option<interactionLevel> =>
  switch tag {
  | 0 => Some(Low)
  | 1 => Some(Medium)
  | 2 => Some(High)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let interactionLevelToTag = (v: interactionLevel): int =>
  switch v {
  | Low => 0
  | Medium => 1
  | High => 2
  }

// ===========================================================================
// HoneypotAlertSeverity (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type honeypotAlertSeverity =
  | @as(0) Info
  | @as(1) AsLow
  | @as(2) AsMedium
  | @as(3) AsHigh
  | @as(4) Critical

/// Decode from the C-ABI tag value.
let honeypotAlertSeverityFromTag = (tag: int): option<honeypotAlertSeverity> =>
  switch tag {
  | 0 => Some(Info)
  | 1 => Some(AsLow)
  | 2 => Some(AsMedium)
  | 3 => Some(AsHigh)
  | 4 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let honeypotAlertSeverityToTag = (v: honeypotAlertSeverity): int =>
  switch v {
  | Info => 0
  | AsLow => 1
  | AsMedium => 2
  | AsHigh => 3
  | Critical => 4
  }

// ===========================================================================
// AttackerAction (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type attackerAction =
  | @as(0) Scan
  | @as(1) BruteForce
  | @as(2) Exploit
  | @as(3) Payload
  | @as(4) Lateral
  | @as(5) Exfiltration

/// Decode from the C-ABI tag value.
let attackerActionFromTag = (tag: int): option<attackerAction> =>
  switch tag {
  | 0 => Some(Scan)
  | 1 => Some(BruteForce)
  | 2 => Some(Exploit)
  | 3 => Some(Payload)
  | 4 => Some(Lateral)
  | 5 => Some(Exfiltration)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let attackerActionToTag = (v: attackerAction): int =>
  switch v {
  | Scan => 0
  | BruteForce => 1
  | Exploit => 2
  | Payload => 3
  | Lateral => 4
  | Exfiltration => 5
  }

// ===========================================================================
// ServerState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Deployed
  | @as(2) Engaged
  | @as(3) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Deployed)
  | 2 => Some(Engaged)
  | 3 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Deployed => 1
  | Engaged => 2
  | Shutdown => 3
  }

