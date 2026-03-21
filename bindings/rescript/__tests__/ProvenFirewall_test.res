// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenFirewall protocol bindings.

open ProvenFirewall

let test_action_roundtrip = () => {
  assert(actionFromTag(0) == Some(Accept))
  assert(actionFromTag(1) == Some(Drop))
  assert(actionFromTag(2) == Some(Reject))
  assert(actionFromTag(3) == Some(Log))
  assert(actionFromTag(4) == Some(Redirect))
  assert(actionFromTag(5) == Some(Dnat))
  assert(actionFromTag(6) == Some(Snat))
  assert(actionFromTag(7) == Some(Masquerade))
  assert(actionFromTag(8) == None)
}

let test_action_toTag = () => {
  assert(actionToTag(Accept) == 0)
  assert(actionToTag(Drop) == 1)
  assert(actionToTag(Reject) == 2)
  assert(actionToTag(Log) == 3)
  assert(actionToTag(Redirect) == 4)
  assert(actionToTag(Dnat) == 5)
  assert(actionToTag(Snat) == 6)
  assert(actionToTag(Masquerade) == 7)
}

let test_protocol_roundtrip = () => {
  assert(protocolFromTag(0) == Some(Tcp))
  assert(protocolFromTag(1) == Some(Udp))
  assert(protocolFromTag(2) == Some(Icmp))
  assert(protocolFromTag(3) == Some(Icmpv6))
  assert(protocolFromTag(4) == Some(Gre))
  assert(protocolFromTag(5) == Some(Esp))
  assert(protocolFromTag(6) == Some(Ah))
  assert(protocolFromTag(7) == Some(Any))
  assert(protocolFromTag(8) == None)
}

let test_protocol_toTag = () => {
  assert(protocolToTag(Tcp) == 0)
  assert(protocolToTag(Udp) == 1)
  assert(protocolToTag(Icmp) == 2)
  assert(protocolToTag(Icmpv6) == 3)
  assert(protocolToTag(Gre) == 4)
  assert(protocolToTag(Esp) == 5)
  assert(protocolToTag(Ah) == 6)
  assert(protocolToTag(Any) == 7)
}

let test_chainType_roundtrip = () => {
  assert(chainTypeFromTag(0) == Some(Input))
  assert(chainTypeFromTag(1) == Some(Output))
  assert(chainTypeFromTag(2) == Some(Forward))
  assert(chainTypeFromTag(3) == Some(PreRouting))
  assert(chainTypeFromTag(4) == Some(PostRouting))
  assert(chainTypeFromTag(5) == None)
}

let test_chainType_toTag = () => {
  assert(chainTypeToTag(Input) == 0)
  assert(chainTypeToTag(Output) == 1)
  assert(chainTypeToTag(Forward) == 2)
  assert(chainTypeToTag(PreRouting) == 3)
  assert(chainTypeToTag(PostRouting) == 4)
}

let test_ruleMatchType_roundtrip = () => {
  assert(ruleMatchTypeFromTag(0) == Some(SourceIp))
  assert(ruleMatchTypeFromTag(1) == Some(DestIp))
  assert(ruleMatchTypeFromTag(2) == Some(SourcePort))
  assert(ruleMatchTypeFromTag(3) == Some(DestPort))
  assert(ruleMatchTypeFromTag(4) == Some(MatchProto))
  assert(ruleMatchTypeFromTag(5) == Some(Interface))
  assert(ruleMatchTypeFromTag(6) == Some(State))
  assert(ruleMatchTypeFromTag(7) == Some(Mark))
  assert(ruleMatchTypeFromTag(8) == None)
}

let test_ruleMatchType_toTag = () => {
  assert(ruleMatchTypeToTag(SourceIp) == 0)
  assert(ruleMatchTypeToTag(DestIp) == 1)
  assert(ruleMatchTypeToTag(SourcePort) == 2)
  assert(ruleMatchTypeToTag(DestPort) == 3)
  assert(ruleMatchTypeToTag(MatchProto) == 4)
  assert(ruleMatchTypeToTag(Interface) == 5)
  assert(ruleMatchTypeToTag(State) == 6)
  assert(ruleMatchTypeToTag(Mark) == 7)
}

let test_connState_roundtrip = () => {
  assert(connStateFromTag(0) == Some(New))
  assert(connStateFromTag(1) == Some(Established))
  assert(connStateFromTag(2) == Some(Related))
  assert(connStateFromTag(3) == Some(Invalid))
  assert(connStateFromTag(4) == None)
}

let test_connState_toTag = () => {
  assert(connStateToTag(New) == 0)
  assert(connStateToTag(Established) == 1)
  assert(connStateToTag(Related) == 2)
  assert(connStateToTag(Invalid) == 3)
}

// Run all tests
test_action_roundtrip()
test_action_toTag()
test_protocol_roundtrip()
test_protocol_toTag()
test_chainType_roundtrip()
test_chainType_toTag()
test_ruleMatchType_roundtrip()
test_ruleMatchType_toTag()
test_connState_roundtrip()
test_connState_toTag()
