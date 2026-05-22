// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Intrusion Detection System types for the proven-servers ABI.
//
// Mirrors the Idris2 module IdsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// AlertSeverity (tags 0-3)
// ===========================================================================

/// Alert severity levels.
type alertSeverity =
  | @as(0) Low
  | @as(1) Medium
  | @as(2) High
  | @as(3) Critical

/// Decode from the C-ABI tag value.
let alertSeverityFromTag = (tag: int): option<alertSeverity> =>
  switch tag {
  | 0 => Some(Low)
  | 1 => Some(Medium)
  | 2 => Some(High)
  | 3 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let alertSeverityToTag = (v: alertSeverity): int =>
  switch v {
  | Low => 0
  | Medium => 1
  | High => 2
  | Critical => 3
  }

// ===========================================================================
// DetectionMethod (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type detectionMethod =
  | @as(0) Signature
  | @as(1) Anomaly
  | @as(2) Stateful
  | @as(3) Heuristic

/// Decode from the C-ABI tag value.
let detectionMethodFromTag = (tag: int): option<detectionMethod> =>
  switch tag {
  | 0 => Some(Signature)
  | 1 => Some(Anomaly)
  | 2 => Some(Stateful)
  | 3 => Some(Heuristic)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let detectionMethodToTag = (v: detectionMethod): int =>
  switch v {
  | Signature => 0
  | Anomaly => 1
  | Stateful => 2
  | Heuristic => 3
  }

// ===========================================================================
// IdsProtocol (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type idsProtocol =
  | @as(0) Tcp
  | @as(1) Udp
  | @as(2) Icmp
  | @as(3) Dns
  | @as(4) Http
  | @as(5) Tls
  | @as(6) Ssh

/// Decode from the C-ABI tag value.
let idsProtocolFromTag = (tag: int): option<idsProtocol> =>
  switch tag {
  | 0 => Some(Tcp)
  | 1 => Some(Udp)
  | 2 => Some(Icmp)
  | 3 => Some(Dns)
  | 4 => Some(Http)
  | 5 => Some(Tls)
  | 6 => Some(Ssh)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let idsProtocolToTag = (v: idsProtocol): int =>
  switch v {
  | Tcp => 0
  | Udp => 1
  | Icmp => 2
  | Dns => 3
  | Http => 4
  | Tls => 5
  | Ssh => 6
  }

// ===========================================================================
// IdsAction (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type idsAction =
  | @as(0) Alert
  | @as(1) Drop
  | @as(2) Log
  | @as(3) Block
  | @as(4) Pass

/// Decode from the C-ABI tag value.
let idsActionFromTag = (tag: int): option<idsAction> =>
  switch tag {
  | 0 => Some(Alert)
  | 1 => Some(Drop)
  | 2 => Some(Log)
  | 3 => Some(Block)
  | 4 => Some(Pass)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let idsActionToTag = (v: idsAction): int =>
  switch v {
  | Alert => 0
  | Drop => 1
  | Log => 2
  | Block => 3
  | Pass => 4
  }

// ===========================================================================
// Direction (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type direction =
  | @as(0) Inbound
  | @as(1) Outbound
  | @as(2) Both

/// Decode from the C-ABI tag value.
let directionFromTag = (tag: int): option<direction> =>
  switch tag {
  | 0 => Some(Inbound)
  | 1 => Some(Outbound)
  | 2 => Some(Both)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let directionToTag = (v: direction): int =>
  switch v {
  | Inbound => 0
  | Outbound => 1
  | Both => 2
  }

// ===========================================================================
// ThreatLevel (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type threatLevel =
  | @as(0) Info
  | @as(1) Low
  | @as(2) Medium
  | @as(3) High
  | @as(4) Critical

/// Decode from the C-ABI tag value.
let threatLevelFromTag = (tag: int): option<threatLevel> =>
  switch tag {
  | 0 => Some(Info)
  | 1 => Some(Low)
  | 2 => Some(Medium)
  | 3 => Some(High)
  | 4 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let threatLevelToTag = (v: threatLevel): int =>
  switch v {
  | Info => 0
  | Low => 1
  | Medium => 2
  | High => 3
  | Critical => 4
  }

