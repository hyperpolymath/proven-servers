-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DotABI.Types: C-ABI-compatible numeric representations of Dot types.
--
-- Maps every constructor of the core Dot sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/dot.zig) exactly.
--
-- Types covered:
--   SessionState              (5 constructors, tags 0-4)
--   PaddingStrategy           (3 constructors, tags 0-2)
--   ErrorReason               (4 constructors, tags 0-3)
--   ServerState               (5 constructors, tags 0-4)

module DotABI.Types

%default total

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Connecting : SessionState
  Handshaking : SessionState
  Established : SessionState
  Closing : SessionState
  Closed : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Connecting = 0
session_stateToTag Handshaking = 1
session_stateToTag Established = 2
session_stateToTag Closing = 3
session_stateToTag Closed = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Connecting
tagToSessionState 1 = Just Handshaking
tagToSessionState 2 = Just Established
tagToSessionState 3 = Just Closing
tagToSessionState 4 = Just Closed
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Connecting = Refl
session_stateRoundtrip Handshaking = Refl
session_stateRoundtrip Established = Refl
session_stateRoundtrip Closing = Refl
session_stateRoundtrip Closed = Refl

---------------------------------------------------------------------------
-- PaddingStrategy (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
padding_strategySize : Nat
padding_strategySize = 1

||| PaddingStrategy sum type for ABI encoding.
public export
data PaddingStrategy : Type where
  NoPadding : PaddingStrategy
  BlockPadding : PaddingStrategy
  RandomPadding : PaddingStrategy

||| Encode a PaddingStrategy to its ABI tag value.
public export
padding_strategyToTag : PaddingStrategy -> Bits8
padding_strategyToTag NoPadding = 0
padding_strategyToTag BlockPadding = 1
padding_strategyToTag RandomPadding = 2

||| Decode an ABI tag to a PaddingStrategy.
public export
tagToPaddingStrategy : Bits8 -> Maybe PaddingStrategy
tagToPaddingStrategy 0 = Just NoPadding
tagToPaddingStrategy 1 = Just BlockPadding
tagToPaddingStrategy 2 = Just RandomPadding
tagToPaddingStrategy _ = Nothing

||| Roundtrip proof: decoding an encoded PaddingStrategy yields the original.
public export
padding_strategyRoundtrip : (x : PaddingStrategy) -> tagToPaddingStrategy (padding_strategyToTag x) = Just x
padding_strategyRoundtrip NoPadding = Refl
padding_strategyRoundtrip BlockPadding = Refl
padding_strategyRoundtrip RandomPadding = Refl

---------------------------------------------------------------------------
-- ErrorReason (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
error_reasonSize : Nat
error_reasonSize = 1

||| ErrorReason sum type for ABI encoding.
public export
data ErrorReason : Type where
  HandshakeFailed : ErrorReason
  CertificateInvalid : ErrorReason
  Timeout : ErrorReason
  UpstreamError : ErrorReason

||| Encode a ErrorReason to its ABI tag value.
public export
error_reasonToTag : ErrorReason -> Bits8
error_reasonToTag HandshakeFailed = 0
error_reasonToTag CertificateInvalid = 1
error_reasonToTag Timeout = 2
error_reasonToTag UpstreamError = 3

||| Decode an ABI tag to a ErrorReason.
public export
tagToErrorReason : Bits8 -> Maybe ErrorReason
tagToErrorReason 0 = Just HandshakeFailed
tagToErrorReason 1 = Just CertificateInvalid
tagToErrorReason 2 = Just Timeout
tagToErrorReason 3 = Just UpstreamError
tagToErrorReason _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorReason yields the original.
public export
error_reasonRoundtrip : (x : ErrorReason) -> tagToErrorReason (error_reasonToTag x) = Just x
error_reasonRoundtrip HandshakeFailed = Refl
error_reasonRoundtrip CertificateInvalid = Refl
error_reasonRoundtrip Timeout = Refl
error_reasonRoundtrip UpstreamError = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
server_stateSize : Nat
server_stateSize = 1

||| ServerState sum type for ABI encoding.
public export
data ServerState : Type where
  Idle : ServerState
  Bound : ServerState
  Listening : ServerState
  Processing : ServerState
  Shutdown : ServerState

||| Encode a ServerState to its ABI tag value.
public export
server_stateToTag : ServerState -> Bits8
server_stateToTag Idle = 0
server_stateToTag Bound = 1
server_stateToTag Listening = 2
server_stateToTag Processing = 3
server_stateToTag Shutdown = 4

||| Decode an ABI tag to a ServerState.
public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just Idle
tagToServerState 1 = Just Bound
tagToServerState 2 = Just Listening
tagToServerState 3 = Just Processing
tagToServerState 4 = Just Shutdown
tagToServerState _ = Nothing

||| Roundtrip proof: decoding an encoded ServerState yields the original.
public export
server_stateRoundtrip : (x : ServerState) -> tagToServerState (server_stateToTag x) = Just x
server_stateRoundtrip Idle = Refl
server_stateRoundtrip Bound = Refl
server_stateRoundtrip Listening = Refl
server_stateRoundtrip Processing = Refl
server_stateRoundtrip Shutdown = Refl
