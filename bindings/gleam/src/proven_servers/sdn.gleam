//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SDN (OpenFlow) protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SdnABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SDN (OpenFlow) Constants
// ===========================================================================

/// Sdn Port constant.
pub const sdn_port = 6653

// ===========================================================================
// SdnMessageType
// ===========================================================================

/// SDN/OpenFlow message types.
/// 
/// Matches `SdnMessageType` in `SdnABI.Types`.
pub type SdnMessageType {
  /// Hello (tag 0).
  Hello
  /// Error (tag 1).
  SdnMessageTypeError
  /// EchoRequest (tag 2).
  EchoRequest
  /// EchoReply (tag 3).
  EchoReply
  /// FeaturesRequest (tag 4).
  FeaturesRequest
  /// FeaturesReply (tag 5).
  FeaturesReply
  /// FlowMod (tag 6).
  FlowMod
  /// PacketIn (tag 7).
  PacketIn
  /// PacketOut (tag 8).
  PacketOut
  /// PortStatus (tag 9).
  PortStatus
  /// BarrierRequest (tag 10).
  BarrierRequest
  /// BarrierReply (tag 11).
  BarrierReply
}

/// Convert a `SdnMessageType` to its C-ABI tag value.
pub fn sdn_message_type_to_int(value: SdnMessageType) -> Int {
  case value {
    Hello -> 0
    SdnMessageTypeError -> 1
    EchoRequest -> 2
    EchoReply -> 3
    FeaturesRequest -> 4
    FeaturesReply -> 5
    FlowMod -> 6
    PacketIn -> 7
    PacketOut -> 8
    PortStatus -> 9
    BarrierRequest -> 10
    BarrierReply -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn sdn_message_type_from_int(tag: Int) -> Result(SdnMessageType, Nil) {
  case tag {
    0 -> Ok(Hello)
    1 -> Ok(SdnMessageTypeError)
    2 -> Ok(EchoRequest)
    3 -> Ok(EchoReply)
    4 -> Ok(FeaturesRequest)
    5 -> Ok(FeaturesReply)
    6 -> Ok(FlowMod)
    7 -> Ok(PacketIn)
    8 -> Ok(PacketOut)
    9 -> Ok(PortStatus)
    10 -> Ok(BarrierRequest)
    11 -> Ok(BarrierReply)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FlowAction
// ===========================================================================

/// OpenFlow flow actions.
/// 
/// Matches `FlowAction` in `SdnABI.Types`.
pub type FlowAction {
  /// Output (tag 0).
  Output
  /// SetField (tag 1).
  SetField
  /// Drop (tag 2).
  Drop
  /// Push VLAN (tag 3).
  PushVlan
  /// Pop VLAN (tag 4).
  PopVlan
  /// SetQueue (tag 5).
  SetQueue
  /// Group (tag 6).
  Group
}

/// Convert a `FlowAction` to its C-ABI tag value.
pub fn flow_action_to_int(value: FlowAction) -> Int {
  case value {
    Output -> 0
    SetField -> 1
    Drop -> 2
    PushVlan -> 3
    PopVlan -> 4
    SetQueue -> 5
    Group -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn flow_action_from_int(tag: Int) -> Result(FlowAction, Nil) {
  case tag {
    0 -> Ok(Output)
    1 -> Ok(SetField)
    2 -> Ok(Drop)
    3 -> Ok(PushVlan)
    4 -> Ok(PopVlan)
    5 -> Ok(SetQueue)
    6 -> Ok(Group)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// MatchField
// ===========================================================================

/// OpenFlow match fields.
/// 
/// Matches `MatchField` in `SdnABI.Types`.
pub type MatchField {
  /// InPort (tag 0).
  InPort
  /// EthDst (tag 1).
  EthDst
  /// EthSrc (tag 2).
  EthSrc
  /// EthType (tag 3).
  EthType
  /// VLAN ID (tag 4).
  VlanId
  /// IP source (tag 5).
  IpSrc
  /// IP destination (tag 6).
  IpDst
  /// TCP source (tag 7).
  TcpSrc
  /// TCP destination (tag 8).
  TcpDst
  /// UDP source (tag 9).
  UdpSrc
  /// UDP destination (tag 10).
  UdpDst
}

/// Convert a `MatchField` to its C-ABI tag value.
pub fn match_field_to_int(value: MatchField) -> Int {
  case value {
    InPort -> 0
    EthDst -> 1
    EthSrc -> 2
    EthType -> 3
    VlanId -> 4
    IpSrc -> 5
    IpDst -> 6
    TcpSrc -> 7
    TcpDst -> 8
    UdpSrc -> 9
    UdpDst -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn match_field_from_int(tag: Int) -> Result(MatchField, Nil) {
  case tag {
    0 -> Ok(InPort)
    1 -> Ok(EthDst)
    2 -> Ok(EthSrc)
    3 -> Ok(EthType)
    4 -> Ok(VlanId)
    5 -> Ok(IpSrc)
    6 -> Ok(IpDst)
    7 -> Ok(TcpSrc)
    8 -> Ok(TcpDst)
    9 -> Ok(UdpSrc)
    10 -> Ok(UdpDst)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PortState
// ===========================================================================

/// SDN port states.
/// 
/// Matches `PortState` in `SdnABI.Types`.
pub type PortState {
  /// Up (tag 0).
  Up
  /// Down (tag 1).
  Down
  /// Blocked (tag 2).
  Blocked
}

/// Convert a `PortState` to its C-ABI tag value.
pub fn port_state_to_int(value: PortState) -> Int {
  case value {
    Up -> 0
    Down -> 1
    Blocked -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn port_state_from_int(tag: Int) -> Result(PortState, Nil) {
  case tag {
    0 -> Ok(Up)
    1 -> Ok(Down)
    2 -> Ok(Blocked)
    _ -> Error(Nil)
  }
}

