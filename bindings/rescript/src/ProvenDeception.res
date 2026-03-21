// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception Platform types for the proven-servers ABI.
//
// Mirrors the Idris2 module DeceptionABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// DecoyType (tags 0-5)
// ===========================================================================

/// Deception decoy types.
type decoyType =
  | @as(0) Service
  | @as(1) Credential
  | @as(2) File
  | @as(3) Network
  | @as(4) Token
  | @as(5) Breadcrumb

/// Decode from the C-ABI tag value.
let decoyTypeFromTag = (tag: int): option<decoyType> =>
  switch tag {
  | 0 => Some(Service)
  | 1 => Some(Credential)
  | 2 => Some(File)
  | 3 => Some(Network)
  | 4 => Some(Token)
  | 5 => Some(Breadcrumb)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let decoyTypeToTag = (v: decoyType): int =>
  switch v {
  | Service => 0
  | Credential => 1
  | File => 2
  | Network => 3
  | Token => 4
  | Breadcrumb => 5
  }

// ===========================================================================
// TriggerEvent (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type triggerEvent =
  | @as(0) Access
  | @as(1) Login
  | @as(2) Read
  | @as(3) Write
  | @as(4) Execute
  | @as(5) Scan

/// Decode from the C-ABI tag value.
let triggerEventFromTag = (tag: int): option<triggerEvent> =>
  switch tag {
  | 0 => Some(Access)
  | 1 => Some(Login)
  | 2 => Some(Read)
  | 3 => Some(Write)
  | 4 => Some(Execute)
  | 5 => Some(Scan)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let triggerEventToTag = (v: triggerEvent): int =>
  switch v {
  | Access => 0
  | Login => 1
  | Read => 2
  | Write => 3
  | Execute => 4
  | Scan => 5
  }

// ===========================================================================
// AlertPriority (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type alertPriority =
  | @as(0) Low
  | @as(1) Medium
  | @as(2) High
  | @as(3) Critical

/// Decode from the C-ABI tag value.
let alertPriorityFromTag = (tag: int): option<alertPriority> =>
  switch tag {
  | 0 => Some(Low)
  | 1 => Some(Medium)
  | 2 => Some(High)
  | 3 => Some(Critical)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let alertPriorityToTag = (v: alertPriority): int =>
  switch v {
  | Low => 0
  | Medium => 1
  | High => 2
  | Critical => 3
  }

// ===========================================================================
// DecoyState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type decoyState =
  | @as(0) Active
  | @as(1) Triggered
  | @as(2) Disabled
  | @as(3) Expired

/// Decode from the C-ABI tag value.
let decoyStateFromTag = (tag: int): option<decoyState> =>
  switch tag {
  | 0 => Some(Active)
  | 1 => Some(Triggered)
  | 2 => Some(Disabled)
  | 3 => Some(Expired)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let decoyStateToTag = (v: decoyState): int =>
  switch v {
  | Active => 0
  | Triggered => 1
  | Disabled => 2
  | Expired => 3
  }

// ===========================================================================
// ResponseAction (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type responseAction =
  | @as(0) Alert
  | @as(1) Redirect
  | @as(2) Delay
  | @as(3) Fingerprint
  | @as(4) Isolate

/// Decode from the C-ABI tag value.
let responseActionFromTag = (tag: int): option<responseAction> =>
  switch tag {
  | 0 => Some(Alert)
  | 1 => Some(Redirect)
  | 2 => Some(Delay)
  | 3 => Some(Fingerprint)
  | 4 => Some(Isolate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseActionToTag = (v: responseAction): int =>
  switch v {
  | Alert => 0
  | Redirect => 1
  | Delay => 2
  | Fingerprint => 3
  | Isolate => 4
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Configured
  | @as(2) Monitoring
  | @as(3) Responding
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Configured)
  | 2 => Some(Monitoring)
  | 3 => Some(Responding)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Configured => 1
  | Monitoring => 2
  | Responding => 3
  | Shutdown => 4
  }

