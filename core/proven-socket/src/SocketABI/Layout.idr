-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SocketABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the six core sum types (SocketDomain, SocketType,
-- SocketState, SocketOp, ShutdownMode, SocketError) to a fixed Bits8 value
-- for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/socket.h) and the
-- Zig FFI enums (ffi/zig/src/socket.zig) exactly.

module SocketABI.Layout

import Socket.Types

%default total

---------------------------------------------------------------------------
-- SocketDomain (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for SocketDomain (1 byte).
public export
socketDomainSize : Nat
socketDomainSize = 1

||| Map SocketDomain to its C-ABI byte value.
|||
||| Tag assignments:
|||   IPv4 = 0
|||   IPv6 = 1
|||   Unix = 2
public export
socketDomainToTag : SocketDomain -> Bits8
socketDomainToTag IPv4 = 0
socketDomainToTag IPv6 = 1
socketDomainToTag Unix = 2

||| Recover SocketDomain from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToSocketDomain : Bits8 -> Maybe SocketDomain
tagToSocketDomain 0 = Just IPv4
tagToSocketDomain 1 = Just IPv6
tagToSocketDomain 2 = Just Unix
tagToSocketDomain _ = Nothing

||| Proof: encoding then decoding SocketDomain is the identity.
public export
socketDomainRoundtrip : (d : SocketDomain) -> tagToSocketDomain (socketDomainToTag d) = Just d
socketDomainRoundtrip IPv4 = Refl
socketDomainRoundtrip IPv6 = Refl
socketDomainRoundtrip Unix = Refl

---------------------------------------------------------------------------
-- SocketType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for SocketType (1 byte).
public export
socketTypeSize : Nat
socketTypeSize = 1

||| Map SocketType to its C-ABI byte value.
|||
||| Tag assignments:
|||   Stream    = 0
|||   Datagram  = 1
|||   SeqPacket = 2
|||   Raw       = 3
public export
socketTypeToTag : SocketType -> Bits8
socketTypeToTag Stream    = 0
socketTypeToTag Datagram  = 1
socketTypeToTag SeqPacket = 2
socketTypeToTag Raw       = 3

||| Recover SocketType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-3.
public export
tagToSocketType : Bits8 -> Maybe SocketType
tagToSocketType 0 = Just Stream
tagToSocketType 1 = Just Datagram
tagToSocketType 2 = Just SeqPacket
tagToSocketType 3 = Just Raw
tagToSocketType _ = Nothing

||| Proof: encoding then decoding SocketType is the identity.
public export
socketTypeRoundtrip : (t : SocketType) -> tagToSocketType (socketTypeToTag t) = Just t
socketTypeRoundtrip Stream    = Refl
socketTypeRoundtrip Datagram  = Refl
socketTypeRoundtrip SeqPacket = Refl
socketTypeRoundtrip Raw       = Refl

---------------------------------------------------------------------------
-- SocketState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for SocketState (1 byte).
public export
socketStateSize : Nat
socketStateSize = 1

||| Map SocketState to its C-ABI byte value.
|||
||| Tag assignments:
|||   Unbound   = 0
|||   Bound     = 1
|||   Listening = 2
|||   Connected = 3
|||   Closed    = 4
|||   Error     = 5
public export
socketStateToTag : SocketState -> Bits8
socketStateToTag Unbound   = 0
socketStateToTag Bound     = 1
socketStateToTag Listening = 2
socketStateToTag Connected = 3
socketStateToTag Closed    = 4
socketStateToTag Error     = 5

||| Recover SocketState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToSocketState : Bits8 -> Maybe SocketState
tagToSocketState 0 = Just Unbound
tagToSocketState 1 = Just Bound
tagToSocketState 2 = Just Listening
tagToSocketState 3 = Just Connected
tagToSocketState 4 = Just Closed
tagToSocketState 5 = Just Error
tagToSocketState _ = Nothing

||| Proof: encoding then decoding SocketState is the identity.
public export
socketStateRoundtrip : (s : SocketState) -> tagToSocketState (socketStateToTag s) = Just s
socketStateRoundtrip Unbound   = Refl
socketStateRoundtrip Bound     = Refl
socketStateRoundtrip Listening = Refl
socketStateRoundtrip Connected = Refl
socketStateRoundtrip Closed    = Refl
socketStateRoundtrip Error     = Refl

---------------------------------------------------------------------------
-- SocketOp (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for SocketOp (1 byte).
public export
socketOpSize : Nat
socketOpSize = 1

||| Map SocketOp to its C-ABI byte value.
|||
||| Tag assignments:
|||   Bind     = 0
|||   Listen   = 1
|||   Accept   = 2
|||   Connect  = 3
|||   Send     = 4
|||   Recv     = 5
|||   Close    = 6
|||   Shutdown = 7
public export
socketOpToTag : SocketOp -> Bits8
socketOpToTag Bind     = 0
socketOpToTag Listen   = 1
socketOpToTag Accept   = 2
socketOpToTag Connect  = 3
socketOpToTag Send     = 4
socketOpToTag Recv     = 5
socketOpToTag Close    = 6
socketOpToTag Shutdown = 7

||| Recover SocketOp from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-7.
public export
tagToSocketOp : Bits8 -> Maybe SocketOp
tagToSocketOp 0 = Just Bind
tagToSocketOp 1 = Just Listen
tagToSocketOp 2 = Just Accept
tagToSocketOp 3 = Just Connect
tagToSocketOp 4 = Just Send
tagToSocketOp 5 = Just Recv
tagToSocketOp 6 = Just Close
tagToSocketOp 7 = Just Shutdown
tagToSocketOp _ = Nothing

||| Proof: encoding then decoding SocketOp is the identity.
public export
socketOpRoundtrip : (op : SocketOp) -> tagToSocketOp (socketOpToTag op) = Just op
socketOpRoundtrip Bind     = Refl
socketOpRoundtrip Listen   = Refl
socketOpRoundtrip Accept   = Refl
socketOpRoundtrip Connect  = Refl
socketOpRoundtrip Send     = Refl
socketOpRoundtrip Recv     = Refl
socketOpRoundtrip Close    = Refl
socketOpRoundtrip Shutdown = Refl

---------------------------------------------------------------------------
-- ShutdownMode (3 constructors, tags 0-2)
---------------------------------------------------------------------------

||| C-ABI representation size for ShutdownMode (1 byte).
public export
shutdownModeSize : Nat
shutdownModeSize = 1

||| Map ShutdownMode to its C-ABI byte value.
|||
||| Tag assignments:
|||   Read  = 0
|||   Write = 1
|||   Both  = 2
public export
shutdownModeToTag : ShutdownMode -> Bits8
shutdownModeToTag Read  = 0
shutdownModeToTag Write = 1
shutdownModeToTag Both  = 2

||| Recover ShutdownMode from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-2.
public export
tagToShutdownMode : Bits8 -> Maybe ShutdownMode
tagToShutdownMode 0 = Just Read
tagToShutdownMode 1 = Just Write
tagToShutdownMode 2 = Just Both
tagToShutdownMode _ = Nothing

||| Proof: encoding then decoding ShutdownMode is the identity.
public export
shutdownModeRoundtrip : (m : ShutdownMode) -> tagToShutdownMode (shutdownModeToTag m) = Just m
shutdownModeRoundtrip Read  = Refl
shutdownModeRoundtrip Write = Refl
shutdownModeRoundtrip Both  = Refl

---------------------------------------------------------------------------
-- SocketError (10 constructors, tags 1-10; 0 = no error)
---------------------------------------------------------------------------

||| C-ABI representation size for SocketError (1 byte).
||| Note: tag 0 is reserved for "no error" in the C header (SOCKET_ERR_NONE).
||| The Idris2 type has no "None" constructor -- the absence of an error
||| is represented by the absence of a SocketError value.
public export
socketErrorSize : Nat
socketErrorSize = 1

||| Map SocketError to its C-ABI byte value.
|||
||| Tag assignments (tag 0 reserved for SOCKET_ERR_NONE):
|||   AddressInUse       = 1
|||   ConnectionRefused  = 2
|||   ConnectionReset    = 3
|||   TimedOut           = 4
|||   HostUnreachable    = 5
|||   NetworkUnreachable = 6
|||   PermissionDenied   = 7
|||   InvalidAddress     = 8
|||   AlreadyConnected   = 9
|||   NotConnected       = 10
public export
socketErrorToTag : SocketError -> Bits8
socketErrorToTag AddressInUse       = 1
socketErrorToTag ConnectionRefused  = 2
socketErrorToTag ConnectionReset    = 3
socketErrorToTag TimedOut           = 4
socketErrorToTag HostUnreachable    = 5
socketErrorToTag NetworkUnreachable = 6
socketErrorToTag PermissionDenied   = 7
socketErrorToTag InvalidAddress     = 8
socketErrorToTag AlreadyConnected   = 9
socketErrorToTag NotConnected       = 10

||| Recover SocketError from its C-ABI byte value.
||| Returns Nothing for tag 0 (no error) and for values > 10.
public export
tagToSocketError : Bits8 -> Maybe SocketError
tagToSocketError 1  = Just AddressInUse
tagToSocketError 2  = Just ConnectionRefused
tagToSocketError 3  = Just ConnectionReset
tagToSocketError 4  = Just TimedOut
tagToSocketError 5  = Just HostUnreachable
tagToSocketError 6  = Just NetworkUnreachable
tagToSocketError 7  = Just PermissionDenied
tagToSocketError 8  = Just InvalidAddress
tagToSocketError 9  = Just AlreadyConnected
tagToSocketError 10 = Just NotConnected
tagToSocketError _  = Nothing

||| Proof: encoding then decoding SocketError is the identity.
public export
socketErrorRoundtrip : (e : SocketError) -> tagToSocketError (socketErrorToTag e) = Just e
socketErrorRoundtrip AddressInUse       = Refl
socketErrorRoundtrip ConnectionRefused  = Refl
socketErrorRoundtrip ConnectionReset    = Refl
socketErrorRoundtrip TimedOut           = Refl
socketErrorRoundtrip HostUnreachable    = Refl
socketErrorRoundtrip NetworkUnreachable = Refl
socketErrorRoundtrip PermissionDenied   = Refl
socketErrorRoundtrip InvalidAddress     = Refl
socketErrorRoundtrip AlreadyConnected   = Refl
socketErrorRoundtrip NotConnected       = Refl
