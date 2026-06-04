-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DeceptionABI.Types: C-ABI-compatible numeric representations of Deception types.
--
-- Maps every constructor of the core Deception sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/deception.zig) exactly.
--
-- Types covered:
--   DecoyType                 (6 constructors, tags 0-5)
--   TriggerEvent              (6 constructors, tags 0-5)
--   AlertPriority             (4 constructors, tags 0-3)
--   DecoyState                (4 constructors, tags 0-3)
--   ResponseAction            (5 constructors, tags 0-4)
--   ServerState               (5 constructors, tags 0-4)

module DeceptionABI.Types

%default total

---------------------------------------------------------------------------
-- DecoyType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
decoy_typeSize : Nat
decoy_typeSize = 1

||| DecoyType sum type for ABI encoding.
public export
data DecoyType : Type where
  Service : DecoyType
  Credential : DecoyType
  File : DecoyType
  Network : DecoyType
  Token : DecoyType
  Breadcrumb : DecoyType

||| Encode a DecoyType to its ABI tag value.
public export
decoy_typeToTag : DecoyType -> Bits8
decoy_typeToTag Service = 0
decoy_typeToTag Credential = 1
decoy_typeToTag File = 2
decoy_typeToTag Network = 3
decoy_typeToTag Token = 4
decoy_typeToTag Breadcrumb = 5

||| Decode an ABI tag to a DecoyType.
public export
tagToDecoyType : Bits8 -> Maybe DecoyType
tagToDecoyType 0 = Just Service
tagToDecoyType 1 = Just Credential
tagToDecoyType 2 = Just File
tagToDecoyType 3 = Just Network
tagToDecoyType 4 = Just Token
tagToDecoyType 5 = Just Breadcrumb
tagToDecoyType _ = Nothing

||| Roundtrip proof: decoding an encoded DecoyType yields the original.
public export
decoy_typeRoundtrip : (x : DecoyType) -> tagToDecoyType (decoy_typeToTag x) = Just x
decoy_typeRoundtrip Service = Refl
decoy_typeRoundtrip Credential = Refl
decoy_typeRoundtrip File = Refl
decoy_typeRoundtrip Network = Refl
decoy_typeRoundtrip Token = Refl
decoy_typeRoundtrip Breadcrumb = Refl

---------------------------------------------------------------------------
-- TriggerEvent (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
trigger_eventSize : Nat
trigger_eventSize = 1

||| TriggerEvent sum type for ABI encoding.
public export
data TriggerEvent : Type where
  Access : TriggerEvent
  Login : TriggerEvent
  Read : TriggerEvent
  Write : TriggerEvent
  Execute : TriggerEvent
  Scan : TriggerEvent

||| Encode a TriggerEvent to its ABI tag value.
public export
trigger_eventToTag : TriggerEvent -> Bits8
trigger_eventToTag Access = 0
trigger_eventToTag Login = 1
trigger_eventToTag Read = 2
trigger_eventToTag Write = 3
trigger_eventToTag Execute = 4
trigger_eventToTag Scan = 5

||| Decode an ABI tag to a TriggerEvent.
public export
tagToTriggerEvent : Bits8 -> Maybe TriggerEvent
tagToTriggerEvent 0 = Just Access
tagToTriggerEvent 1 = Just Login
tagToTriggerEvent 2 = Just Read
tagToTriggerEvent 3 = Just Write
tagToTriggerEvent 4 = Just Execute
tagToTriggerEvent 5 = Just Scan
tagToTriggerEvent _ = Nothing

||| Roundtrip proof: decoding an encoded TriggerEvent yields the original.
public export
trigger_eventRoundtrip : (x : TriggerEvent) -> tagToTriggerEvent (trigger_eventToTag x) = Just x
trigger_eventRoundtrip Access = Refl
trigger_eventRoundtrip Login = Refl
trigger_eventRoundtrip Read = Refl
trigger_eventRoundtrip Write = Refl
trigger_eventRoundtrip Execute = Refl
trigger_eventRoundtrip Scan = Refl

---------------------------------------------------------------------------
-- AlertPriority (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
alert_prioritySize : Nat
alert_prioritySize = 1

||| AlertPriority sum type for ABI encoding.
public export
data AlertPriority : Type where
  Low : AlertPriority
  Medium : AlertPriority
  High : AlertPriority
  Critical : AlertPriority

||| Encode a AlertPriority to its ABI tag value.
public export
alert_priorityToTag : AlertPriority -> Bits8
alert_priorityToTag Low = 0
alert_priorityToTag Medium = 1
alert_priorityToTag High = 2
alert_priorityToTag Critical = 3

||| Decode an ABI tag to a AlertPriority.
public export
tagToAlertPriority : Bits8 -> Maybe AlertPriority
tagToAlertPriority 0 = Just Low
tagToAlertPriority 1 = Just Medium
tagToAlertPriority 2 = Just High
tagToAlertPriority 3 = Just Critical
tagToAlertPriority _ = Nothing

||| Roundtrip proof: decoding an encoded AlertPriority yields the original.
public export
alert_priorityRoundtrip : (x : AlertPriority) -> tagToAlertPriority (alert_priorityToTag x) = Just x
alert_priorityRoundtrip Low = Refl
alert_priorityRoundtrip Medium = Refl
alert_priorityRoundtrip High = Refl
alert_priorityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- DecoyState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
decoy_stateSize : Nat
decoy_stateSize = 1

||| DecoyState sum type for ABI encoding.
public export
data DecoyState : Type where
  Active : DecoyState
  Triggered : DecoyState
  Disabled : DecoyState
  Expired : DecoyState

||| Encode a DecoyState to its ABI tag value.
public export
decoy_stateToTag : DecoyState -> Bits8
decoy_stateToTag Active = 0
decoy_stateToTag Triggered = 1
decoy_stateToTag Disabled = 2
decoy_stateToTag Expired = 3

||| Decode an ABI tag to a DecoyState.
public export
tagToDecoyState : Bits8 -> Maybe DecoyState
tagToDecoyState 0 = Just Active
tagToDecoyState 1 = Just Triggered
tagToDecoyState 2 = Just Disabled
tagToDecoyState 3 = Just Expired
tagToDecoyState _ = Nothing

||| Roundtrip proof: decoding an encoded DecoyState yields the original.
public export
decoy_stateRoundtrip : (x : DecoyState) -> tagToDecoyState (decoy_stateToTag x) = Just x
decoy_stateRoundtrip Active = Refl
decoy_stateRoundtrip Triggered = Refl
decoy_stateRoundtrip Disabled = Refl
decoy_stateRoundtrip Expired = Refl

---------------------------------------------------------------------------
-- ResponseAction (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
response_actionSize : Nat
response_actionSize = 1

||| ResponseAction sum type for ABI encoding.
public export
data ResponseAction : Type where
  Alert : ResponseAction
  Redirect : ResponseAction
  Delay : ResponseAction
  Fingerprint : ResponseAction
  Isolate : ResponseAction

||| Encode a ResponseAction to its ABI tag value.
public export
response_actionToTag : ResponseAction -> Bits8
response_actionToTag Alert = 0
response_actionToTag Redirect = 1
response_actionToTag Delay = 2
response_actionToTag Fingerprint = 3
response_actionToTag Isolate = 4

||| Decode an ABI tag to a ResponseAction.
public export
tagToResponseAction : Bits8 -> Maybe ResponseAction
tagToResponseAction 0 = Just Alert
tagToResponseAction 1 = Just Redirect
tagToResponseAction 2 = Just Delay
tagToResponseAction 3 = Just Fingerprint
tagToResponseAction 4 = Just Isolate
tagToResponseAction _ = Nothing

||| Roundtrip proof: decoding an encoded ResponseAction yields the original.
public export
response_actionRoundtrip : (x : ResponseAction) -> tagToResponseAction (response_actionToTag x) = Just x
response_actionRoundtrip Alert = Refl
response_actionRoundtrip Redirect = Refl
response_actionRoundtrip Delay = Refl
response_actionRoundtrip Fingerprint = Refl
response_actionRoundtrip Isolate = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
server_stateSize : Nat
server_stateSize = 1

||| ServerState sum type for ABI encoding.
public export
data ServerState : Type where
  Idle : ServerState
  Configured : ServerState
  Monitoring : ServerState
  Responding : ServerState
  Shutdown : ServerState

||| Encode a ServerState to its ABI tag value.
public export
server_stateToTag : ServerState -> Bits8
server_stateToTag Idle = 0
server_stateToTag Configured = 1
server_stateToTag Monitoring = 2
server_stateToTag Responding = 3
server_stateToTag Shutdown = 4

||| Decode an ABI tag to a ServerState.
public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just Idle
tagToServerState 1 = Just Configured
tagToServerState 2 = Just Monitoring
tagToServerState 3 = Just Responding
tagToServerState 4 = Just Shutdown
tagToServerState _ = Nothing

||| Roundtrip proof: decoding an encoded ServerState yields the original.
public export
server_stateRoundtrip : (x : ServerState) -> tagToServerState (server_stateToTag x) = Just x
server_stateRoundtrip Idle = Refl
server_stateRoundtrip Configured = Refl
server_stateRoundtrip Monitoring = Refl
server_stateRoundtrip Responding = Refl
server_stateRoundtrip Shutdown = Refl
