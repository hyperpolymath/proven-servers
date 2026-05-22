-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VoIPABI.Types: C-ABI-compatible numeric representations of VoIP types.
--
-- Maps every constructor of the core VoIP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/voip.h) and the
-- Zig FFI enums (ffi/zig/src/voip.zig) exactly.
--
-- Types covered:
--   Method        (13 constructors, tags 0-12)
--   ResponseCode  (17 constructors, tags 0-16)
--   DialogState   (3 constructors, tags 0-2)

module VoIPABI.Types

import VoIP.Types

%default total

---------------------------------------------------------------------------
-- Method (13 constructors, tags 0-12)
---------------------------------------------------------------------------

public export
methodSize : Nat
methodSize = 1

||| Encode a Method to its ABI tag value.
public export
methodToTag : Method -> Bits8
methodToTag Invite    = 0
methodToTag Ack       = 1
methodToTag Bye       = 2
methodToTag Cancel    = 3
methodToTag Register  = 4
methodToTag Options   = 5
methodToTag Info      = 6
methodToTag Update    = 7
methodToTag Subscribe = 8
methodToTag Notify    = 9
methodToTag Refer     = 10
methodToTag Message   = 11
methodToTag Prack     = 12

||| Decode an ABI tag to a Method.
public export
tagToMethod : Bits8 -> Maybe Method
tagToMethod 0  = Just Invite
tagToMethod 1  = Just Ack
tagToMethod 2  = Just Bye
tagToMethod 3  = Just Cancel
tagToMethod 4  = Just Register
tagToMethod 5  = Just Options
tagToMethod 6  = Just Info
tagToMethod 7  = Just Update
tagToMethod 8  = Just Subscribe
tagToMethod 9  = Just Notify
tagToMethod 10 = Just Refer
tagToMethod 11 = Just Message
tagToMethod 12 = Just Prack
tagToMethod _  = Nothing

||| Roundtrip proof: decoding an encoded Method yields the original.
public export
methodRoundtrip : (m : Method) -> tagToMethod (methodToTag m) = Just m
methodRoundtrip Invite    = Refl
methodRoundtrip Ack       = Refl
methodRoundtrip Bye       = Refl
methodRoundtrip Cancel    = Refl
methodRoundtrip Register  = Refl
methodRoundtrip Options   = Refl
methodRoundtrip Info      = Refl
methodRoundtrip Update    = Refl
methodRoundtrip Subscribe = Refl
methodRoundtrip Notify    = Refl
methodRoundtrip Refer     = Refl
methodRoundtrip Message   = Refl
methodRoundtrip Prack     = Refl

---------------------------------------------------------------------------
-- ResponseCode (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
responseCodeSize : Nat
responseCodeSize = 1

||| Encode a ResponseCode to its ABI tag value.
public export
responseCodeToTag : ResponseCode -> Bits8
responseCodeToTag Trying              = 0
responseCodeToTag Ringing             = 1
responseCodeToTag SessionProgress     = 2
responseCodeToTag OK                  = 3
responseCodeToTag MultipleChoices     = 4
responseCodeToTag MovedPermanently    = 5
responseCodeToTag MovedTemporarily    = 6
responseCodeToTag BadRequest          = 7
responseCodeToTag Unauthorized        = 8
responseCodeToTag Forbidden           = 9
responseCodeToTag NotFound            = 10
responseCodeToTag MethodNotAllowed    = 11
responseCodeToTag RequestTimeout      = 12
responseCodeToTag BusyHere            = 13
responseCodeToTag Decline             = 14
responseCodeToTag ServerInternalError = 15
responseCodeToTag ServiceUnavailable  = 16

||| Decode an ABI tag to a ResponseCode.
public export
tagToResponseCode : Bits8 -> Maybe ResponseCode
tagToResponseCode 0  = Just Trying
tagToResponseCode 1  = Just Ringing
tagToResponseCode 2  = Just SessionProgress
tagToResponseCode 3  = Just OK
tagToResponseCode 4  = Just MultipleChoices
tagToResponseCode 5  = Just MovedPermanently
tagToResponseCode 6  = Just MovedTemporarily
tagToResponseCode 7  = Just BadRequest
tagToResponseCode 8  = Just Unauthorized
tagToResponseCode 9  = Just Forbidden
tagToResponseCode 10 = Just NotFound
tagToResponseCode 11 = Just MethodNotAllowed
tagToResponseCode 12 = Just RequestTimeout
tagToResponseCode 13 = Just BusyHere
tagToResponseCode 14 = Just Decline
tagToResponseCode 15 = Just ServerInternalError
tagToResponseCode 16 = Just ServiceUnavailable
tagToResponseCode _  = Nothing

||| Roundtrip proof: decoding an encoded ResponseCode yields the original.
public export
responseCodeRoundtrip : (r : ResponseCode) -> tagToResponseCode (responseCodeToTag r) = Just r
responseCodeRoundtrip Trying              = Refl
responseCodeRoundtrip Ringing             = Refl
responseCodeRoundtrip SessionProgress     = Refl
responseCodeRoundtrip OK                  = Refl
responseCodeRoundtrip MultipleChoices     = Refl
responseCodeRoundtrip MovedPermanently    = Refl
responseCodeRoundtrip MovedTemporarily    = Refl
responseCodeRoundtrip BadRequest          = Refl
responseCodeRoundtrip Unauthorized        = Refl
responseCodeRoundtrip Forbidden           = Refl
responseCodeRoundtrip NotFound            = Refl
responseCodeRoundtrip MethodNotAllowed    = Refl
responseCodeRoundtrip RequestTimeout      = Refl
responseCodeRoundtrip BusyHere            = Refl
responseCodeRoundtrip Decline             = Refl
responseCodeRoundtrip ServerInternalError = Refl
responseCodeRoundtrip ServiceUnavailable  = Refl

---------------------------------------------------------------------------
-- DialogState (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
dialogStateSize : Nat
dialogStateSize = 1

||| Encode a DialogState to its ABI tag value.
public export
dialogStateToTag : DialogState -> Bits8
dialogStateToTag Early      = 0
dialogStateToTag Confirmed  = 1
dialogStateToTag Terminated = 2

||| Decode an ABI tag to a DialogState.
public export
tagToDialogState : Bits8 -> Maybe DialogState
tagToDialogState 0 = Just Early
tagToDialogState 1 = Just Confirmed
tagToDialogState 2 = Just Terminated
tagToDialogState _ = Nothing

||| Roundtrip proof: decoding an encoded DialogState yields the original.
public export
dialogStateRoundtrip : (d : DialogState) -> tagToDialogState (dialogStateToTag d) = Just d
dialogStateRoundtrip Early      = Refl
dialogStateRoundtrip Confirmed  = Refl
dialogStateRoundtrip Terminated = Refl
