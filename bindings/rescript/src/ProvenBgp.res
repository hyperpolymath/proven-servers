// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module BgpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard BGP port (RFC 4271).
let bgpPort = 179

// ===========================================================================
// BgpState (tags 0-5)
// ===========================================================================

/// Standard BGP port (RFC 4271).
type bgpState =
  | @as(0) Idle
  | @as(1) Connect
  | @as(2) Active
  | @as(3) OpenSent
  | @as(4) OpenConfirm
  | @as(5) Established

/// Decode from the C-ABI tag value.
let bgpStateFromTag = (tag: int): option<bgpState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connect)
  | 2 => Some(Active)
  | 3 => Some(OpenSent)
  | 4 => Some(OpenConfirm)
  | 5 => Some(Established)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let bgpStateToTag = (v: bgpState): int =>
  switch v {
  | Idle => 0
  | Connect => 1
  | Active => 2
  | OpenSent => 3
  | OpenConfirm => 4
  | Established => 5
  }

/// Whether routes can be exchanged in this state.
let bgpStateIsRouteExchange = (v: bgpState): bool =>
  switch v {
  | Established => true
  | _ => false
  }

/// Whether a TCP connection exists in this state.
let bgpStateHasConnection = (v: bgpState): bool =>
  switch v {
  | OpenSent | OpenConfirm | Established => true
  | _ => false
  }

// ===========================================================================
// BgpEvent (tags 0-18)
// ===========================================================================

/// Decode from an ABI tag value.
type bgpEvent =
  | @as(0) ManualStart
  | @as(1) ManualStop
  | @as(2) AutomaticStart
  | @as(3) ConnectRetryTimerExpires
  | @as(4) HoldTimerExpires
  | @as(5) KeepaliveTimerExpires
  | @as(6) DelayOpenTimerExpires
  | @as(7) TcpConnectionValid
  | @as(8) TcpCrAcked
  | @as(9) TcpConnectionConfirmed
  | @as(10) TcpConnectionFails
  | @as(11) BgpOpenReceived
  | @as(12) BgpHeaderErr
  | @as(13) BgpOpenMsgErr
  | @as(14) NotifMsgVerErr
  | @as(15) NotifMsg
  | @as(16) KeepaliveMsg
  | @as(17) UpdateMsg
  | @as(18) UpdateMsgErr

/// Decode from the C-ABI tag value.
let bgpEventFromTag = (tag: int): option<bgpEvent> =>
  switch tag {
  | 0 => Some(ManualStart)
  | 1 => Some(ManualStop)
  | 2 => Some(AutomaticStart)
  | 3 => Some(ConnectRetryTimerExpires)
  | 4 => Some(HoldTimerExpires)
  | 5 => Some(KeepaliveTimerExpires)
  | 6 => Some(DelayOpenTimerExpires)
  | 7 => Some(TcpConnectionValid)
  | 8 => Some(TcpCrAcked)
  | 9 => Some(TcpConnectionConfirmed)
  | 10 => Some(TcpConnectionFails)
  | 11 => Some(BgpOpenReceived)
  | 12 => Some(BgpHeaderErr)
  | 13 => Some(BgpOpenMsgErr)
  | 14 => Some(NotifMsgVerErr)
  | 15 => Some(NotifMsg)
  | 16 => Some(KeepaliveMsg)
  | 17 => Some(UpdateMsg)
  | 18 => Some(UpdateMsgErr)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let bgpEventToTag = (v: bgpEvent): int =>
  switch v {
  | ManualStart => 0
  | ManualStop => 1
  | AutomaticStart => 2
  | ConnectRetryTimerExpires => 3
  | HoldTimerExpires => 4
  | KeepaliveTimerExpires => 5
  | DelayOpenTimerExpires => 6
  | TcpConnectionValid => 7
  | TcpCrAcked => 8
  | TcpConnectionConfirmed => 9
  | TcpConnectionFails => 10
  | BgpOpenReceived => 11
  | BgpHeaderErr => 12
  | BgpOpenMsgErr => 13
  | NotifMsgVerErr => 14
  | NotifMsg => 15
  | KeepaliveMsg => 16
  | UpdateMsg => 17
  | UpdateMsgErr => 18
  }

/// Whether this event is a timer expiry.
let bgpEventIsTimerEvent = (v: bgpEvent): bool =>
  switch v {
  | ConnectRetryTimerExpires | HoldTimerExpires | KeepaliveTimerExpires | DelayOpenTimerExpires => true
  | _ => false
  }

/// Whether this event indicates an error.
let bgpEventIsErrorEvent = (v: bgpEvent): bool =>
  switch v {
  | TcpConnectionFails | BgpHeaderErr | BgpOpenMsgErr | NotifMsgVerErr | UpdateMsgErr => true
  | _ => false
  }

// ===========================================================================
// MessageType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type messageType =
  | @as(0) Open
  | @as(1) Update
  | @as(2) Notification
  | @as(3) Keepalive

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(Open)
  | 1 => Some(Update)
  | 2 => Some(Notification)
  | 3 => Some(Keepalive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | Open => 0
  | Update => 1
  | Notification => 2
  | Keepalive => 3
  }

// ===========================================================================
// ErrorCode (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) MessageHeaderError
  | @as(1) OpenMessageError
  | @as(2) UpdateMessageError
  | @as(3) HoldTimerExpired
  | @as(4) FsmError
  | @as(5) Cease

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(MessageHeaderError)
  | 1 => Some(OpenMessageError)
  | 2 => Some(UpdateMessageError)
  | 3 => Some(HoldTimerExpired)
  | 4 => Some(FsmError)
  | 5 => Some(Cease)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | MessageHeaderError => 0
  | OpenMessageError => 1
  | UpdateMessageError => 2
  | HoldTimerExpired => 3
  | FsmError => 4
  | Cease => 5
  }

// ===========================================================================
// Origin (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type origin =
  | @as(0) Igp
  | @as(1) Egp
  | @as(2) Incomplete

/// Decode from the C-ABI tag value.
let originFromTag = (tag: int): option<origin> =>
  switch tag {
  | 0 => Some(Igp)
  | 1 => Some(Egp)
  | 2 => Some(Incomplete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let originToTag = (v: origin): int =>
  switch v {
  | Igp => 0
  | Egp => 1
  | Incomplete => 2
  }

// ===========================================================================
// AsPathSegmentType (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type asPathSegmentType =
  | @as(0) AsSet
  | @as(1) AsSequence

/// Decode from the C-ABI tag value.
let asPathSegmentTypeFromTag = (tag: int): option<asPathSegmentType> =>
  switch tag {
  | 0 => Some(AsSet)
  | 1 => Some(AsSequence)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let asPathSegmentTypeToTag = (v: asPathSegmentType): int =>
  switch v {
  | AsSet => 0
  | AsSequence => 1
  }

// ===========================================================================
// PathAttrType (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type pathAttrType =
  | @as(0) Origin
  | @as(1) AsPath
  | @as(2) NextHop
  | @as(3) Med
  | @as(4) LocalPref
  | @as(5) AtomicAggr
  | @as(6) Aggregator
  | @as(7) Unknown

/// Decode from the C-ABI tag value.
let pathAttrTypeFromTag = (tag: int): option<pathAttrType> =>
  switch tag {
  | 0 => Some(Origin)
  | 1 => Some(AsPath)
  | 2 => Some(NextHop)
  | 3 => Some(Med)
  | 4 => Some(LocalPref)
  | 5 => Some(AtomicAggr)
  | 6 => Some(Aggregator)
  | 7 => Some(Unknown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let pathAttrTypeToTag = (v: pathAttrType): int =>
  switch v {
  | Origin => 0
  | AsPath => 1
  | NextHop => 2
  | Med => 3
  | LocalPref => 4
  | AtomicAggr => 5
  | Aggregator => 6
  | Unknown => 7
  }

/// Whether this attribute is mandatory (well-known mandatory per RFC 4271).
let pathAttrTypeIsMandatory = (v: pathAttrType): bool =>
  switch v {
  | Origin | AsPath | NextHop => true
  | _ => false
  }

