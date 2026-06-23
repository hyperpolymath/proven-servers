-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| C-ABI numeric encodings for the proven-quic enums, each with a total
||| encoder, partial decoder, and encode-then-decode round-trip proof.
||| Tag values MUST match the Zig engine (ffi/zig/src/quic.zig) exactly.
module QuicABI.Types

import Quic.Types

%default total

---------------------------------------------------------------------------
-- Endpoint (tags 0-1)
---------------------------------------------------------------------------

public export
endpointToTag : Endpoint -> Bits8
endpointToTag Client = 0
endpointToTag Server = 1

public export
tagToEndpoint : Bits8 -> Maybe Endpoint
tagToEndpoint 0 = Just Client
tagToEndpoint 1 = Just Server
tagToEndpoint _ = Nothing

public export
endpointRoundtrip : (e : Endpoint) -> tagToEndpoint (endpointToTag e) = Just e
endpointRoundtrip Client = Refl
endpointRoundtrip Server = Refl

---------------------------------------------------------------------------
-- Direction (tags 0-1)
---------------------------------------------------------------------------

public export
directionToTag : Direction -> Bits8
directionToTag Bidi = 0
directionToTag Uni  = 1

public export
tagToDirection : Bits8 -> Maybe Direction
tagToDirection 0 = Just Bidi
tagToDirection 1 = Just Uni
tagToDirection _ = Nothing

public export
directionRoundtrip : (d : Direction) -> tagToDirection (directionToTag d) = Just d
directionRoundtrip Bidi = Refl
directionRoundtrip Uni  = Refl

---------------------------------------------------------------------------
-- StreamKind (tags 0-3, matching the RFC 9000 two-bit code)
---------------------------------------------------------------------------

public export
streamKindToTag : StreamKind -> Bits8
streamKindToTag ClientBidi = 0
streamKindToTag ServerBidi = 1
streamKindToTag ClientUni  = 2
streamKindToTag ServerUni  = 3

public export
tagToStreamKind : Bits8 -> Maybe StreamKind
tagToStreamKind 0 = Just ClientBidi
tagToStreamKind 1 = Just ServerBidi
tagToStreamKind 2 = Just ClientUni
tagToStreamKind 3 = Just ServerUni
tagToStreamKind _ = Nothing

public export
streamKindRoundtrip : (k : StreamKind) -> tagToStreamKind (streamKindToTag k) = Just k
streamKindRoundtrip ClientBidi = Refl
streamKindRoundtrip ServerBidi = Refl
streamKindRoundtrip ClientUni  = Refl
streamKindRoundtrip ServerUni  = Refl

---------------------------------------------------------------------------
-- ConnState (tags 0-5)
---------------------------------------------------------------------------

public export
connStateToTag : ConnState -> Bits8
connStateToTag CInitial     = 0
connStateToTag CHandshaking = 1
connStateToTag CConnected   = 2
connStateToTag CClosing     = 3
connStateToTag CDraining    = 4
connStateToTag CClosed      = 5

public export
tagToConnState : Bits8 -> Maybe ConnState
tagToConnState 0 = Just CInitial
tagToConnState 1 = Just CHandshaking
tagToConnState 2 = Just CConnected
tagToConnState 3 = Just CClosing
tagToConnState 4 = Just CDraining
tagToConnState 5 = Just CClosed
tagToConnState _ = Nothing

public export
connStateRoundtrip : (s : ConnState) -> tagToConnState (connStateToTag s) = Just s
connStateRoundtrip CInitial     = Refl
connStateRoundtrip CHandshaking = Refl
connStateRoundtrip CConnected   = Refl
connStateRoundtrip CClosing     = Refl
connStateRoundtrip CDraining    = Refl
connStateRoundtrip CClosed      = Refl

---------------------------------------------------------------------------
-- SendState (tags 0-5)
---------------------------------------------------------------------------

public export
sendStateToTag : SendState -> Bits8
sendStateToTag SReady      = 0
sendStateToTag SSend       = 1
sendStateToTag SDataSent   = 2
sendStateToTag SDataRecvd  = 3
sendStateToTag SResetSent  = 4
sendStateToTag SResetRecvd = 5

public export
tagToSendState : Bits8 -> Maybe SendState
tagToSendState 0 = Just SReady
tagToSendState 1 = Just SSend
tagToSendState 2 = Just SDataSent
tagToSendState 3 = Just SDataRecvd
tagToSendState 4 = Just SResetSent
tagToSendState 5 = Just SResetRecvd
tagToSendState _ = Nothing

public export
sendStateRoundtrip : (s : SendState) -> tagToSendState (sendStateToTag s) = Just s
sendStateRoundtrip SReady      = Refl
sendStateRoundtrip SSend       = Refl
sendStateRoundtrip SDataSent   = Refl
sendStateRoundtrip SDataRecvd  = Refl
sendStateRoundtrip SResetSent  = Refl
sendStateRoundtrip SResetRecvd = Refl

---------------------------------------------------------------------------
-- RecvState (tags 0-5)
---------------------------------------------------------------------------

public export
recvStateToTag : RecvState -> Bits8
recvStateToTag RRecv       = 0
recvStateToTag RSizeKnown  = 1
recvStateToTag RDataRecvd  = 2
recvStateToTag RDataRead   = 3
recvStateToTag RResetRecvd = 4
recvStateToTag RResetRead  = 5

public export
tagToRecvState : Bits8 -> Maybe RecvState
tagToRecvState 0 = Just RRecv
tagToRecvState 1 = Just RSizeKnown
tagToRecvState 2 = Just RDataRecvd
tagToRecvState 3 = Just RDataRead
tagToRecvState 4 = Just RResetRecvd
tagToRecvState 5 = Just RResetRead
tagToRecvState _ = Nothing

public export
recvStateRoundtrip : (s : RecvState) -> tagToRecvState (recvStateToTag s) = Just s
recvStateRoundtrip RRecv       = Refl
recvStateRoundtrip RSizeKnown  = Refl
recvStateRoundtrip RDataRecvd  = Refl
recvStateRoundtrip RDataRead   = Refl
recvStateRoundtrip RResetRecvd = Refl
recvStateRoundtrip RResetRead  = Refl

---------------------------------------------------------------------------
-- PacketType (tags 0-5)
---------------------------------------------------------------------------

public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag PInitial            = 0
packetTypeToTag PZeroRtt            = 1
packetTypeToTag PHandshake          = 2
packetTypeToTag PRetry              = 3
packetTypeToTag PVersionNegotiation = 4
packetTypeToTag POneRtt             = 5

public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just PInitial
tagToPacketType 1 = Just PZeroRtt
tagToPacketType 2 = Just PHandshake
tagToPacketType 3 = Just PRetry
tagToPacketType 4 = Just PVersionNegotiation
tagToPacketType 5 = Just POneRtt
tagToPacketType _ = Nothing

public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip PInitial            = Refl
packetTypeRoundtrip PZeroRtt            = Refl
packetTypeRoundtrip PHandshake          = Refl
packetTypeRoundtrip PRetry              = Refl
packetTypeRoundtrip PVersionNegotiation = Refl
packetTypeRoundtrip POneRtt             = Refl

---------------------------------------------------------------------------
-- TransportError (tags 0-8, matching RFC 9000 wire values)
---------------------------------------------------------------------------

public export
transportErrorToTag : TransportError -> Bits8
transportErrorToTag NoError                 = 0
transportErrorToTag InternalError           = 1
transportErrorToTag ConnectionRefused       = 2
transportErrorToTag FlowControlError        = 3
transportErrorToTag StreamLimitError        = 4
transportErrorToTag StreamStateError        = 5
transportErrorToTag FinalSizeError          = 6
transportErrorToTag FrameEncodingError      = 7
transportErrorToTag TransportParameterError = 8

public export
tagToTransportError : Bits8 -> Maybe TransportError
tagToTransportError 0 = Just NoError
tagToTransportError 1 = Just InternalError
tagToTransportError 2 = Just ConnectionRefused
tagToTransportError 3 = Just FlowControlError
tagToTransportError 4 = Just StreamLimitError
tagToTransportError 5 = Just StreamStateError
tagToTransportError 6 = Just FinalSizeError
tagToTransportError 7 = Just FrameEncodingError
tagToTransportError 8 = Just TransportParameterError
tagToTransportError _ = Nothing

public export
transportErrorRoundtrip : (e : TransportError) -> tagToTransportError (transportErrorToTag e) = Just e
transportErrorRoundtrip NoError                 = Refl
transportErrorRoundtrip InternalError           = Refl
transportErrorRoundtrip ConnectionRefused       = Refl
transportErrorRoundtrip FlowControlError        = Refl
transportErrorRoundtrip StreamLimitError        = Refl
transportErrorRoundtrip StreamStateError        = Refl
transportErrorRoundtrip FinalSizeError          = Refl
transportErrorRoundtrip FrameEncodingError      = Refl
transportErrorRoundtrip TransportParameterError = Refl

---------------------------------------------------------------------------
-- FrameKind (tags 0-19, declaration order)
---------------------------------------------------------------------------

public export
frameKindToTag : FrameKind -> Bits8
frameKindToTag Padding            = 0
frameKindToTag Ping               = 1
frameKindToTag Ack                = 2
frameKindToTag ResetStream        = 3
frameKindToTag StopSending        = 4
frameKindToTag Crypto             = 5
frameKindToTag NewToken           = 6
frameKindToTag StreamFrame        = 7
frameKindToTag MaxData            = 8
frameKindToTag MaxStreamData      = 9
frameKindToTag MaxStreams         = 10
frameKindToTag DataBlocked        = 11
frameKindToTag StreamDataBlocked  = 12
frameKindToTag StreamsBlocked     = 13
frameKindToTag NewConnectionId    = 14
frameKindToTag RetireConnectionId = 15
frameKindToTag PathChallenge      = 16
frameKindToTag PathResponse       = 17
frameKindToTag ConnectionClose    = 18
frameKindToTag HandshakeDone      = 19

public export
tagToFrameKind : Bits8 -> Maybe FrameKind
tagToFrameKind 0  = Just Padding
tagToFrameKind 1  = Just Ping
tagToFrameKind 2  = Just Ack
tagToFrameKind 3  = Just ResetStream
tagToFrameKind 4  = Just StopSending
tagToFrameKind 5  = Just Crypto
tagToFrameKind 6  = Just NewToken
tagToFrameKind 7  = Just StreamFrame
tagToFrameKind 8  = Just MaxData
tagToFrameKind 9  = Just MaxStreamData
tagToFrameKind 10 = Just MaxStreams
tagToFrameKind 11 = Just DataBlocked
tagToFrameKind 12 = Just StreamDataBlocked
tagToFrameKind 13 = Just StreamsBlocked
tagToFrameKind 14 = Just NewConnectionId
tagToFrameKind 15 = Just RetireConnectionId
tagToFrameKind 16 = Just PathChallenge
tagToFrameKind 17 = Just PathResponse
tagToFrameKind 18 = Just ConnectionClose
tagToFrameKind 19 = Just HandshakeDone
tagToFrameKind _  = Nothing

public export
frameKindRoundtrip : (f : FrameKind) -> tagToFrameKind (frameKindToTag f) = Just f
frameKindRoundtrip Padding            = Refl
frameKindRoundtrip Ping               = Refl
frameKindRoundtrip Ack                = Refl
frameKindRoundtrip ResetStream        = Refl
frameKindRoundtrip StopSending        = Refl
frameKindRoundtrip Crypto             = Refl
frameKindRoundtrip NewToken           = Refl
frameKindRoundtrip StreamFrame        = Refl
frameKindRoundtrip MaxData            = Refl
frameKindRoundtrip MaxStreamData      = Refl
frameKindRoundtrip MaxStreams         = Refl
frameKindRoundtrip DataBlocked        = Refl
frameKindRoundtrip StreamDataBlocked  = Refl
frameKindRoundtrip StreamsBlocked     = Refl
frameKindRoundtrip NewConnectionId    = Refl
frameKindRoundtrip RetireConnectionId = Refl
frameKindRoundtrip PathChallenge      = Refl
frameKindRoundtrip PathResponse       = Refl
frameKindRoundtrip ConnectionClose    = Refl
frameKindRoundtrip HandshakeDone      = Refl
