//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// TACACS+ protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `TacacsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// TACACS+ Constants
// ===========================================================================

/// Tacacs Port constant.
pub const tacacs_port = 49

// ===========================================================================
// PacketType
// ===========================================================================

/// TACACS+ packet types (RFC 8907 Section 4.1).
/// 
/// Matches `PacketType` in `TACACSABI.Types`.
/// The three fundamental AAA (Authentication, Authorization, Accounting)
/// service types.
pub type PacketType {
  /// Authentication packet (tag 0).
  Authentication
  /// Authorization packet (tag 1).
  Authorization
  /// Accounting packet (tag 2).
  Accounting
}

/// Convert a `PacketType` to its C-ABI tag value.
pub fn packet_type_to_int(value: PacketType) -> Int {
  case value {
    Authentication -> 0
    Authorization -> 1
    Accounting -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn packet_type_from_int(tag: Int) -> Result(PacketType, Nil) {
  case tag {
    0 -> Ok(Authentication)
    1 -> Ok(Authorization)
    2 -> Ok(Accounting)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthenType
// ===========================================================================

/// TACACS+ authentication types (RFC 8907 Section 4.4.2).
/// 
/// Matches `AuthenType` in `TACACSABI.Types`.
pub type AuthenType {
  /// ASCII interactive login (tag 0).
  Ascii
  /// PAP — Password Authentication Protocol (tag 1).
  Pap
  /// CHAP — Challenge-Handshake Authentication Protocol (tag 2).
  Chap
  /// MS-CHAPv1 (tag 3).
  MsChapV1
  /// MS-CHAPv2 (tag 4).
  MsChapV2
}

/// Convert a `AuthenType` to its C-ABI tag value.
pub fn authen_type_to_int(value: AuthenType) -> Int {
  case value {
    Ascii -> 0
    Pap -> 1
    Chap -> 2
    MsChapV1 -> 3
    MsChapV2 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn authen_type_from_int(tag: Int) -> Result(AuthenType, Nil) {
  case tag {
    0 -> Ok(Ascii)
    1 -> Ok(Pap)
    2 -> Ok(Chap)
    3 -> Ok(MsChapV1)
    4 -> Ok(MsChapV2)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthenAction
// ===========================================================================

/// TACACS+ authentication actions (RFC 8907 Section 4.4.1).
/// 
/// Matches `AuthenAction` in `TACACSABI.Types`.
pub type AuthenAction {
  /// Login — authenticate a user (tag 0).
  Login
  /// ChangePass — change user password (tag 1).
  ChangePass
  /// SendAuth — send authentication data (tag 2).
  SendAuth
}

/// Convert a `AuthenAction` to its C-ABI tag value.
pub fn authen_action_to_int(value: AuthenAction) -> Int {
  case value {
    Login -> 0
    ChangePass -> 1
    SendAuth -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn authen_action_from_int(tag: Int) -> Result(AuthenAction, Nil) {
  case tag {
    0 -> Ok(Login)
    1 -> Ok(ChangePass)
    2 -> Ok(SendAuth)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthenStatus
// ===========================================================================

/// TACACS+ authentication reply statuses (RFC 8907 Section 4.4.2).
/// 
/// Matches `AuthenStatus` in `TACACSABI.Types`.
pub type AuthenStatus {
  /// Authentication passed (tag 0).
  Pass
  /// Authentication failed (tag 1).
  AuthenStatusFail
  /// Server requests additional data (tag 2).
  GetData
  /// Server requests username (tag 3).
  GetUser
  /// Server requests password (tag 4).
  GetPass
  /// Restart authentication (tag 5).
  Restart
  /// Authentication error (tag 6).
  AuthenStatusError
  /// Follow — redirect to another server (tag 7).
  AuthenStatusFollow
}

/// Convert a `AuthenStatus` to its C-ABI tag value.
pub fn authen_status_to_int(value: AuthenStatus) -> Int {
  case value {
    Pass -> 0
    AuthenStatusFail -> 1
    GetData -> 2
    GetUser -> 3
    GetPass -> 4
    Restart -> 5
    AuthenStatusError -> 6
    AuthenStatusFollow -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn authen_status_from_int(tag: Int) -> Result(AuthenStatus, Nil) {
  case tag {
    0 -> Ok(Pass)
    1 -> Ok(AuthenStatusFail)
    2 -> Ok(GetData)
    3 -> Ok(GetUser)
    4 -> Ok(GetPass)
    5 -> Ok(Restart)
    6 -> Ok(AuthenStatusError)
    7 -> Ok(AuthenStatusFollow)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AuthorStatus
// ===========================================================================

/// TACACS+ authorization reply statuses (RFC 8907 Section 4.5).
/// 
/// Matches `AuthorStatus` in `TACACSABI.Types`.
pub type AuthorStatus {
  /// Authorized, server added attributes (tag 0).
  PassAdd
  /// Authorized, server replaced attributes (tag 1).
  PassRepl
  /// Authorization failed (tag 2).
  AuthorStatusFail
  /// Authorization error (tag 3).
  AuthorStatusError
  /// Follow — redirect to another server (tag 4).
  AuthorStatusFollow
}

/// Convert a `AuthorStatus` to its C-ABI tag value.
pub fn author_status_to_int(value: AuthorStatus) -> Int {
  case value {
    PassAdd -> 0
    PassRepl -> 1
    AuthorStatusFail -> 2
    AuthorStatusError -> 3
    AuthorStatusFollow -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn author_status_from_int(tag: Int) -> Result(AuthorStatus, Nil) {
  case tag {
    0 -> Ok(PassAdd)
    1 -> Ok(PassRepl)
    2 -> Ok(AuthorStatusFail)
    3 -> Ok(AuthorStatusError)
    4 -> Ok(AuthorStatusFollow)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AcctStatus
// ===========================================================================

/// TACACS+ accounting reply statuses (RFC 8907 Section 4.6).
/// 
/// Matches `AcctStatus` in `TACACSABI.Types`.
pub type AcctStatus {
  /// Accounting record accepted (tag 0).
  Success
  /// Accounting error (tag 1).
  AcctStatusError
  /// Follow — redirect to another server (tag 2).
  AcctStatusFollow
}

/// Convert a `AcctStatus` to its C-ABI tag value.
pub fn acct_status_to_int(value: AcctStatus) -> Int {
  case value {
    Success -> 0
    AcctStatusError -> 1
    AcctStatusFollow -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn acct_status_from_int(tag: Int) -> Result(AcctStatus, Nil) {
  case tag {
    0 -> Ok(Success)
    1 -> Ok(AcctStatusError)
    2 -> Ok(AcctStatusFollow)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AcctFlag
// ===========================================================================

/// TACACS+ accounting record flags (RFC 8907 Section 4.6.1).
/// 
/// Matches `AcctFlag` in `TACACSABI.Types`.
pub type AcctFlag {
  /// Start of a session (tag 0).
  Start
  /// End of a session (tag 1).
  Stop
  /// Interim update / watchdog (tag 2).
  Watchdog
}

/// Convert a `AcctFlag` to its C-ABI tag value.
pub fn acct_flag_to_int(value: AcctFlag) -> Int {
  case value {
    Start -> 0
    Stop -> 1
    Watchdog -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn acct_flag_from_int(tag: Int) -> Result(AcctFlag, Nil) {
  case tag {
    0 -> Ok(Start)
    1 -> Ok(Stop)
    2 -> Ok(Watchdog)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// TACACS+ session lifecycle states for the FFI layer.
/// 
/// Matches `SessionState` in `TACACSABI.Types`.
/// Combines the AAA phases into a single composite lifecycle enum.
pub type SessionState {
  /// No session active (tag 0).
  Idle
  /// Authentication in progress (tag 1).
  Authenticating
  /// Authorization in progress (tag 2).
  Authorizing
  /// Session active, accounting records may be generated (tag 3).
  Active
  /// Session ending, final accounting being sent (tag 4).
  Closing
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Authenticating -> 1
    Authorizing -> 2
    Active -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Authenticating)
    2 -> Ok(Authorizing)
    3 -> Ok(Active)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

