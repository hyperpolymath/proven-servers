// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer types for the proven-servers ABI.
//
// Mirrors the Idris2 module LoadbalancerABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Algorithm (tags 0-5)
// ===========================================================================

/// Load balancing algorithms.
type algorithm =
  | @as(0) RoundRobin
  | @as(1) LeastConnections
  | @as(2) IpHash
  | @as(3) Random
  | @as(4) WeightedRoundRobin
  | @as(5) LeastResponseTime

/// Decode from the C-ABI tag value.
let algorithmFromTag = (tag: int): option<algorithm> =>
  switch tag {
  | 0 => Some(RoundRobin)
  | 1 => Some(LeastConnections)
  | 2 => Some(IpHash)
  | 3 => Some(Random)
  | 4 => Some(WeightedRoundRobin)
  | 5 => Some(LeastResponseTime)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let algorithmToTag = (v: algorithm): int =>
  switch v {
  | RoundRobin => 0
  | LeastConnections => 1
  | IpHash => 2
  | Random => 3
  | WeightedRoundRobin => 4
  | LeastResponseTime => 5
  }

// ===========================================================================
// HealthCheckType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type healthCheckType =
  | @as(0) Http
  | @as(1) Tcp
  | @as(2) Grpc
  | @as(3) Script

/// Decode from the C-ABI tag value.
let healthCheckTypeFromTag = (tag: int): option<healthCheckType> =>
  switch tag {
  | 0 => Some(Http)
  | 1 => Some(Tcp)
  | 2 => Some(Grpc)
  | 3 => Some(Script)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let healthCheckTypeToTag = (v: healthCheckType): int =>
  switch v {
  | Http => 0
  | Tcp => 1
  | Grpc => 2
  | Script => 3
  }

// ===========================================================================
// BackendState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type backendState =
  | @as(0) Healthy
  | @as(1) Unhealthy
  | @as(2) Draining
  | @as(3) Disabled

/// Decode from the C-ABI tag value.
let backendStateFromTag = (tag: int): option<backendState> =>
  switch tag {
  | 0 => Some(Healthy)
  | 1 => Some(Unhealthy)
  | 2 => Some(Draining)
  | 3 => Some(Disabled)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let backendStateToTag = (v: backendState): int =>
  switch v {
  | Healthy => 0
  | Unhealthy => 1
  | Draining => 2
  | Disabled => 3
  }

/// Whether this backend can receive new connections.
let backendStateCanReceiveTraffic = (v: backendState): bool =>
  switch v {
  | Healthy => true
  | _ => false
  }

// ===========================================================================
// SessionPersistence (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionPersistence =
  | @as(0) None
  | @as(1) Cookie
  | @as(2) SourceIp
  | @as(3) Header

/// Decode from the C-ABI tag value.
let sessionPersistenceFromTag = (tag: int): option<sessionPersistence> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(Cookie)
  | 2 => Some(SourceIp)
  | 3 => Some(Header)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionPersistenceToTag = (v: sessionPersistence): int =>
  switch v {
  | None => 0
  | Cookie => 1
  | SourceIp => 2
  | Header => 3
  }

// ===========================================================================
// LbProtocol (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type lbProtocol =
  | @as(0) Http
  | @as(1) Https
  | @as(2) Tcp
  | @as(3) Udp
  | @as(4) Grpc

/// Decode from the C-ABI tag value.
let lbProtocolFromTag = (tag: int): option<lbProtocol> =>
  switch tag {
  | 0 => Some(Http)
  | 1 => Some(Https)
  | 2 => Some(Tcp)
  | 3 => Some(Udp)
  | 4 => Some(Grpc)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lbProtocolToTag = (v: lbProtocol): int =>
  switch v {
  | Http => 0
  | Https => 1
  | Tcp => 2
  | Udp => 3
  | Grpc => 4
  }

