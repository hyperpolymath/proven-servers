-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- IDSABI.Transitions: Valid packet inspection and alert lifecycle state transitions.
--
-- Models the packet inspection lifecycle through the IDS engine:
--
--   Captured --> Decoded --> Inspecting --> Evaluated --> Disposed
--
-- With an alert lifecycle layered on top:
--
--   Idle --> Triggered --> Escalated --> Acknowledged --> Closed
--
-- The key invariants:
--   - Disposed is terminal for packet inspection (no outbound edges).
--   - Closed is terminal for alert lifecycle (no outbound edges).
--   - Cannot skip from Captured directly to Evaluated without inspection.
--   - Cannot go backwards from Evaluated to Captured.
--   - Escalation requires the alert to be in Triggered state.
--   - Only Acknowledged alerts can be Closed.

module IDSABI.Transitions

import IDS.Types

%default total

---------------------------------------------------------------------------
-- Packet inspection states
---------------------------------------------------------------------------

||| The lifecycle state of a packet being inspected by the IDS engine.
public export
data InspectionState : Type where
  ||| Packet captured from the wire but not yet decoded.
  Captured   : InspectionState
  ||| Packet decoded: protocol, addresses, ports extracted.
  Decoded    : InspectionState
  ||| Rules are being evaluated against the decoded packet.
  Inspecting : InspectionState
  ||| All rules evaluated, match status determined.
  Evaluated  : InspectionState
  ||| Packet has been disposed of (alert raised, dropped, logged, etc.) -- terminal.
  Disposed   : InspectionState

public export
Eq InspectionState where
  Captured   == Captured   = True
  Decoded    == Decoded    = True
  Inspecting == Inspecting = True
  Evaluated  == Evaluated  = True
  Disposed   == Disposed   = True
  _          == _          = False

---------------------------------------------------------------------------
-- Alert lifecycle states
---------------------------------------------------------------------------

||| The lifecycle state of an IDS alert.
public export
data AlertState : Type where
  ||| No alert raised yet (initial state).
  Idle         : AlertState
  ||| Alert triggered by a rule match.
  Triggered    : AlertState
  ||| Alert escalated to a higher severity or notification channel.
  Escalated    : AlertState
  ||| Alert acknowledged by an operator.
  Acknowledged : AlertState
  ||| Alert closed (resolved or dismissed) -- terminal.
  Closed       : AlertState

public export
Eq AlertState where
  Idle         == Idle         = True
  Triggered    == Triggered    = True
  Escalated    == Escalated    = True
  Acknowledged == Acknowledged = True
  Closed       == Closed       = True
  _            == _            = False

---------------------------------------------------------------------------
-- ValidInspectionTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a packet inspection state transition is valid.
public export
data ValidInspectionTransition : InspectionState -> InspectionState -> Type where
  ||| Captured -> Decoded (parse packet headers, extract fields).
  DecodePacket    : ValidInspectionTransition Captured Decoded
  ||| Decoded -> Inspecting (begin walking rule set against packet).
  BeginInspection : ValidInspectionTransition Decoded Inspecting
  ||| Inspecting -> Evaluated (all rules checked, match status known).
  CompleteRules   : ValidInspectionTransition Inspecting Evaluated
  ||| Evaluated -> Disposed (apply decided action: alert, drop, log, etc.).
  DisposePacket   : ValidInspectionTransition Evaluated Disposed
  ||| Captured -> Disposed (abort: malformed packet, drop immediately).
  AbortCaptured   : ValidInspectionTransition Captured Disposed
  ||| Decoded -> Disposed (abort: invalid protocol, drop after decode).
  AbortDecoded    : ValidInspectionTransition Decoded Disposed
  ||| Inspecting -> Disposed (abort: engine error during inspection).
  AbortInspecting : ValidInspectionTransition Inspecting Disposed

---------------------------------------------------------------------------
-- ValidAlertTransition: exhaustive enumeration of legal alert transitions.
---------------------------------------------------------------------------

||| Proof witness that an alert lifecycle state transition is valid.
public export
data ValidAlertTransition : AlertState -> AlertState -> Type where
  ||| Idle -> Triggered (rule matched, alert raised).
  TriggerAlert      : ValidAlertTransition Idle Triggered
  ||| Triggered -> Escalated (severity upgrade or operator notification).
  EscalateAlert     : ValidAlertTransition Triggered Escalated
  ||| Triggered -> Acknowledged (operator acknowledges without escalation).
  AcknowledgeDirect : ValidAlertTransition Triggered Acknowledged
  ||| Escalated -> Acknowledged (operator acknowledges after escalation).
  AcknowledgeEsc    : ValidAlertTransition Escalated Acknowledged
  ||| Acknowledged -> Closed (operator resolves or dismisses the alert).
  CloseAlert        : ValidAlertTransition Acknowledged Closed
  ||| Triggered -> Closed (auto-close: suppression threshold reached).
  AutoClose         : ValidAlertTransition Triggered Closed

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that rules can be evaluated against a packet (must be Inspecting).
public export
data CanInspect : InspectionState -> Type where
  InspectingCanInspect : CanInspect Inspecting

||| Proof that a packet can be disposed (must be Evaluated).
public export
data CanDispose : InspectionState -> Type where
  EvaluatedCanDispose : CanDispose Evaluated

||| Proof that an alert can be triggered (must be Idle).
public export
data CanTrigger : AlertState -> Type where
  IdleCanTrigger : CanTrigger Idle

||| Proof that an alert can be escalated (must be Triggered).
public export
data CanEscalate : AlertState -> Type where
  TriggeredCanEscalate : CanEscalate Triggered

||| Proof that an alert can be acknowledged (Triggered or Escalated).
public export
data CanAcknowledge : AlertState -> Type where
  TriggeredCanAck : CanAcknowledge Triggered
  EscalatedCanAck : CanAcknowledge Escalated

||| Proof that an alert can be closed (must be Acknowledged).
public export
data CanClose : AlertState -> Type where
  AcknowledgedCanClose : CanClose Acknowledged

---------------------------------------------------------------------------
-- Impossibility proofs -- packet inspection
---------------------------------------------------------------------------

||| Cannot leave the Disposed state -- it is terminal.
public export
disposedIsTerminal : ValidInspectionTransition Disposed s -> Void
disposedIsTerminal _ impossible

||| Cannot skip from Captured directly to Evaluated.
public export
cannotSkipToEvaluated : ValidInspectionTransition Captured Evaluated -> Void
cannotSkipToEvaluated _ impossible

||| Cannot go backwards from Evaluated to Captured.
public export
cannotGoBackToCaptured : ValidInspectionTransition Evaluated Captured -> Void
cannotGoBackToCaptured _ impossible

||| Cannot go backwards from Inspecting to Captured.
public export
cannotGoBackFromInspecting : ValidInspectionTransition Inspecting Captured -> Void
cannotGoBackFromInspecting _ impossible

||| Cannot go backwards from Evaluated to Decoded.
public export
cannotGoBackToDecoded : ValidInspectionTransition Evaluated Decoded -> Void
cannotGoBackToDecoded _ impossible

||| Cannot inspect rules from Captured state (must decode first).
public export
cannotInspectFromCaptured : CanInspect Captured -> Void
cannotInspectFromCaptured _ impossible

||| Cannot dispose from Captured via CanDispose (must evaluate first).
public export
cannotDisposeFromCaptured : CanDispose Captured -> Void
cannotDisposeFromCaptured _ impossible

---------------------------------------------------------------------------
-- Impossibility proofs -- alert lifecycle
---------------------------------------------------------------------------

||| Cannot leave the Closed state -- it is terminal.
public export
closedIsTerminal : ValidAlertTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot escalate from Idle (must trigger first).
public export
cannotEscalateFromIdle : CanEscalate Idle -> Void
cannotEscalateFromIdle _ impossible

||| Cannot close from Idle (must trigger first).
public export
cannotCloseFromIdle : CanClose Idle -> Void
cannotCloseFromIdle _ impossible

||| Cannot trigger from Triggered (already triggered).
public export
cannotDoubleTrigger : CanTrigger Triggered -> Void
cannotDoubleTrigger _ impossible

||| Cannot close directly from Escalated (must acknowledge first).
public export
cannotCloseFromEscalated : CanClose Escalated -> Void
cannotCloseFromEscalated _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a packet inspection state transition is valid.
public export
validateInspectionTransition : (from : InspectionState) -> (to : InspectionState)
                             -> Maybe (ValidInspectionTransition from to)
validateInspectionTransition Captured   Decoded    = Just DecodePacket
validateInspectionTransition Decoded    Inspecting = Just BeginInspection
validateInspectionTransition Inspecting Evaluated  = Just CompleteRules
validateInspectionTransition Evaluated  Disposed   = Just DisposePacket
validateInspectionTransition Captured   Disposed   = Just AbortCaptured
validateInspectionTransition Decoded    Disposed   = Just AbortDecoded
validateInspectionTransition Inspecting Disposed   = Just AbortInspecting
validateInspectionTransition _          _          = Nothing

||| Check whether an alert lifecycle state transition is valid.
public export
validateAlertTransition : (from : AlertState) -> (to : AlertState)
                        -> Maybe (ValidAlertTransition from to)
validateAlertTransition Idle         Triggered    = Just TriggerAlert
validateAlertTransition Triggered    Escalated    = Just EscalateAlert
validateAlertTransition Triggered    Acknowledged = Just AcknowledgeDirect
validateAlertTransition Escalated    Acknowledged = Just AcknowledgeEsc
validateAlertTransition Acknowledged Closed       = Just CloseAlert
validateAlertTransition Triggered    Closed       = Just AutoClose
validateAlertTransition _            _            = Nothing
