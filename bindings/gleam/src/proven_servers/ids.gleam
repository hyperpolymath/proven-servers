//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Intrusion Detection System protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `IdsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// AlertSeverity
// ===========================================================================

/// Alert severity levels.
/// 
/// Matches `AlertSeverity` in `IdsABI.Types`.
pub type AlertSeverity {
  /// Low (tag 0).
  AlertSeverityLow
  /// Medium (tag 1).
  AlertSeverityMedium
  /// High (tag 2).
  AlertSeverityHigh
  /// Critical (tag 3).
  AlertSeverityCritical
}

/// Convert a `AlertSeverity` to its C-ABI tag value.
pub fn alert_severity_to_int(value: AlertSeverity) -> Int {
  case value {
    AlertSeverityLow -> 0
    AlertSeverityMedium -> 1
    AlertSeverityHigh -> 2
    AlertSeverityCritical -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_severity_from_int(tag: Int) -> Result(AlertSeverity, Nil) {
  case tag {
    0 -> Ok(AlertSeverityLow)
    1 -> Ok(AlertSeverityMedium)
    2 -> Ok(AlertSeverityHigh)
    3 -> Ok(AlertSeverityCritical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DetectionMethod
// ===========================================================================

/// Intrusion detection methods.
/// 
/// Matches `DetectionMethod` in `IdsABI.Types`.
pub type DetectionMethod {
  /// Signature (tag 0).
  Signature
  /// Anomaly (tag 1).
  Anomaly
  /// Stateful (tag 2).
  Stateful
  /// Heuristic (tag 3).
  Heuristic
}

/// Convert a `DetectionMethod` to its C-ABI tag value.
pub fn detection_method_to_int(value: DetectionMethod) -> Int {
  case value {
    Signature -> 0
    Anomaly -> 1
    Stateful -> 2
    Heuristic -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn detection_method_from_int(tag: Int) -> Result(DetectionMethod, Nil) {
  case tag {
    0 -> Ok(Signature)
    1 -> Ok(Anomaly)
    2 -> Ok(Stateful)
    3 -> Ok(Heuristic)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IdsProtocol
// ===========================================================================

/// Monitored network protocols.
/// 
/// Matches `IdsProtocol` in `IdsABI.Types`.
pub type IdsProtocol {
  /// TCP (tag 0).
  Tcp
  /// UDP (tag 1).
  Udp
  /// ICMP (tag 2).
  Icmp
  /// DNS (tag 3).
  Dns
  /// HTTP (tag 4).
  Http
  /// TLS (tag 5).
  Tls
  /// SSH (tag 6).
  Ssh
}

/// Convert a `IdsProtocol` to its C-ABI tag value.
pub fn ids_protocol_to_int(value: IdsProtocol) -> Int {
  case value {
    Tcp -> 0
    Udp -> 1
    Icmp -> 2
    Dns -> 3
    Http -> 4
    Tls -> 5
    Ssh -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn ids_protocol_from_int(tag: Int) -> Result(IdsProtocol, Nil) {
  case tag {
    0 -> Ok(Tcp)
    1 -> Ok(Udp)
    2 -> Ok(Icmp)
    3 -> Ok(Dns)
    4 -> Ok(Http)
    5 -> Ok(Tls)
    6 -> Ok(Ssh)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IdsAction
// ===========================================================================

/// IDS response actions.
/// 
/// Matches `IdsAction` in `IdsABI.Types`.
pub type IdsAction {
  /// Alert (tag 0).
  Alert
  /// Drop (tag 1).
  Drop
  /// Log (tag 2).
  Log
  /// Block (tag 3).
  Block
  /// Pass (tag 4).
  Pass
}

/// Convert a `IdsAction` to its C-ABI tag value.
pub fn ids_action_to_int(value: IdsAction) -> Int {
  case value {
    Alert -> 0
    Drop -> 1
    Log -> 2
    Block -> 3
    Pass -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn ids_action_from_int(tag: Int) -> Result(IdsAction, Nil) {
  case tag {
    0 -> Ok(Alert)
    1 -> Ok(Drop)
    2 -> Ok(Log)
    3 -> Ok(Block)
    4 -> Ok(Pass)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Direction
// ===========================================================================

/// Traffic direction.
/// 
/// Matches `Direction` in `IdsABI.Types`.
pub type Direction {
  /// Inbound (tag 0).
  Inbound
  /// Outbound (tag 1).
  Outbound
  /// Both (tag 2).
  Both
}

/// Convert a `Direction` to its C-ABI tag value.
pub fn direction_to_int(value: Direction) -> Int {
  case value {
    Inbound -> 0
    Outbound -> 1
    Both -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn direction_from_int(tag: Int) -> Result(Direction, Nil) {
  case tag {
    0 -> Ok(Inbound)
    1 -> Ok(Outbound)
    2 -> Ok(Both)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ThreatLevel
// ===========================================================================

/// Threat assessment levels.
/// 
/// Matches `ThreatLevel` in `IdsABI.Types`.
pub type ThreatLevel {
  /// Info (tag 0).
  Info
  /// Low (tag 1).
  ThreatLevelLow
  /// Medium (tag 2).
  ThreatLevelMedium
  /// High (tag 3).
  ThreatLevelHigh
  /// Critical (tag 4).
  ThreatLevelCritical
}

/// Convert a `ThreatLevel` to its C-ABI tag value.
pub fn threat_level_to_int(value: ThreatLevel) -> Int {
  case value {
    Info -> 0
    ThreatLevelLow -> 1
    ThreatLevelMedium -> 2
    ThreatLevelHigh -> 3
    ThreatLevelCritical -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn threat_level_from_int(tag: Int) -> Result(ThreatLevel, Nil) {
  case tag {
    0 -> Ok(Info)
    1 -> Ok(ThreatLevelLow)
    2 -> Ok(ThreatLevelMedium)
    3 -> Ok(ThreatLevelHigh)
    4 -> Ok(ThreatLevelCritical)
    _ -> Error(Nil)
  }
}

