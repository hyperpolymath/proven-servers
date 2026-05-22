// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN types for the proven-servers ABI.
//
// Mirrors the Idris2 module SdnABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard OpenFlow port.
let sdnPort = 6653

// ===========================================================================
// SdnMessageType (tags 0-11)
// ===========================================================================

/// Standard OpenFlow port.
type sdnMessageType =
  | @as(0) Hello
  | @as(1) Error
  | @as(2) EchoRequest
  | @as(3) EchoReply
  | @as(4) FeaturesRequest
  | @as(5) FeaturesReply
  | @as(6) FlowMod
  | @as(7) PacketIn
  | @as(8) PacketOut
  | @as(9) PortStatus
  | @as(10) BarrierRequest
  | @as(11) BarrierReply

/// Decode from the C-ABI tag value.
let sdnMessageTypeFromTag = (tag: int): option<sdnMessageType> =>
  switch tag {
  | 0 => Some(Hello)
  | 1 => Some(Error)
  | 2 => Some(EchoRequest)
  | 3 => Some(EchoReply)
  | 4 => Some(FeaturesRequest)
  | 5 => Some(FeaturesReply)
  | 6 => Some(FlowMod)
  | 7 => Some(PacketIn)
  | 8 => Some(PacketOut)
  | 9 => Some(PortStatus)
  | 10 => Some(BarrierRequest)
  | 11 => Some(BarrierReply)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sdnMessageTypeToTag = (v: sdnMessageType): int =>
  switch v {
  | Hello => 0
  | Error => 1
  | EchoRequest => 2
  | EchoReply => 3
  | FeaturesRequest => 4
  | FeaturesReply => 5
  | FlowMod => 6
  | PacketIn => 7
  | PacketOut => 8
  | PortStatus => 9
  | BarrierRequest => 10
  | BarrierReply => 11
  }

// ===========================================================================
// FlowAction (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type flowAction =
  | @as(0) Output
  | @as(1) SetField
  | @as(2) Drop
  | @as(3) PushVlan
  | @as(4) PopVlan
  | @as(5) SetQueue
  | @as(6) Group

/// Decode from the C-ABI tag value.
let flowActionFromTag = (tag: int): option<flowAction> =>
  switch tag {
  | 0 => Some(Output)
  | 1 => Some(SetField)
  | 2 => Some(Drop)
  | 3 => Some(PushVlan)
  | 4 => Some(PopVlan)
  | 5 => Some(SetQueue)
  | 6 => Some(Group)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let flowActionToTag = (v: flowAction): int =>
  switch v {
  | Output => 0
  | SetField => 1
  | Drop => 2
  | PushVlan => 3
  | PopVlan => 4
  | SetQueue => 5
  | Group => 6
  }

// ===========================================================================
// MatchField (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type matchField =
  | @as(0) InPort
  | @as(1) EthDst
  | @as(2) EthSrc
  | @as(3) EthType
  | @as(4) VlanId
  | @as(5) IpSrc
  | @as(6) IpDst
  | @as(7) TcpSrc
  | @as(8) TcpDst
  | @as(9) UdpSrc
  | @as(10) UdpDst

/// Decode from the C-ABI tag value.
let matchFieldFromTag = (tag: int): option<matchField> =>
  switch tag {
  | 0 => Some(InPort)
  | 1 => Some(EthDst)
  | 2 => Some(EthSrc)
  | 3 => Some(EthType)
  | 4 => Some(VlanId)
  | 5 => Some(IpSrc)
  | 6 => Some(IpDst)
  | 7 => Some(TcpSrc)
  | 8 => Some(TcpDst)
  | 9 => Some(UdpSrc)
  | 10 => Some(UdpDst)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let matchFieldToTag = (v: matchField): int =>
  switch v {
  | InPort => 0
  | EthDst => 1
  | EthSrc => 2
  | EthType => 3
  | VlanId => 4
  | IpSrc => 5
  | IpDst => 6
  | TcpSrc => 7
  | TcpDst => 8
  | UdpSrc => 9
  | UdpDst => 10
  }

// ===========================================================================
// PortState (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type portState =
  | @as(0) Up
  | @as(1) Down
  | @as(2) Blocked

/// Decode from the C-ABI tag value.
let portStateFromTag = (tag: int): option<portState> =>
  switch tag {
  | 0 => Some(Up)
  | 1 => Some(Down)
  | 2 => Some(Blocked)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let portStateToTag = (v: portState): int =>
  switch v {
  | Up => 0
  | Down => 1
  | Blocked => 2
  }

