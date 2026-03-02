-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FrameABI.Transitions: Valid state transition proofs for frame parsing.
--
-- This module is the heart of the formal verification layer.  It defines:
--
--   1. ValidTransition -- a GADT whose constructors enumerate every legal
--      state transition in the frame parsing state machine.
--
--   2. CanDecode -- a proof witness that the parser is in an active state
--      where more data can be fed in (AwaitingHeader or AwaitingPayload).
--
--   3. CanEmit -- a proof witness that a complete frame is ready to be
--      consumed (Complete only).
--
--   4. CanReset -- a proof witness that the parser can be reset to start
--      parsing a new frame (Complete or Failed).
--
--   5. Impossibility proofs and decidability procedures.
--
-- The state machine modelled here is:
--
--   AwaitingHeader --HeaderReceived--> AwaitingPayload --PayloadDone--> Complete
--        |                                   |                            |
--        +---DirectComplete--> Complete       |                         Reset
--        |                       |            |                            |
--        +---HeaderFail--->      |            +---PayloadFail-->           |
--        |                  Failed <----------+                  AwaitingHeader
--        |                    |                                            ^
--        |                    +---ErrorReset----> AwaitingHeader -----------+
--        |                                                                 |
--        +----------------------------------------------------------------+
--                              (Reset from Complete)
--
-- Every arrow has exactly one ValidTransition constructor.

module FrameABI.Transitions

import Frame.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a state transition is valid.
||| Only constructors for legal transitions exist -- the type system
||| prevents any transition not listed here.
public export
data ValidTransition : FrameState -> FrameState -> Type where
  ||| AwaitingHeader -> AwaitingPayload (header parsed, need payload).
  HeaderReceived : ValidTransition AwaitingHeader AwaitingPayload
  ||| AwaitingPayload -> Complete (full frame assembled).
  PayloadDone    : ValidTransition AwaitingPayload Complete
  ||| AwaitingHeader -> Complete (delimiter-based: frame complete at header).
  DirectComplete : ValidTransition AwaitingHeader Complete
  ||| AwaitingHeader -> Failed (header parse error).
  HeaderFail     : ValidTransition AwaitingHeader Failed
  ||| AwaitingPayload -> Failed (payload error, e.g. oversized).
  PayloadFail    : ValidTransition AwaitingPayload Failed
  ||| Complete -> AwaitingHeader (reset parser for next frame).
  Reset          : ValidTransition Complete AwaitingHeader
  ||| Failed -> AwaitingHeader (reset after error, discard bad data).
  ErrorReset     : ValidTransition Failed AwaitingHeader

||| Show instance for ValidTransition.
public export
Show (ValidTransition from to) where
  show HeaderReceived = "HeaderReceived"
  show PayloadDone    = "PayloadDone"
  show DirectComplete = "DirectComplete"
  show HeaderFail     = "HeaderFail"
  show PayloadFail    = "PayloadFail"
  show Reset          = "Reset"
  show ErrorReset     = "ErrorReset"

---------------------------------------------------------------------------
-- CanDecode: proof that the parser is in an active decoding state.
---------------------------------------------------------------------------

||| Proof witness that the parser can accept more input data.
||| Only AwaitingHeader and AwaitingPayload are active parsing states.
public export
data CanDecode : FrameState -> Type where
  ||| Decoding is possible when waiting for a frame header.
  DecodeHeader  : CanDecode AwaitingHeader
  ||| Decoding is possible when waiting for frame payload.
  DecodePayload : CanDecode AwaitingPayload

---------------------------------------------------------------------------
-- CanEmit: proof that a complete frame is ready.
---------------------------------------------------------------------------

||| Proof witness that a complete frame can be emitted / consumed.
||| Only the Complete state has a fully assembled frame.
public export
data CanEmit : FrameState -> Type where
  ||| A frame is ready to emit when parsing is Complete.
  EmitComplete : CanEmit Complete

---------------------------------------------------------------------------
-- CanReset: proof that the parser can be reset.
---------------------------------------------------------------------------

||| Proof witness that the parser can be reset to AwaitingHeader.
||| Resetting is valid from Complete (normal) or Failed (error recovery).
public export
data CanReset : FrameState -> Type where
  ||| Reset is allowed after a complete frame has been consumed.
  ResetFromComplete : CanReset Complete
  ||| Reset is allowed after a parse failure (error recovery).
  ResetFromFailed   : CanReset Failed

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Proof that you cannot decode when Complete.
public export
completeCantDecode : CanDecode Complete -> Void
completeCantDecode x impossible

||| Proof that you cannot decode when Failed.
public export
failedCantDecode : CanDecode Failed -> Void
failedCantDecode x impossible

||| Proof that you cannot emit when AwaitingHeader.
public export
awaitingHeaderCantEmit : CanEmit AwaitingHeader -> Void
awaitingHeaderCantEmit x impossible

||| Proof that you cannot emit when AwaitingPayload.
public export
awaitingPayloadCantEmit : CanEmit AwaitingPayload -> Void
awaitingPayloadCantEmit x impossible

||| Proof that you cannot emit when Failed.
public export
failedCantEmit : CanEmit Failed -> Void
failedCantEmit x impossible

||| Proof that you cannot reset when AwaitingHeader.
public export
awaitingHeaderCantReset : CanReset AwaitingHeader -> Void
awaitingHeaderCantReset x impossible

||| Proof that you cannot reset when AwaitingPayload.
public export
awaitingPayloadCantReset : CanReset AwaitingPayload -> Void
awaitingPayloadCantReset x impossible

---------------------------------------------------------------------------
-- Decidability: runtime decision procedures for capabilities.
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits decoding (feeding data).
public export
canDecode : (s : FrameState) -> Dec (CanDecode s)
canDecode AwaitingHeader  = Yes DecodeHeader
canDecode AwaitingPayload = Yes DecodePayload
canDecode Complete        = No completeCantDecode
canDecode Failed          = No failedCantDecode

||| Decide at runtime whether a given state has a complete frame to emit.
public export
canEmit : (s : FrameState) -> Dec (CanEmit s)
canEmit AwaitingHeader  = No awaitingHeaderCantEmit
canEmit AwaitingPayload = No awaitingPayloadCantEmit
canEmit Complete        = Yes EmitComplete
canEmit Failed          = No failedCantEmit

||| Decide at runtime whether a given state permits resetting.
public export
canReset : (s : FrameState) -> Dec (CanReset s)
canReset AwaitingHeader  = No awaitingHeaderCantReset
canReset AwaitingPayload = No awaitingPayloadCantReset
canReset Complete        = Yes ResetFromComplete
canReset Failed          = Yes ResetFromFailed
