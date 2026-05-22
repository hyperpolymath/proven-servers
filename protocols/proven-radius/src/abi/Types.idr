-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- RadiusABI.Types: C-ABI-compatible numeric representations of Radius types.
--
-- Maps every constructor of the core Radius sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/radius.zig) exactly.
--
-- Types covered:
--   PacketType                (6 constructors, tags 0-11)
--   AttributeType             (9 constructors, tags 0-27)
--   ServiceType               (6 constructors, tags 0-6)
--   AuthMethod                (5 constructors, tags 0-4)
--   SessionState              (7 constructors, tags 0-6)
--   RadiusResult              (5 constructors, tags 0-4)

module RadiusABI.Types

%default total

---------------------------------------------------------------------------
-- PacketType (6 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
packet_typeSize : Nat
packet_typeSize = 1

||| PacketType sum type for ABI encoding.
public export
data PacketType : Type where
  AccessRequest : PacketType
  AccessAccept : PacketType
  AccessReject : PacketType
  AccountingRequest : PacketType
  AccountingResponse : PacketType
  AccessChallenge : PacketType

||| Encode a PacketType to its ABI tag value.
public export
packet_typeToTag : PacketType -> Bits8
packet_typeToTag AccessRequest = 1
packet_typeToTag AccessAccept = 2
packet_typeToTag AccessReject = 3
packet_typeToTag AccountingRequest = 4
packet_typeToTag AccountingResponse = 5
packet_typeToTag AccessChallenge = 11

||| Decode an ABI tag to a PacketType.
public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 1 = Just AccessRequest
tagToPacketType 2 = Just AccessAccept
tagToPacketType 3 = Just AccessReject
tagToPacketType 4 = Just AccountingRequest
tagToPacketType 5 = Just AccountingResponse
tagToPacketType 11 = Just AccessChallenge
tagToPacketType _ = Nothing

||| Roundtrip proof: decoding an encoded PacketType yields the original.
public export
packet_typeRoundtrip : (x : PacketType) -> tagToPacketType (packet_typeToTag x) = Just x
packet_typeRoundtrip AccessRequest = Refl
packet_typeRoundtrip AccessAccept = Refl
packet_typeRoundtrip AccessReject = Refl
packet_typeRoundtrip AccountingRequest = Refl
packet_typeRoundtrip AccountingResponse = Refl
packet_typeRoundtrip AccessChallenge = Refl

---------------------------------------------------------------------------
-- AttributeType (9 constructors, tags 0-27)
---------------------------------------------------------------------------

public export
attribute_typeSize : Nat
attribute_typeSize = 1

||| AttributeType sum type for ABI encoding.
public export
data AttributeType : Type where
  UserName : AttributeType
  UserPassword : AttributeType
  NasIpAddress : AttributeType
  NasPort : AttributeType
  ServiceType : AttributeType
  FramedProtocol : AttributeType
  FramedIpAddress : AttributeType
  ReplyMessage : AttributeType
  SessionTimeout : AttributeType

||| Encode a AttributeType to its ABI tag value.
public export
attribute_typeToTag : AttributeType -> Bits8
attribute_typeToTag UserName = 1
attribute_typeToTag UserPassword = 2
attribute_typeToTag NasIpAddress = 4
attribute_typeToTag NasPort = 5
attribute_typeToTag ServiceType = 6
attribute_typeToTag FramedProtocol = 7
attribute_typeToTag FramedIpAddress = 8
attribute_typeToTag ReplyMessage = 18
attribute_typeToTag SessionTimeout = 27

||| Decode an ABI tag to a AttributeType.
public export
tagToAttributeType : Bits8 -> Maybe AttributeType
tagToAttributeType 1 = Just UserName
tagToAttributeType 2 = Just UserPassword
tagToAttributeType 4 = Just NasIpAddress
tagToAttributeType 5 = Just NasPort
tagToAttributeType 6 = Just ServiceType
tagToAttributeType 7 = Just FramedProtocol
tagToAttributeType 8 = Just FramedIpAddress
tagToAttributeType 18 = Just ReplyMessage
tagToAttributeType 27 = Just SessionTimeout
tagToAttributeType _ = Nothing

||| Roundtrip proof: decoding an encoded AttributeType yields the original.
public export
attribute_typeRoundtrip : (x : AttributeType) -> tagToAttributeType (attribute_typeToTag x) = Just x
attribute_typeRoundtrip UserName = Refl
attribute_typeRoundtrip UserPassword = Refl
attribute_typeRoundtrip NasIpAddress = Refl
attribute_typeRoundtrip NasPort = Refl
attribute_typeRoundtrip ServiceType = Refl
attribute_typeRoundtrip FramedProtocol = Refl
attribute_typeRoundtrip FramedIpAddress = Refl
attribute_typeRoundtrip ReplyMessage = Refl
attribute_typeRoundtrip SessionTimeout = Refl

---------------------------------------------------------------------------
-- ServiceType (6 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
service_typeSize : Nat
service_typeSize = 1

||| ServiceType sum type for ABI encoding.
public export
data ServiceType : Type where
  Login : ServiceType
  Framed : ServiceType
  CallbackLogin : ServiceType
  CallbackFramed : ServiceType
  Outbound : ServiceType
  Administrative : ServiceType

||| Encode a ServiceType to its ABI tag value.
public export
service_typeToTag : ServiceType -> Bits8
service_typeToTag Login = 1
service_typeToTag Framed = 2
service_typeToTag CallbackLogin = 3
service_typeToTag CallbackFramed = 4
service_typeToTag Outbound = 5
service_typeToTag Administrative = 6

||| Decode an ABI tag to a ServiceType.
public export
tagToServiceType : Bits8 -> Maybe ServiceType
tagToServiceType 1 = Just Login
tagToServiceType 2 = Just Framed
tagToServiceType 3 = Just CallbackLogin
tagToServiceType 4 = Just CallbackFramed
tagToServiceType 5 = Just Outbound
tagToServiceType 6 = Just Administrative
tagToServiceType _ = Nothing

||| Roundtrip proof: decoding an encoded ServiceType yields the original.
public export
service_typeRoundtrip : (x : ServiceType) -> tagToServiceType (service_typeToTag x) = Just x
service_typeRoundtrip Login = Refl
service_typeRoundtrip Framed = Refl
service_typeRoundtrip CallbackLogin = Refl
service_typeRoundtrip CallbackFramed = Refl
service_typeRoundtrip Outbound = Refl
service_typeRoundtrip Administrative = Refl

---------------------------------------------------------------------------
-- AuthMethod (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
auth_methodSize : Nat
auth_methodSize = 1

||| AuthMethod sum type for ABI encoding.
public export
data AuthMethod : Type where
  Pap : AuthMethod
  Chap : AuthMethod
  Mschap : AuthMethod
  Mschapv2 : AuthMethod
  Eap : AuthMethod

||| Encode a AuthMethod to its ABI tag value.
public export
auth_methodToTag : AuthMethod -> Bits8
auth_methodToTag Pap = 0
auth_methodToTag Chap = 1
auth_methodToTag Mschap = 2
auth_methodToTag Mschapv2 = 3
auth_methodToTag Eap = 4

||| Decode an ABI tag to a AuthMethod.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just Pap
tagToAuthMethod 1 = Just Chap
tagToAuthMethod 2 = Just Mschap
tagToAuthMethod 3 = Just Mschapv2
tagToAuthMethod 4 = Just Eap
tagToAuthMethod _ = Nothing

||| Roundtrip proof: decoding an encoded AuthMethod yields the original.
public export
auth_methodRoundtrip : (x : AuthMethod) -> tagToAuthMethod (auth_methodToTag x) = Just x
auth_methodRoundtrip Pap = Refl
auth_methodRoundtrip Chap = Refl
auth_methodRoundtrip Mschap = Refl
auth_methodRoundtrip Mschapv2 = Refl
auth_methodRoundtrip Eap = Refl

---------------------------------------------------------------------------
-- SessionState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Idle : SessionState
  Authenticating : SessionState
  Authorized : SessionState
  Rejected : SessionState
  Challenged : SessionState
  Accounting : SessionState
  Complete : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Idle = 0
session_stateToTag Authenticating = 1
session_stateToTag Authorized = 2
session_stateToTag Rejected = 3
session_stateToTag Challenged = 4
session_stateToTag Accounting = 5
session_stateToTag Complete = 6

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Idle
tagToSessionState 1 = Just Authenticating
tagToSessionState 2 = Just Authorized
tagToSessionState 3 = Just Rejected
tagToSessionState 4 = Just Challenged
tagToSessionState 5 = Just Accounting
tagToSessionState 6 = Just Complete
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Idle = Refl
session_stateRoundtrip Authenticating = Refl
session_stateRoundtrip Authorized = Refl
session_stateRoundtrip Rejected = Refl
session_stateRoundtrip Challenged = Refl
session_stateRoundtrip Accounting = Refl
session_stateRoundtrip Complete = Refl

---------------------------------------------------------------------------
-- RadiusResult (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
radius_resultSize : Nat
radius_resultSize = 1

||| RadiusResult sum type for ABI encoding.
public export
data RadiusResult : Type where
  Ok : RadiusResult
  Err : RadiusResult
  InvalidParam : RadiusResult
  PoolExhausted : RadiusResult
  BadSecret : RadiusResult

||| Encode a RadiusResult to its ABI tag value.
public export
radius_resultToTag : RadiusResult -> Bits8
radius_resultToTag Ok = 0
radius_resultToTag Err = 1
radius_resultToTag InvalidParam = 2
radius_resultToTag PoolExhausted = 3
radius_resultToTag BadSecret = 4

||| Decode an ABI tag to a RadiusResult.
public export
tagToRadiusResult : Bits8 -> Maybe RadiusResult
tagToRadiusResult 0 = Just Ok
tagToRadiusResult 1 = Just Err
tagToRadiusResult 2 = Just InvalidParam
tagToRadiusResult 3 = Just PoolExhausted
tagToRadiusResult 4 = Just BadSecret
tagToRadiusResult _ = Nothing

||| Roundtrip proof: decoding an encoded RadiusResult yields the original.
public export
radius_resultRoundtrip : (x : RadiusResult) -> tagToRadiusResult (radius_resultToTag x) = Just x
radius_resultRoundtrip Ok = Refl
radius_resultRoundtrip Err = Refl
radius_resultRoundtrip InvalidParam = Refl
radius_resultRoundtrip PoolExhausted = Refl
radius_resultRoundtrip BadSecret = Refl
