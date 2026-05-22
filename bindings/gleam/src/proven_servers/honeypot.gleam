//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Honeypot protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `HoneypotABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ServiceEmulation
// ===========================================================================

/// Emulated service types.
/// 
/// Matches `ServiceEmulation` in `HoneypotABI.Types`.
pub type ServiceEmulation {
  /// SSH (tag 0).
  Ssh
  /// HTTP (tag 1).
  Http
  /// FTP (tag 2).
  Ftp
  /// SMTP (tag 3).
  Smtp
  /// Telnet (tag 4).
  Telnet
  /// MySQL (tag 5).
  Mysql
  /// RDP (tag 6).
  Rdp
}

/// Convert a `ServiceEmulation` to its C-ABI tag value.
pub fn service_emulation_to_int(value: ServiceEmulation) -> Int {
  case value {
    Ssh -> 0
    Http -> 1
    Ftp -> 2
    Smtp -> 3
    Telnet -> 4
    Mysql -> 5
    Rdp -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn service_emulation_from_int(tag: Int) -> Result(ServiceEmulation, Nil) {
  case tag {
    0 -> Ok(Ssh)
    1 -> Ok(Http)
    2 -> Ok(Ftp)
    3 -> Ok(Smtp)
    4 -> Ok(Telnet)
    5 -> Ok(Mysql)
    6 -> Ok(Rdp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// InteractionLevel
// ===========================================================================

/// Honeypot interaction levels.
/// 
/// Matches `InteractionLevel` in `HoneypotABI.Types`.
pub type InteractionLevel {
  /// Low (tag 0).
  Low
  /// Medium (tag 1).
  Medium
  /// High (tag 2).
  High
}

/// Convert a `InteractionLevel` to its C-ABI tag value.
pub fn interaction_level_to_int(value: InteractionLevel) -> Int {
  case value {
    Low -> 0
    Medium -> 1
    High -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn interaction_level_from_int(tag: Int) -> Result(InteractionLevel, Nil) {
  case tag {
    0 -> Ok(Low)
    1 -> Ok(Medium)
    2 -> Ok(High)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HoneypotAlertSeverity
// ===========================================================================

/// Honeypot alert severity levels.
/// 
/// Matches `HoneypotAlertSeverity` in `HoneypotABI.Types`.
pub type HoneypotAlertSeverity {
  /// Info (tag 0).
  Info
  /// Low (tag 1).
  AsLow
  /// Medium (tag 2).
  AsMedium
  /// High (tag 3).
  AsHigh
  /// Critical (tag 4).
  Critical
}

/// Convert a `HoneypotAlertSeverity` to its C-ABI tag value.
pub fn honeypot_alert_severity_to_int(value: HoneypotAlertSeverity) -> Int {
  case value {
    Info -> 0
    AsLow -> 1
    AsMedium -> 2
    AsHigh -> 3
    Critical -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn honeypot_alert_severity_from_int(tag: Int) -> Result(HoneypotAlertSeverity, Nil) {
  case tag {
    0 -> Ok(Info)
    1 -> Ok(AsLow)
    2 -> Ok(AsMedium)
    3 -> Ok(AsHigh)
    4 -> Ok(Critical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AttackerAction
// ===========================================================================

/// Observed attacker actions.
/// 
/// Matches `AttackerAction` in `HoneypotABI.Types`.
pub type AttackerAction {
  /// Scan (tag 0).
  Scan
  /// BruteForce (tag 1).
  BruteForce
  /// Exploit (tag 2).
  Exploit
  /// Payload (tag 3).
  Payload
  /// Lateral (tag 4).
  Lateral
  /// Exfiltration (tag 5).
  Exfiltration
}

/// Convert a `AttackerAction` to its C-ABI tag value.
pub fn attacker_action_to_int(value: AttackerAction) -> Int {
  case value {
    Scan -> 0
    BruteForce -> 1
    Exploit -> 2
    Payload -> 3
    Lateral -> 4
    Exfiltration -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn attacker_action_from_int(tag: Int) -> Result(AttackerAction, Nil) {
  case tag {
    0 -> Ok(Scan)
    1 -> Ok(BruteForce)
    2 -> Ok(Exploit)
    3 -> Ok(Payload)
    4 -> Ok(Lateral)
    5 -> Ok(Exfiltration)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// Honeypot server states.
/// 
/// Matches `ServerState` in `HoneypotABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Deployed (tag 1).
  Deployed
  /// Engaged (tag 2).
  Engaged
  /// Shutdown (tag 3).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Deployed -> 1
    Engaged -> 2
    Shutdown -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Deployed)
    2 -> Ok(Engaged)
    3 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

