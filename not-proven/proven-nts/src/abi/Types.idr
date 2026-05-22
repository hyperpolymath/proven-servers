-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTSABI.Types: C-ABI-compatible numeric representations of NTS types.
--
-- Maps every constructor of the NTS sum types (from NTS.Types) to
-- fixed Bits8 values for C interop. Each type gets a total encoder,
-- partial decoder, and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/nts.zig) exactly.
--
-- Types covered:
--   RecordType      (9 constructors, tags 0-8)
--   ErrorCode       (3 constructors, tags 0-2)
--   AEADAlgorithm   (3 constructors, tags 0-2)
--   HandshakeState  (4 constructors, tags 0-3)
--   SessionState    (5 constructors, tags 0-4)

module NTSABI.Types

import NTS.Types

%default total

---------------------------------------------------------------------------
-- RecordType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
recordTypeSize : Nat
recordTypeSize = 1

||| Encode a RecordType to its ABI tag value.
public export
recordTypeToTag : RecordType -> Bits8
recordTypeToTag EndOfMessage      = 0
recordTypeToTag NextProtocol      = 1
recordTypeToTag Error             = 2
recordTypeToTag Warning           = 3
recordTypeToTag AEADAlgorithm     = 4
recordTypeToTag Cookie            = 5
recordTypeToTag CookiePlaceholder = 6
recordTypeToTag NTSKEServer       = 7
recordTypeToTag NTSKEPort         = 8

public export
tagToRecordType : Bits8 -> Maybe RecordType
tagToRecordType 0 = Just EndOfMessage
tagToRecordType 1 = Just NextProtocol
tagToRecordType 2 = Just Error
tagToRecordType 3 = Just Warning
tagToRecordType 4 = Just AEADAlgorithm
tagToRecordType 5 = Just Cookie
tagToRecordType 6 = Just CookiePlaceholder
tagToRecordType 7 = Just NTSKEServer
tagToRecordType 8 = Just NTSKEPort
tagToRecordType _ = Nothing

public export
recordTypeRoundtrip : (r : RecordType) -> tagToRecordType (recordTypeToTag r) = Just r
recordTypeRoundtrip EndOfMessage      = Refl
recordTypeRoundtrip NextProtocol      = Refl
recordTypeRoundtrip Error             = Refl
recordTypeRoundtrip Warning           = Refl
recordTypeRoundtrip AEADAlgorithm     = Refl
recordTypeRoundtrip Cookie            = Refl
recordTypeRoundtrip CookiePlaceholder = Refl
recordTypeRoundtrip NTSKEServer       = Refl
recordTypeRoundtrip NTSKEPort         = Refl

---------------------------------------------------------------------------
-- ErrorCode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
errorCodeSize : Nat
errorCodeSize = 1

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag UnrecognizedCritical = 0
errorCodeToTag BadRequest           = 1
errorCodeToTag InternalError        = 2

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just UnrecognizedCritical
tagToErrorCode 1 = Just BadRequest
tagToErrorCode 2 = Just InternalError
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip UnrecognizedCritical = Refl
errorCodeRoundtrip BadRequest           = Refl
errorCodeRoundtrip InternalError        = Refl

---------------------------------------------------------------------------
-- AEADAlgorithm (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
aeadAlgorithmSize : Nat
aeadAlgorithmSize = 1

public export
aeadAlgorithmToTag : NTS.Types.AEADAlgorithm -> Bits8
aeadAlgorithmToTag AEAD_AES_128_GCM      = 0
aeadAlgorithmToTag AEAD_AES_256_GCM      = 1
aeadAlgorithmToTag AEAD_AES_SIV_CMAC_256 = 2

public export
tagToAEADAlgorithm : Bits8 -> Maybe NTS.Types.AEADAlgorithm
tagToAEADAlgorithm 0 = Just AEAD_AES_128_GCM
tagToAEADAlgorithm 1 = Just AEAD_AES_256_GCM
tagToAEADAlgorithm 2 = Just AEAD_AES_SIV_CMAC_256
tagToAEADAlgorithm _ = Nothing

public export
aeadAlgorithmRoundtrip : (a : NTS.Types.AEADAlgorithm) -> tagToAEADAlgorithm (aeadAlgorithmToTag a) = Just a
aeadAlgorithmRoundtrip AEAD_AES_128_GCM      = Refl
aeadAlgorithmRoundtrip AEAD_AES_256_GCM      = Refl
aeadAlgorithmRoundtrip AEAD_AES_SIV_CMAC_256 = Refl

---------------------------------------------------------------------------
-- HandshakeState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
handshakeStateSize : Nat
handshakeStateSize = 1

public export
handshakeStateToTag : HandshakeState -> Bits8
handshakeStateToTag Initial     = 0
handshakeStateToTag Negotiating = 1
handshakeStateToTag Established = 2
handshakeStateToTag Failed      = 3

public export
tagToHandshakeState : Bits8 -> Maybe HandshakeState
tagToHandshakeState 0 = Just Initial
tagToHandshakeState 1 = Just Negotiating
tagToHandshakeState 2 = Just Established
tagToHandshakeState 3 = Just Failed
tagToHandshakeState _ = Nothing

public export
handshakeStateRoundtrip : (h : HandshakeState) -> tagToHandshakeState (handshakeStateToTag h) = Just h
handshakeStateRoundtrip Initial     = Refl
handshakeStateRoundtrip Negotiating = Refl
handshakeStateRoundtrip Established = Refl
handshakeStateRoundtrip Failed      = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| NTS session lifecycle states for the FFI layer.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle          : SessionState
  ||| TLS handshake in progress.
  SSHandshaking   : SessionState
  ||| NTS-KE negotiation in progress.
  SSNegotiating   : SessionState
  ||| Session established with cookies.
  SSEstablished   : SessionState
  ||| Session closing / error recovery.
  SSClosing       : SessionState

public export
Eq SessionState where
  SSIdle        == SSIdle        = True
  SSHandshaking == SSHandshaking = True
  SSNegotiating == SSNegotiating = True
  SSEstablished == SSEstablished = True
  SSClosing     == SSClosing     = True
  _             == _             = False

public export
Show SessionState where
  show SSIdle        = "Idle"
  show SSHandshaking = "Handshaking"
  show SSNegotiating = "Negotiating"
  show SSEstablished = "Established"
  show SSClosing     = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle        = 0
sessionStateToTag SSHandshaking = 1
sessionStateToTag SSNegotiating = 2
sessionStateToTag SSEstablished = 3
sessionStateToTag SSClosing     = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSHandshaking
tagToSessionState 2 = Just SSNegotiating
tagToSessionState 3 = Just SSEstablished
tagToSessionState 4 = Just SSClosing
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle        = Refl
sessionStateRoundtrip SSHandshaking = Refl
sessionStateRoundtrip SSNegotiating = Refl
sessionStateRoundtrip SSEstablished = Refl
sessionStateRoundtrip SSClosing     = Refl
