// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Firewall types for the proven-servers ABI.
//
// Mirrors the Idris2 module FirewallABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Action (tags 0-7)
// ===========================================================================

/// Firewall rule actions.
type action =
  | @as(0) Accept
  | @as(1) Drop
  | @as(2) Reject
  | @as(3) Log
  | @as(4) Redirect
  | @as(5) Dnat
  | @as(6) Snat
  | @as(7) Masquerade

/// Decode from the C-ABI tag value.
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

/// Encode to the C-ABI tag value.
let actionToTag = (v: action): int =>
  switch v {
  | Accept => 0
  | Drop => 1
  | Reject => 2
  | Log => 3
  | Redirect => 4
  | Dnat => 5
  | Snat => 6
  | Masquerade => 7
  }

/// Whether this action allows traffic.
let actionIsPermissive = (v: action): bool =>
  switch v {
  | Accept | Redirect | Dnat | Snat | Masquerade => true
  | _ => false
  }

// ===========================================================================
// Protocol (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type protocol =
  | @as(0) Tcp
  | @as(1) Udp
  | @as(2) Icmp
  | @as(3) Icmpv6
  | @as(4) Gre
  | @as(5) Esp
  | @as(6) Ah
  | @as(7) Any

/// Decode from the C-ABI tag value.
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

/// Encode to the C-ABI tag value.
let protocolToTag = (v: protocol): int =>
  switch v {
  | Tcp => 0
  | Udp => 1
  | Icmp => 2
  | Icmpv6 => 3
  | Gre => 4
  | Esp => 5
  | Ah => 6
  | Any => 7
  }

// ===========================================================================
// ChainType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type chainType =
  | @as(0) Input
  | @as(1) Output
  | @as(2) Forward
  | @as(3) PreRouting
  | @as(4) PostRouting

/// Decode from the C-ABI tag value.
let chainTypeFromTag = (tag: int): option<chainType> =>
  switch tag {
  | 0 => Some(Input)
  | 1 => Some(Output)
  | 2 => Some(Forward)
  | 3 => Some(PreRouting)
  | 4 => Some(PostRouting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let chainTypeToTag = (v: chainType): int =>
  switch v {
  | Input => 0
  | Output => 1
  | Forward => 2
  | PreRouting => 3
  | PostRouting => 4
  }

// ===========================================================================
// RuleMatchType (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type ruleMatchType =
  | @as(0) SourceIp
  | @as(1) DestIp
  | @as(2) SourcePort
  | @as(3) DestPort
  | @as(4) MatchProto
  | @as(5) Interface
  | @as(6) State
  | @as(7) Mark

/// Decode from the C-ABI tag value.
let ruleMatchTypeFromTag = (tag: int): option<ruleMatchType> =>
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

/// Encode to the C-ABI tag value.
let ruleMatchTypeToTag = (v: ruleMatchType): int =>
  switch v {
  | SourceIp => 0
  | DestIp => 1
  | SourcePort => 2
  | DestPort => 3
  | MatchProto => 4
  | Interface => 5
  | State => 6
  | Mark => 7
  }

// ===========================================================================
// ConnState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type connState =
  | @as(0) New
  | @as(1) Established
  | @as(2) Related
  | @as(3) Invalid

/// Decode from the C-ABI tag value.
let connStateFromTag = (tag: int): option<connState> =>
  switch tag {
  | 0 => Some(New)
  | 1 => Some(Established)
  | 2 => Some(Related)
  | 3 => Some(Invalid)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let connStateToTag = (v: connState): int =>
  switch v {
  | New => 0
  | Established => 1
  | Related => 2
  | Invalid => 3
  }

