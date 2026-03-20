-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoTABI.Types: C-ABI-compatible numeric representations of DoT types.
--
-- Maps every constructor of the core DoT sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/dot.h) and the
-- Zig FFI enums (ffi/zig/src/dot.zig) exactly.
--
-- Types covered:
--   SessionState    (5 constructors, tags 0-4)
--   PaddingStrategy (3 constructors, tags 0-2)
--   ErrorReason     (4 constructors, tags 0-3)
--   ServerState     (5 constructors, tags 0-4)

module DoTABI.Types

import DoT.Types

%default total

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
sessionStateToTag : DoT.Types.SessionState -> Bits8
sessionStateToTag Connecting  = 0
sessionStateToTag Handshaking = 1
sessionStateToTag Established = 2
sessionStateToTag Closing     = 3
sessionStateToTag Closed      = 4

public export
tagToSessionState : Bits8 -> Maybe DoT.Types.SessionState
tagToSessionState 0 = Just Connecting
tagToSessionState 1 = Just Handshaking
tagToSessionState 2 = Just Established
tagToSessionState 3 = Just Closing
tagToSessionState 4 = Just Closed
tagToSessionState _ = Nothing

public export
sessionStateRoundtrip : (s : DoT.Types.SessionState) -> tagToSessionState (sessionStateToTag s) = Just s
sessionStateRoundtrip Connecting  = Refl
sessionStateRoundtrip Handshaking = Refl
sessionStateRoundtrip Established = Refl
sessionStateRoundtrip Closing     = Refl
sessionStateRoundtrip Closed      = Refl

---------------------------------------------------------------------------
-- PaddingStrategy (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
paddingStrategyToTag : PaddingStrategy -> Bits8
paddingStrategyToTag NoPadding     = 0
paddingStrategyToTag BlockPadding  = 1
paddingStrategyToTag RandomPadding = 2

public export
tagToPaddingStrategy : Bits8 -> Maybe PaddingStrategy
tagToPaddingStrategy 0 = Just NoPadding
tagToPaddingStrategy 1 = Just BlockPadding
tagToPaddingStrategy 2 = Just RandomPadding
tagToPaddingStrategy _ = Nothing

public export
paddingStrategyRoundtrip : (p : PaddingStrategy) -> tagToPaddingStrategy (paddingStrategyToTag p) = Just p
paddingStrategyRoundtrip NoPadding     = Refl
paddingStrategyRoundtrip BlockPadding  = Refl
paddingStrategyRoundtrip RandomPadding = Refl

---------------------------------------------------------------------------
-- ErrorReason (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
errorReasonToTag : ErrorReason -> Bits8
errorReasonToTag HandshakeFailed    = 0
errorReasonToTag CertificateInvalid = 1
errorReasonToTag Timeout            = 2
errorReasonToTag UpstreamError      = 3

public export
tagToErrorReason : Bits8 -> Maybe ErrorReason
tagToErrorReason 0 = Just HandshakeFailed
tagToErrorReason 1 = Just CertificateInvalid
tagToErrorReason 2 = Just Timeout
tagToErrorReason 3 = Just UpstreamError
tagToErrorReason _ = Nothing

public export
errorReasonRoundtrip : (e : ErrorReason) -> tagToErrorReason (errorReasonToTag e) = Just e
errorReasonRoundtrip HandshakeFailed    = Refl
errorReasonRoundtrip CertificateInvalid = Refl
errorReasonRoundtrip Timeout            = Refl
errorReasonRoundtrip UpstreamError      = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- DoT server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| DoT proxy server lifecycle states (RFC 7858 server endpoint).
public export
data ServerState : Type where
  ||| No server active. Initial and terminal state.
  SVIdle       : ServerState
  ||| Server bound to port 853 with TLS configured.
  SVBound      : ServerState
  ||| Actively accepting TLS connections for DNS queries.
  SVListening  : ServerState
  ||| Processing DNS queries over TLS.
  SVProcessing : ServerState
  ||| Shutting down, closing TLS sessions.
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
