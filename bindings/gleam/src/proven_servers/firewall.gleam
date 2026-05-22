//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Firewall protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `Firewall.Types`          -- actions, protocols, chain types, match criteria,
////                                connection states
//// - `FirewallABI.Layout`      -- C-ABI tag values for all types
//// - `FirewallABI.Transitions` -- rule evaluation state machine

// ===========================================================================
// Action (FirewallABI.Layout.Action, tags 0-7)
// ===========================================================================

/// Firewall rule actions applied to matching packets.
pub type Action {
  Accept
  Drop
  Reject
  Log
  Redirect
  Dnat
  Snat
  Masquerade
}

/// Convert an `Action` to its C-ABI tag value.
pub fn action_to_int(action: Action) -> Int {
  case action {
    Accept -> 0
    Drop -> 1
    Reject -> 2
    Log -> 3
    Redirect -> 4
    Dnat -> 5
    Snat -> 6
    Masquerade -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn action_from_int(tag: Int) -> Result(Action, Nil) {
  case tag {
    0 -> Ok(Accept)
    1 -> Ok(Drop)
    2 -> Ok(Reject)
    3 -> Ok(Log)
    4 -> Ok(Redirect)
    5 -> Ok(Dnat)
    6 -> Ok(Snat)
    7 -> Ok(Masquerade)
    _ -> Error(Nil)
  }
}

/// iptables/nftables action string.
pub fn action_to_string(action: Action) -> String {
  case action {
    Accept -> "ACCEPT"
    Drop -> "DROP"
    Reject -> "REJECT"
    Log -> "LOG"
    Redirect -> "REDIRECT"
    Dnat -> "DNAT"
    Snat -> "SNAT"
    Masquerade -> "MASQUERADE"
  }
}

/// Whether this action terminates rule processing (LOG does not terminate).
pub fn action_is_terminating(action: Action) -> Bool {
  case action {
    Log -> False
    _ -> True
  }
}

/// Whether this action performs network address translation.
pub fn action_is_nat(action: Action) -> Bool {
  case action {
    Dnat | Snat | Masquerade | Redirect -> True
    _ -> False
  }
}

// ===========================================================================
// Protocol (FirewallABI.Layout.Protocol, tags 0-7)
// ===========================================================================

/// IP protocols for firewall rule matching.
pub type FwProtocol {
  Tcp
  Udp
  Icmp
  Icmpv6
  Gre
  Esp
  Ah
  Any
}

/// Convert a `FwProtocol` to its C-ABI tag value.
pub fn protocol_to_int(protocol: FwProtocol) -> Int {
  case protocol {
    Tcp -> 0
    Udp -> 1
    Icmp -> 2
    Icmpv6 -> 3
    Gre -> 4
    Esp -> 5
    Ah -> 6
    Any -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn protocol_from_int(tag: Int) -> Result(FwProtocol, Nil) {
  case tag {
    0 -> Ok(Tcp)
    1 -> Ok(Udp)
    2 -> Ok(Icmp)
    3 -> Ok(Icmpv6)
    4 -> Ok(Gre)
    5 -> Ok(Esp)
    6 -> Ok(Ah)
    7 -> Ok(Any)
    _ -> Error(Nil)
  }
}

/// Protocol name string.
pub fn protocol_to_string(protocol: FwProtocol) -> String {
  case protocol {
    Tcp -> "TCP"
    Udp -> "UDP"
    Icmp -> "ICMP"
    Icmpv6 -> "ICMPv6"
    Gre -> "GRE"
    Esp -> "ESP"
    Ah -> "AH"
    Any -> "ANY"
  }
}

/// IANA protocol number.
pub fn protocol_number(protocol: FwProtocol) -> Int {
  case protocol {
    Tcp -> 6
    Udp -> 17
    Icmp -> 1
    Icmpv6 -> 58
    Gre -> 47
    Esp -> 50
    Ah -> 51
    Any -> 0
  }
}

/// Whether this protocol supports port-based matching.
pub fn protocol_has_ports(protocol: FwProtocol) -> Bool {
  case protocol {
    Tcp | Udp -> True
    _ -> False
  }
}

// ===========================================================================
// ChainType (FirewallABI.Layout.ChainType, tags 0-4)
// ===========================================================================

/// Netfilter chain types for firewall rule organisation.
pub type ChainType {
  Input
  Output
  Forward
  PreRouting
  PostRouting
}

/// Convert a `ChainType` to its C-ABI tag value.
pub fn chain_type_to_int(ct: ChainType) -> Int {
  case ct {
    Input -> 0
    Output -> 1
    Forward -> 2
    PreRouting -> 3
    PostRouting -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn chain_type_from_int(tag: Int) -> Result(ChainType, Nil) {
  case tag {
    0 -> Ok(Input)
    1 -> Ok(Output)
    2 -> Ok(Forward)
    3 -> Ok(PreRouting)
    4 -> Ok(PostRouting)
    _ -> Error(Nil)
  }
}

/// Chain name string.
pub fn chain_type_to_string(ct: ChainType) -> String {
  case ct {
    Input -> "INPUT"
    Output -> "OUTPUT"
    Forward -> "FORWARD"
    PreRouting -> "PREROUTING"
    PostRouting -> "POSTROUTING"
  }
}

/// Whether NAT actions are valid in this chain.
pub fn chain_type_supports_nat(ct: ChainType) -> Bool {
  case ct {
    PreRouting | PostRouting -> True
    _ -> False
  }
}

// ===========================================================================
// RuleMatch (FirewallABI.Layout.RuleMatch, tags 0-7)
// ===========================================================================

/// Match criteria for firewall rules.
pub type RuleMatch {
  SourceIp
  DestIp
  SourcePort
  DestPort
  MatchProto
  MatchInterface
  MatchState
  MatchMark
}

/// Convert a `RuleMatch` to its C-ABI tag value.
pub fn rule_match_to_int(rm: RuleMatch) -> Int {
  case rm {
    SourceIp -> 0
    DestIp -> 1
    SourcePort -> 2
    DestPort -> 3
    MatchProto -> 4
    MatchInterface -> 5
    MatchState -> 6
    MatchMark -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn rule_match_from_int(tag: Int) -> Result(RuleMatch, Nil) {
  case tag {
    0 -> Ok(SourceIp)
    1 -> Ok(DestIp)
    2 -> Ok(SourcePort)
    3 -> Ok(DestPort)
    4 -> Ok(MatchProto)
    5 -> Ok(MatchInterface)
    6 -> Ok(MatchState)
    7 -> Ok(MatchMark)
    _ -> Error(Nil)
  }
}

/// Match criteria name string.
pub fn rule_match_to_string(rm: RuleMatch) -> String {
  case rm {
    SourceIp -> "SourceIP"
    DestIp -> "DestIP"
    SourcePort -> "SourcePort"
    DestPort -> "DestPort"
    MatchProto -> "Protocol"
    MatchInterface -> "Interface"
    MatchState -> "State"
    MatchMark -> "Mark"
  }
}

// ===========================================================================
// ConnState (FirewallABI.Layout.ConnState, tags 0-3)
// ===========================================================================

/// Connection tracking states for stateful firewall inspection.
pub type ConnState {
  New
  Established
  Related
  Invalid
}

/// Convert a `ConnState` to its C-ABI tag value.
pub fn conn_state_to_int(state: ConnState) -> Int {
  case state {
    New -> 0
    Established -> 1
    Related -> 2
    Invalid -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn conn_state_from_int(tag: Int) -> Result(ConnState, Nil) {
  case tag {
    0 -> Ok(New)
    1 -> Ok(Established)
    2 -> Ok(Related)
    3 -> Ok(Invalid)
    _ -> Error(Nil)
  }
}

/// Connection state name string.
pub fn conn_state_to_string(state: ConnState) -> String {
  case state {
    New -> "NEW"
    Established -> "ESTABLISHED"
    Related -> "RELATED"
    Invalid -> "INVALID"
  }
}

/// Whether this state represents an active, valid connection.
pub fn conn_state_is_active(state: ConnState) -> Bool {
  case state {
    Established | Related -> True
    _ -> False
  }
}
