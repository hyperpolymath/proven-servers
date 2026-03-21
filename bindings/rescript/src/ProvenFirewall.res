// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Firewall protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - Firewall.Types        -- actions, protocols, chain types, match criteria,
//                            connection states
// - FirewallABI.Layout    -- C-ABI tag values for all types
// - FirewallABI.Transitions -- rule evaluation state machine
//
// All tag values match the Layout encoders in FirewallABI.Layout exactly.

// ===========================================================================
// Action (FirewallABI.Layout.Action, tags 0-7)
// ===========================================================================

/// Firewall rule actions applied to matching packets.
/// Matches Action in Firewall.Types.
type action =
  | @as(0) Accept
  | @as(1) Drop
  | @as(2) Reject
  | @as(3) Log
  | @as(4) Redirect
  | @as(5) Dnat
  | @as(6) Snat
  | @as(7) Masquerade

/// Decode from C-ABI tag value.
let actionFromTag = (tag: int): option<action> =>
  switch tag {
  | 0 => Some(Accept)
  | 1 => Some(Drop)
  | 2 => Some(Reject)
  | 3 => Some(Log)
  | 4 => Some(Redirect)
  | 5 => Some(Dnat)
  | 6 => Some(Snat)
  | 7 => Some(Masquerade)
  | _ => None
  }

/// Encode to C-ABI tag value.
let actionToTag = (a: action): int =>
  switch a {
  | Accept => 0
  | Drop => 1
  | Reject => 2
  | Log => 3
  | Redirect => 4
  | Dnat => 5
  | Snat => 6
  | Masquerade => 7
  }

/// iptables/nftables action string.
/// Matches Show instance in Firewall.Types.
let actionAsStr = (a: action): string =>
  switch a {
  | Accept => "ACCEPT"
  | Drop => "DROP"
  | Reject => "REJECT"
  | Log => "LOG"
  | Redirect => "REDIRECT"
  | Dnat => "DNAT"
  | Snat => "SNAT"
  | Masquerade => "MASQUERADE"
  }

/// Whether this action terminates rule processing (vs continuing).
/// LOG does not terminate; the packet continues through remaining rules.
let actionIsTerminating = (a: action): bool =>
  switch a {
  | Log => false
  | Accept | Drop | Reject | Redirect | Dnat | Snat | Masquerade => true
  }

/// Whether this action performs network address translation.
let actionIsNat = (a: action): bool =>
  switch a {
  | Dnat | Snat | Masquerade | Redirect => true
  | Accept | Drop | Reject | Log => false
  }

// ===========================================================================
// Protocol (FirewallABI.Layout.Protocol, tags 0-7)
// ===========================================================================

/// IP protocols for firewall rule matching.
/// Matches Protocol in Firewall.Types.
type protocol =
  | @as(0) Tcp
  | @as(1) Udp
  | @as(2) Icmp
  | @as(3) Icmpv6
  | @as(4) Gre
  | @as(5) Esp
  | @as(6) Ah
  | @as(7) Any

/// Decode from C-ABI tag value.
let protocolFromTag = (tag: int): option<protocol> =>
  switch tag {
  | 0 => Some(Tcp)
  | 1 => Some(Udp)
  | 2 => Some(Icmp)
  | 3 => Some(Icmpv6)
  | 4 => Some(Gre)
  | 5 => Some(Esp)
  | 6 => Some(Ah)
  | 7 => Some(Any)
  | _ => None
  }

/// Encode to C-ABI tag value.
let protocolToTag = (p: protocol): int =>
  switch p {
  | Tcp => 0
  | Udp => 1
  | Icmp => 2
  | Icmpv6 => 3
  | Gre => 4
  | Esp => 5
  | Ah => 6
  | Any => 7
  }

/// Protocol name string.
/// Matches Show instance in Firewall.Types.
let protocolAsStr = (p: protocol): string =>
  switch p {
  | Tcp => "TCP"
  | Udp => "UDP"
  | Icmp => "ICMP"
  | Icmpv6 => "ICMPv6"
  | Gre => "GRE"
  | Esp => "ESP"
  | Ah => "AH"
  | Any => "ANY"
  }

/// IANA protocol number.
let protocolNumber = (p: protocol): int =>
  switch p {
  | Tcp => 6
  | Udp => 17
  | Icmp => 1
  | Icmpv6 => 58
  | Gre => 47
  | Esp => 50
  | Ah => 51
  | Any => 0
  }

/// Whether this protocol supports port-based matching.
let protocolHasPorts = (p: protocol): bool =>
  switch p {
  | Tcp | Udp => true
  | Icmp | Icmpv6 | Gre | Esp | Ah | Any => false
  }

// ===========================================================================
// Chain Type (FirewallABI.Layout.ChainType, tags 0-4)
// ===========================================================================

/// Netfilter chain types for firewall rule organisation.
/// Matches ChainType in Firewall.Types.
type chainType =
  | @as(0) Input
  | @as(1) Output
  | @as(2) Forward
  | @as(3) PreRouting
  | @as(4) PostRouting

/// Decode from C-ABI tag value.
let chainTypeFromTag = (tag: int): option<chainType> =>
  switch tag {
  | 0 => Some(Input)
  | 1 => Some(Output)
  | 2 => Some(Forward)
  | 3 => Some(PreRouting)
  | 4 => Some(PostRouting)
  | _ => None
  }

/// Encode to C-ABI tag value.
let chainTypeToTag = (ct: chainType): int =>
  switch ct {
  | Input => 0
  | Output => 1
  | Forward => 2
  | PreRouting => 3
  | PostRouting => 4
  }

/// Chain name string.
/// Matches Show instance in Firewall.Types.
let chainTypeAsStr = (ct: chainType): string =>
  switch ct {
  | Input => "INPUT"
  | Output => "OUTPUT"
  | Forward => "FORWARD"
  | PreRouting => "PREROUTING"
  | PostRouting => "POSTROUTING"
  }

/// Whether NAT actions are valid in this chain.
/// DNAT: PREROUTING only.  SNAT/MASQUERADE: POSTROUTING only.
let chainTypeSupportsNat = (ct: chainType): bool =>
  switch ct {
  | PreRouting | PostRouting => true
  | Input | Output | Forward => false
  }

// ===========================================================================
// Rule Match (FirewallABI.Layout.RuleMatch, tags 0-7)
// ===========================================================================

/// Match criteria for firewall rules.
/// Matches RuleMatch in Firewall.Types.
type ruleMatch =
  | @as(0) SourceIp
  | @as(1) DestIp
  | @as(2) SourcePort
  | @as(3) DestPort
  | @as(4) MatchProto
  | @as(5) Interface
  | @as(6) State
  | @as(7) Mark

/// Decode from C-ABI tag value.
let ruleMatchFromTag = (tag: int): option<ruleMatch> =>
  switch tag {
  | 0 => Some(SourceIp)
  | 1 => Some(DestIp)
  | 2 => Some(SourcePort)
  | 3 => Some(DestPort)
  | 4 => Some(MatchProto)
  | 5 => Some(Interface)
  | 6 => Some(State)
  | 7 => Some(Mark)
  | _ => None
  }

/// Encode to C-ABI tag value.
let ruleMatchToTag = (rm: ruleMatch): int =>
  switch rm {
  | SourceIp => 0
  | DestIp => 1
  | SourcePort => 2
  | DestPort => 3
  | MatchProto => 4
  | Interface => 5
  | State => 6
  | Mark => 7
  }

/// Match criteria name string.
/// Matches Show instance in Firewall.Types.
let ruleMatchAsStr = (rm: ruleMatch): string =>
  switch rm {
  | SourceIp => "SourceIP"
  | DestIp => "DestIP"
  | SourcePort => "SourcePort"
  | DestPort => "DestPort"
  | MatchProto => "Protocol"
  | Interface => "Interface"
  | State => "State"
  | Mark => "Mark"
  }

// ===========================================================================
// Connection State (FirewallABI.Layout.ConnState, tags 0-3)
// ===========================================================================

/// Connection tracking states for stateful firewall inspection.
/// Matches ConnState in Firewall.Types.
type connState =
  | @as(0) New
  | @as(1) Established
  | @as(2) Related
  | @as(3) Invalid

/// Decode from C-ABI tag value.
let connStateFromTag = (tag: int): option<connState> =>
  switch tag {
  | 0 => Some(New)
  | 1 => Some(Established)
  | 2 => Some(Related)
  | 3 => Some(Invalid)
  | _ => None
  }

/// Encode to C-ABI tag value.
let connStateToTag = (s: connState): int =>
  switch s {
  | New => 0
  | Established => 1
  | Related => 2
  | Invalid => 3
  }

/// Connection state name string.
/// Matches Show instance in Firewall.Types.
let connStateAsStr = (s: connState): string =>
  switch s {
  | New => "NEW"
  | Established => "ESTABLISHED"
  | Related => "RELATED"
  | Invalid => "INVALID"
  }

/// Whether this state represents an active, valid connection.
let connStateIsActive = (s: connState): bool =>
  switch s {
  | Established | Related => true
  | New | Invalid => false
  }
