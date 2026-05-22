// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSdn protocol bindings.

open ProvenSdn

let test_sdnMessageType_roundtrip = () => {
  assert(sdnMessageTypeFromTag(0) == Some(Hello))
  assert(sdnMessageTypeFromTag(1) == Some(Error))
  assert(sdnMessageTypeFromTag(2) == Some(EchoRequest))
  assert(sdnMessageTypeFromTag(3) == Some(EchoReply))
  assert(sdnMessageTypeFromTag(4) == Some(FeaturesRequest))
  assert(sdnMessageTypeFromTag(5) == Some(FeaturesReply))
  assert(sdnMessageTypeFromTag(6) == Some(FlowMod))
  assert(sdnMessageTypeFromTag(7) == Some(PacketIn))
  assert(sdnMessageTypeFromTag(8) == Some(PacketOut))
  assert(sdnMessageTypeFromTag(9) == Some(PortStatus))
  assert(sdnMessageTypeFromTag(10) == Some(BarrierRequest))
  assert(sdnMessageTypeFromTag(11) == Some(BarrierReply))
  assert(sdnMessageTypeFromTag(12) == None)
}

let test_sdnMessageType_toTag = () => {
  assert(sdnMessageTypeToTag(Hello) == 0)
  assert(sdnMessageTypeToTag(Error) == 1)
  assert(sdnMessageTypeToTag(EchoRequest) == 2)
  assert(sdnMessageTypeToTag(EchoReply) == 3)
  assert(sdnMessageTypeToTag(FeaturesRequest) == 4)
  assert(sdnMessageTypeToTag(FeaturesReply) == 5)
  assert(sdnMessageTypeToTag(FlowMod) == 6)
  assert(sdnMessageTypeToTag(PacketIn) == 7)
  assert(sdnMessageTypeToTag(PacketOut) == 8)
  assert(sdnMessageTypeToTag(PortStatus) == 9)
  assert(sdnMessageTypeToTag(BarrierRequest) == 10)
  assert(sdnMessageTypeToTag(BarrierReply) == 11)
}

let test_flowAction_roundtrip = () => {
  assert(flowActionFromTag(0) == Some(Output))
  assert(flowActionFromTag(1) == Some(SetField))
  assert(flowActionFromTag(2) == Some(Drop))
  assert(flowActionFromTag(3) == Some(PushVlan))
  assert(flowActionFromTag(4) == Some(PopVlan))
  assert(flowActionFromTag(5) == Some(SetQueue))
  assert(flowActionFromTag(6) == Some(Group))
  assert(flowActionFromTag(7) == None)
}

let test_flowAction_toTag = () => {
  assert(flowActionToTag(Output) == 0)
  assert(flowActionToTag(SetField) == 1)
  assert(flowActionToTag(Drop) == 2)
  assert(flowActionToTag(PushVlan) == 3)
  assert(flowActionToTag(PopVlan) == 4)
  assert(flowActionToTag(SetQueue) == 5)
  assert(flowActionToTag(Group) == 6)
}

let test_matchField_roundtrip = () => {
  assert(matchFieldFromTag(0) == Some(InPort))
  assert(matchFieldFromTag(1) == Some(EthDst))
  assert(matchFieldFromTag(2) == Some(EthSrc))
  assert(matchFieldFromTag(3) == Some(EthType))
  assert(matchFieldFromTag(4) == Some(VlanId))
  assert(matchFieldFromTag(5) == Some(IpSrc))
  assert(matchFieldFromTag(6) == Some(IpDst))
  assert(matchFieldFromTag(7) == Some(TcpSrc))
  assert(matchFieldFromTag(8) == Some(TcpDst))
  assert(matchFieldFromTag(9) == Some(UdpSrc))
  assert(matchFieldFromTag(10) == Some(UdpDst))
  assert(matchFieldFromTag(11) == None)
}

let test_matchField_toTag = () => {
  assert(matchFieldToTag(InPort) == 0)
  assert(matchFieldToTag(EthDst) == 1)
  assert(matchFieldToTag(EthSrc) == 2)
  assert(matchFieldToTag(EthType) == 3)
  assert(matchFieldToTag(VlanId) == 4)
  assert(matchFieldToTag(IpSrc) == 5)
  assert(matchFieldToTag(IpDst) == 6)
  assert(matchFieldToTag(TcpSrc) == 7)
  assert(matchFieldToTag(TcpDst) == 8)
  assert(matchFieldToTag(UdpSrc) == 9)
  assert(matchFieldToTag(UdpDst) == 10)
}

let test_portState_roundtrip = () => {
  assert(portStateFromTag(0) == Some(Up))
  assert(portStateFromTag(1) == Some(Down))
  assert(portStateFromTag(2) == Some(Blocked))
  assert(portStateFromTag(3) == None)
}

let test_portState_toTag = () => {
  assert(portStateToTag(Up) == 0)
  assert(portStateToTag(Down) == 1)
  assert(portStateToTag(Blocked) == 2)
}

// Run all tests
test_sdnMessageType_roundtrip()
test_sdnMessageType_toTag()
test_flowAction_roundtrip()
test_flowAction_toTag()
test_matchField_roundtrip()
test_matchField_toTag()
test_portState_roundtrip()
test_portState_toTag()
