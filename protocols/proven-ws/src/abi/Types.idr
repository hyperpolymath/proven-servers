-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- WSABI.Types: C-ABI-compatible numeric representations of WebSocket types.
--
-- Maps every constructor of the core WS sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/ws.h) and the
-- Zig FFI enums (ffi/zig/src/ws.zig) exactly.
--
-- Types covered:
--   Opcode    (6 constructors, tags 0-5)
--   CloseCode (11 constructors, tags 0-10)

module WSABI.Types

import WS.Opcode
import WS.CloseCode

%default total

---------------------------------------------------------------------------
-- Opcode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
opcodeSize : Nat
opcodeSize = 1

||| Encode an Opcode to its ABI tag value.
public export
opcodeToTag : Opcode -> Bits8
opcodeToTag Continuation = 0
opcodeToTag Text         = 1
opcodeToTag Binary       = 2
opcodeToTag Close        = 3
opcodeToTag Ping         = 4
opcodeToTag Pong         = 5

||| Decode an ABI tag to an Opcode.
public export
tagToOpcode : Bits8 -> Maybe Opcode
tagToOpcode 0 = Just Continuation
tagToOpcode 1 = Just Text
tagToOpcode 2 = Just Binary
tagToOpcode 3 = Just Close
tagToOpcode 4 = Just Ping
tagToOpcode 5 = Just Pong
tagToOpcode _ = Nothing

||| Roundtrip proof: decoding an encoded Opcode yields the original.
public export
opcodeRoundtrip : (o : Opcode) -> tagToOpcode (opcodeToTag o) = Just o
opcodeRoundtrip Continuation = Refl
opcodeRoundtrip Text         = Refl
opcodeRoundtrip Binary       = Refl
opcodeRoundtrip Close        = Refl
opcodeRoundtrip Ping         = Refl
opcodeRoundtrip Pong         = Refl

---------------------------------------------------------------------------
-- CloseCode (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
closeCodeSize : Nat
closeCodeSize = 1

||| Encode a CloseCode to its ABI tag value.
public export
closeCodeToTag : CloseCode -> Bits8
closeCodeToTag Normal             = 0
closeCodeToTag GoingAway          = 1
closeCodeToTag ProtocolError      = 2
closeCodeToTag UnsupportedData    = 3
closeCodeToTag NoStatus           = 4
closeCodeToTag Abnormal           = 5
closeCodeToTag InvalidPayload     = 6
closeCodeToTag PolicyViolation    = 7
closeCodeToTag MessageTooBig      = 8
closeCodeToTag MandatoryExtension = 9
closeCodeToTag InternalError      = 10

||| Decode an ABI tag to a CloseCode.
public export
tagToCloseCode : Bits8 -> Maybe CloseCode
tagToCloseCode 0  = Just Normal
tagToCloseCode 1  = Just GoingAway
tagToCloseCode 2  = Just ProtocolError
tagToCloseCode 3  = Just UnsupportedData
tagToCloseCode 4  = Just NoStatus
tagToCloseCode 5  = Just Abnormal
tagToCloseCode 6  = Just InvalidPayload
tagToCloseCode 7  = Just PolicyViolation
tagToCloseCode 8  = Just MessageTooBig
tagToCloseCode 9  = Just MandatoryExtension
tagToCloseCode 10 = Just InternalError
tagToCloseCode _  = Nothing

||| Roundtrip proof: decoding an encoded CloseCode yields the original.
public export
closeCodeRoundtrip : (c : CloseCode) -> tagToCloseCode (closeCodeToTag c) = Just c
closeCodeRoundtrip Normal             = Refl
closeCodeRoundtrip GoingAway          = Refl
closeCodeRoundtrip ProtocolError      = Refl
closeCodeRoundtrip UnsupportedData    = Refl
closeCodeRoundtrip NoStatus           = Refl
closeCodeRoundtrip Abnormal           = Refl
closeCodeRoundtrip InvalidPayload     = Refl
closeCodeRoundtrip PolicyViolation    = Refl
closeCodeRoundtrip MessageTooBig      = Refl
closeCodeRoundtrip MandatoryExtension = Refl
closeCodeRoundtrip InternalError      = Refl
