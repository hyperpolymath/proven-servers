-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

-- | Core packet filtering types as closed sum types.
-- | Models firewall rule actions, IP protocols, traffic direction,
-- | match criteria, and connection tracking states.
module Firewall.Types

%default total

-------------------------------------------------------------------------------
-- Actions
-------------------------------------------------------------------------------

||| Firewall rule actions applied to matching packets.
public export
data Action : Type where
  Accept     : Action
  Drop       : Action
  Reject     : Action
  Log        : Action
  Redirect   : Action
  DNAT       : Action
  SNAT       : Action
  Masquerade : Action

||| Show instance for Action.
export
Show Action where
  show Accept     = "ACCEPT"
  show Drop       = "DROP"
  show Reject     = "REJECT"
  show Log        = "LOG"
  show Redirect   = "REDIRECT"
  show DNAT       = "DNAT"
  show SNAT       = "SNAT"
  show Masquerade = "MASQUERADE"

-------------------------------------------------------------------------------
-- Protocols
-------------------------------------------------------------------------------

||| IP protocols for firewall rule matching.
public export
data Protocol : Type where
  TCP    : Protocol
  UDP    : Protocol
  ICMP   : Protocol
  ICMPv6 : Protocol
  GRE    : Protocol
  ESP    : Protocol
  AH     : Protocol
  Any    : Protocol

||| Show instance for Protocol.
export
Show Protocol where
  show TCP    = "TCP"
  show UDP    = "UDP"
  show ICMP   = "ICMP"
  show ICMPv6 = "ICMPv6"
  show GRE    = "GRE"
  show ESP    = "ESP"
  show AH     = "AH"
  show Any    = "ANY"

-------------------------------------------------------------------------------
-- Direction
-------------------------------------------------------------------------------

||| Netfilter chain types for firewall rule organisation.
public export
data ChainType : Type where
  Input       : ChainType
  Output      : ChainType
  Forward     : ChainType
  PreRouting  : ChainType
  PostRouting : ChainType

||| Show instance for ChainType.
export
Show ChainType where
  show Input       = "INPUT"
  show Output      = "OUTPUT"
  show Forward     = "FORWARD"
  show PreRouting  = "PREROUTING"
  show PostRouting = "POSTROUTING"

-------------------------------------------------------------------------------
-- Rule Match Criteria
-------------------------------------------------------------------------------

||| Match criteria for firewall rules.
||| Each constructor represents a different field to match against.
public export
data RuleMatch : Type where
  SourceIP   : RuleMatch
  DestIP     : RuleMatch
  SourcePort : RuleMatch
  DestPort   : RuleMatch
  MatchProto : RuleMatch
  Interface  : RuleMatch
  State      : RuleMatch
  Mark       : RuleMatch

||| Show instance for RuleMatch.
export
Show RuleMatch where
  show SourceIP   = "SourceIP"
  show DestIP     = "DestIP"
  show SourcePort = "SourcePort"
  show DestPort   = "DestPort"
  show MatchProto = "Protocol"
  show Interface  = "Interface"
  show State      = "State"
  show Mark       = "Mark"

-------------------------------------------------------------------------------
-- Connection States
-------------------------------------------------------------------------------

||| Connection tracking states for stateful firewall inspection.
public export
data ConnState : Type where
  New         : ConnState
  Established : ConnState
  Related     : ConnState
  Invalid     : ConnState

||| Show instance for ConnState.
export
Show ConnState where
  show New         = "NEW"
  show Established = "ESTABLISHED"
  show Related     = "RELATED"
  show Invalid     = "INVALID"
