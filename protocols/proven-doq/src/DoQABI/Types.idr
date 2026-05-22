-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoQABI.Types: C-ABI-compatible numeric representations of DoQ types.
--
-- Maps every constructor of the core DoQ sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/doq.h) and the
-- Zig FFI enums (ffi/zig/src/doq.zig) exactly.
--
-- Types covered:
--   StreamType    (2 constructors, tags 0-1)
--   ErrorCode     (4 constructors, tags 0-3)
--   SessionState  (5 constructors, tags 0-4)
--   ServerState   (5 constructors, tags 0-4)

module DoQABI.Types

import DoQ.Types

%default total

---------------------------------------------------------------------------
-- StreamType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
streamTypeToTag : StreamType -> Bits8
streamTypeToTag Unidirectional = 0
streamTypeToTag Bidirectional  = 1

public export
tagToStreamType : Bits8 -> Maybe StreamType
tagToStreamType 0 = Just Unidirectional
tagToStreamType 1 = Just Bidirectional
tagToStreamType _ = Nothing

public export
streamTypeRoundtrip : (s : StreamType) -> tagToStreamType (streamTypeToTag s) = Just s
streamTypeRoundtrip Unidirectional = Refl
streamTypeRoundtrip Bidirectional  = Refl

---------------------------------------------------------------------------
-- ErrorCode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag NoError       = 0
errorCodeToTag InternalError = 1
errorCodeToTag ExcessiveLoad = 2
errorCodeToTag ProtocolError = 3

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just NoError
tagToErrorCode 1 = Just InternalError
tagToErrorCode 2 = Just ExcessiveLoad
tagToErrorCode 3 = Just ProtocolError
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip NoError       = Refl
errorCodeRoundtrip InternalError = Refl
errorCodeRoundtrip ExcessiveLoad = Refl
errorCodeRoundtrip ProtocolError = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
sessionStateToTag : SessionState -> Bits8
sessionStateToTag Initial     = 0
sessionStateToTag Handshaking = 1
sessionStateToTag Ready       = 2
sessionStateToTag Draining    = 3
sessionStateToTag Closed      = 4

public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Initial
tagToSessionState 1 = Just Handshaking
tagToSessionState 2 = Just Ready
tagToSessionState 3 = Just Draining
tagToSessionState 4 = Just Closed
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Initial     = Refl
sessionStateRoundtrip Handshaking = Refl
sessionStateRoundtrip Ready       = Refl
sessionStateRoundtrip Draining    = Refl
sessionStateRoundtrip Closed      = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- DoQ server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| DoQ server lifecycle states (RFC 9250 server endpoint).
public export
data ServerState : Type where
  ||| No server active. Initial and terminal state.
  SVIdle       : ServerState
  ||| Server bound to listening address with QUIC transport.
  SVBound      : ServerState
  ||| Actively accepting QUIC connections for DNS queries.
  SVListening  : ServerState
  ||| Processing DNS queries over QUIC streams.
  SVProcessing : ServerState
  ||| Shutting down, draining QUIC connections.
  SVShutdown   : ServerState

public export
Eq ServerState where
  SVIdle       == SVIdle       = True
  SVBound      == SVBound      = True
  SVListening  == SVListening  = True
  SVProcessing == SVProcessing = True
  SVShutdown   == SVShutdown   = True
  _            == _            = False

public export
Show ServerState where
  show SVIdle       = "Idle"
  show SVBound      = "Bound"
  show SVListening  = "Listening"
  show SVProcessing = "Processing"
  show SVShutdown   = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SVIdle       = 0
serverStateToTag SVBound      = 1
serverStateToTag SVListening  = 2
serverStateToTag SVProcessing = 3
serverStateToTag SVShutdown   = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SVIdle
tagToServerState 1 = Just SVBound
tagToServerState 2 = Just SVListening
tagToServerState 3 = Just SVProcessing
tagToServerState 4 = Just SVShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SVIdle       = Refl
serverStateRoundtrip SVBound      = Refl
serverStateRoundtrip SVListening  = Refl
serverStateRoundtrip SVProcessing = Refl
serverStateRoundtrip SVShutdown   = Refl
