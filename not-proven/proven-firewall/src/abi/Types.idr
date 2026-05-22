-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FirewallABI.Types: C-ABI-compatible numeric representations of Firewall types.
--
-- Maps every constructor of the core Firewall sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/firewall.zig) exactly.
--
-- Types covered:
--   Action                    (8 constructors, tags 0-7)
--   Protocol                  (8 constructors, tags 0-7)
--   ChainType                 (5 constructors, tags 0-4)
--   RuleMatchType             (8 constructors, tags 0-7)
--   ConnState                 (4 constructors, tags 0-3)
--   PacketState               (5 constructors, tags 0-4)
--   ConnTrackState            (4 constructors, tags 0-3)

module FirewallABI.Types

%default total

---------------------------------------------------------------------------
-- Action (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
actionSize : Nat
actionSize = 1

||| Action sum type for ABI encoding.
public export
data Action : Type where
  Accept : Action
  Drop : Action
  Reject : Action
  Log : Action
  Redirect : Action
  Dnat : Action
  Snat : Action
  Masquerade : Action

||| Encode a Action to its ABI tag value.
public export
actionToTag : Action -> Bits8
actionToTag Accept = 0
actionToTag Drop = 1
actionToTag Reject = 2
actionToTag Log = 3
actionToTag Redirect = 4
actionToTag Dnat = 5
actionToTag Snat = 6
actionToTag Masquerade = 7

||| Decode an ABI tag to a Action.
public export
tagToAction : Bits8 -> Maybe Action
tagToAction 0 = Just Accept
tagToAction 1 = Just Drop
tagToAction 2 = Just Reject
tagToAction 3 = Just Log
tagToAction 4 = Just Redirect
tagToAction 5 = Just Dnat
tagToAction 6 = Just Snat
tagToAction 7 = Just Masquerade
tagToAction _ = Nothing

||| Roundtrip proof: decoding an encoded Action yields the original.
public export
actionRoundtrip : (x : Action) -> tagToAction (actionToTag x) = Just x
actionRoundtrip Accept = Refl
actionRoundtrip Drop = Refl
actionRoundtrip Reject = Refl
actionRoundtrip Log = Refl
actionRoundtrip Redirect = Refl
actionRoundtrip Dnat = Refl
actionRoundtrip Snat = Refl
actionRoundtrip Masquerade = Refl

---------------------------------------------------------------------------
-- Protocol (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
protocolSize : Nat
protocolSize = 1

||| Protocol sum type for ABI encoding.
public export
data Protocol : Type where
  Tcp : Protocol
  Udp : Protocol
  Icmp : Protocol
  Icmpv6 : Protocol
  Gre : Protocol
  Esp : Protocol
  Ah : Protocol
  Any : Protocol

||| Encode a Protocol to its ABI tag value.
public export
protocolToTag : Protocol -> Bits8
protocolToTag Tcp = 0
protocolToTag Udp = 1
protocolToTag Icmp = 2
protocolToTag Icmpv6 = 3
protocolToTag Gre = 4
protocolToTag Esp = 5
protocolToTag Ah = 6
protocolToTag Any = 7

||| Decode an ABI tag to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just Tcp
tagToProtocol 1 = Just Udp
tagToProtocol 2 = Just Icmp
tagToProtocol 3 = Just Icmpv6
tagToProtocol 4 = Just Gre
tagToProtocol 5 = Just Esp
tagToProtocol 6 = Just Ah
tagToProtocol 7 = Just Any
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (x : Protocol) -> tagToProtocol (protocolToTag x) = Just x
protocolRoundtrip Tcp = Refl
protocolRoundtrip Udp = Refl
protocolRoundtrip Icmp = Refl
protocolRoundtrip Icmpv6 = Refl
protocolRoundtrip Gre = Refl
protocolRoundtrip Esp = Refl
protocolRoundtrip Ah = Refl
protocolRoundtrip Any = Refl

---------------------------------------------------------------------------
-- ChainType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
chain_typeSize : Nat
chain_typeSize = 1

||| ChainType sum type for ABI encoding.
public export
data ChainType : Type where
  Input : ChainType
  Output : ChainType
  Forward : ChainType
  PreRouting : ChainType
  PostRouting : ChainType

||| Encode a ChainType to its ABI tag value.
public export
chain_typeToTag : ChainType -> Bits8
chain_typeToTag Input = 0
chain_typeToTag Output = 1
chain_typeToTag Forward = 2
chain_typeToTag PreRouting = 3
chain_typeToTag PostRouting = 4

||| Decode an ABI tag to a ChainType.
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
chain_typeRoundtrip : (x : ChainType) -> tagToChainType (chain_typeToTag x) = Just x
chain_typeRoundtrip Input = Refl
chain_typeRoundtrip Output = Refl
chain_typeRoundtrip Forward = Refl
chain_typeRoundtrip PreRouting = Refl
chain_typeRoundtrip PostRouting = Refl

---------------------------------------------------------------------------
-- RuleMatchType (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
rule_match_typeSize : Nat
rule_match_typeSize = 1

||| RuleMatchType sum type for ABI encoding.
public export
data RuleMatchType : Type where
  SourceIp : RuleMatchType
  DestIp : RuleMatchType
  SourcePort : RuleMatchType
  DestPort : RuleMatchType
  MatchProto : RuleMatchType
  Interface : RuleMatchType
  State : RuleMatchType
  Mark : RuleMatchType

||| Encode a RuleMatchType to its ABI tag value.
public export
rule_match_typeToTag : RuleMatchType -> Bits8
rule_match_typeToTag SourceIp = 0
rule_match_typeToTag DestIp = 1
rule_match_typeToTag SourcePort = 2
rule_match_typeToTag DestPort = 3
rule_match_typeToTag MatchProto = 4
rule_match_typeToTag Interface = 5
rule_match_typeToTag State = 6
rule_match_typeToTag Mark = 7

||| Decode an ABI tag to a RuleMatchType.
public export
tagToRuleMatchType : Bits8 -> Maybe RuleMatchType
tagToRuleMatchType 0 = Just SourceIp
tagToRuleMatchType 1 = Just DestIp
tagToRuleMatchType 2 = Just SourcePort
tagToRuleMatchType 3 = Just DestPort
tagToRuleMatchType 4 = Just MatchProto
tagToRuleMatchType 5 = Just Interface
tagToRuleMatchType 6 = Just State
tagToRuleMatchType 7 = Just Mark
tagToRuleMatchType _ = Nothing

||| Roundtrip proof: decoding an encoded RuleMatchType yields the original.
public export
rule_match_typeRoundtrip : (x : RuleMatchType) -> tagToRuleMatchType (rule_match_typeToTag x) = Just x
rule_match_typeRoundtrip SourceIp = Refl
rule_match_typeRoundtrip DestIp = Refl
rule_match_typeRoundtrip SourcePort = Refl
rule_match_typeRoundtrip DestPort = Refl
rule_match_typeRoundtrip MatchProto = Refl
rule_match_typeRoundtrip Interface = Refl
rule_match_typeRoundtrip State = Refl
rule_match_typeRoundtrip Mark = Refl

---------------------------------------------------------------------------
-- ConnState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
conn_stateSize : Nat
conn_stateSize = 1

||| ConnState sum type for ABI encoding.
public export
data ConnState : Type where
  New : ConnState
  Established : ConnState
  Related : ConnState
  Invalid : ConnState

||| Encode a ConnState to its ABI tag value.
public export
conn_stateToTag : ConnState -> Bits8
conn_stateToTag New = 0
conn_stateToTag Established = 1
conn_stateToTag Related = 2
conn_stateToTag Invalid = 3

||| Decode an ABI tag to a ConnState.
public export
tagToConnState : Bits8 -> Maybe ConnState
tagToConnState 0 = Just New
tagToConnState 1 = Just Established
tagToConnState 2 = Just Related
tagToConnState 3 = Just Invalid
tagToConnState _ = Nothing

||| Roundtrip proof: decoding an encoded ConnState yields the original.
public export
conn_stateRoundtrip : (x : ConnState) -> tagToConnState (conn_stateToTag x) = Just x
conn_stateRoundtrip New = Refl
conn_stateRoundtrip Established = Refl
conn_stateRoundtrip Related = Refl
conn_stateRoundtrip Invalid = Refl

---------------------------------------------------------------------------
-- PacketState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
packet_stateSize : Nat
packet_stateSize = 1

||| PacketState sum type for ABI encoding.
public export
data PacketState : Type where
  Arrived : PacketState
  Classified : PacketState
  ChainTraversal : PacketState
  Decided : PacketState
  Committed : PacketState

||| Encode a PacketState to its ABI tag value.
public export
packet_stateToTag : PacketState -> Bits8
packet_stateToTag Arrived = 0
packet_stateToTag Classified = 1
packet_stateToTag ChainTraversal = 2
packet_stateToTag Decided = 3
packet_stateToTag Committed = 4

||| Decode an ABI tag to a PacketState.
public export
tagToPacketState : Bits8 -> Maybe PacketState
tagToPacketState 0 = Just Arrived
tagToPacketState 1 = Just Classified
tagToPacketState 2 = Just ChainTraversal
tagToPacketState 3 = Just Decided
tagToPacketState 4 = Just Committed
tagToPacketState _ = Nothing

||| Roundtrip proof: decoding an encoded PacketState yields the original.
public export
packet_stateRoundtrip : (x : PacketState) -> tagToPacketState (packet_stateToTag x) = Just x
packet_stateRoundtrip Arrived = Refl
packet_stateRoundtrip Classified = Refl
packet_stateRoundtrip ChainTraversal = Refl
packet_stateRoundtrip Decided = Refl
packet_stateRoundtrip Committed = Refl

---------------------------------------------------------------------------
-- ConnTrackState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
conn_track_stateSize : Nat
conn_track_stateSize = 1

||| ConnTrackState sum type for ABI encoding.
public export
data ConnTrackState : Type where
  Untracked : ConnTrackState
  Tracking : ConnTrackState
  Tracked : ConnTrackState
  Expired : ConnTrackState

||| Encode a ConnTrackState to its ABI tag value.
public export
conn_track_stateToTag : ConnTrackState -> Bits8
conn_track_stateToTag Untracked = 0
conn_track_stateToTag Tracking = 1
conn_track_stateToTag Tracked = 2
conn_track_stateToTag Expired = 3

||| Decode an ABI tag to a ConnTrackState.
public export
tagToConnTrackState : Bits8 -> Maybe ConnTrackState
tagToConnTrackState 0 = Just Untracked
tagToConnTrackState 1 = Just Tracking
tagToConnTrackState 2 = Just Tracked
tagToConnTrackState 3 = Just Expired
tagToConnTrackState _ = Nothing

||| Roundtrip proof: decoding an encoded ConnTrackState yields the original.
public export
conn_track_stateRoundtrip : (x : ConnTrackState) -> tagToConnTrackState (conn_track_stateToTag x) = Just x
conn_track_stateRoundtrip Untracked = Refl
conn_track_stateRoundtrip Tracking = Refl
conn_track_stateRoundtrip Tracked = Refl
conn_track_stateRoundtrip Expired = Refl
