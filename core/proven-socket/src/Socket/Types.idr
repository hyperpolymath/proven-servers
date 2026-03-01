-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Socket.Types: Core type definitions for typed socket operations.
-- Closed sum types representing socket domains, types, states, operations,
-- shutdown modes, and error conditions.

module Socket.Types

%default total

---------------------------------------------------------------------------
-- Socket domain — the address family a socket belongs to.
---------------------------------------------------------------------------

||| The address family / domain for a socket.
public export
data SocketDomain : Type where
  ||| Internet Protocol version 4.
  IPv4 : SocketDomain
  ||| Internet Protocol version 6.
  IPv6 : SocketDomain
  ||| Unix domain socket (local IPC).
  Unix : SocketDomain

public export
Show SocketDomain where
  show IPv4 = "IPv4"
  show IPv6 = "IPv6"
  show Unix = "Unix"

---------------------------------------------------------------------------
-- Socket type — the communication semantics.
---------------------------------------------------------------------------

||| The type of socket, determining communication semantics.
public export
data SocketType : Type where
  ||| Reliable, ordered, connection-based byte stream (TCP).
  Stream    : SocketType
  ||| Unreliable, unordered datagrams (UDP).
  Datagram  : SocketType
  ||| Reliable, ordered, connection-based datagrams.
  SeqPacket : SocketType
  ||| Raw network protocol access.
  Raw       : SocketType

public export
Show SocketType where
  show Stream    = "Stream"
  show Datagram  = "Datagram"
  show SeqPacket = "SeqPacket"
  show Raw       = "Raw"

---------------------------------------------------------------------------
-- Socket state — lifecycle states a socket transitions through.
---------------------------------------------------------------------------

||| The lifecycle state of a socket.
public export
data SocketState : Type where
  ||| Freshly created, not yet bound to an address.
  Unbound   : SocketState
  ||| Bound to a local address.
  Bound     : SocketState
  ||| Listening for incoming connections.
  Listening : SocketState
  ||| Connected to a remote peer.
  Connected : SocketState
  ||| Socket has been closed.
  Closed    : SocketState
  ||| Socket is in an error state.
  Error     : SocketState

public export
Show SocketState where
  show Unbound   = "Unbound"
  show Bound     = "Bound"
  show Listening = "Listening"
  show Connected = "Connected"
  show Closed    = "Closed"
  show Error     = "Error"

---------------------------------------------------------------------------
-- Socket operation — the actions that can be performed on a socket.
---------------------------------------------------------------------------

||| An operation that can be performed on a socket.
public export
data SocketOp : Type where
  ||| Bind the socket to a local address.
  Bind     : SocketOp
  ||| Start listening for incoming connections.
  Listen   : SocketOp
  ||| Accept an incoming connection.
  Accept   : SocketOp
  ||| Connect to a remote address.
  Connect  : SocketOp
  ||| Send data on the socket.
  Send     : SocketOp
  ||| Receive data from the socket.
  Recv     : SocketOp
  ||| Close the socket.
  Close    : SocketOp
  ||| Shut down part of the connection.
  Shutdown : SocketOp

public export
Show SocketOp where
  show Bind     = "Bind"
  show Listen   = "Listen"
  show Accept   = "Accept"
  show Connect  = "Connect"
  show Send     = "Send"
  show Recv     = "Recv"
  show Close    = "Close"
  show Shutdown = "Shutdown"

---------------------------------------------------------------------------
-- Shutdown mode — which half of the connection to shut down.
---------------------------------------------------------------------------

||| Which direction(s) of a socket connection to shut down.
public export
data ShutdownMode : Type where
  ||| Shut down the read half.
  Read  : ShutdownMode
  ||| Shut down the write half.
  Write : ShutdownMode
  ||| Shut down both halves.
  Both  : ShutdownMode

public export
Show ShutdownMode where
  show Read  = "Read"
  show Write = "Write"
  show Both  = "Both"

---------------------------------------------------------------------------
-- Socket error — error conditions that can arise from socket operations.
---------------------------------------------------------------------------

||| Error conditions that can arise from socket operations.
public export
data SocketError : Type where
  ||| The requested address is already in use.
  AddressInUse      : SocketError
  ||| The connection was refused by the remote host.
  ConnectionRefused : SocketError
  ||| The connection was reset by the remote host.
  ConnectionReset   : SocketError
  ||| The operation timed out.
  TimedOut          : SocketError
  ||| The remote host is unreachable.
  HostUnreachable   : SocketError
  ||| The network is unreachable.
  NetworkUnreachable : SocketError
  ||| Insufficient permissions for the operation.
  PermissionDenied  : SocketError
  ||| The address is invalid or malformed.
  InvalidAddress    : SocketError
  ||| The socket is already connected.
  AlreadyConnected  : SocketError
  ||| The socket is not connected.
  NotConnected      : SocketError

public export
Show SocketError where
  show AddressInUse       = "AddressInUse"
  show ConnectionRefused  = "ConnectionRefused"
  show ConnectionReset    = "ConnectionReset"
  show TimedOut           = "TimedOut"
  show HostUnreachable    = "HostUnreachable"
  show NetworkUnreachable = "NetworkUnreachable"
  show PermissionDenied   = "PermissionDenied"
  show InvalidAddress     = "InvalidAddress"
  show AlreadyConnected   = "AlreadyConnected"
  show NotConnected       = "NotConnected"
