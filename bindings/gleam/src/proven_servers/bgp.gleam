//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// BGP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `BgpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// BGP Constants
// ===========================================================================

/// Bgp Port constant.
pub const bgp_port = 179

// ===========================================================================
// BgpState
// ===========================================================================

/// BGP finite state machine states (RFC 4271 Section 8.2.2).
/// 
/// Matches `BGPState` in `BgpABI.Types`.
pub type BgpState {
  /// Idle — initial state, no connection (tag 0).
  Idle
  /// Connect — waiting for TCP connection (tag 1).
  Connect
  /// Active — retrying TCP connection (tag 2).
  Active
  /// OpenSent — OPEN message sent, awaiting OPEN (tag 3).
  OpenSent
  /// OpenConfirm — OPEN received, awaiting KEEPALIVE (tag 4).
  OpenConfirm
  /// Established — peers exchanging UPDATE messages (tag 5).
  Established
}

/// Convert a `BgpState` to its C-ABI tag value.
pub fn bgp_state_to_int(value: BgpState) -> Int {
  case value {
    Idle -> 0
    Connect -> 1
    Active -> 2
    OpenSent -> 3
    OpenConfirm -> 4
    Established -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn bgp_state_from_int(tag: Int) -> Result(BgpState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connect)
    2 -> Ok(Active)
    3 -> Ok(OpenSent)
    4 -> Ok(OpenConfirm)
    5 -> Ok(Established)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// BgpEvent
// ===========================================================================

/// BGP FSM events (RFC 4271 Section 8.1).
/// 
/// Matches `BGPEvent` in `BgpABI.Types`.
pub type BgpEvent {
  /// ManualStart — administrative start (tag 0).
  ManualStart
  /// ManualStop — administrative stop (tag 1).
  ManualStop
  /// AutomaticStart — automatic restart (tag 2).
  AutomaticStart
  /// ConnectRetryTimerExpires (tag 3).
  ConnectRetryTimerExpires
  /// HoldTimerExpires (tag 4).
  HoldTimerExpires
  /// KeepaliveTimerExpires (tag 5).
  KeepaliveTimerExpires
  /// DelayOpenTimerExpires (tag 6).
  DelayOpenTimerExpires
  /// TcpCRValid — valid incoming TCP connection (tag 7).
  TcpConnectionValid
  /// TcpCRAcked — outgoing TCP connection acknowledged (tag 8).
  TcpCrAcked
  /// TcpConnectionConfirmed (tag 9).
  TcpConnectionConfirmed
  /// TcpConnectionFails (tag 10).
  TcpConnectionFails
  /// BGPOpen received (tag 11).
  BgpOpenReceived
  /// BGPHeaderErr — bad header received (tag 12).
  BgpHeaderErr
  /// BGPOpenMsgErr — bad OPEN received (tag 13).
  BgpOpenMsgErr
  /// NotifMsgVerErr — NOTIFICATION version error (tag 14).
  NotifMsgVerErr
  /// NotifMsg — NOTIFICATION received (tag 15).
  NotifMsg
  /// KeepaliveMsg — KEEPALIVE received (tag 16).
  KeepaliveMsg
  /// UpdateMsg — UPDATE received (tag 17).
  UpdateMsg
  /// UpdateMsgErr — bad UPDATE received (tag 18).
  UpdateMsgErr
}

/// Convert a `BgpEvent` to its C-ABI tag value.
pub fn bgp_event_to_int(value: BgpEvent) -> Int {
  case value {
    ManualStart -> 0
    ManualStop -> 1
    AutomaticStart -> 2
    ConnectRetryTimerExpires -> 3
    HoldTimerExpires -> 4
    KeepaliveTimerExpires -> 5
    DelayOpenTimerExpires -> 6
    TcpConnectionValid -> 7
    TcpCrAcked -> 8
    TcpConnectionConfirmed -> 9
    TcpConnectionFails -> 10
    BgpOpenReceived -> 11
    BgpHeaderErr -> 12
    BgpOpenMsgErr -> 13
    NotifMsgVerErr -> 14
    NotifMsg -> 15
    KeepaliveMsg -> 16
    UpdateMsg -> 17
    UpdateMsgErr -> 18
  }
}

/// Decode from a C-ABI tag value.
pub fn bgp_event_from_int(tag: Int) -> Result(BgpEvent, Nil) {
  case tag {
    0 -> Ok(ManualStart)
    1 -> Ok(ManualStop)
    2 -> Ok(AutomaticStart)
    3 -> Ok(ConnectRetryTimerExpires)
    4 -> Ok(HoldTimerExpires)
    5 -> Ok(KeepaliveTimerExpires)
    6 -> Ok(DelayOpenTimerExpires)
    7 -> Ok(TcpConnectionValid)
    8 -> Ok(TcpCrAcked)
    9 -> Ok(TcpConnectionConfirmed)
    10 -> Ok(TcpConnectionFails)
    11 -> Ok(BgpOpenReceived)
    12 -> Ok(BgpHeaderErr)
    13 -> Ok(BgpOpenMsgErr)
    14 -> Ok(NotifMsgVerErr)
    15 -> Ok(NotifMsg)
    16 -> Ok(KeepaliveMsg)
    17 -> Ok(UpdateMsg)
    18 -> Ok(UpdateMsgErr)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MessageType
// ===========================================================================

/// BGP message types (RFC 4271 Section 4).
/// 
/// Matches `MessageType` in `BgpABI.Types`.
pub type MessageType {
  /// OPEN — establish BGP session (tag 0).
  Open
  /// UPDATE — advertise/withdraw routes (tag 1).
  Update
  /// NOTIFICATION — report error (tag 2).
  Notification
  /// KEEPALIVE — maintain session (tag 3).
  Keepalive
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    Open -> 0
    Update -> 1
    Notification -> 2
    Keepalive -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(Open)
    1 -> Ok(Update)
    2 -> Ok(Notification)
    3 -> Ok(Keepalive)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// BGP NOTIFICATION error codes (RFC 4271 Section 4.5).
/// 
/// Matches `ErrorCode` in `BgpABI.Types`.
pub type ErrorCode {
  /// Message Header Error (tag 0).
  MessageHeaderError
  /// OPEN Message Error (tag 1).
  OpenMessageError
  /// UPDATE Message Error (tag 2).
  UpdateMessageError
  /// Hold Timer Expired (tag 3).
  HoldTimerExpired
  /// Finite State Machine Error (tag 4).
  FsmError
  /// Cease (tag 5).
  Cease
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    MessageHeaderError -> 0
    OpenMessageError -> 1
    UpdateMessageError -> 2
    HoldTimerExpired -> 3
    FsmError -> 4
    Cease -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(MessageHeaderError)
    1 -> Ok(OpenMessageError)
    2 -> Ok(UpdateMessageError)
    3 -> Ok(HoldTimerExpired)
    4 -> Ok(FsmError)
    5 -> Ok(Cease)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Origin
// ===========================================================================

/// BGP ORIGIN path attribute values (RFC 4271 Section 4.3).
/// 
/// Matches `Origin` in `BgpABI.Types`.
pub type Origin {
  /// IGP — route originated within the AS (tag 0).
  Igp
  /// EGP — route learned via EGP (tag 1).
  Egp
  /// Incomplete — origin unknown (tag 2).
  Incomplete
}

/// Convert a `Origin` to its C-ABI tag value.
pub fn origin_to_int(value: Origin) -> Int {
  case value {
    Igp -> 0
    Egp -> 1
    Incomplete -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn origin_from_int(tag: Int) -> Result(Origin, Nil) {
  case tag {
    0 -> Ok(Igp)
    1 -> Ok(Egp)
    2 -> Ok(Incomplete)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AsPathSegmentType
// ===========================================================================

/// BGP ASPATH segment types (RFC 4271 Section 4.3).
/// 
/// Matches `ASPathSegmentType` in `BgpABI.Types`.
pub type AsPathSegmentType {
  /// ASSET — unordered set of ASes (tag 0).
  AsSet
  /// ASSEQUENCE — ordered sequence of ASes (tag 1).
  AsSequence
}

/// Convert a `AsPathSegmentType` to its C-ABI tag value.
pub fn as_path_segment_type_to_int(value: AsPathSegmentType) -> Int {
  case value {
    AsSet -> 0
    AsSequence -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn as_path_segment_type_from_int(tag: Int) -> Result(AsPathSegmentType, Nil) {
  case tag {
    0 -> Ok(AsSet)
    1 -> Ok(AsSequence)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PathAttrType
// ===========================================================================

/// BGP path attribute types (RFC 4271 Section 5).
/// 
/// Matches `PathAttrType` in `BgpABI.Types`.
pub type PathAttrType {
  /// ORIGIN (tag 0).
  Origin
  /// ASPATH (tag 1).
  AsPath
  /// NEXTHOP (tag 2).
  NextHop
  /// MULTIEXITDISC (tag 3).
  Med
  /// LOCALPREF (tag 4).
  LocalPref
  /// ATOMICAGGREGATE (tag 5).
  AtomicAggr
  /// AGGREGATOR (tag 6).
  Aggregator
  /// Unknown/vendor-specific (tag 7).
  Unknown
}

/// Convert a `PathAttrType` to its C-ABI tag value.
pub fn path_attr_type_to_int(value: PathAttrType) -> Int {
  case value {
    Origin -> 0
    AsPath -> 1
    NextHop -> 2
    Med -> 3
    LocalPref -> 4
    AtomicAggr -> 5
    Aggregator -> 6
    Unknown -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn path_attr_type_from_int(tag: Int) -> Result(PathAttrType, Nil) {
  case tag {
    0 -> Ok(Origin)
    1 -> Ok(AsPath)
    2 -> Ok(NextHop)
    3 -> Ok(Med)
    4 -> Ok(LocalPref)
    5 -> Ok(AtomicAggr)
    6 -> Ok(Aggregator)
    7 -> Ok(Unknown)
    _ -> Error(Nil)
  }
}

