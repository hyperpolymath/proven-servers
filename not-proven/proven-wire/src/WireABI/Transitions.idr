-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WireABI.Transitions: Valid codec operation proofs for wire encoding.
--
-- Models the lifecycle of a wire encoding/decoding operation:
--
--   Idle --BeginEncode--> Encoding --Finalize--> Complete
--   Idle --BeginDecode--> Decoding --Finalize--> Complete
--   Encoding|Decoding --Fail--> Failed
--   Failed --Reset--> Idle
--   Complete --Reset--> Idle
--
-- The key invariant: a codec cannot be simultaneously encoding and decoding.
-- The Roundtrip codec verifies that encode-then-decode is the identity.

module WireABI.Transitions

import Wire.Types

%default total

---------------------------------------------------------------------------
-- Codec state — the lifecycle state of a wire codec operation.
---------------------------------------------------------------------------

||| The lifecycle state of a wire codec session.
public export
data CodecState : Type where
  ||| No operation in progress.
  Idle     : CodecState
  ||| Encoding (serialising) is in progress.
  Encoding : CodecState
  ||| Decoding (deserialising) is in progress.
  Decoding : CodecState
  ||| Operation completed successfully.
  Complete : CodecState
  ||| Operation failed with an error.
  Failed   : CodecState

public export
Show CodecState where
  show Idle     = "Idle"
  show Encoding = "Encoding"
  show Decoding = "Decoding"
  show Complete = "Complete"
  show Failed   = "Failed"

---------------------------------------------------------------------------
-- ValidCodecTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a codec state transition is valid.
public export
data ValidCodecTransition : CodecState -> CodecState -> Type where
  ||| Idle -> Encoding (begin serialisation).
  BeginEncode   : ValidCodecTransition Idle Encoding
  ||| Idle -> Decoding (begin deserialisation).
  BeginDecode   : ValidCodecTransition Idle Decoding
  ||| Encoding -> Complete (serialisation succeeded).
  FinalizeEnc   : ValidCodecTransition Encoding Complete
  ||| Decoding -> Complete (deserialisation succeeded).
  FinalizeDec   : ValidCodecTransition Decoding Complete
  ||| Encoding -> Failed (serialisation error).
  FailEncode    : ValidCodecTransition Encoding Failed
  ||| Decoding -> Failed (deserialisation error).
  FailDecode    : ValidCodecTransition Decoding Failed
  ||| Failed -> Idle (reset after error).
  ResetFailed   : ValidCodecTransition Failed Idle
  ||| Complete -> Idle (reset after success, for reuse).
  ResetComplete : ValidCodecTransition Complete Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a codec session can write data (encoding in progress).
public export
data CanWrite : CodecState -> Type where
  EncodingCanWrite : CanWrite Encoding

||| Proof that a codec session can read data (decoding in progress).
public export
data CanRead : CodecState -> Type where
  DecodingCanRead : CanRead Decoding

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot encode while decoding.
public export
cannotEncodeWhileDecoding : ValidCodecTransition Decoding Encoding -> Void
cannotEncodeWhileDecoding _ impossible

||| Cannot decode while encoding.
public export
cannotDecodeWhileEncoding : ValidCodecTransition Encoding Decoding -> Void
cannotDecodeWhileEncoding _ impossible

||| Cannot begin operations from Failed state without reset.
public export
failedCannotBeginEncode : ValidCodecTransition Failed Encoding -> Void
failedCannotBeginEncode _ impossible

||| Cannot begin operations from Complete state without reset.
public export
completeCannotBeginEncode : ValidCodecTransition Complete Encoding -> Void
completeCannotBeginEncode _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a codec state transition is valid.
public export
validateCodecTransition : (from : CodecState) -> (to : CodecState) -> Maybe (ValidCodecTransition from to)
validateCodecTransition Idle     Encoding = Just BeginEncode
validateCodecTransition Idle     Decoding = Just BeginDecode
validateCodecTransition Encoding Complete = Just FinalizeEnc
validateCodecTransition Decoding Complete = Just FinalizeDec
validateCodecTransition Encoding Failed   = Just FailEncode
validateCodecTransition Decoding Failed   = Just FailDecode
validateCodecTransition Failed   Idle     = Just ResetFailed
validateCodecTransition Complete Idle     = Just ResetComplete
validateCodecTransition _ _               = Nothing
