-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DeceptionABI.Types: C-ABI-compatible numeric representations of Deception types.
--
-- Maps every constructor of the core Deception sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/deception.h) and the
-- Zig FFI enums (ffi/zig/src/deception.zig) exactly.
--
-- Types covered:
--   DecoyType      (6 constructors, tags 0-5)
--   TriggerEvent   (6 constructors, tags 0-5)
--   AlertPriority  (4 constructors, tags 0-3)
--   DecoyState     (4 constructors, tags 0-3)
--   ResponseAction (5 constructors, tags 0-4)
--   ServerState    (5 constructors, tags 0-4)

module DeceptionABI.Types

import Deception.Types

%default total

---------------------------------------------------------------------------
-- DecoyType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
decoyTypeToTag : DecoyType -> Bits8
decoyTypeToTag Service    = 0
decoyTypeToTag Credential = 1
decoyTypeToTag File       = 2
decoyTypeToTag Network    = 3
decoyTypeToTag Token      = 4
decoyTypeToTag Breadcrumb = 5

public export
tagToDecoyType : Bits8 -> Maybe DecoyType
tagToDecoyType 0 = Just Service
tagToDecoyType 1 = Just Credential
tagToDecoyType 2 = Just File
tagToDecoyType 3 = Just Network
tagToDecoyType 4 = Just Token
tagToDecoyType 5 = Just Breadcrumb
tagToDecoyType _ = Nothing

public export
decoyTypeRoundtrip : (d : DecoyType) -> tagToDecoyType (decoyTypeToTag d) = Just d
decoyTypeRoundtrip Service    = Refl
decoyTypeRoundtrip Credential = Refl
decoyTypeRoundtrip File       = Refl
decoyTypeRoundtrip Network    = Refl
decoyTypeRoundtrip Token      = Refl
decoyTypeRoundtrip Breadcrumb = Refl

---------------------------------------------------------------------------
-- TriggerEvent (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
triggerEventToTag : TriggerEvent -> Bits8
triggerEventToTag Access  = 0
triggerEventToTag Login   = 1
triggerEventToTag Read    = 2
triggerEventToTag Write   = 3
triggerEventToTag Execute = 4
triggerEventToTag Scan    = 5

public export
tagToTriggerEvent : Bits8 -> Maybe TriggerEvent
tagToTriggerEvent 0 = Just Access
tagToTriggerEvent 1 = Just Login
tagToTriggerEvent 2 = Just Read
tagToTriggerEvent 3 = Just Write
tagToTriggerEvent 4 = Just Execute
tagToTriggerEvent 5 = Just Scan
tagToTriggerEvent _ = Nothing

public export
triggerEventRoundtrip : (t : TriggerEvent) -> tagToTriggerEvent (triggerEventToTag t) = Just t
triggerEventRoundtrip Access  = Refl
triggerEventRoundtrip Login   = Refl
triggerEventRoundtrip Read    = Refl
triggerEventRoundtrip Write   = Refl
triggerEventRoundtrip Execute = Refl
triggerEventRoundtrip Scan    = Refl

---------------------------------------------------------------------------
-- AlertPriority (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
alertPriorityToTag : AlertPriority -> Bits8
alertPriorityToTag Low      = 0
alertPriorityToTag Medium   = 1
alertPriorityToTag High     = 2
alertPriorityToTag Critical = 3

public export
tagToAlertPriority : Bits8 -> Maybe AlertPriority
tagToAlertPriority 0 = Just Low
tagToAlertPriority 1 = Just Medium
tagToAlertPriority 2 = Just High
tagToAlertPriority 3 = Just Critical
tagToAlertPriority _ = Nothing

public export
alertPriorityRoundtrip : (a : AlertPriority) -> tagToAlertPriority (alertPriorityToTag a) = Just a
alertPriorityRoundtrip Low      = Refl
alertPriorityRoundtrip Medium   = Refl
alertPriorityRoundtrip High     = Refl
alertPriorityRoundtrip Critical = Refl

---------------------------------------------------------------------------
-- DecoyState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
decoyStateToTag : DecoyState -> Bits8
decoyStateToTag Active    = 0
decoyStateToTag Triggered = 1
decoyStateToTag Disabled  = 2
decoyStateToTag Expired   = 3

public export
tagToDecoyState : Bits8 -> Maybe DecoyState
tagToDecoyState 0 = Just Active
tagToDecoyState 1 = Just Triggered
tagToDecoyState 2 = Just Disabled
tagToDecoyState 3 = Just Expired
tagToDecoyState _ = Nothing

public export
decoyStateRoundtrip : (s : DecoyState) -> tagToDecoyState (decoyStateToTag s) = Just s
decoyStateRoundtrip Active    = Refl
decoyStateRoundtrip Triggered = Refl
decoyStateRoundtrip Disabled  = Refl
decoyStateRoundtrip Expired   = Refl

---------------------------------------------------------------------------
-- ResponseAction (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
responseActionToTag : ResponseAction -> Bits8
responseActionToTag Alert       = 0
responseActionToTag Redirect    = 1
responseActionToTag Delay       = 2
responseActionToTag Fingerprint = 3
responseActionToTag Isolate     = 4

public export
tagToResponseAction : Bits8 -> Maybe ResponseAction
tagToResponseAction 0 = Just Alert
tagToResponseAction 1 = Just Redirect
tagToResponseAction 2 = Just Delay
tagToResponseAction 3 = Just Fingerprint
tagToResponseAction 4 = Just Isolate
tagToResponseAction _ = Nothing

public export
responseActionRoundtrip : (r : ResponseAction) -> tagToResponseAction (responseActionToTag r) = Just r
responseActionRoundtrip Alert       = Refl
responseActionRoundtrip Redirect    = Refl
responseActionRoundtrip Delay       = Refl
responseActionRoundtrip Fingerprint = Refl
responseActionRoundtrip Isolate     = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- Deception server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Deception server lifecycle states.
public export
data ServerState : Type where
  ||| No decoys deployed. Initial and terminal state.
  SSIdle       : ServerState
  ||| Server configured, ready to deploy decoys.
  SSConfigured : ServerState
  ||| Actively monitoring deployed decoys.
  SSMonitoring : ServerState
  ||| Processing a triggered decoy alert.
  SSResponding : ServerState
  ||| Shutting down, removing decoys.
  SSShutdown   : ServerState

public export
Eq ServerState where
  SSIdle       == SSIdle       = True
  SSConfigured == SSConfigured = True
  SSMonitoring == SSMonitoring = True
  SSResponding == SSResponding = True
  SSShutdown   == SSShutdown   = True
  _            == _            = False

public export
Show ServerState where
  show SSIdle       = "Idle"
  show SSConfigured = "Configured"
  show SSMonitoring = "Monitoring"
  show SSResponding = "Responding"
  show SSShutdown   = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SSIdle       = 0
serverStateToTag SSConfigured = 1
serverStateToTag SSMonitoring = 2
serverStateToTag SSResponding = 3
serverStateToTag SSShutdown   = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SSIdle
tagToServerState 1 = Just SSConfigured
tagToServerState 2 = Just SSMonitoring
tagToServerState 3 = Just SSResponding
tagToServerState 4 = Just SSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SSIdle       = Refl
serverStateRoundtrip SSConfigured = Refl
serverStateRoundtrip SSMonitoring = Refl
serverStateRoundtrip SSResponding = Refl
serverStateRoundtrip SSShutdown   = Refl
