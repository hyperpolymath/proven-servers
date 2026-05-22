-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SIEMABI.Types: C-ABI-compatible numeric representations of SIEM types.
--
-- Maps every constructor of the core SIEM sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/siem.zig) exactly.
--
-- Types covered:
--   EventSeverity    (5 constructors, tags 0-4)
--   EventCategory    (7 constructors, tags 0-6)
--   CorrelationRule  (5 constructors, tags 0-4)
--   AlertState       (5 constructors, tags 0-4)

module SIEMABI.Types

import SIEM.Types

%default total

---------------------------------------------------------------------------
-- EventSeverity (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
eventSeveritySize : Nat
eventSeveritySize = 1

||| Encode an EventSeverity to its ABI tag value.
public export
eventSeverityToTag : EventSeverity -> Bits8
eventSeverityToTag Info     = 0
eventSeverityToTag Low      = 1
eventSeverityToTag Medium   = 2
eventSeverityToTag High     = 3
eventSeverityToTag Critical = 4

||| Decode an ABI tag value to an EventSeverity.
public export
tagToEventSeverity : Bits8 -> Maybe EventSeverity
tagToEventSeverity 0 = Just Info
tagToEventSeverity 1 = Just Low
tagToEventSeverity 2 = Just Medium
tagToEventSeverity 3 = Just High
tagToEventSeverity 4 = Just Critical
tagToEventSeverity _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
eventSeverityRoundtrip : (s : EventSeverity) -> tagToEventSeverity (eventSeverityToTag s) = Just s
eventSeverityRoundtrip Info     = Refl
eventSeverityRoundtrip Low      = Refl
eventSeverityRoundtrip Medium   = Refl
eventSeverityRoundtrip High     = Refl
eventSeverityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- EventCategory (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
eventCategorySize : Nat
eventCategorySize = 1

||| Encode an EventCategory to its ABI tag value.
public export
eventCategoryToTag : EventCategory -> Bits8
eventCategoryToTag Authentication   = 0
eventCategoryToTag NetworkTraffic   = 1
eventCategoryToTag FileActivity     = 2
eventCategoryToTag ProcessExecution = 3
eventCategoryToTag PolicyViolation  = 4
eventCategoryToTag Malware          = 5
eventCategoryToTag DataExfiltration = 6

||| Decode an ABI tag value to an EventCategory.
public export
tagToEventCategory : Bits8 -> Maybe EventCategory
tagToEventCategory 0 = Just Authentication
tagToEventCategory 1 = Just NetworkTraffic
tagToEventCategory 2 = Just FileActivity
tagToEventCategory 3 = Just ProcessExecution
tagToEventCategory 4 = Just PolicyViolation
tagToEventCategory 5 = Just Malware
tagToEventCategory 6 = Just DataExfiltration
tagToEventCategory _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
eventCategoryRoundtrip : (c : EventCategory) -> tagToEventCategory (eventCategoryToTag c) = Just c
eventCategoryRoundtrip Authentication   = Refl
eventCategoryRoundtrip NetworkTraffic   = Refl
eventCategoryRoundtrip FileActivity     = Refl
eventCategoryRoundtrip ProcessExecution = Refl
eventCategoryRoundtrip PolicyViolation  = Refl
eventCategoryRoundtrip Malware          = Refl
eventCategoryRoundtrip DataExfiltration = Refl

---------------------------------------------------------------------------
-- CorrelationRule (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
correlationRuleSize : Nat
correlationRuleSize = 1

||| Encode a CorrelationRule to its ABI tag value.
public export
correlationRuleToTag : CorrelationRule -> Bits8
correlationRuleToTag Threshold   = 0
correlationRuleToTag Sequence    = 1
correlationRuleToTag Aggregation = 2
correlationRuleToTag Absence     = 3
correlationRuleToTag Statistical = 4

||| Decode an ABI tag value to a CorrelationRule.
public export
tagToCorrelationRule : Bits8 -> Maybe CorrelationRule
tagToCorrelationRule 0 = Just Threshold
tagToCorrelationRule 1 = Just Sequence
tagToCorrelationRule 2 = Just Aggregation
tagToCorrelationRule 3 = Just Absence
tagToCorrelationRule 4 = Just Statistical
tagToCorrelationRule _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
correlationRuleRoundtrip : (r : CorrelationRule) -> tagToCorrelationRule (correlationRuleToTag r) = Just r
correlationRuleRoundtrip Threshold   = Refl
correlationRuleRoundtrip Sequence    = Refl
correlationRuleRoundtrip Aggregation = Refl
correlationRuleRoundtrip Absence     = Refl
correlationRuleRoundtrip Statistical = Refl

---------------------------------------------------------------------------
-- AlertState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
alertStateSize : Nat
alertStateSize = 1

||| Encode an AlertState to its ABI tag value.
public export
alertStateToTag : AlertState -> Bits8
alertStateToTag New           = 0
alertStateToTag Acknowledged  = 1
alertStateToTag InProgress    = 2
alertStateToTag Resolved      = 3
alertStateToTag FalsePositive = 4

||| Decode an ABI tag value to an AlertState.
public export
tagToAlertState : Bits8 -> Maybe AlertState
tagToAlertState 0 = Just New
tagToAlertState 1 = Just Acknowledged
tagToAlertState 2 = Just InProgress
tagToAlertState 3 = Just Resolved
tagToAlertState 4 = Just FalsePositive
tagToAlertState _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
alertStateRoundtrip : (a : AlertState) -> tagToAlertState (alertStateToTag a) = Just a
alertStateRoundtrip New           = Refl
alertStateRoundtrip Acknowledged  = Refl
alertStateRoundtrip InProgress    = Refl
alertStateRoundtrip Resolved      = Refl
alertStateRoundtrip FalsePositive = Refl
