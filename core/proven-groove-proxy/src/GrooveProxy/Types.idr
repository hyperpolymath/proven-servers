-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrooveProxy.Types: Core type definitions for the frame-level proxy.
--
-- These types model the proxy's state machine, address families,
-- splice modes, and connection lifecycle. All types are total.

module GrooveProxy.Types

%default total

---------------------------------------------------------------------------
-- Address family (the two sides of the proxy)
---------------------------------------------------------------------------

||| The address family of a socket endpoint.
||| The proxy translates from IPv4 to IPv6.
public export
data AddrFamily = IPv4 | IPv6

||| The proxy always translates FROM IPv4 TO IPv6. Never the reverse.
||| This type-level constraint prevents misconfiguration.
public export
data ProxyDirection = Translate AddrFamily AddrFamily

||| The only valid proxy direction: IPv4 → IPv6.
public export
ValidDirection : ProxyDirection
ValidDirection = Translate IPv4 IPv6

---------------------------------------------------------------------------
-- Splice mode (zero-copy vs buffered)
---------------------------------------------------------------------------

||| How bytes are transferred between sockets.
public export
data SpliceMode
  = KernelSplice   -- ^ Linux splice(2): zero-copy via kernel pipe buffers
  | UserspaceCopy   -- ^ Fallback: 4KB userspace buffer (macOS, Windows)

||| Maximum userspace buffer size in bytes.
||| This is a provable upper bound on memory usage per connection.
public export
maxBufferSize : Nat
maxBufferSize = 4096

---------------------------------------------------------------------------
-- Proxy state machine
---------------------------------------------------------------------------

||| States of a single proxied connection.
public export
data ProxyState
  = Idle          -- ^ No connection, waiting for IPv4 accept
  | Accepted      -- ^ IPv4 connection accepted, IPv6 not yet connected
  | Connected     -- ^ Both sides connected, ready to splice
  | Splicing      -- ^ Actively transferring bytes
  | Draining      -- ^ One side closed, draining remaining bytes
  | Closed        -- ^ Both sides closed, resources released

||| Valid state transitions for a proxied connection.
||| The type system enforces that connections follow this lifecycle.
public export
data ValidTransition : ProxyState -> ProxyState -> Type where
  AcceptIPv4    : ValidTransition Idle Accepted
  ConnectIPv6   : ValidTransition Accepted Connected
  BeginSplice   : ValidTransition Connected Splicing
  HalfClose     : ValidTransition Splicing Draining
  FullClose     : ValidTransition Draining Closed
  DirectClose   : ValidTransition Accepted Closed  -- IPv6 connect failed
  AbortSplice   : ValidTransition Splicing Closed   -- Error during splice

---------------------------------------------------------------------------
-- Connection handle (linear)
---------------------------------------------------------------------------

||| A proxied connection handle. Linear: must be consumed exactly once.
||| Parameterised by its current state, so the type system tracks the
||| connection lifecycle.
public export
data ProxyConn : ProxyState -> Type where
  MkProxyConn : (ipv4Handle : Bits64)
             -> (ipv6Handle : Bits64)
             -> (spliceMode : SpliceMode)
             -> (bytesForward : Nat)   -- bytes sent IPv4→IPv6
             -> (bytesReverse : Nat)   -- bytes sent IPv6→IPv4
             -> ProxyConn state

---------------------------------------------------------------------------
-- Proxy configuration
---------------------------------------------------------------------------

||| Configuration for the frame proxy.
public export
record ProxyConfig where
  constructor MkProxyConfig
  ipv4BindAddr  : String    -- e.g. "127.0.0.1"
  ipv4Port      : Bits16
  ipv6TargetAddr : String   -- e.g. "::1"
  ipv6Port      : Bits16
  maxConnections : Nat      -- concurrent connection limit
  bufferSize     : Nat      -- userspace buffer size (≤ maxBufferSize)

---------------------------------------------------------------------------
-- Proxy statistics
---------------------------------------------------------------------------

||| Runtime statistics for the proxy.
public export
record ProxyStats where
  constructor MkProxyStats
  totalConnections  : Nat
  activeConnections : Nat
  bytesProxied      : Nat
  failedConnections : Nat
  spliceMode        : SpliceMode
