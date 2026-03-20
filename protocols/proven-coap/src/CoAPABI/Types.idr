-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CoAPABI.Types: C-ABI-compatible numeric representations of CoAP types.
--
-- Maps every constructor of the core CoAP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/coap.h) and the
-- Zig FFI enums (ffi/zig/src/coap.zig) exactly.
--
-- Types covered:
--   Method        (4 constructors, tags 0-3)
--   MessageType   (4 constructors, tags 0-3)
--   ContentFormat (7 constructors, tags 0-6)
--   ResponseClass (5 constructors, tags 0-4)
--   SessionState  (5 constructors, tags 0-4)

module CoAPABI.Types

import CoAP.Types

%default total

---------------------------------------------------------------------------
-- Method (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
methodSize : Nat
methodSize = 1

||| Encode a CoAP Method to its ABI tag value.
public export
methodToTag : Method -> Bits8
methodToTag Get    = 0
methodToTag Post   = 1
methodToTag Put    = 2
methodToTag Delete = 3

||| Decode an ABI tag to a CoAP Method.
public export
tagToMethod : Bits8 -> Maybe Method
tagToMethod 0 = Just Get
tagToMethod 1 = Just Post
tagToMethod 2 = Just Put
tagToMethod 3 = Just Delete
tagToMethod _ = Nothing

||| Roundtrip proof: decoding an encoded Method yields the original.
public export
methodRoundtrip : (m : Method) -> tagToMethod (methodToTag m) = Just m
methodRoundtrip Get    = Refl
methodRoundtrip Post   = Refl
methodRoundtrip Put    = Refl
methodRoundtrip Delete = Refl

---------------------------------------------------------------------------
-- MessageType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a CoAP MessageType to its ABI tag value.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag Confirmable     = 0
messageTypeToTag NonConfirmable  = 1
messageTypeToTag Acknowledgement = 2
messageTypeToTag Reset           = 3

||| Decode an ABI tag to a CoAP MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0 = Just Confirmable
tagToMessageType 1 = Just NonConfirmable
tagToMessageType 2 = Just Acknowledgement
tagToMessageType 3 = Just Reset
tagToMessageType _ = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
messageTypeRoundtrip : (t : MessageType) -> tagToMessageType (messageTypeToTag t) = Just t
messageTypeRoundtrip Confirmable     = Refl
messageTypeRoundtrip NonConfirmable  = Refl
messageTypeRoundtrip Acknowledgement = Refl
messageTypeRoundtrip Reset           = Refl

---------------------------------------------------------------------------
-- ContentFormat (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
contentFormatSize : Nat
contentFormatSize = 1

||| Encode a CoAP ContentFormat to its ABI tag value.
public export
contentFormatToTag : ContentFormat -> Bits8
contentFormatToTag TextPlain   = 0
contentFormatToTag LinkFormat  = 1
contentFormatToTag XML         = 2
contentFormatToTag OctetStream = 3
contentFormatToTag EXI         = 4
contentFormatToTag JSON        = 5
contentFormatToTag CBOR        = 6

||| Decode an ABI tag to a CoAP ContentFormat.
public export
tagToContentFormat : Bits8 -> Maybe ContentFormat
tagToContentFormat 0 = Just TextPlain
tagToContentFormat 1 = Just LinkFormat
tagToContentFormat 2 = Just XML
tagToContentFormat 3 = Just OctetStream
tagToContentFormat 4 = Just EXI
tagToContentFormat 5 = Just JSON
tagToContentFormat 6 = Just CBOR
tagToContentFormat _ = Nothing

||| Roundtrip proof: decoding an encoded ContentFormat yields the original.
public export
contentFormatRoundtrip : (f : ContentFormat) -> tagToContentFormat (contentFormatToTag f) = Just f
contentFormatRoundtrip TextPlain   = Refl
contentFormatRoundtrip LinkFormat  = Refl
contentFormatRoundtrip XML         = Refl
contentFormatRoundtrip OctetStream = Refl
contentFormatRoundtrip EXI         = Refl
contentFormatRoundtrip JSON        = Refl
contentFormatRoundtrip CBOR        = Refl

---------------------------------------------------------------------------
-- ResponseClass (5 constructors, tags 0-4)
-- Groups CoAP response codes by class (2.xx, 4.xx, 5.xx).
---------------------------------------------------------------------------

||| CoAP response class per RFC 7252 Section 5.9.
public export
data ResponseClass : Type where
  ||| Success (2.xx): request was successfully processed.
  Success       : ResponseClass
  ||| Client Error (4.xx): request contained bad syntax or cannot be fulfilled.
  ClientError   : ResponseClass
  ||| Server Error (5.xx): server failed to fulfill valid request.
  ServerError   : ResponseClass
  ||| Signaling (7.xx): CSM, Ping, Pong, Release, Abort (RFC 8323).
  Signaling     : ResponseClass
  ||| Empty (0.00): empty message (ACK/RST with no code).
  Empty         : ResponseClass

public export
Eq ResponseClass where
  Success     == Success     = True
  ClientError == ClientError = True
  ServerError == ServerError = True
  Signaling   == Signaling   = True
  Empty       == Empty       = True
  _           == _           = False

public export
Show ResponseClass where
  show Success     = "Success (2.xx)"
  show ClientError = "Client Error (4.xx)"
  show ServerError = "Server Error (5.xx)"
  show Signaling   = "Signaling (7.xx)"
  show Empty       = "Empty (0.00)"

public export
responseClassToTag : ResponseClass -> Bits8
responseClassToTag Success     = 0
responseClassToTag ClientError = 1
responseClassToTag ServerError = 2
responseClassToTag Signaling   = 3
responseClassToTag Empty       = 4

public export
tagToResponseClass : Bits8 -> Maybe ResponseClass
tagToResponseClass 0 = Just Success
tagToResponseClass 1 = Just ClientError
tagToResponseClass 2 = Just ServerError
tagToResponseClass 3 = Just Signaling
tagToResponseClass 4 = Just Empty
tagToResponseClass _ = Nothing

public export
responseClassRoundtrip : (r : ResponseClass) -> tagToResponseClass (responseClassToTag r) = Just r
responseClassRoundtrip Success     = Refl
responseClassRoundtrip ClientError = Refl
responseClassRoundtrip ServerError = Refl
responseClassRoundtrip Signaling   = Refl
responseClassRoundtrip Empty       = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
-- CoAP server endpoint lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| CoAP server endpoint lifecycle states.
||| This is a simplified view used by the FFI layer, combining
||| resource management and observation into a single enum.
public export
data SessionState : Type where
  ||| No endpoint bound. Initial and terminal state.
  SSIdle       : SessionState
  ||| Endpoint bound to a UDP port, ready to receive.
  SSBound      : SessionState
  ||| Actively serving resources (at least one resource registered).
  SSServing    : SessionState
  ||| Observing resources on behalf of clients (RFC 7641).
  SSObserving  : SessionState
  ||| Shutting down (draining in-flight exchanges).
  SSShutdown   : SessionState

public export
Eq SessionState where
  SSIdle      == SSIdle      = True
  SSBound     == SSBound     = True
  SSServing   == SSServing   = True
  SSObserving == SSObserving = True
  SSShutdown  == SSShutdown  = True
  _           == _           = False

public export
Show SessionState where
  show SSIdle      = "Idle"
  show SSBound     = "Bound"
  show SSServing   = "Serving"
  show SSObserving = "Observing"
  show SSShutdown  = "Shutdown"

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag SSIdle      = 0
sessionStateToTag SSBound     = 1
sessionStateToTag SSServing   = 2
sessionStateToTag SSObserving = 3
sessionStateToTag SSShutdown  = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just SSIdle
tagToSessionState 1 = Just SSBound
tagToSessionState 2 = Just SSServing
tagToSessionState 3 = Just SSObserving
tagToSessionState 4 = Just SSShutdown
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip SSIdle      = Refl
sessionStateRoundtrip SSBound     = Refl
sessionStateRoundtrip SSServing   = Refl
sessionStateRoundtrip SSObserving = Refl
sessionStateRoundtrip SSShutdown  = Refl
