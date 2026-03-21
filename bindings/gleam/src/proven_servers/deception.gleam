//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Deception/Honeypot protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DeceptionABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DecoyType
// ===========================================================================

/// Deception decoy types.
/// 
/// Matches `DecoyType` in `DeceptionABI.Types`.
pub type DecoyType {
  /// Service (tag 0).
  Service
  /// Credential (tag 1).
  Credential
  /// File (tag 2).
  File
  /// Network (tag 3).
  Network
  /// Token (tag 4).
  Token
  /// Breadcrumb (tag 5).
  Breadcrumb
}

/// Convert a `DecoyType` to its C-ABI tag value.
pub fn decoy_type_to_int(value: DecoyType) -> Int {
  case value {
    Service -> 0
    Credential -> 1
    File -> 2
    Network -> 3
    Token -> 4
    Breadcrumb -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn decoy_type_from_int(tag: Int) -> Result(DecoyType, Nil) {
  case tag {
    0 -> Ok(Service)
    1 -> Ok(Credential)
    2 -> Ok(File)
    3 -> Ok(Network)
    4 -> Ok(Token)
    5 -> Ok(Breadcrumb)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TriggerEvent
// ===========================================================================

/// Decoy trigger events.
/// 
/// Matches `TriggerEvent` in `DeceptionABI.Types`.
pub type TriggerEvent {
  /// Access (tag 0).
  Access
  /// Login (tag 1).
  Login
  /// Read (tag 2).
  Read
  /// Write (tag 3).
  Write
  /// Execute (tag 4).
  Execute
  /// Scan (tag 5).
  Scan
}

/// Convert a `TriggerEvent` to its C-ABI tag value.
pub fn trigger_event_to_int(value: TriggerEvent) -> Int {
  case value {
    Access -> 0
    Login -> 1
    Read -> 2
    Write -> 3
    Execute -> 4
    Scan -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn trigger_event_from_int(tag: Int) -> Result(TriggerEvent, Nil) {
  case tag {
    0 -> Ok(Access)
    1 -> Ok(Login)
    2 -> Ok(Read)
    3 -> Ok(Write)
    4 -> Ok(Execute)
    5 -> Ok(Scan)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AlertPriority
// ===========================================================================

/// Deception alert priority.
/// 
/// Matches `AlertPriority` in `DeceptionABI.Types`.
pub type AlertPriority {
  /// Low (tag 0).
  Low
  /// Medium (tag 1).
  Medium
  /// High (tag 2).
  High
  /// Critical (tag 3).
  Critical
}

/// Convert a `AlertPriority` to its C-ABI tag value.
pub fn alert_priority_to_int(value: AlertPriority) -> Int {
  case value {
    Low -> 0
    Medium -> 1
    High -> 2
    Critical -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_priority_from_int(tag: Int) -> Result(AlertPriority, Nil) {
  case tag {
    0 -> Ok(Low)
    1 -> Ok(Medium)
    2 -> Ok(High)
    3 -> Ok(Critical)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DecoyState
// ===========================================================================

/// Decoy lifecycle states.
/// 
/// Matches `DecoyState` in `DeceptionABI.Types`.
pub type DecoyState {
  /// Active (tag 0).
  Active
  /// Triggered (tag 1).
  Triggered
  /// Disabled (tag 2).
  Disabled
  /// Expired (tag 3).
  Expired
}

/// Convert a `DecoyState` to its C-ABI tag value.
pub fn decoy_state_to_int(value: DecoyState) -> Int {
  case value {
    Active -> 0
    Triggered -> 1
    Disabled -> 2
    Expired -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn decoy_state_from_int(tag: Int) -> Result(DecoyState, Nil) {
  case tag {
    0 -> Ok(Active)
    1 -> Ok(Triggered)
    2 -> Ok(Disabled)
    3 -> Ok(Expired)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponseAction
// ===========================================================================

/// Deception response actions.
/// 
/// Matches `ResponseAction` in `DeceptionABI.Types`.
pub type ResponseAction {
  /// Alert (tag 0).
  Alert
  /// Redirect (tag 1).
  Redirect
  /// Delay (tag 2).
  Delay
  /// Fingerprint (tag 3).
  Fingerprint
  /// Isolate (tag 4).
  Isolate
}

/// Convert a `ResponseAction` to its C-ABI tag value.
pub fn response_action_to_int(value: ResponseAction) -> Int {
  case value {
    Alert -> 0
    Redirect -> 1
    Delay -> 2
    Fingerprint -> 3
    Isolate -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn response_action_from_int(tag: Int) -> Result(ResponseAction, Nil) {
  case tag {
    0 -> Ok(Alert)
    1 -> Ok(Redirect)
    2 -> Ok(Delay)
    3 -> Ok(Fingerprint)
    4 -> Ok(Isolate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// Deception server states.
/// 
/// Matches `ServerState` in `DeceptionABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Configured (tag 1).
  Configured
  /// Monitoring (tag 2).
  Monitoring
  /// Responding (tag 3).
  Responding
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Configured -> 1
    Monitoring -> 2
    Responding -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Configured)
    2 -> Ok(Monitoring)
    3 -> Ok(Responding)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

