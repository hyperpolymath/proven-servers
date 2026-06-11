-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- RADIUSABI.Layout: C-ABI-compatible numeric representations of RADIUS types.
--
-- Maps every constructor of the core RADIUS sum types (PacketType,
-- AttributeType, ServiceType, AuthMethod, RadiusResult) to fixed Bits8
-- values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/radius.h) and the
-- Zig FFI enums (ffi/zig/src/radius.zig) exactly.

module RADIUSABI.Layout

import RADIUS.Types

%default total

---------------------------------------------------------------------------
-- PacketType (6 constructors, tags 1/2/3/4/5/11 matching RFC 2865 Code field)
---------------------------------------------------------------------------

||| C-ABI representation size for PacketType (1 byte).
public export
packetTypeSize : Nat
packetTypeSize = 1

||| Map PacketType to its C-ABI byte value.
||| Tag assignments match the RADIUS Code field (RFC 2865 Section 3):
|||   AccessRequest      = 1
|||   AccessAccept       = 2
|||   AccessReject       = 3
|||   AccountingRequest  = 4
|||   AccountingResponse = 5
|||   AccessChallenge    = 11
public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag AccessRequest      = 1
packetTypeToTag AccessAccept       = 2
packetTypeToTag AccessReject       = 3
packetTypeToTag AccountingRequest  = 4
packetTypeToTag AccountingResponse = 5
packetTypeToTag AccessChallenge    = 11

||| Recover PacketType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid set.
public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 1  = Just AccessRequest
tagToPacketType 2  = Just AccessAccept
tagToPacketType 3  = Just AccessReject
tagToPacketType 4  = Just AccountingRequest
tagToPacketType 5  = Just AccountingResponse
tagToPacketType 11 = Just AccessChallenge
tagToPacketType _  = Nothing

||| Proof: encoding then decoding PacketType is the identity.
public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip AccessRequest      = Refl
packetTypeRoundtrip AccessAccept       = Refl
packetTypeRoundtrip AccessReject       = Refl
packetTypeRoundtrip AccountingRequest  = Refl
packetTypeRoundtrip AccountingResponse = Refl
packetTypeRoundtrip AccessChallenge    = Refl

---------------------------------------------------------------------------
-- AttributeType (9 constructors, tags matching RFC 2865 attribute numbers)
---------------------------------------------------------------------------

||| C-ABI representation size for AttributeType (1 byte).
public export
attributeTypeSize : Nat
attributeTypeSize = 1

||| Map AttributeType to its C-ABI byte value.
||| Tag assignments match the RADIUS Type field (RFC 2865 Section 5):
|||   UserName       = 1
|||   UserPassword   = 2
|||   NASIPAddress   = 4
|||   NASPort        = 5
|||   ServiceTy      = 6
|||   FramedProtocol = 7
|||   FramedIPAddr   = 8
|||   ReplyMessage   = 18
|||   SessionTimeout = 27
public export
attributeTypeToTag : AttributeType -> Bits8
attributeTypeToTag UserName       = 1
attributeTypeToTag UserPassword   = 2
attributeTypeToTag NASIPAddress   = 4
attributeTypeToTag NASPort        = 5
attributeTypeToTag ServiceTy      = 6
attributeTypeToTag FramedProtocol = 7
attributeTypeToTag FramedIPAddr   = 8
attributeTypeToTag ReplyMessage   = 18
attributeTypeToTag SessionTimeout = 27

||| Recover AttributeType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid set.
public export
tagToAttributeType : Bits8 -> Maybe AttributeType
tagToAttributeType 1  = Just UserName
tagToAttributeType 2  = Just UserPassword
tagToAttributeType 4  = Just NASIPAddress
tagToAttributeType 5  = Just NASPort
tagToAttributeType 6  = Just ServiceTy
tagToAttributeType 7  = Just FramedProtocol
tagToAttributeType 8  = Just FramedIPAddr
tagToAttributeType 18 = Just ReplyMessage
tagToAttributeType 27 = Just SessionTimeout
tagToAttributeType _  = Nothing

||| Proof: encoding then decoding AttributeType is the identity.
public export
attributeTypeRoundtrip : (a : AttributeType) -> tagToAttributeType (attributeTypeToTag a) = Just a
attributeTypeRoundtrip UserName       = Refl
attributeTypeRoundtrip UserPassword   = Refl
attributeTypeRoundtrip NASIPAddress   = Refl
attributeTypeRoundtrip NASPort        = Refl
attributeTypeRoundtrip ServiceTy      = Refl
attributeTypeRoundtrip FramedProtocol = Refl
attributeTypeRoundtrip FramedIPAddr   = Refl
attributeTypeRoundtrip ReplyMessage   = Refl
attributeTypeRoundtrip SessionTimeout = Refl

---------------------------------------------------------------------------
-- ServiceType (6 constructors, tags 1-6 matching RFC 2865 Section 5.6)
---------------------------------------------------------------------------

||| C-ABI representation size for ServiceType (1 byte).
public export
serviceTypeSize : Nat
serviceTypeSize = 1

||| Map ServiceType to its C-ABI byte value.
||| Tag assignments match RFC 2865 Section 5.6:
|||   Login          = 1
|||   Framed         = 2
|||   CallbackLogin  = 3
|||   CallbackFramed = 4
|||   Outbound       = 5
|||   Administrative = 6
public export
serviceTypeToTag : ServiceType -> Bits8
serviceTypeToTag Login          = 1
serviceTypeToTag Framed         = 2
serviceTypeToTag CallbackLogin  = 3
serviceTypeToTag CallbackFramed = 4
serviceTypeToTag Outbound       = 5
serviceTypeToTag Administrative = 6

||| Recover ServiceType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 1-6.
public export
tagToServiceType : Bits8 -> Maybe ServiceType
tagToServiceType 1 = Just Login
tagToServiceType 2 = Just Framed
tagToServiceType 3 = Just CallbackLogin
tagToServiceType 4 = Just CallbackFramed
tagToServiceType 5 = Just Outbound
tagToServiceType 6 = Just Administrative
tagToServiceType _ = Nothing

||| Proof: encoding then decoding ServiceType is the identity.
public export
serviceTypeRoundtrip : (s : ServiceType) -> tagToServiceType (serviceTypeToTag s) = Just s
serviceTypeRoundtrip Login          = Refl
serviceTypeRoundtrip Framed         = Refl
serviceTypeRoundtrip CallbackLogin  = Refl
serviceTypeRoundtrip CallbackFramed = Refl
serviceTypeRoundtrip Outbound       = Refl
serviceTypeRoundtrip Administrative = Refl

---------------------------------------------------------------------------
-- AuthMethod (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Authentication methods supported by the RADIUS server.
||| PAP  = Password Authentication Protocol (RFC 2865 Section 5.2)
||| CHAP = Challenge-Handshake Auth Protocol (RFC 2865 Section 5.3)
||| MSCHAP  = Microsoft CHAP (RFC 2548)
||| MSCHAPv2 = Microsoft CHAP v2 (RFC 2759)
||| EAP  = Extensible Authentication Protocol (RFC 3579)
public export
data AuthMethod : Type where
  PAP      : AuthMethod
  CHAP     : AuthMethod
  MSCHAP   : AuthMethod
  MSCHAPv2 : AuthMethod
  EAP      : AuthMethod

public export
Eq AuthMethod where
  PAP      == PAP      = True
  CHAP     == CHAP     = True
  MSCHAP   == MSCHAP   = True
  MSCHAPv2 == MSCHAPv2 = True
  EAP      == EAP      = True
  _        == _        = False

public export
Show AuthMethod where
  show PAP      = "PAP(0)"
  show CHAP     = "CHAP(1)"
  show MSCHAP   = "MS-CHAP(2)"
  show MSCHAPv2 = "MS-CHAPv2(3)"
  show EAP      = "EAP(4)"

||| C-ABI representation size for AuthMethod (1 byte).
public export
authMethodSize : Nat
authMethodSize = 1

||| Map AuthMethod to its C-ABI byte value.
|||   PAP      = 0
|||   CHAP     = 1
|||   MSCHAP   = 2
|||   MSCHAPv2 = 3
|||   EAP      = 4
public export
authMethodToTag : AuthMethod -> Bits8
authMethodToTag PAP      = 0
authMethodToTag CHAP     = 1
authMethodToTag MSCHAP   = 2
authMethodToTag MSCHAPv2 = 3
authMethodToTag EAP      = 4

||| Recover AuthMethod from its C-ABI byte value.
public export
tagToAuthMethod : Bits8 -> Maybe AuthMethod
tagToAuthMethod 0 = Just PAP
tagToAuthMethod 1 = Just CHAP
tagToAuthMethod 2 = Just MSCHAP
tagToAuthMethod 3 = Just MSCHAPv2
tagToAuthMethod 4 = Just EAP
tagToAuthMethod _ = Nothing

||| Proof: encoding then decoding AuthMethod is the identity.
public export
authMethodRoundtrip : (m : AuthMethod) -> tagToAuthMethod (authMethodToTag m) = Just m
authMethodRoundtrip PAP      = Refl
authMethodRoundtrip CHAP     = Refl
authMethodRoundtrip MSCHAP   = Refl
authMethodRoundtrip MSCHAPv2 = Refl
authMethodRoundtrip EAP      = Refl

---------------------------------------------------------------------------
-- RadiusResult (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Result codes for RADIUS FFI operations.
public export
data RadiusResult : Type where
  ||| Operation succeeded.
  ROk            : RadiusResult
  ||| Generic error.
  RError         : RadiusResult
  ||| Invalid parameter provided.
  RInvalidParam  : RadiusResult
  ||| No free session slots available.
  RPoolExhausted : RadiusResult
  ||| Shared secret is missing or invalid.
  RBadSecret     : RadiusResult

public export
Eq RadiusResult where
  ROk            == ROk            = True
  RError         == RError         = True
  RInvalidParam  == RInvalidParam  = True
  RPoolExhausted == RPoolExhausted = True
  RBadSecret     == RBadSecret     = True
  _              == _              = False

public export
Show RadiusResult where
  show ROk            = "Ok(0)"
  show RError         = "Error(1)"
  show RInvalidParam  = "InvalidParam(2)"
  show RPoolExhausted = "PoolExhausted(3)"
  show RBadSecret     = "BadSecret(4)"

||| C-ABI representation size for RadiusResult (1 byte).
public export
radiusResultSize : Nat
radiusResultSize = 1

||| Map RadiusResult to its C-ABI byte value.
|||   ROk            = 0
|||   RError         = 1
|||   RInvalidParam  = 2
|||   RPoolExhausted = 3
|||   RBadSecret     = 4
public export
radiusResultToTag : RadiusResult -> Bits8
radiusResultToTag ROk            = 0
radiusResultToTag RError         = 1
radiusResultToTag RInvalidParam  = 2
radiusResultToTag RPoolExhausted = 3
radiusResultToTag RBadSecret     = 4

||| Recover RadiusResult from its C-ABI byte value.
public export
tagToRadiusResult : Bits8 -> Maybe RadiusResult
tagToRadiusResult 0 = Just ROk
tagToRadiusResult 1 = Just RError
tagToRadiusResult 2 = Just RInvalidParam
tagToRadiusResult 3 = Just RPoolExhausted
tagToRadiusResult 4 = Just RBadSecret
tagToRadiusResult _ = Nothing

||| Proof: encoding then decoding RadiusResult is the identity.
public export
radiusResultRoundtrip : (r : RadiusResult) -> tagToRadiusResult (radiusResultToTag r) = Just r
radiusResultRoundtrip ROk            = Refl
radiusResultRoundtrip RError         = Refl
radiusResultRoundtrip RInvalidParam  = Refl
radiusResultRoundtrip RPoolExhausted = Refl
radiusResultRoundtrip RBadSecret     = Refl

---------------------------------------------------------------------------
-- RADIUS packet header layout (RFC 2865 Section 3)
---------------------------------------------------------------------------

||| RADIUS packet header is exactly 20 bytes:
|||   Code       (1 byte)  - PacketType tag
|||   Identifier (1 byte)  - matching request/response
|||   Length     (2 bytes)  - total packet length (big-endian)
|||   Authenticator (16 bytes) - request authenticator or response auth
public export
packetHeaderSize : Nat
packetHeaderSize = 20

||| Maximum RADIUS packet size (RFC 2865 Section 3).
public export
maxPacketSize : Nat
maxPacketSize = 4096

||| Minimum RADIUS packet size (header only, no attributes).
public export
minPacketSize : Nat
minPacketSize = 20

||| Proof: minimum packet size equals header size.
public export
minIsHeader : RADIUSABI.Layout.minPacketSize = RADIUSABI.Layout.packetHeaderSize
minIsHeader = Refl

||| Proof: maximum packet size is at least the minimum.
public export
maxGEMin : So (RADIUSABI.Layout.maxPacketSize >= RADIUSABI.Layout.minPacketSize)
maxGEMin = Oh

---------------------------------------------------------------------------
-- Attribute TLV layout (RFC 2865 Section 5)
---------------------------------------------------------------------------

||| Attribute header is 2 bytes: Type (1 byte) + Length (1 byte).
||| The Length field includes the header itself, so minimum attribute
||| length is 2 (empty value) and maximum is 255.
public export
attributeHeaderSize : Nat
attributeHeaderSize = 2

||| Maximum attribute value length = 255 - 2 = 253 bytes.
public export
maxAttributeValueLen : Nat
maxAttributeValueLen = 253

||| Proof: attribute header + max value = 255.
public export
maxAttrTotal : RADIUSABI.Layout.attributeHeaderSize + RADIUSABI.Layout.maxAttributeValueLen = 255
maxAttrTotal = Refl

---------------------------------------------------------------------------
-- Enumerations of all AuthMethod constructors
---------------------------------------------------------------------------

||| All authentication methods.
public export
allAuthMethods : List AuthMethod
allAuthMethods = [PAP, CHAP, MSCHAP, MSCHAPv2, EAP]
