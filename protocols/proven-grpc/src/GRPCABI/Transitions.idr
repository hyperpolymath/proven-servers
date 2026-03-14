-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GRPCABI.Transitions: Valid HTTP/2 stream state transitions for gRPC.
--
-- Models the HTTP/2 stream lifecycle (RFC 7540 section 5.1):
--
--   Idle --HEADERS--> Open --END_STREAM(local)--> HalfClosedLocal --> Closed
--                      |  --END_STREAM(remote)--> HalfClosedRemote --> Closed
--                      |  --RST_STREAM--> Closed
--   Idle --PUSH_PROMISE--> Reserved --HEADERS--> HalfClosedRemote
--   Reserved --RST_STREAM--> Closed
--
-- The key invariant: once Closed, no transition is possible.
-- Streams must follow the RFC 7540 state machine exactly.
--
-- Also models:
--   - Flow control capability witnesses (who can send DATA)
--   - Impossibility proofs (cannot leave Closed, cannot skip states)

module GRPCABI.Transitions

import GRPCABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidStreamTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that an HTTP/2 stream state transition is valid.
||| Mirrors RFC 7540 section 5.1 stream state machine.
public export
data ValidStreamTransition : StreamState -> StreamState -> Type where
  ||| Idle -> Open (sending or receiving HEADERS).
  SendHeaders       : ValidStreamTransition Idle Open
  ||| Open -> HalfClosedLocal (local side sends END_STREAM).
  LocalEndStream    : ValidStreamTransition Open HalfClosedLocal
  ||| Open -> HalfClosedRemote (remote side sends END_STREAM).
  RemoteEndStream   : ValidStreamTransition Open HalfClosedRemote
  ||| Open -> Closed (RST_STREAM from either side).
  ResetFromOpen     : ValidStreamTransition Open Closed
  ||| HalfClosedLocal -> Closed (remote sends END_STREAM or RST_STREAM).
  CloseHalfLocal    : ValidStreamTransition HalfClosedLocal Closed
  ||| HalfClosedRemote -> Closed (local sends END_STREAM or RST_STREAM).
  CloseHalfRemote   : ValidStreamTransition HalfClosedRemote Closed
  ||| Idle -> Reserved (received PUSH_PROMISE).
  PushPromiseRecv   : ValidStreamTransition Idle Reserved
  ||| Reserved -> HalfClosedRemote (server sends HEADERS to open push).
  ReservedToHalf    : ValidStreamTransition Reserved HalfClosedRemote
  ||| Reserved -> Closed (RST_STREAM cancels push).
  ReservedReset     : ValidStreamTransition Reserved Closed

---------------------------------------------------------------------------
-- Capability witnesses: who can send DATA frames
---------------------------------------------------------------------------

||| Proof that a stream can send DATA frames (local direction).
||| Only Open and HalfClosedRemote allow local DATA sends.
public export
data CanSendData : StreamState -> Type where
  ||| Open streams can send DATA in both directions.
  OpenCanSend       : CanSendData Open
  ||| HalfClosedRemote means local side can still send.
  HalfRemoteCanSend : CanSendData HalfClosedRemote

||| Proof that a stream can receive DATA frames (remote direction).
||| Only Open and HalfClosedLocal allow remote DATA receives.
public export
data CanReceiveData : StreamState -> Type where
  ||| Open streams can receive DATA in both directions.
  OpenCanReceive       : CanReceiveData Open
  ||| HalfClosedLocal means remote side can still send to us.
  HalfLocalCanReceive  : CanReceiveData HalfClosedLocal

||| Proof that a stream can adjust its flow control window.
||| WINDOW_UPDATE is valid on Open and half-closed streams (RFC 7540 6.9).
public export
data CanUpdateWindow : StreamState -> Type where
  ||| Open streams support window updates.
  OpenCanUpdate       : CanUpdateWindow Open
  ||| HalfClosedLocal — still receiving, so window updates matter.
  HalfLocalCanUpdate  : CanUpdateWindow HalfClosedLocal
  ||| HalfClosedRemote — still sending, so window updates matter.
  HalfRemoteCanUpdate : CanUpdateWindow HalfClosedRemote

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Closed state — it is terminal.
public export
closedIsTerminal : ValidStreamTransition Closed s -> Void
closedIsTerminal _ impossible

||| Cannot skip from Idle directly to HalfClosedLocal.
||| Must go through Open first.
public export
cannotSkipToHalfClosed : ValidStreamTransition Idle HalfClosedLocal -> Void
cannotSkipToHalfClosed _ impossible

||| Cannot go backwards from HalfClosedLocal to Open.
public export
cannotReopenHalfClosed : ValidStreamTransition HalfClosedLocal Open -> Void
cannotReopenHalfClosed _ impossible

||| Cannot send DATA from Idle state.
public export
cannotSendFromIdle : CanSendData Idle -> Void
cannotSendFromIdle _ impossible

||| Cannot send DATA from Closed state.
public export
cannotSendFromClosed : CanSendData Closed -> Void
cannotSendFromClosed _ impossible

||| Cannot send DATA from HalfClosedLocal (local already sent END_STREAM).
public export
cannotSendFromHalfLocal : CanSendData HalfClosedLocal -> Void
cannotSendFromHalfLocal _ impossible

||| Cannot receive DATA on Closed state.
public export
cannotReceiveFromClosed : CanReceiveData Closed -> Void
cannotReceiveFromClosed _ impossible

||| Cannot receive DATA on HalfClosedRemote (remote already sent END_STREAM).
public export
cannotReceiveFromHalfRemote : CanReceiveData HalfClosedRemote -> Void
cannotReceiveFromHalfRemote _ impossible

||| Cannot reopen a Reserved stream directly to Open — must go HalfClosedRemote.
public export
cannotReservedToOpen : ValidStreamTransition Reserved Open -> Void
cannotReservedToOpen _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether an HTTP/2 stream state transition is valid.
public export
validateStreamTransition : (from : StreamState) -> (to : StreamState)
                        -> Maybe (ValidStreamTransition from to)
validateStreamTransition Idle             Open             = Just SendHeaders
validateStreamTransition Open             HalfClosedLocal  = Just LocalEndStream
validateStreamTransition Open             HalfClosedRemote = Just RemoteEndStream
validateStreamTransition Open             Closed           = Just ResetFromOpen
validateStreamTransition HalfClosedLocal  Closed           = Just CloseHalfLocal
validateStreamTransition HalfClosedRemote Closed           = Just CloseHalfRemote
validateStreamTransition Idle             Reserved         = Just PushPromiseRecv
validateStreamTransition Reserved         HalfClosedRemote = Just ReservedToHalf
validateStreamTransition Reserved         Closed           = Just ReservedReset
validateStreamTransition _ _                               = Nothing
