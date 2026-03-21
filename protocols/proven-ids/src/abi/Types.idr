-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IdsABI.Types: C-ABI-compatible numeric representations of Ids types.
--
-- Maps every constructor of the core Ids sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ids.zig) exactly.
--
-- Types covered:
--   AlertSeverity             (4 constructors, tags 0-3)
--   DetectionMethod           (4 constructors, tags 0-3)
--   Protocol                  (7 constructors, tags 0-6)
--   Action                    (5 constructors, tags 0-4)
--   Direction                 (3 constructors, tags 0-2)
--   ThreatLevel               (5 constructors, tags 0-4)
--   RuleMatch                 (8 constructors, tags 0-7)
--   MatchStatus               (3 constructors, tags 0-2)
--   InspectionState           (5 constructors, tags 0-4)
--   AlertState                (5 constructors, tags 0-4)

module IdsABI.Types

%default total

---------------------------------------------------------------------------
-- AlertSeverity (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
alert_severitySize : Nat
alert_severitySize = 1

||| AlertSeverity sum type for ABI encoding.
public export
data AlertSeverity : Type where
  Low : AlertSeverity
  Medium : AlertSeverity
  High : AlertSeverity
  Critical : AlertSeverity

||| Encode a AlertSeverity to its ABI tag value.
public export
alert_severityToTag : AlertSeverity -> Bits8
alert_severityToTag Low = 0
alert_severityToTag Medium = 1
alert_severityToTag High = 2
alert_severityToTag Critical = 3

||| Decode an ABI tag to a AlertSeverity.
public export
tagToAlertSeverity : Bits8 -> Maybe AlertSeverity
tagToAlertSeverity 0 = Just Low
tagToAlertSeverity 1 = Just Medium
tagToAlertSeverity 2 = Just High
tagToAlertSeverity 3 = Just Critical
tagToAlertSeverity _ = Nothing

||| Roundtrip proof: decoding an encoded AlertSeverity yields the original.
public export
alert_severityRoundtrip : (x : AlertSeverity) -> tagToAlertSeverity (alert_severityToTag x) = Just x
alert_severityRoundtrip Low = Refl
alert_severityRoundtrip Medium = Refl
alert_severityRoundtrip High = Refl
alert_severityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- DetectionMethod (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
detection_methodSize : Nat
detection_methodSize = 1

||| DetectionMethod sum type for ABI encoding.
public export
data DetectionMethod : Type where
  Signature : DetectionMethod
  Anomaly : DetectionMethod
  Stateful : DetectionMethod
  Heuristic : DetectionMethod

||| Encode a DetectionMethod to its ABI tag value.
public export
detection_methodToTag : DetectionMethod -> Bits8
detection_methodToTag Signature = 0
detection_methodToTag Anomaly = 1
detection_methodToTag Stateful = 2
detection_methodToTag Heuristic = 3

||| Decode an ABI tag to a DetectionMethod.
public export
tagToDetectionMethod : Bits8 -> Maybe DetectionMethod
tagToDetectionMethod 0 = Just Signature
tagToDetectionMethod 1 = Just Anomaly
tagToDetectionMethod 2 = Just Stateful
tagToDetectionMethod 3 = Just Heuristic
tagToDetectionMethod _ = Nothing

||| Roundtrip proof: decoding an encoded DetectionMethod yields the original.
public export
detection_methodRoundtrip : (x : DetectionMethod) -> tagToDetectionMethod (detection_methodToTag x) = Just x
detection_methodRoundtrip Signature = Refl
detection_methodRoundtrip Anomaly = Refl
detection_methodRoundtrip Stateful = Refl
detection_methodRoundtrip Heuristic = Refl

---------------------------------------------------------------------------
-- Protocol (7 constructors, tags 0-6)
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
  Dns : Protocol
  Http : Protocol
  Tls : Protocol
  Ssh : Protocol

||| Encode a Protocol to its ABI tag value.
public export
protocolToTag : Protocol -> Bits8
protocolToTag Tcp = 0
protocolToTag Udp = 1
protocolToTag Icmp = 2
protocolToTag Dns = 3
protocolToTag Http = 4
protocolToTag Tls = 5
protocolToTag Ssh = 6

||| Decode an ABI tag to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just Tcp
tagToProtocol 1 = Just Udp
tagToProtocol 2 = Just Icmp
tagToProtocol 3 = Just Dns
tagToProtocol 4 = Just Http
tagToProtocol 5 = Just Tls
tagToProtocol 6 = Just Ssh
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (x : Protocol) -> tagToProtocol (protocolToTag x) = Just x
protocolRoundtrip Tcp = Refl
protocolRoundtrip Udp = Refl
protocolRoundtrip Icmp = Refl
protocolRoundtrip Dns = Refl
protocolRoundtrip Http = Refl
protocolRoundtrip Tls = Refl
protocolRoundtrip Ssh = Refl

---------------------------------------------------------------------------
-- Action (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
actionSize : Nat
actionSize = 1

||| Action sum type for ABI encoding.
public export
data Action : Type where
  Alert : Action
  Drop : Action
  Log : Action
  Block : Action
  Pass : Action

||| Encode a Action to its ABI tag value.
public export
actionToTag : Action -> Bits8
actionToTag Alert = 0
actionToTag Drop = 1
actionToTag Log = 2
actionToTag Block = 3
actionToTag Pass = 4

||| Decode an ABI tag to a Action.
public export
tagToAction : Bits8 -> Maybe Action
tagToAction 0 = Just Alert
tagToAction 1 = Just Drop
tagToAction 2 = Just Log
tagToAction 3 = Just Block
tagToAction 4 = Just Pass
tagToAction _ = Nothing

||| Roundtrip proof: decoding an encoded Action yields the original.
public export
actionRoundtrip : (x : Action) -> tagToAction (actionToTag x) = Just x
actionRoundtrip Alert = Refl
actionRoundtrip Drop = Refl
actionRoundtrip Log = Refl
actionRoundtrip Block = Refl
actionRoundtrip Pass = Refl

---------------------------------------------------------------------------
-- Direction (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
directionSize : Nat
directionSize = 1

||| Direction sum type for ABI encoding.
public export
data Direction : Type where
  Inbound : Direction
  Outbound : Direction
  Both : Direction

||| Encode a Direction to its ABI tag value.
public export
directionToTag : Direction -> Bits8
directionToTag Inbound = 0
directionToTag Outbound = 1
directionToTag Both = 2

||| Decode an ABI tag to a Direction.
public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just Inbound
tagToDirection 1 = Just Outbound
tagToDirection 2 = Just Both
tagToDirection _ = Nothing

||| Roundtrip proof: decoding an encoded Direction yields the original.
public export
directionRoundtrip : (x : Direction) -> tagToDirection (directionToTag x) = Just x
directionRoundtrip Inbound = Refl
directionRoundtrip Outbound = Refl
directionRoundtrip Both = Refl

---------------------------------------------------------------------------
-- ThreatLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
threat_levelSize : Nat
threat_levelSize = 1

||| ThreatLevel sum type for ABI encoding.
public export
data ThreatLevel : Type where
  Info : ThreatLevel
  Low : ThreatLevel
  Medium : ThreatLevel
  High : ThreatLevel
  Critical : ThreatLevel

||| Encode a ThreatLevel to its ABI tag value.
public export
threat_levelToTag : ThreatLevel -> Bits8
threat_levelToTag Info = 0
threat_levelToTag Low = 1
threat_levelToTag Medium = 2
threat_levelToTag High = 3
threat_levelToTag Critical = 4

||| Decode an ABI tag to a ThreatLevel.
public export
tagToThreatLevel : Bits8 -> Maybe ThreatLevel
tagToThreatLevel 0 = Just Info
tagToThreatLevel 1 = Just Low
tagToThreatLevel 2 = Just Medium
tagToThreatLevel 3 = Just High
tagToThreatLevel 4 = Just Critical
tagToThreatLevel _ = Nothing

||| Roundtrip proof: decoding an encoded ThreatLevel yields the original.
public export
threat_levelRoundtrip : (x : ThreatLevel) -> tagToThreatLevel (threat_levelToTag x) = Just x
threat_levelRoundtrip Info = Refl
threat_levelRoundtrip Low = Refl
threat_levelRoundtrip Medium = Refl
threat_levelRoundtrip High = Refl
threat_levelRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- RuleMatch (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
rule_matchSize : Nat
rule_matchSize = 1

||| RuleMatch sum type for ABI encoding.
public export
data RuleMatch : Type where
  SrcAddr : RuleMatch
  DstAddr : RuleMatch
  SrcPort : RuleMatch
  DstPort : RuleMatch
  Content : RuleMatch
  Regex : RuleMatch
  Threshold : RuleMatch
  FlowBits : RuleMatch

||| Encode a RuleMatch to its ABI tag value.
public export
rule_matchToTag : RuleMatch -> Bits8
rule_matchToTag SrcAddr = 0
rule_matchToTag DstAddr = 1
rule_matchToTag SrcPort = 2
rule_matchToTag DstPort = 3
rule_matchToTag Content = 4
rule_matchToTag Regex = 5
rule_matchToTag Threshold = 6
rule_matchToTag FlowBits = 7

||| Decode an ABI tag to a RuleMatch.
public export
tagToRuleMatch : Bits8 -> Maybe RuleMatch
tagToRuleMatch 0 = Just SrcAddr
tagToRuleMatch 1 = Just DstAddr
tagToRuleMatch 2 = Just SrcPort
tagToRuleMatch 3 = Just DstPort
tagToRuleMatch 4 = Just Content
tagToRuleMatch 5 = Just Regex
tagToRuleMatch 6 = Just Threshold
tagToRuleMatch 7 = Just FlowBits
tagToRuleMatch _ = Nothing

||| Roundtrip proof: decoding an encoded RuleMatch yields the original.
public export
rule_matchRoundtrip : (x : RuleMatch) -> tagToRuleMatch (rule_matchToTag x) = Just x
rule_matchRoundtrip SrcAddr = Refl
rule_matchRoundtrip DstAddr = Refl
rule_matchRoundtrip SrcPort = Refl
rule_matchRoundtrip DstPort = Refl
rule_matchRoundtrip Content = Refl
rule_matchRoundtrip Regex = Refl
rule_matchRoundtrip Threshold = Refl
rule_matchRoundtrip FlowBits = Refl

---------------------------------------------------------------------------
-- MatchStatus (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
match_statusSize : Nat
match_statusSize = 1

||| MatchStatus sum type for ABI encoding.
public export
data MatchStatus : Type where
  NoMatch : MatchStatus
  Matched : MatchStatus
  Suppressed : MatchStatus

||| Encode a MatchStatus to its ABI tag value.
public export
match_statusToTag : MatchStatus -> Bits8
match_statusToTag NoMatch = 0
match_statusToTag Matched = 1
match_statusToTag Suppressed = 2

||| Decode an ABI tag to a MatchStatus.
public export
tagToMatchStatus : Bits8 -> Maybe MatchStatus
tagToMatchStatus 0 = Just NoMatch
tagToMatchStatus 1 = Just Matched
tagToMatchStatus 2 = Just Suppressed
tagToMatchStatus _ = Nothing

||| Roundtrip proof: decoding an encoded MatchStatus yields the original.
public export
match_statusRoundtrip : (x : MatchStatus) -> tagToMatchStatus (match_statusToTag x) = Just x
match_statusRoundtrip NoMatch = Refl
match_statusRoundtrip Matched = Refl
match_statusRoundtrip Suppressed = Refl

---------------------------------------------------------------------------
-- InspectionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
inspection_stateSize : Nat
inspection_stateSize = 1

||| InspectionState sum type for ABI encoding.
public export
data InspectionState : Type where
  Captured : InspectionState
  Decoded : InspectionState
  Inspecting : InspectionState
  Evaluated : InspectionState
  Disposed : InspectionState

||| Encode a InspectionState to its ABI tag value.
public export
inspection_stateToTag : InspectionState -> Bits8
inspection_stateToTag Captured = 0
inspection_stateToTag Decoded = 1
inspection_stateToTag Inspecting = 2
inspection_stateToTag Evaluated = 3
inspection_stateToTag Disposed = 4

||| Decode an ABI tag to a InspectionState.
public export
tagToInspectionState : Bits8 -> Maybe InspectionState
tagToInspectionState 0 = Just Captured
tagToInspectionState 1 = Just Decoded
tagToInspectionState 2 = Just Inspecting
tagToInspectionState 3 = Just Evaluated
tagToInspectionState 4 = Just Disposed
tagToInspectionState _ = Nothing

||| Roundtrip proof: decoding an encoded InspectionState yields the original.
public export
inspection_stateRoundtrip : (x : InspectionState) -> tagToInspectionState (inspection_stateToTag x) = Just x
inspection_stateRoundtrip Captured = Refl
inspection_stateRoundtrip Decoded = Refl
inspection_stateRoundtrip Inspecting = Refl
inspection_stateRoundtrip Evaluated = Refl
inspection_stateRoundtrip Disposed = Refl

---------------------------------------------------------------------------
-- AlertState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
alert_stateSize : Nat
alert_stateSize = 1

||| AlertState sum type for ABI encoding.
public export
data AlertState : Type where
  Idle : AlertState
  Triggered : AlertState
  Escalated : AlertState
  Acknowledged : AlertState
  Closed : AlertState

||| Encode a AlertState to its ABI tag value.
public export
alert_stateToTag : AlertState -> Bits8
alert_stateToTag Idle = 0
alert_stateToTag Triggered = 1
alert_stateToTag Escalated = 2
alert_stateToTag Acknowledged = 3
alert_stateToTag Closed = 4

||| Decode an ABI tag to a AlertState.
public export
tagToAlertState : Bits8 -> Maybe AlertState
tagToAlertState 0 = Just Idle
tagToAlertState 1 = Just Triggered
tagToAlertState 2 = Just Escalated
tagToAlertState 3 = Just Acknowledged
tagToAlertState 4 = Just Closed
tagToAlertState _ = Nothing

||| Roundtrip proof: decoding an encoded AlertState yields the original.
public export
alert_stateRoundtrip : (x : AlertState) -> tagToAlertState (alert_stateToTag x) = Just x
alert_stateRoundtrip Idle = Refl
alert_stateRoundtrip Triggered = Refl
alert_stateRoundtrip Escalated = Refl
alert_stateRoundtrip Acknowledged = Refl
alert_stateRoundtrip Closed = Refl
