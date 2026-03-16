-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IDSABI.Layout: C-ABI-compatible numeric representations of IDS types.
--
-- Maps every constructor of the IDS sum types (AlertSeverity, DetectionMethod,
-- Protocol, Action, Direction, ThreatLevel, RuleMatch, MatchStatus) to fixed
-- Bits8 values for C interop.  Each type gets a total encoder, partial decoder,
-- and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/ids.h) and the
-- Zig FFI enums (ffi/zig/src/ids.zig) exactly.

module IDSABI.Layout

import IDS.Types

%default total

---------------------------------------------------------------------------
-- AlertSeverity (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
alertSeveritySize : Nat
alertSeveritySize = 1

||| Encode an AlertSeverity as a Bits8 tag for C interop.
public export
alertSeverityToTag : AlertSeverity -> Bits8
alertSeverityToTag Low      = 0
alertSeverityToTag Medium   = 1
alertSeverityToTag High     = 2
alertSeverityToTag Critical = 3

||| Decode a Bits8 tag back to an AlertSeverity.
public export
tagToAlertSeverity : Bits8 -> Maybe AlertSeverity
tagToAlertSeverity 0 = Just Low
tagToAlertSeverity 1 = Just Medium
tagToAlertSeverity 2 = Just High
tagToAlertSeverity 3 = Just Critical
tagToAlertSeverity _ = Nothing

||| Roundtrip proof: decoding an encoded AlertSeverity yields the original.
public export
alertSeverityRoundtrip : (s : AlertSeverity) -> tagToAlertSeverity (alertSeverityToTag s) = Just s
alertSeverityRoundtrip Low      = Refl
alertSeverityRoundtrip Medium   = Refl
alertSeverityRoundtrip High     = Refl
alertSeverityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- DetectionMethod (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
detectionMethodSize : Nat
detectionMethodSize = 1

||| Encode a DetectionMethod as a Bits8 tag for C interop.
public export
detectionMethodToTag : DetectionMethod -> Bits8
detectionMethodToTag Signature = 0
detectionMethodToTag Anomaly   = 1
detectionMethodToTag Stateful  = 2
detectionMethodToTag Heuristic = 3

||| Decode a Bits8 tag back to a DetectionMethod.
public export
tagToDetectionMethod : Bits8 -> Maybe DetectionMethod
tagToDetectionMethod 0 = Just Signature
tagToDetectionMethod 1 = Just Anomaly
tagToDetectionMethod 2 = Just Stateful
tagToDetectionMethod 3 = Just Heuristic
tagToDetectionMethod _ = Nothing

||| Roundtrip proof: decoding an encoded DetectionMethod yields the original.
public export
detectionMethodRoundtrip : (m : DetectionMethod) -> tagToDetectionMethod (detectionMethodToTag m) = Just m
detectionMethodRoundtrip Signature = Refl
detectionMethodRoundtrip Anomaly   = Refl
detectionMethodRoundtrip Stateful  = Refl
detectionMethodRoundtrip Heuristic = Refl

---------------------------------------------------------------------------
-- Protocol (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
protocolSize : Nat
protocolSize = 1

||| Encode a Protocol as a Bits8 tag for C interop.
public export
protocolToTag : Protocol -> Bits8
protocolToTag TCP  = 0
protocolToTag UDP  = 1
protocolToTag ICMP = 2
protocolToTag DNS  = 3
protocolToTag HTTP = 4
protocolToTag TLS  = 5
protocolToTag SSH  = 6

||| Decode a Bits8 tag back to a Protocol.
public export
tagToProtocol : Bits8 -> Maybe Protocol
tagToProtocol 0 = Just TCP
tagToProtocol 1 = Just UDP
tagToProtocol 2 = Just ICMP
tagToProtocol 3 = Just DNS
tagToProtocol 4 = Just HTTP
tagToProtocol 5 = Just TLS
tagToProtocol 6 = Just SSH
tagToProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded Protocol yields the original.
public export
protocolRoundtrip : (p : Protocol) -> tagToProtocol (protocolToTag p) = Just p
protocolRoundtrip TCP  = Refl
protocolRoundtrip UDP  = Refl
protocolRoundtrip ICMP = Refl
protocolRoundtrip DNS  = Refl
protocolRoundtrip HTTP = Refl
protocolRoundtrip TLS  = Refl
protocolRoundtrip SSH  = Refl

---------------------------------------------------------------------------
-- Action (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
actionSize : Nat
actionSize = 1

||| Encode an Action as a Bits8 tag for C interop.
public export
actionToTag : Action -> Bits8
actionToTag Alert = 0
actionToTag Drop  = 1
actionToTag Log   = 2
actionToTag Block = 3
actionToTag Pass  = 4

||| Decode a Bits8 tag back to an Action.
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
actionRoundtrip : (a : Action) -> tagToAction (actionToTag a) = Just a
actionRoundtrip Alert = Refl
actionRoundtrip Drop  = Refl
actionRoundtrip Log   = Refl
actionRoundtrip Block = Refl
actionRoundtrip Pass  = Refl

---------------------------------------------------------------------------
-- Direction (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
directionSize : Nat
directionSize = 1

||| Encode a Direction as a Bits8 tag for C interop.
public export
directionToTag : Direction -> Bits8
directionToTag Inbound  = 0
directionToTag Outbound = 1
directionToTag Both     = 2

||| Decode a Bits8 tag back to a Direction.
public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just Inbound
tagToDirection 1 = Just Outbound
tagToDirection 2 = Just Both
tagToDirection _ = Nothing

||| Roundtrip proof: decoding an encoded Direction yields the original.
public export
directionRoundtrip : (d : Direction) -> tagToDirection (directionToTag d) = Just d
directionRoundtrip Inbound  = Refl
directionRoundtrip Outbound = Refl
directionRoundtrip Both     = Refl

---------------------------------------------------------------------------
-- ThreatLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
threatLevelSize : Nat
threatLevelSize = 1

||| Encode a ThreatLevel as a Bits8 tag for C interop.
public export
threatLevelToTag : ThreatLevel -> Bits8
threatLevelToTag TLInfo     = 0
threatLevelToTag TLLow      = 1
threatLevelToTag TLMedium   = 2
threatLevelToTag TLHigh     = 3
threatLevelToTag TLCritical = 4

||| Decode a Bits8 tag back to a ThreatLevel.
public export
tagToThreatLevel : Bits8 -> Maybe ThreatLevel
tagToThreatLevel 0 = Just TLInfo
tagToThreatLevel 1 = Just TLLow
tagToThreatLevel 2 = Just TLMedium
tagToThreatLevel 3 = Just TLHigh
tagToThreatLevel 4 = Just TLCritical
tagToThreatLevel _ = Nothing

||| Roundtrip proof: decoding an encoded ThreatLevel yields the original.
public export
threatLevelRoundtrip : (t : ThreatLevel) -> tagToThreatLevel (threatLevelToTag t) = Just t
threatLevelRoundtrip TLInfo     = Refl
threatLevelRoundtrip TLLow      = Refl
threatLevelRoundtrip TLMedium   = Refl
threatLevelRoundtrip TLHigh     = Refl
threatLevelRoundtrip TLCritical = Refl

---------------------------------------------------------------------------
-- RuleMatch (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
ruleMatchSize : Nat
ruleMatchSize = 1

||| Encode a RuleMatch as a Bits8 tag for C interop.
public export
ruleMatchToTag : RuleMatch -> Bits8
ruleMatchToTag SrcAddr   = 0
ruleMatchToTag DstAddr   = 1
ruleMatchToTag SrcPort   = 2
ruleMatchToTag DstPort   = 3
ruleMatchToTag Content   = 4
ruleMatchToTag Regex     = 5
ruleMatchToTag Threshold = 6
ruleMatchToTag FlowBits  = 7

||| Decode a Bits8 tag back to a RuleMatch.
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
ruleMatchRoundtrip : (r : RuleMatch) -> tagToRuleMatch (ruleMatchToTag r) = Just r
ruleMatchRoundtrip SrcAddr   = Refl
ruleMatchRoundtrip DstAddr   = Refl
ruleMatchRoundtrip SrcPort   = Refl
ruleMatchRoundtrip DstPort   = Refl
ruleMatchRoundtrip Content   = Refl
ruleMatchRoundtrip Regex     = Refl
ruleMatchRoundtrip Threshold = Refl
ruleMatchRoundtrip FlowBits  = Refl

---------------------------------------------------------------------------
-- MatchStatus (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
matchStatusSize : Nat
matchStatusSize = 1

||| Encode a MatchStatus as a Bits8 tag for C interop.
public export
matchStatusToTag : MatchStatus -> Bits8
matchStatusToTag NoMatch    = 0
matchStatusToTag Matched    = 1
matchStatusToTag Suppressed = 2

||| Decode a Bits8 tag back to a MatchStatus.
public export
tagToMatchStatus : Bits8 -> Maybe MatchStatus
tagToMatchStatus 0 = Just NoMatch
tagToMatchStatus 1 = Just Matched
tagToMatchStatus 2 = Just Suppressed
tagToMatchStatus _ = Nothing

||| Roundtrip proof: decoding an encoded MatchStatus yields the original.
public export
matchStatusRoundtrip : (m : MatchStatus) -> tagToMatchStatus (matchStatusToTag m) = Just m
matchStatusRoundtrip NoMatch    = Refl
matchStatusRoundtrip Matched    = Refl
matchStatusRoundtrip Suppressed = Refl
