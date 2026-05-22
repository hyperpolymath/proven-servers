-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ODNSABI.Types: C-ABI-compatible numeric representations of Oblivious
-- DNS types.
--
-- Maps every constructor of the ODNS sum types (from ODNS.Types) to
-- fixed Bits8 values for C interop. Each type gets a total encoder,
-- partial decoder, and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/odns.zig)
-- exactly.
--
-- Types covered:
--   Role                  (3 constructors, tags 0-2)
--   MessageType           (2 constructors, tags 0-1)
--   ErrorReason           (5 constructors, tags 0-4)
--   EncapsulationFormat   (1 constructor, tag 0)
--   SessionState          (5 constructors, tags 0-4)

module ODNSABI.Types

import ODNS.Types

%default total

---------------------------------------------------------------------------
-- Role (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
roleSize : Nat
roleSize = 1

public export
roleToTag : Role -> Bits8
roleToTag Client = 0
roleToTag Proxy  = 1
roleToTag Target = 2

public export
tagToRole : Bits8 -> Maybe Role
tagToRole 0 = Just Client
tagToRole 1 = Just Proxy
tagToRole 2 = Just Target
tagToRole _ = Nothing

public export
roleRoundtrip : (r : Role) -> tagToRole (roleToTag r) = Just r
roleRoundtrip Client = Refl
roleRoundtrip Proxy  = Refl
roleRoundtrip Target = Refl

---------------------------------------------------------------------------
-- MessageType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Query    = 0
messageTypeToTag Response = 1

public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Query
tagToMessageType 1 = Just Response
tagToMessageType _ = Nothing

public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip Query    = Refl
messageTypeRoundtrip Response = Refl

---------------------------------------------------------------------------
-- ErrorReason (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorReasonSize : Nat
errorReasonSize = 1

public export
errorReasonToTag : ErrorReason -> Bits8
errorReasonToTag ProxyError       = 0
errorReasonToTag TargetError      = 1
errorReasonToTag DecryptionFailed = 2
errorReasonToTag InvalidConfig    = 3
errorReasonToTag PayloadTooLarge  = 4

public export
tagToErrorReason : Bits8 -> Maybe ErrorReason
tagToErrorReason 0 = Just ProxyError
tagToErrorReason 1 = Just TargetError
tagToErrorReason 2 = Just DecryptionFailed
tagToErrorReason 3 = Just InvalidConfig
tagToErrorReason 4 = Just PayloadTooLarge
tagToErrorReason _ = Nothing

public export
errorReasonRoundtrip : (e : ErrorReason) -> tagToErrorReason (errorReasonToTag e) = Just e
errorReasonRoundtrip ProxyError       = Refl
errorReasonRoundtrip TargetError      = Refl
errorReasonRoundtrip DecryptionFailed = Refl
errorReasonRoundtrip InvalidConfig    = Refl
errorReasonRoundtrip PayloadTooLarge  = Refl

---------------------------------------------------------------------------
-- EncapsulationFormat (1 constructor, tag 0)
---------------------------------------------------------------------------

public export
encapsulationFormatSize : Nat
encapsulationFormatSize = 1

public export
encapsulationFormatToTag : EncapsulationFormat -> Bits8
encapsulationFormatToTag HPKE = 0

public export
tagToEncapsulationFormat : Bits8 -> Maybe EncapsulationFormat
tagToEncapsulationFormat 0 = Just HPKE
tagToEncapsulationFormat _ = Nothing

public export
encapsulationFormatRoundtrip : (f : EncapsulationFormat) -> tagToEncapsulationFormat (encapsulationFormatToTag f) = Just f
encapsulationFormatRoundtrip HPKE = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Oblivious DNS session lifecycle states for the FFI layer.
public export
data SessionState : Type where
  ||| No session. Initial and terminal state.
  SSIdle          : SessionState
  ||| HPKE key exchange in progress.
  SSKeyExchange   : SessionState
  ||| Session ready, can process queries.
  SSReady         : SessionState
  ||| Processing an oblivious query.
  SSProcessing    : SessionState
  ||| Session closing / error recovery.
  SSClosing       : SessionState

public export
Eq SessionState where
  SSIdle        == SSIdle        = True
  SSKeyExchange == SSKeyExchange = True
  SSReady       == SSReady       = True
  SSProcessing  == SSProcessing  = True
  SSClosing     == SSClosing     = True
  _             == _             = False

public export
Show SessionState where
  show SSIdle        = "Idle"
  show SSKeyExchange = "KeyExchange"
  show SSReady       = "Ready"
  show SSProcessing  = "Processing"
  show SSClosing     = "Closing"

public export
sessionStateSize : Nat
sessionStateSize = 1

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle        = 0
sessionStateToTag SSKeyExchange = 1
sessionStateToTag SSReady       = 2
sessionStateToTag SSProcessing  = 3
sessionStateToTag SSClosing     = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSKeyExchange
tagToSessionState 2 = Just SSReady
tagToSessionState 3 = Just SSProcessing
tagToSessionState 4 = Just SSClosing
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle        = Refl
sessionStateRoundtrip SSKeyExchange = Refl
sessionStateRoundtrip SSReady       = Refl
sessionStateRoundtrip SSProcessing  = Refl
sessionStateRoundtrip SSClosing     = Refl
