-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoqABI.Types: C-ABI-compatible numeric representations of Doq types.
--
-- Maps every constructor of the core Doq sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/doq.zig) exactly.
--
-- Types covered:
--   StreamType                (2 constructors, tags 0-1)
--   ErrorCode                 (4 constructors, tags 0-3)
--   SessionState              (5 constructors, tags 0-4)
--   ServerState               (5 constructors, tags 0-4)

module DoqABI.Types

%default total

---------------------------------------------------------------------------
-- StreamType (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
stream_typeSize : Nat
stream_typeSize = 1

||| StreamType sum type for ABI encoding.
public export
data StreamType : Type where
  Unidirectional : StreamType
  Bidirectional : StreamType

||| Encode a StreamType to its ABI tag value.
public export
stream_typeToTag : StreamType -> Bits8
stream_typeToTag Unidirectional = 0
stream_typeToTag Bidirectional = 1

||| Decode an ABI tag to a StreamType.
public export
tagToStreamType : Bits8 -> Maybe StreamType
tagToStreamType 0 = Just Unidirectional
tagToStreamType 1 = Just Bidirectional
tagToStreamType _ = Nothing

||| Roundtrip proof: decoding an encoded StreamType yields the original.
public export
stream_typeRoundtrip : (x : StreamType) -> tagToStreamType (stream_typeToTag x) = Just x
stream_typeRoundtrip Unidirectional = Refl
stream_typeRoundtrip Bidirectional = Refl

---------------------------------------------------------------------------
-- ErrorCode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
error_codeSize : Nat
error_codeSize = 1

||| ErrorCode sum type for ABI encoding.
public export
data ErrorCode : Type where
  NoError : ErrorCode
  InternalError : ErrorCode
  ExcessiveLoad : ErrorCode
  ProtocolError : ErrorCode

||| Encode a ErrorCode to its ABI tag value.
public export
error_codeToTag : ErrorCode -> Bits8
error_codeToTag NoError = 0
error_codeToTag InternalError = 1
error_codeToTag ExcessiveLoad = 2
error_codeToTag ProtocolError = 3

||| Decode an ABI tag to a ErrorCode.
public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just NoError
tagToErrorCode 1 = Just InternalError
tagToErrorCode 2 = Just ExcessiveLoad
tagToErrorCode 3 = Just ProtocolError
tagToErrorCode _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCode yields the original.
public export
error_codeRoundtrip : (x : ErrorCode) -> tagToErrorCode (error_codeToTag x) = Just x
error_codeRoundtrip NoError = Refl
error_codeRoundtrip InternalError = Refl
error_codeRoundtrip ExcessiveLoad = Refl
error_codeRoundtrip ProtocolError = Refl

---------------------------------------------------------------------------
-- SessionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
session_stateSize : Nat
session_stateSize = 1

||| SessionState sum type for ABI encoding.
public export
data SessionState : Type where
  Initial : SessionState
  Handshaking : SessionState
  Ready : SessionState
  Draining : SessionState
  Closed : SessionState

||| Encode a SessionState to its ABI tag value.
public export
session_stateToTag : SessionState -> Bits8
session_stateToTag Initial = 0
session_stateToTag Handshaking = 1
session_stateToTag Ready = 2
session_stateToTag Draining = 3
session_stateToTag Closed = 4

||| Decode an ABI tag to a SessionState.
public export
tagToSessionState : Bits8 -> Maybe SessionState
tagToSessionState 0 = Just Initial
tagToSessionState 1 = Just Handshaking
tagToSessionState 2 = Just Ready
tagToSessionState 3 = Just Draining
tagToSessionState 4 = Just Closed
tagToSessionState _ = Nothing

||| Roundtrip proof: decoding an encoded SessionState yields the original.
public export
session_stateRoundtrip : (x : SessionState) -> tagToSessionState (session_stateToTag x) = Just x
session_stateRoundtrip Initial = Refl
session_stateRoundtrip Handshaking = Refl
session_stateRoundtrip Ready = Refl
session_stateRoundtrip Draining = Refl
session_stateRoundtrip Closed = Refl

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
