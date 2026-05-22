-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- STUNABI.Types: C-ABI-compatible numeric representations of STUN/TURN types.
--
-- Maps every constructor of the core STUN/TURN sum types to fixed Bits8
-- values for C interop. Each type gets a total encoder, partial decoder,
-- and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/stun.h) and the
-- Zig FFI enums (ffi/zig/src/stun.zig) exactly.
--
-- Types covered:
--   MessageType       (12 constructors, tags 0-11)
--   TransportProtocol (4 constructors, tags 0-3)
--   ErrorCode         (8 constructors, tags 0-7)

module STUNABI.Types

import STUN.Types

%default total

---------------------------------------------------------------------------
-- MessageType (12 constructors, tags 0-11)
---------------------------------------------------------------------------

public export
messageTypeSize : Nat
messageTypeSize = 1

||| Encode a MessageType to its ABI tag value.
public export
messageTypeToTag : MessageType -> Bits8
messageTypeToTag BindingRequest   = 0
messageTypeToTag BindingResponse  = 1
messageTypeToTag BindingError     = 2
messageTypeToTag AllocateRequest  = 3
messageTypeToTag AllocateResponse = 4
messageTypeToTag AllocateError    = 5
messageTypeToTag RefreshRequest   = 6
messageTypeToTag RefreshResponse  = 7
messageTypeToTag SendIndication   = 8
messageTypeToTag DataIndication   = 9
messageTypeToTag CreatePermission = 10
messageTypeToTag ChannelBind      = 11

||| Decode an ABI tag to a MessageType.
public export
tagToMessageType : Bits8 -> Maybe MessageType
tagToMessageType 0  = Just BindingRequest
tagToMessageType 1  = Just BindingResponse
tagToMessageType 2  = Just BindingError
tagToMessageType 3  = Just AllocateRequest
tagToMessageType 4  = Just AllocateResponse
tagToMessageType 5  = Just AllocateError
tagToMessageType 6  = Just RefreshRequest
tagToMessageType 7  = Just RefreshResponse
tagToMessageType 8  = Just SendIndication
tagToMessageType 9  = Just DataIndication
tagToMessageType 10 = Just CreatePermission
tagToMessageType 11 = Just ChannelBind
tagToMessageType _  = Nothing

||| Roundtrip proof: decoding an encoded MessageType yields the original.
public export
messageTypeRoundtrip : (m : MessageType) -> tagToMessageType (messageTypeToTag m) = Just m
messageTypeRoundtrip BindingRequest   = Refl
messageTypeRoundtrip BindingResponse  = Refl
messageTypeRoundtrip BindingError     = Refl
messageTypeRoundtrip AllocateRequest  = Refl
messageTypeRoundtrip AllocateResponse = Refl
messageTypeRoundtrip AllocateError    = Refl
messageTypeRoundtrip RefreshRequest   = Refl
messageTypeRoundtrip RefreshResponse  = Refl
messageTypeRoundtrip SendIndication   = Refl
messageTypeRoundtrip DataIndication   = Refl
messageTypeRoundtrip CreatePermission = Refl
messageTypeRoundtrip ChannelBind      = Refl

---------------------------------------------------------------------------
-- TransportProtocol (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
transportProtocolSize : Nat
transportProtocolSize = 1

||| Encode a TransportProtocol to its ABI tag value.
public export
transportProtocolToTag : TransportProtocol -> Bits8
transportProtocolToTag UDP  = 0
transportProtocolToTag TCP  = 1
transportProtocolToTag TLS  = 2
transportProtocolToTag DTLS = 3

||| Decode an ABI tag to a TransportProtocol.
public export
tagToTransportProtocol : Bits8 -> Maybe TransportProtocol
tagToTransportProtocol 0 = Just UDP
tagToTransportProtocol 1 = Just TCP
tagToTransportProtocol 2 = Just TLS
tagToTransportProtocol 3 = Just DTLS
tagToTransportProtocol _ = Nothing

||| Roundtrip proof: decoding an encoded TransportProtocol yields the original.
public export
transportProtocolRoundtrip : (t : TransportProtocol) -> tagToTransportProtocol (transportProtocolToTag t) = Just t
transportProtocolRoundtrip UDP  = Refl
transportProtocolRoundtrip TCP  = Refl
transportProtocolRoundtrip TLS  = Refl
transportProtocolRoundtrip DTLS = Refl

---------------------------------------------------------------------------
-- ErrorCode (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
errorCodeSize : Nat
errorCodeSize = 1

||| Encode an ErrorCode to its ABI tag value.
public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag TryAlternate         = 0
errorCodeToTag BadRequest           = 1
errorCodeToTag Unauthorized         = 2
errorCodeToTag Forbidden            = 3
errorCodeToTag MobilityForbidden    = 4
errorCodeToTag StaleNonce           = 5
errorCodeToTag ServerError          = 6
errorCodeToTag InsufficientCapacity = 7

||| Decode an ABI tag to an ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just TryAlternate
tagToErrorCode 1 = Just BadRequest
tagToErrorCode 2 = Just Unauthorized
tagToErrorCode 3 = Just Forbidden
tagToErrorCode 4 = Just MobilityForbidden
tagToErrorCode 5 = Just StaleNonce
tagToErrorCode 6 = Just ServerError
tagToErrorCode 7 = Just InsufficientCapacity
tagToErrorCode _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCode yields the original.
public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip TryAlternate         = Refl
errorCodeRoundtrip BadRequest           = Refl
errorCodeRoundtrip Unauthorized         = Refl
errorCodeRoundtrip Forbidden            = Refl
errorCodeRoundtrip MobilityForbidden    = Refl
errorCodeRoundtrip StaleNonce           = Refl
errorCodeRoundtrip ServerError          = Refl
errorCodeRoundtrip InsufficientCapacity = Refl
