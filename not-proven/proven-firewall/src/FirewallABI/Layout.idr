-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FirewallABI.Layout: C-ABI-compatible numeric representations of firewall types.
--
-- Maps every constructor of the firewall sum types (Action, Protocol, ChainType,
-- RuleMatch, ConnState) to fixed Bits8 values for C interop.  Each type gets a
-- total encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/firewall.h) and the
-- Zig FFI enums (ffi/zig/src/firewall.zig) exactly.

module FirewallABI.Layout

import Firewall.Types

%default total

---------------------------------------------------------------------------
-- Action (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
actionSize : Nat
actionSize = 1

||| Encode a firewall Action as a Bits8 tag for C interop.
public export
actionToTag : Action -> Bits8
actionToTag Accept     = 0
actionToTag Drop       = 1
actionToTag Reject     = 2
actionToTag Log        = 3
actionToTag Redirect   = 4
actionToTag DNAT       = 5
actionToTag SNAT       = 6
actionToTag Masquerade = 7

||| Decode a Bits8 tag back to a firewall Action.
public export
tagToAction : Bits8 -> Maybe Action
tagToAction 0 = Just Accept
tagToAction 1 = Just Drop
tagToAction 2 = Just Reject
tagToAction 3 = Just Log
tagToAction 4 = Just Redirect
tagToAction 5 = Just DNAT
tagToAction 6 = Just SNAT
tagToAction 7 = Just Masquerade
tagToAction _ = Nothing

||| Roundtrip proof: decoding an encoded Action yields the original.
public export
actionRoundtrip : (a : Action) -> tagToAction (actionToTag a) = Just a
actionRoundtrip Accept     = Refl
actionRoundtrip Drop       = Refl
actionRoundtrip Reject     = Refl
actionRoundtrip Log        = Refl
actionRoundtrip Redirect   = Refl
actionRoundtrip DNAT       = Refl
actionRoundtrip SNAT       = Refl
actionRoundtrip Masquerade = Refl

---------------------------------------------------------------------------
-- Protocol (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
protocolSize : Nat
protocolSize = 1

||| Encode a Protocol as a Bits8 tag for C interop.
public export
protocolToTag : Protocol -> Bits8
protocolToTag TCP    = 0
protocolToTag UDP    = 1
protocolToTag ICMP   = 2
protocolToTag ICMPv6 = 3
protocolToTag GRE    = 4
protocolToTag ESP    = 5
protocolToTag AH     = 6
protocolToTag Any    = 7

||| Decode a Bits8 tag back to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just TCP
tagToProtocol 1 = Just UDP
tagToProtocol 2 = Just ICMP
tagToProtocol 3 = Just ICMPv6
tagToProtocol 4 = Just GRE
tagToProtocol 5 = Just ESP
tagToProtocol 6 = Just AH
tagToProtocol 7 = Just Any
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (p : Protocol) -> tagToProtocol (protocolToTag p) = Just p
protocolRoundtrip TCP    = Refl
protocolRoundtrip UDP    = Refl
protocolRoundtrip ICMP   = Refl
protocolRoundtrip ICMPv6 = Refl
protocolRoundtrip GRE    = Refl
protocolRoundtrip ESP    = Refl
protocolRoundtrip AH     = Refl
protocolRoundtrip Any    = Refl

---------------------------------------------------------------------------
-- ChainType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
chainTypeSize : Nat
chainTypeSize = 1

||| Encode a ChainType as a Bits8 tag for C interop.
public export
chainTypeToTag : ChainType -> Bits8
chainTypeToTag Input       = 0
chainTypeToTag Output      = 1
chainTypeToTag Forward     = 2
chainTypeToTag PreRouting  = 3
chainTypeToTag PostRouting = 4

||| Decode a Bits8 tag back to a ChainType.
public export
tagToChainType : Bits8 -> Maybe ChainType
tagToChainType 0 = Just Input
tagToChainType 1 = Just Output
tagToChainType 2 = Just Forward
tagToChainType 3 = Just PreRouting
tagToChainType 4 = Just PostRouting
tagToChainType _ = Nothing

||| Roundtrip proof: decoding an encoded ChainType yields the original.
public export
chainTypeRoundtrip : (c : ChainType) -> tagToChainType (chainTypeToTag c) = Just c
chainTypeRoundtrip Input       = Refl
chainTypeRoundtrip Output      = Refl
chainTypeRoundtrip Forward     = Refl
chainTypeRoundtrip PreRouting  = Refl
chainTypeRoundtrip PostRouting = Refl

---------------------------------------------------------------------------
-- RuleMatch (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
ruleMatchSize : Nat
ruleMatchSize = 1

||| Encode a RuleMatch as a Bits8 tag for C interop.
public export
ruleMatchToTag : RuleMatch -> Bits8
ruleMatchToTag SourceIP   = 0
ruleMatchToTag DestIP     = 1
ruleMatchToTag SourcePort = 2
ruleMatchToTag DestPort   = 3
ruleMatchToTag MatchProto = 4
ruleMatchToTag Interface  = 5
ruleMatchToTag State      = 6
ruleMatchToTag Mark       = 7

||| Decode a Bits8 tag back to a RuleMatch.
public export
tagToRuleMatch : Bits8 -> Maybe RuleMatch
tagToRuleMatch 0 = Just SourceIP
tagToRuleMatch 1 = Just DestIP
tagToRuleMatch 2 = Just SourcePort
tagToRuleMatch 3 = Just DestPort
tagToRuleMatch 4 = Just MatchProto
tagToRuleMatch 5 = Just Interface
tagToRuleMatch 6 = Just State
tagToRuleMatch 7 = Just Mark
tagToRuleMatch _ = Nothing

||| Roundtrip proof: decoding an encoded RuleMatch yields the original.
public export
ruleMatchRoundtrip : (r : RuleMatch) -> tagToRuleMatch (ruleMatchToTag r) = Just r
ruleMatchRoundtrip SourceIP   = Refl
ruleMatchRoundtrip DestIP     = Refl
ruleMatchRoundtrip SourcePort = Refl
ruleMatchRoundtrip DestPort   = Refl
ruleMatchRoundtrip MatchProto = Refl
ruleMatchRoundtrip Interface  = Refl
ruleMatchRoundtrip State      = Refl
ruleMatchRoundtrip Mark       = Refl

---------------------------------------------------------------------------
-- ConnState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
connStateSize : Nat
connStateSize = 1

||| Encode a ConnState as a Bits8 tag for C interop.
public export
connStateToTag : ConnState -> Bits8
connStateToTag New         = 0
connStateToTag Established = 1
connStateToTag Related     = 2
connStateToTag Invalid     = 3

||| Decode a Bits8 tag back to a ConnState.
public export
tagToConnState : Bits8 -> Maybe ConnState
tagToConnState 0 = Just New
tagToConnState 1 = Just Established
tagToConnState 2 = Just Related
tagToConnState 3 = Just Invalid
tagToConnState _ = Nothing

||| Roundtrip proof: decoding an encoded ConnState yields the original.
public export
connStateRoundtrip : (s : ConnState) -> tagToConnState (connStateToTag s) = Just s
connStateRoundtrip New         = Refl
connStateRoundtrip Established = Refl
connStateRoundtrip Related     = Refl
connStateRoundtrip Invalid     = Refl
