-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FSMABI.Layout: C-ABI-compatible numeric representations of FSM types.
--
-- Maps every constructor of the four core sum types (TransitionResult,
-- ValidationError, MachineState, EventDisposition) to a fixed Bits8 value
-- for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/fsm.h) and the
-- Zig FFI enums (ffi/zig/src/fsm.zig) exactly.

module FSMABI.Layout

import FSM.Types

%default total

---------------------------------------------------------------------------
-- TransitionResult (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for TransitionResult (1 byte).
public export
transitionResultSize : Nat
transitionResultSize = 1

||| Map TransitionResult to its C-ABI byte value.
|||
||| Tag assignments:
|||   Accepted = 0
|||   Rejected = 1
|||   Deferred = 2
public export
transitionResultToTag : TransitionResult -> Bits8
transitionResultToTag Accepted = 0
transitionResultToTag Rejected = 1
transitionResultToTag Deferred = 2

||| Recover TransitionResult from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToTransitionResult : Bits8 -> Maybe TransitionResult
tagToTransitionResult 0 = Just Accepted
tagToTransitionResult 1 = Just Rejected
tagToTransitionResult 2 = Just Deferred
tagToTransitionResult _ = Nothing

||| Proof: encoding then decoding TransitionResult is the identity.
public export
transitionResultRoundtrip : (r : TransitionResult) -> tagToTransitionResult (transitionResultToTag r) = Just r
transitionResultRoundtrip Accepted = Refl
transitionResultRoundtrip Rejected = Refl
transitionResultRoundtrip Deferred = Refl

---------------------------------------------------------------------------
-- ValidationError (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for ValidationError (1 byte).
public export
validationErrorSize : Nat
validationErrorSize = 1

||| Map ValidationError to its C-ABI byte value.
|||
||| Tag assignments:
|||   InvalidTransition   = 0
|||   PreconditionFailed  = 1
|||   PostconditionFailed = 2
|||   GuardFailed         = 3
public export
validationErrorToTag : ValidationError -> Bits8
validationErrorToTag InvalidTransition   = 0
validationErrorToTag PreconditionFailed  = 1
validationErrorToTag PostconditionFailed = 2
validationErrorToTag GuardFailed         = 3

||| Recover ValidationError from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToValidationError : Bits8 -> Maybe ValidationError
tagToValidationError 0 = Just InvalidTransition
tagToValidationError 1 = Just PreconditionFailed
tagToValidationError 2 = Just PostconditionFailed
tagToValidationError 3 = Just GuardFailed
tagToValidationError _ = Nothing

||| Proof: encoding then decoding ValidationError is the identity.
public export
validationErrorRoundtrip : (e : ValidationError) -> tagToValidationError (validationErrorToTag e) = Just e
validationErrorRoundtrip InvalidTransition   = Refl
validationErrorRoundtrip PreconditionFailed  = Refl
validationErrorRoundtrip PostconditionFailed = Refl
validationErrorRoundtrip GuardFailed         = Refl

---------------------------------------------------------------------------
-- MachineState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for MachineState (1 byte).
public export
machineStateSize : Nat
machineStateSize = 1

||| Map MachineState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Initial  = 0
|||   Running  = 1
|||   Terminal = 2
|||   Faulted  = 3
public export
machineStateToTag : MachineState -> Bits8
machineStateToTag Initial  = 0
machineStateToTag Running  = 1
machineStateToTag Terminal = 2
machineStateToTag Faulted  = 3

||| Recover MachineState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToMachineState : Bits8 -> Maybe MachineState
tagToMachineState 0 = Just Initial
tagToMachineState 1 = Just Running
tagToMachineState 2 = Just Terminal
tagToMachineState 3 = Just Faulted
tagToMachineState _ = Nothing

||| Proof: encoding then decoding MachineState is the identity.
public export
machineStateRoundtrip : (s : MachineState) -> tagToMachineState (machineStateToTag s) = Just s
machineStateRoundtrip Initial  = Refl
machineStateRoundtrip Running  = Refl
machineStateRoundtrip Terminal = Refl
machineStateRoundtrip Faulted  = Refl

---------------------------------------------------------------------------
-- EventDisposition (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for EventDisposition (1 byte).
public export
eventDispositionSize : Nat
eventDispositionSize = 1

||| Map EventDisposition to its C-ABI byte value.
|||
||| Tag assignments:
|||   Consumed = 0
|||   Ignored  = 1
|||   Queued   = 2
|||   Dropped  = 3
public export
eventDispositionToTag : EventDisposition -> Bits8
eventDispositionToTag Consumed = 0
eventDispositionToTag Ignored  = 1
eventDispositionToTag Queued   = 2
eventDispositionToTag Dropped  = 3

||| Recover EventDisposition from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToEventDisposition : Bits8 -> Maybe EventDisposition
tagToEventDisposition 0 = Just Consumed
tagToEventDisposition 1 = Just Ignored
tagToEventDisposition 2 = Just Queued
tagToEventDisposition 3 = Just Dropped
tagToEventDisposition _ = Nothing

||| Proof: encoding then decoding EventDisposition is the identity.
public export
eventDispositionRoundtrip : (d : EventDisposition) -> tagToEventDisposition (eventDispositionToTag d) = Just d
eventDispositionRoundtrip Consumed = Refl
eventDispositionRoundtrip Ignored  = Refl
eventDispositionRoundtrip Queued   = Refl
eventDispositionRoundtrip Dropped  = Refl
