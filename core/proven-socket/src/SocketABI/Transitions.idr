-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SocketABI.Transitions: Valid state transition proofs for sockets.
--
-- This module is the heart of the formal verification layer.  It defines:
--
--   1. ValidTransition -- a GADT whose constructors enumerate every legal
--      state transition.  Because only legal transitions have constructors,
--      any function requiring a ValidTransition proof as an argument is
--      *statically guaranteed* to only perform valid transitions.
--
--   2. CanSendRecv -- a proof witness that a socket is in a state where
--      data transfer is permitted (Connected only).
--
--   3. CanBind -- a proof witness that a socket can be bound to an address
--      (Unbound only).
--
--   4. CanListen -- a proof witness that a socket can begin listening
--      (Bound only).
--
--   5. CanAccept -- a proof witness that a socket can accept connections
--      (Listening only).
--
--   6. Impossibility proofs -- functions that prove certain transitions
--      cannot occur.
--
-- The state machine modelled here is:
--
--   Unbound --Bind--> Bound --Listen--> Listening --Accept(new)--> Connected
--      |                                    |                          |
--      +--Connect--> Connected              |                     Send/Recv
--      |                |                   |                          |
--      +--BindFail-->   |                   +--AcceptFail-->           |
--      |            Error <--ConnDropped----+                    Error |
--      +--ConnFail-->   ^                                          ^  |
--                       |   +---SendFail/RecvFail------------------+  |
--                       |                                             |
--                  ErrorClose --> Closed <--- CloseConn/CloseListen ---+
--                                  ^              /CloseBound/CloseUnbound
--
-- Every arrow has exactly one ValidTransition constructor.

module SocketABI.Transitions

import Socket.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition: exhaustive enumeration of legal state transitions.
---------------------------------------------------------------------------

||| Proof witness that a state transition is valid.
||| Only constructors for legal transitions exist -- the type system
||| prevents any transition not listed here.
public export
data ValidTransition : SocketState -> SocketState -> Type where
  ||| Unbound -> Bound (bind to a local address succeeded).
  BindSocket    : ValidTransition Unbound Bound
  ||| Unbound -> Error (bind failed, e.g. address in use).
  BindFail      : ValidTransition Unbound Error
  ||| Bound -> Listening (start listening for connections).
  ListenSocket  : ValidTransition Bound Listening
  ||| Bound -> Error (listen failed).
  ListenFail    : ValidTransition Bound Error
  ||| Unbound -> Connected (client connect succeeded, skipping bind).
  ConnectSocket : ValidTransition Unbound Connected
  ||| Unbound -> Error (client connect failed).
  ConnectFail   : ValidTransition Unbound Error
  ||| Listening -> Connected (accept produced a new connected socket).
  AcceptConn    : ValidTransition Listening Connected
  ||| Listening -> Error (accept failed).
  AcceptFail    : ValidTransition Listening Error
  ||| Connected -> Connected (send or recv succeeded, state unchanged).
  DataOk        : ValidTransition Connected Connected
  ||| Connected -> Error (send or recv failed, connection broken).
  DataFail      : ValidTransition Connected Error
  ||| Connected -> Closed (graceful close from connected state).
  CloseConn     : ValidTransition Connected Closed
  ||| Listening -> Closed (close a listening socket).
  CloseListen   : ValidTransition Listening Closed
  ||| Bound -> Closed (close a bound but not listening socket).
  CloseBound    : ValidTransition Bound Closed
  ||| Unbound -> Closed (close before any operations).
  CloseUnbound  : ValidTransition Unbound Closed
  ||| Error -> Closed (clean up after an error).
  ErrorClose    : ValidTransition Error Closed

||| Show instance for ValidTransition.
public export
Show (ValidTransition from to) where
  show BindSocket    = "BindSocket"
  show BindFail      = "BindFail"
  show ListenSocket  = "ListenSocket"
  show ListenFail    = "ListenFail"
  show ConnectSocket = "ConnectSocket"
  show ConnectFail   = "ConnectFail"
  show AcceptConn    = "AcceptConn"
  show AcceptFail    = "AcceptFail"
  show DataOk        = "DataOk"
  show DataFail      = "DataFail"
  show CloseConn     = "CloseConn"
  show CloseListen   = "CloseListen"
  show CloseBound    = "CloseBound"
  show CloseUnbound  = "CloseUnbound"
  show ErrorClose    = "ErrorClose"

---------------------------------------------------------------------------
-- CanSendRecv: proof that a state permits data transfer.
---------------------------------------------------------------------------

||| Proof witness that data can be sent or received in the given socket state.
||| Only Connected permits data transfer -- there are no constructors for
||| any other state.
public export
data CanSendRecv : SocketState -> Type where
  ||| Data transfer is allowed when the socket is connected to a peer.
  SendRecvConnected : CanSendRecv Connected

---------------------------------------------------------------------------
-- CanBind: proof that a socket can be bound to an address.
---------------------------------------------------------------------------

||| Proof witness that a socket can be bound to a local address.
||| Only Unbound sockets can be bound -- binding an already-bound or
||| connected socket is not permitted.
public export
data CanBind : SocketState -> Type where
  ||| Binding is allowed when the socket is freshly created (unbound).
  BindUnbound : CanBind Unbound

---------------------------------------------------------------------------
-- CanListen: proof that a socket can begin listening.
---------------------------------------------------------------------------

||| Proof witness that a socket can start listening for connections.
||| Only Bound sockets can listen -- you must bind before listening.
public export
data CanListen : SocketState -> Type where
  ||| Listening is allowed when the socket is bound to an address.
  ListenBound : CanListen Bound

---------------------------------------------------------------------------
-- CanAccept: proof that a socket can accept incoming connections.
---------------------------------------------------------------------------

||| Proof witness that a socket can accept incoming connections.
||| Only Listening sockets can accept -- the socket must be bound and
||| listening before accepting.
public export
data CanAccept : SocketState -> Type where
  ||| Accepting is allowed when the socket is listening.
  AcceptListening : CanAccept Listening

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Proof that you cannot send/recv when Unbound.
public export
unboundCantSendRecv : CanSendRecv Unbound -> Void
unboundCantSendRecv x impossible

||| Proof that you cannot send/recv when Bound.
public export
boundCantSendRecv : CanSendRecv Bound -> Void
boundCantSendRecv x impossible

||| Proof that you cannot send/recv when Listening.
public export
listeningCantSendRecv : CanSendRecv Listening -> Void
listeningCantSendRecv x impossible

||| Proof that you cannot send/recv when Closed.
public export
closedCantSendRecv : CanSendRecv Closed -> Void
closedCantSendRecv x impossible

||| Proof that you cannot send/recv when in Error state.
public export
errorCantSendRecv : CanSendRecv Error -> Void
errorCantSendRecv x impossible

||| Proof that you cannot bind when already Bound.
public export
boundCantBind : CanBind Bound -> Void
boundCantBind x impossible

||| Proof that you cannot bind when Connected.
public export
connectedCantBind : CanBind Connected -> Void
connectedCantBind x impossible

||| Proof that you cannot listen when Unbound.
public export
unboundCantListen : CanListen Unbound -> Void
unboundCantListen x impossible

||| Proof that you cannot listen when Connected.
public export
connectedCantListen : CanListen Connected -> Void
connectedCantListen x impossible

||| Proof that you cannot accept when Unbound.
public export
unboundCantAccept : CanAccept Unbound -> Void
unboundCantAccept x impossible

||| Proof that you cannot accept when Connected.
public export
connectedCantAccept : CanAccept Connected -> Void
connectedCantAccept x impossible

||| Proof that you cannot accept when Bound (must be Listening).
public export
boundCantAccept : CanAccept Bound -> Void
boundCantAccept x impossible

---------------------------------------------------------------------------
-- Decidability: runtime decision procedures for capabilities.
---------------------------------------------------------------------------

||| Decide at runtime whether a given state permits data transfer.
public export
canSendRecv : (s : SocketState) -> Dec (CanSendRecv s)
canSendRecv Unbound   = No unboundCantSendRecv
canSendRecv Bound     = No boundCantSendRecv
canSendRecv Listening = No listeningCantSendRecv
canSendRecv Connected = Yes SendRecvConnected
canSendRecv Closed    = No closedCantSendRecv
canSendRecv Error     = No errorCantSendRecv

||| Decide at runtime whether a given state permits binding.
public export
canBind : (s : SocketState) -> Dec (CanBind s)
canBind Unbound   = Yes BindUnbound
canBind Bound     = No boundCantBind
canBind Listening = No (\x => case x of _ impossible)
canBind Connected = No connectedCantBind
canBind Closed    = No (\x => case x of _ impossible)
canBind Error     = No (\x => case x of _ impossible)

||| Decide at runtime whether a given state permits listening.
public export
canListen : (s : SocketState) -> Dec (CanListen s)
canListen Unbound   = No unboundCantListen
canListen Bound     = Yes ListenBound
canListen Listening = No (\x => case x of _ impossible)
canListen Connected = No connectedCantListen
canListen Closed    = No (\x => case x of _ impossible)
canListen Error     = No (\x => case x of _ impossible)

||| Decide at runtime whether a given state permits accepting.
public export
canAccept : (s : SocketState) -> Dec (CanAccept s)
canAccept Unbound   = No unboundCantAccept
canAccept Bound     = No boundCantAccept
canAccept Listening = Yes AcceptListening
canAccept Connected = No connectedCantAccept
canAccept Closed    = No (\x => case x of _ impossible)
canAccept Error     = No (\x => case x of _ impossible)
