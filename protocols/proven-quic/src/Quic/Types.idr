-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Core QUIC types (RFC 9000) as closed sum types with Show/Eq.
|||
||| proven-quic is a *transport-core* skeleton: it captures the parts of QUIC
||| whose correctness is structural — stream identity, stream/connection state
||| machines, frame-in-packet rules — as dependently-typed data with proofs,
||| plus a real variable-length-integer codec in the Zig engine.  It is NOT a
||| full QUIC stack: TLS 1.3, packet protection, congestion control, loss
||| recovery, and flow control accounting are out of scope (see README).
module Quic.Types

%default total

---------------------------------------------------------------------------
-- Endpoint role and stream directionality (RFC 9000 Section 2.1)
---------------------------------------------------------------------------

||| Which endpoint a stream or action belongs to.
public export
data Endpoint : Type where
  Client : Endpoint
  Server : Endpoint

public export
Eq Endpoint where
  Client == Client = True
  Server == Server = True
  _      == _      = False

public export
Show Endpoint where
  show Client = "client"
  show Server = "server"

||| Stream directionality.
public export
data Direction : Type where
  Bidi : Direction
  Uni  : Direction

public export
Eq Direction where
  Bidi == Bidi = True
  Uni  == Uni  = True
  _    == _    = False

public export
Show Direction where
  show Bidi = "bidirectional"
  show Uni  = "unidirectional"

||| The four stream kinds, identified by the two least-significant bits of a
||| stream ID (RFC 9000 Section 2.1).
public export
data StreamKind : Type where
  ClientBidi : StreamKind
  ServerBidi : StreamKind
  ClientUni  : StreamKind
  ServerUni  : StreamKind

public export
Eq StreamKind where
  ClientBidi == ClientBidi = True
  ServerBidi == ServerBidi = True
  ClientUni  == ClientUni  = True
  ServerUni  == ServerUni  = True
  _          == _          = False

public export
Show StreamKind where
  show ClientBidi = "client-bidi"
  show ServerBidi = "server-bidi"
  show ClientUni  = "client-uni"
  show ServerUni  = "server-uni"

---------------------------------------------------------------------------
-- Connection lifecycle (RFC 9000 Sections 9-10)
---------------------------------------------------------------------------

||| Connection lifecycle states.  `Closing` is entered when this endpoint
||| initiates the close; `Draining` when it receives a CONNECTION_CLOSE.
public export
data ConnState : Type where
  CInitial     : ConnState
  CHandshaking : ConnState
  CConnected   : ConnState
  CClosing     : ConnState
  CDraining    : ConnState
  CClosed      : ConnState

public export
Eq ConnState where
  CInitial     == CInitial     = True
  CHandshaking == CHandshaking = True
  CConnected   == CConnected   = True
  CClosing     == CClosing     = True
  CDraining    == CDraining    = True
  CClosed      == CClosed      = True
  _            == _            = False

public export
Show ConnState where
  show CInitial     = "Initial"
  show CHandshaking = "Handshaking"
  show CConnected   = "Connected"
  show CClosing     = "Closing"
  show CDraining    = "Draining"
  show CClosed      = "Closed"

---------------------------------------------------------------------------
-- Stream sending part state machine (RFC 9000 Section 3.1)
---------------------------------------------------------------------------

public export
data SendState : Type where
  SReady    : SendState
  SSend     : SendState
  SDataSent : SendState
  SDataRecvd : SendState
  SResetSent : SendState
  SResetRecvd : SendState

public export
Eq SendState where
  SReady      == SReady      = True
  SSend       == SSend       = True
  SDataSent   == SDataSent   = True
  SDataRecvd  == SDataRecvd  = True
  SResetSent  == SResetSent  = True
  SResetRecvd == SResetRecvd = True
  _           == _           = False

public export
Show SendState where
  show SReady      = "Ready"
  show SSend       = "Send"
  show SDataSent   = "DataSent"
  show SDataRecvd  = "DataRecvd"
  show SResetSent  = "ResetSent"
  show SResetRecvd = "ResetRecvd"

---------------------------------------------------------------------------
-- Stream receiving part state machine (RFC 9000 Section 3.2)
---------------------------------------------------------------------------

public export
data RecvState : Type where
  RRecv      : RecvState
  RSizeKnown : RecvState
  RDataRecvd : RecvState
  RDataRead  : RecvState
  RResetRecvd : RecvState
  RResetRead  : RecvState

public export
Eq RecvState where
  RRecv       == RRecv       = True
  RSizeKnown  == RSizeKnown  = True
  RDataRecvd  == RDataRecvd  = True
  RDataRead   == RDataRead   = True
  RResetRecvd == RResetRecvd = True
  RResetRead  == RResetRead  = True
  _           == _           = False

public export
Show RecvState where
  show RRecv       = "Recv"
  show RSizeKnown  = "SizeKnown"
  show RDataRecvd  = "DataRecvd"
  show RDataRead   = "DataRead"
  show RResetRecvd = "ResetRecvd"
  show RResetRead  = "ResetRead"

---------------------------------------------------------------------------
-- Packet types (RFC 9000 Section 17)
---------------------------------------------------------------------------

public export
data PacketType : Type where
  PInitial            : PacketType
  PZeroRtt            : PacketType
  PHandshake          : PacketType
  PRetry              : PacketType
  PVersionNegotiation : PacketType
  POneRtt             : PacketType

public export
Eq PacketType where
  PInitial            == PInitial            = True
  PZeroRtt            == PZeroRtt            = True
  PHandshake          == PHandshake          = True
  PRetry              == PRetry              = True
  PVersionNegotiation == PVersionNegotiation = True
  POneRtt             == POneRtt             = True
  _                   == _                   = False

public export
Show PacketType where
  show PInitial            = "Initial"
  show PZeroRtt            = "0-RTT"
  show PHandshake          = "Handshake"
  show PRetry              = "Retry"
  show PVersionNegotiation = "VersionNegotiation"
  show POneRtt             = "1-RTT"

---------------------------------------------------------------------------
-- Frame kinds (RFC 9000 Section 19, ranges collapsed to one kind each)
---------------------------------------------------------------------------

public export
data FrameKind : Type where
  Padding            : FrameKind
  Ping               : FrameKind
  Ack                : FrameKind
  ResetStream        : FrameKind
  StopSending        : FrameKind
  Crypto             : FrameKind
  NewToken           : FrameKind
  StreamFrame        : FrameKind
  MaxData            : FrameKind
  MaxStreamData      : FrameKind
  MaxStreams         : FrameKind
  DataBlocked        : FrameKind
  StreamDataBlocked  : FrameKind
  StreamsBlocked     : FrameKind
  NewConnectionId    : FrameKind
  RetireConnectionId : FrameKind
  PathChallenge      : FrameKind
  PathResponse       : FrameKind
  ConnectionClose    : FrameKind
  HandshakeDone      : FrameKind

public export
Eq FrameKind where
  Padding            == Padding            = True
  Ping               == Ping               = True
  Ack                == Ack                = True
  ResetStream        == ResetStream        = True
  StopSending        == StopSending        = True
  Crypto             == Crypto             = True
  NewToken           == NewToken           = True
  StreamFrame        == StreamFrame        = True
  MaxData            == MaxData            = True
  MaxStreamData      == MaxStreamData      = True
  MaxStreams         == MaxStreams         = True
  DataBlocked        == DataBlocked        = True
  StreamDataBlocked  == StreamDataBlocked  = True
  StreamsBlocked     == StreamsBlocked     = True
  NewConnectionId    == NewConnectionId    = True
  RetireConnectionId == RetireConnectionId = True
  PathChallenge      == PathChallenge      = True
  PathResponse       == PathResponse       = True
  ConnectionClose    == ConnectionClose    = True
  HandshakeDone      == HandshakeDone      = True
  _                  == _                  = False

public export
Show FrameKind where
  show Padding            = "PADDING"
  show Ping               = "PING"
  show Ack                = "ACK"
  show ResetStream        = "RESET_STREAM"
  show StopSending        = "STOP_SENDING"
  show Crypto             = "CRYPTO"
  show NewToken           = "NEW_TOKEN"
  show StreamFrame        = "STREAM"
  show MaxData            = "MAX_DATA"
  show MaxStreamData      = "MAX_STREAM_DATA"
  show MaxStreams         = "MAX_STREAMS"
  show DataBlocked        = "DATA_BLOCKED"
  show StreamDataBlocked  = "STREAM_DATA_BLOCKED"
  show StreamsBlocked     = "STREAMS_BLOCKED"
  show NewConnectionId    = "NEW_CONNECTION_ID"
  show RetireConnectionId = "RETIRE_CONNECTION_ID"
  show PathChallenge      = "PATH_CHALLENGE"
  show PathResponse       = "PATH_RESPONSE"
  show ConnectionClose    = "CONNECTION_CLOSE"
  show HandshakeDone      = "HANDSHAKE_DONE"

---------------------------------------------------------------------------
-- Transport error codes (RFC 9000 Section 20.1), contiguous subset 0x0-0x8
---------------------------------------------------------------------------

public export
data TransportError : Type where
  NoError                : TransportError
  InternalError          : TransportError
  ConnectionRefused      : TransportError
  FlowControlError       : TransportError
  StreamLimitError       : TransportError
  StreamStateError       : TransportError
  FinalSizeError         : TransportError
  FrameEncodingError     : TransportError
  TransportParameterError : TransportError

public export
Eq TransportError where
  NoError                 == NoError                 = True
  InternalError           == InternalError           = True
  ConnectionRefused       == ConnectionRefused       = True
  FlowControlError        == FlowControlError        = True
  StreamLimitError        == StreamLimitError        = True
  StreamStateError        == StreamStateError        = True
  FinalSizeError          == FinalSizeError          = True
  FrameEncodingError      == FrameEncodingError      = True
  TransportParameterError == TransportParameterError = True
  _                       == _                       = False

public export
Show TransportError where
  show NoError                 = "0x0 NO_ERROR"
  show InternalError           = "0x1 INTERNAL_ERROR"
  show ConnectionRefused       = "0x2 CONNECTION_REFUSED"
  show FlowControlError        = "0x3 FLOW_CONTROL_ERROR"
  show StreamLimitError        = "0x4 STREAM_LIMIT_ERROR"
  show StreamStateError        = "0x5 STREAM_STATE_ERROR"
  show FinalSizeError          = "0x6 FINAL_SIZE_ERROR"
  show FrameEncodingError      = "0x7 FRAME_ENCODING_ERROR"
  show TransportParameterError = "0x8 TRANSPORT_PARAMETER_ERROR"
