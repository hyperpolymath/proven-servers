-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTPABI.Transitions: Valid state transition proofs for NTP exchange lifecycle
-- and clock discipline algorithm.
--
-- This module defines the formal verification layer for NTP protocol
-- state machines.  It models two distinct lifecycles:
--
-- 1. NTP Exchange Lifecycle (per-request):
--
--   Idle --ReceiveRequest--> RequestReceived
--     --CalculateTimestamps--> TimestampCalculated
--     --SendResponse--> ResponseSent
--     --ResetExchange--> Idle
--
-- 2. Clock Discipline States (RFC 5905 Section 12):
--
--   Unset --FirstSample--> Spike --Stabilise--> Freq --Lock--> Sync
--     |                      |                    |              |
--     +---PanicOffset------->+---PanicOffset----->+--PanicOff-->Panic
--     |                                                          |
--     +<---Recovery (from Panic to Unset)------------------------+
--
-- Every arrow has exactly one GADT constructor.
-- The type system prevents any transition not listed here.

module NTPABI.Transitions

import NTPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidExchangeTransition: exhaustive enumeration of legal NTP exchange
-- lifecycle transitions.
---------------------------------------------------------------------------

||| Proof witness that an NTP exchange state transition is valid.
||| Only constructors for legal transitions exist — the type system
||| prevents any transition not listed here.
public export
data ValidExchangeTransition : ExchangeState -> ExchangeState -> Type where
  ||| Idle -> RequestReceived (client request arrives, t1 and t2 captured).
  ReceiveRequest      : ValidExchangeTransition Idle RequestReceived
  ||| RequestReceived -> TimestampCalculated (offset/delay computed from t1,t2,t3).
  CalculateTimestamps : ValidExchangeTransition RequestReceived TimestampCalculated
  ||| TimestampCalculated -> ResponseSent (server response dispatched, t4 recorded).
  SendResponse        : ValidExchangeTransition TimestampCalculated ResponseSent
  ||| ResponseSent -> Idle (exchange complete, ready for next request).
  ResetExchange       : ValidExchangeTransition ResponseSent Idle

---------------------------------------------------------------------------
-- Capability witnesses for exchange states
---------------------------------------------------------------------------

||| Proof that the exchange is idle and can receive a new request.
public export
data CanReceiveRequest : ExchangeState -> Type where
  IdleCanReceive : CanReceiveRequest Idle

||| Proof that the exchange has a request and can calculate timestamps.
public export
data CanCalculate : ExchangeState -> Type where
  ReceivedCanCalculate : CanCalculate RequestReceived

||| Proof that timestamps are calculated and a response can be sent.
public export
data CanSendResponse : ExchangeState -> Type where
  CalculatedCanSend : CanSendResponse TimestampCalculated

||| Proof that the response was sent and the exchange can be reset.
public export
data CanResetExchange : ExchangeState -> Type where
  SentCanReset : CanResetExchange ResponseSent

---------------------------------------------------------------------------
-- Impossibility proofs for exchange transitions
---------------------------------------------------------------------------

||| Cannot receive a request while already processing one.
public export
cannotReceiveWhileProcessing : ValidExchangeTransition RequestReceived Idle -> Void
cannotReceiveWhileProcessing _ impossible

||| Cannot skip calculation and send response directly from Idle.
public export
cannotSendFromIdle : ValidExchangeTransition Idle ResponseSent -> Void
cannotSendFromIdle _ impossible

||| Cannot go backwards from TimestampCalculated to RequestReceived.
public export
cannotUncalculate : ValidExchangeTransition TimestampCalculated RequestReceived -> Void
cannotUncalculate _ impossible

||| Cannot go backwards from ResponseSent to TimestampCalculated.
public export
cannotUnsend : ValidExchangeTransition ResponseSent TimestampCalculated -> Void
cannotUnsend _ impossible

||| Cannot skip straight from Idle to TimestampCalculated.
public export
cannotCalculateWithoutRequest : ValidExchangeTransition Idle TimestampCalculated -> Void
cannotCalculateWithoutRequest _ impossible

||| Cannot skip from RequestReceived to ResponseSent.
public export
cannotSkipCalculation : ValidExchangeTransition RequestReceived ResponseSent -> Void
cannotSkipCalculation _ impossible

---------------------------------------------------------------------------
-- Exchange transition validation function
---------------------------------------------------------------------------

||| Check whether a transition between two exchange states is valid.
||| Returns the proof witness if valid, Nothing otherwise.
public export
validateExchangeTransition : (from : ExchangeState) -> (to : ExchangeState)
                          -> Maybe (ValidExchangeTransition from to)
validateExchangeTransition Idle                RequestReceived     = Just ReceiveRequest
validateExchangeTransition RequestReceived     TimestampCalculated = Just CalculateTimestamps
validateExchangeTransition TimestampCalculated ResponseSent        = Just SendResponse
validateExchangeTransition ResponseSent        Idle                = Just ResetExchange
validateExchangeTransition _                   _                   = Nothing

---------------------------------------------------------------------------
-- ValidDisciplineTransition: exhaustive enumeration of legal clock
-- discipline state transitions (RFC 5905 Section 12).
---------------------------------------------------------------------------

||| Proof witness that a clock discipline state transition is valid.
||| Models the NTP clock discipline algorithm's state machine.
public export
data ValidDisciplineTransition : ClockDisciplineState -> ClockDisciplineState -> Type where
  ||| Unset -> Spike (first measurement arrives).
  FirstSample   : ValidDisciplineTransition Unset Spike
  ||| Spike -> Freq (enough samples to begin frequency estimation).
  Stabilise     : ValidDisciplineTransition Spike Freq
  ||| Freq -> Sync (frequency correction complete, phase-lock engaged).
  Lock          : ValidDisciplineTransition Freq Sync
  ||| Unset -> Panic (initial offset exceeds panic threshold).
  PanicFromUnset : ValidDisciplineTransition Unset Panic
  ||| Spike -> Panic (spike exceeds panic threshold).
  PanicFromSpike : ValidDisciplineTransition Spike Panic
  ||| Freq -> Panic (frequency drift exceeds panic threshold).
  PanicFromFreq  : ValidDisciplineTransition Freq Panic
  ||| Sync -> Panic (synchronised clock drifts beyond panic threshold).
  PanicFromSync  : ValidDisciplineTransition Sync Panic
  ||| Panic -> Unset (operator/automatic recovery, restart discipline).
  Recovery       : ValidDisciplineTransition Panic Unset
  ||| Sync -> Freq (lost lock, need to re-estimate frequency).
  LostLock       : ValidDisciplineTransition Sync Freq

---------------------------------------------------------------------------
-- Capability witnesses for discipline states
---------------------------------------------------------------------------

||| Proof that the clock is synchronised and providing corrections.
public export
data IsSynchronised : ClockDisciplineState -> Type where
  SyncIsSynchronised : IsSynchronised Sync

||| Proof that the clock discipline has panicked and needs recovery.
public export
data IsPanicked : ClockDisciplineState -> Type where
  PanicIsPanicked : IsPanicked Panic

---------------------------------------------------------------------------
-- Impossibility proofs for discipline transitions
---------------------------------------------------------------------------

||| Cannot go from Panic directly to Sync (must restart discipline).
public export
cannotPanicToSync : ValidDisciplineTransition Panic Sync -> Void
cannotPanicToSync _ impossible

||| Cannot go from Panic directly to Freq (must restart from Unset).
public export
cannotPanicToFreq : ValidDisciplineTransition Panic Freq -> Void
cannotPanicToFreq _ impossible

||| Cannot go backwards from Freq to Spike.
public export
cannotFreqToSpike : ValidDisciplineTransition Freq Spike -> Void
cannotFreqToSpike _ impossible

||| Cannot skip from Unset directly to Sync.
public export
cannotSkipToSync : ValidDisciplineTransition Unset Sync -> Void
cannotSkipToSync _ impossible

---------------------------------------------------------------------------
-- Discipline transition validation function
---------------------------------------------------------------------------

||| Check whether a transition between two discipline states is valid.
||| Returns the proof witness if valid, Nothing otherwise.
public export
validateDisciplineTransition : (from : ClockDisciplineState) -> (to : ClockDisciplineState)
                            -> Maybe (ValidDisciplineTransition from to)
validateDisciplineTransition Unset Spike = Just FirstSample
validateDisciplineTransition Spike Freq  = Just Stabilise
validateDisciplineTransition Freq  Sync  = Just Lock
validateDisciplineTransition Unset Panic = Just PanicFromUnset
validateDisciplineTransition Spike Panic = Just PanicFromSpike
validateDisciplineTransition Freq  Panic = Just PanicFromFreq
validateDisciplineTransition Sync  Panic = Just PanicFromSync
validateDisciplineTransition Panic Unset = Just Recovery
validateDisciplineTransition Sync  Freq  = Just LostLock
validateDisciplineTransition _     _     = Nothing

---------------------------------------------------------------------------
-- Exchange lifecycle GADT: typed sequence of transitions.
-- Ensures that a complete exchange follows the exact protocol order.
---------------------------------------------------------------------------

||| A proof that a sequence of exchange transitions forms a valid
||| protocol run from state `start` to state `end`.
public export
data ExchangeTrace : ExchangeState -> ExchangeState -> Type where
  ||| Empty trace: the exchange is already in the target state.
  Done : ExchangeTrace s s
  ||| A single transition step followed by a continuation trace.
  Step : ValidExchangeTransition s mid
      -> ExchangeTrace mid end
      -> ExchangeTrace s end

||| A complete NTP exchange: Idle -> ResponseSent.
||| This is the only valid full-cycle trace through the protocol.
public export
completeExchange : ExchangeTrace Idle ResponseSent
completeExchange = Step ReceiveRequest
                 $ Step CalculateTimestamps
                 $ Step SendResponse
                 $ Done

||| A complete NTP exchange cycle: Idle -> Idle (including reset).
public export
fullCycle : ExchangeTrace Idle Idle
fullCycle = Step ReceiveRequest
          $ Step CalculateTimestamps
          $ Step SendResponse
          $ Step ResetExchange
          $ Done
