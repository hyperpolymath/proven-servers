-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SocketABI.Foreign: Foreign function declarations for the C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle types (SocketHandle, ListenHandle, AcceptedHandle)
--      that cannot be inspected or forged from Idris2 code -- they exist
--      only as pointers managed by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function socket_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.
--
-- The opaque handle pattern ensures that:
--   - Idris2 code cannot construct a SocketHandle out of thin air
--   - Idris2 code cannot inspect the internal representation
--   - Lifetime management is handled entirely by the Zig allocator
--   - The type checker can still track handles through the program

module SocketABI.Foreign

import Socket.Types
import SocketABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a socket.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via socket_create() and destroyed via
||| socket_close().  The [external] pragma tells Idris2 that this
||| type's representation is managed externally.
export
data SocketHandle : Type where [external]

||| Opaque handle to a listening socket.
||| Created when a socket transitions to Listening state.
||| Can only accept connections; cannot send/recv data directly.
export
data ListenHandle : Type where [external]

||| Opaque handle to an accepted connection.
||| Created by socket_accept(); represents the server side of
||| an accepted client connection.
export
data AcceptedHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's socket_abi_version() function MUST return
||| this exact value.  Callers should compare the returned value against
||| this constant before using any other FFI function.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Layout.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/socket.zig) must export.  Each entry
-- specifies the function name, parameter types, return type, and
-- semantic contract.
--
-- These are DECLARATIONS ONLY -- no %foreign annotations yet, because
-- the Zig shared library is not linked at Idris2 compile time for now.
--
-- +-----------------------------------------------------------------------+
-- | Function              | Signature                                     |
-- +-----------------------+-----------------------------------------------+
-- | socket_abi_version    | () -> Bits32                                  |
-- |                       | Must return abiVersion (currently 1).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_create         | (domain: Bits8, type: Bits8,                  |
-- |                       |  err: Ptr) -> Ptr SocketHandle                |
-- |                       | Creates a new socket in Unbound state.        |
-- |                       | Returns NULL on failure, sets *err.            |
-- +-----------------------+-----------------------------------------------+
-- | socket_bind           | (h: Ptr SocketHandle, addr: Ptr,              |
-- |                       |  port: Bits16, err: Ptr) -> Bits8             |
-- |                       | Transitions: Unbound -> Bound.                |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_listen         | (h: Ptr SocketHandle, backlog: Bits32)        |
-- |                       |  -> Bits8                                     |
-- |                       | Transitions: Bound -> Listening.               |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_accept         | (h: Ptr SocketHandle,                         |
-- |                       |  err: Ptr) -> Ptr AcceptedHandle              |
-- |                       | Requires: Listening state.                     |
-- |                       | Returns NULL on failure, sets *err.            |
-- +-----------------------+-----------------------------------------------+
-- | socket_connect        | (h: Ptr SocketHandle, addr: Ptr,              |
-- |                       |  port: Bits16, err: Ptr) -> Bits8             |
-- |                       | Transitions: Unbound -> Connected.             |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_send           | (h: Ptr SocketHandle, buf: Ptr,               |
-- |                       |  len: Bits32, sent: Ptr Bits32) -> Bits8      |
-- |                       | Requires: Connected state (CanSendRecv).       |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_recv           | (h: Ptr SocketHandle, buf: Ptr,               |
-- |                       |  len: Bits32, received: Ptr Bits32) -> Bits8  |
-- |                       | Requires: Connected state (CanSendRecv).       |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_shutdown       | (h: Ptr SocketHandle, mode: Bits8) -> Bits8   |
-- |                       | Requires: Connected state.                     |
-- |                       | mode is a ShutdownMode tag.                    |
-- |                       | Returns SocketError tag (0 = success).         |
-- +-----------------------+-----------------------------------------------+
-- | socket_close          | (h: Ptr SocketHandle) -> ()                   |
-- |                       | Transitions: any -> Closed.                    |
-- |                       | Frees the handle.  Safe to call with NULL.     |
-- +-----------------------+-----------------------------------------------+
-- | socket_state          | (h: Ptr SocketHandle) -> Bits8                |
-- |                       | Returns the SocketState tag for handle h.      |
-- |                       | Returns Closed (4) if h is NULL.               |
-- +-----------------------+-----------------------------------------------+
