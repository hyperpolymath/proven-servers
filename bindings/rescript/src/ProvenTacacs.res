// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ (Terminal Access Controller Access-Control System Plus) types
//
// Mirrors the Idris2 module TACACSABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard TACACS+ port (RFC 8907).
let tacacsPort = 49

// ===========================================================================
// PacketType (tags 0-2)
// ===========================================================================

/// Standard TACACS+ port (RFC 8907).
type packetType =
  | @as(0) Authentication
  | @as(1) Authorization
  | @as(2) Accounting

/// Decode from the C-ABI tag value.
let packetTypeFromTag = (tag: int): option<packetType> =>
  switch tag {
  | 0 => Some(Authentication)
  | 1 => Some(Authorization)
  | 2 => Some(Accounting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let packetTypeToTag = (v: packetType): int =>
  switch v {
  | Authentication => 0
  | Authorization => 1
  | Accounting => 2
  }

// ===========================================================================
// AuthenType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type authenType =
  | @as(0) Ascii
  | @as(1) Pap
  | @as(2) Chap
  | @as(3) MsChapV1
  | @as(4) MsChapV2

/// Decode from the C-ABI tag value.
let authenTypeFromTag = (tag: int): option<authenType> =>
  switch tag {
  | 0 => Some(Ascii)
  | 1 => Some(Pap)
  | 2 => Some(Chap)
  | 3 => Some(MsChapV1)
  | 4 => Some(MsChapV2)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authenTypeToTag = (v: authenType): int =>
  switch v {
  | Ascii => 0
  | Pap => 1
  | Chap => 2
  | MsChapV1 => 3
  | MsChapV2 => 4
  }

/// Whether this authentication type uses challenge-response.
let authenTypeIsChallengeResponse = (v: authenType): bool =>
  switch v {
  | Chap | MsChapV1 | MsChapV2 => true
  | _ => false
  }

/// Whether this authentication type is interactive (multi-round).
let authenTypeIsInteractive = (v: authenType): bool =>
  switch v {
  | Ascii => true
  | _ => false
  }

// ===========================================================================
// AuthenAction (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type authenAction =
  | @as(0) Login
  | @as(1) ChangePass
  | @as(2) SendAuth

/// Decode from the C-ABI tag value.
let authenActionFromTag = (tag: int): option<authenAction> =>
  switch tag {
  | 0 => Some(Login)
  | 1 => Some(ChangePass)
  | 2 => Some(SendAuth)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authenActionToTag = (v: authenAction): int =>
  switch v {
  | Login => 0
  | ChangePass => 1
  | SendAuth => 2
  }

// ===========================================================================
// AuthenStatus (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type authenStatus =
  | @as(0) Pass
  | @as(1) Fail
  | @as(2) GetData
  | @as(3) GetUser
  | @as(4) GetPass
  | @as(5) Restart
  | @as(6) Error
  | @as(7) Follow

/// Decode from the C-ABI tag value.
let authenStatusFromTag = (tag: int): option<authenStatus> =>
  switch tag {
  | 0 => Some(Pass)
  | 1 => Some(Fail)
  | 2 => Some(GetData)
  | 3 => Some(GetUser)
  | 4 => Some(GetPass)
  | 5 => Some(Restart)
  | 6 => Some(Error)
  | 7 => Some(Follow)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authenStatusToTag = (v: authenStatus): int =>
  switch v {
  | Pass => 0
  | Fail => 1
  | GetData => 2
  | GetUser => 3
  | GetPass => 4
  | Restart => 5
  | Error => 6
  | Follow => 7
  }

/// Whether authentication succeeded.
let authenStatusIsSuccess = (v: authenStatus): bool =>
  switch v {
  | Pass => true
  | _ => false
  }

/// Whether the server needs more information from the client.
let authenStatusNeedsMoreData = (v: authenStatus): bool =>
  switch v {
  | GetData | GetUser | GetPass => true
  | _ => false
  }

/// Whether this status indicates a terminal (final) state.
let authenStatusIsTerminal = (v: authenStatus): bool =>
  switch v {
  | Pass | Fail | Error => true
  | _ => false
  }

// ===========================================================================
// AuthorStatus (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type authorStatus =
  | @as(0) PassAdd
  | @as(1) PassRepl
  | @as(2) Fail
  | @as(3) Error
  | @as(4) Follow

/// Decode from the C-ABI tag value.
let authorStatusFromTag = (tag: int): option<authorStatus> =>
  switch tag {
  | 0 => Some(PassAdd)
  | 1 => Some(PassRepl)
  | 2 => Some(Fail)
  | 3 => Some(Error)
  | 4 => Some(Follow)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authorStatusToTag = (v: authorStatus): int =>
  switch v {
  | PassAdd => 0
  | PassRepl => 1
  | Fail => 2
  | Error => 3
  | Follow => 4
  }

/// Whether authorization was granted.
let authorStatusIsAuthorized = (v: authorStatus): bool =>
  switch v {
  | PassAdd | PassRepl => true
  | _ => false
  }

// ===========================================================================
// AcctStatus (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type acctStatus =
  | @as(0) Success
  | @as(1) Error
  | @as(2) Follow

/// Decode from the C-ABI tag value.
let acctStatusFromTag = (tag: int): option<acctStatus> =>
  switch tag {
  | 0 => Some(Success)
  | 1 => Some(Error)
  | 2 => Some(Follow)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let acctStatusToTag = (v: acctStatus): int =>
  switch v {
  | Success => 0
  | Error => 1
  | Follow => 2
  }

/// Whether the accounting record was accepted.
let acctStatusIsSuccess = (v: acctStatus): bool =>
  switch v {
  | Success => true
  | _ => false
  }

// ===========================================================================
// AcctFlag (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type acctFlag =
  | @as(0) Start
  | @as(1) Stop
  | @as(2) Watchdog

/// Decode from the C-ABI tag value.
let acctFlagFromTag = (tag: int): option<acctFlag> =>
  switch tag {
  | 0 => Some(Start)
  | 1 => Some(Stop)
  | 2 => Some(Watchdog)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let acctFlagToTag = (v: acctFlag): int =>
  switch v {
  | Start => 0
  | Stop => 1
  | Watchdog => 2
  }

/// Whether this flag marks a session boundary (start or stop).
let acctFlagIsBoundary = (v: acctFlag): bool =>
  switch v {
  | Start | Stop => true
  | _ => false
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Authenticating
  | @as(2) Authorizing
  | @as(3) Active
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Authenticating)
  | 2 => Some(Authorizing)
  | 3 => Some(Active)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Authenticating => 1
  | Authorizing => 2
  | Active => 3
  | Closing => 4
  }

/// Whether the session is in an AAA processing phase.
let sessionStateIsProcessing = (v: sessionState): bool =>
  switch v {
  | Authenticating | Authorizing => true
  | _ => false
  }

/// Whether the session has been fully authorised and is active.
let sessionStateIsActive = (v: sessionState): bool =>
  switch v {
  | Active => true
  | _ => false
  }

