//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Load Balancer protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `LoadbalancerABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Algorithm
// ===========================================================================

/// Load balancing algorithms.
/// 
/// Matches `Algorithm` in `LoadbalancerABI.Types`.
pub type Algorithm {
  /// RoundRobin (tag 0).
  RoundRobin
  /// LeastConnections (tag 1).
  LeastConnections
  /// IpHash (tag 2).
  IpHash
  /// Random (tag 3).
  Random
  /// WeightedRoundRobin (tag 4).
  WeightedRoundRobin
  /// LeastResponseTime (tag 5).
  LeastResponseTime
}

/// Convert a `Algorithm` to its C-ABI tag value.
pub fn algorithm_to_int(value: Algorithm) -> Int {
  case value {
    RoundRobin -> 0
    LeastConnections -> 1
    IpHash -> 2
    Random -> 3
    WeightedRoundRobin -> 4
    LeastResponseTime -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn algorithm_from_int(tag: Int) -> Result(Algorithm, Nil) {
  case tag {
    0 -> Ok(RoundRobin)
    1 -> Ok(LeastConnections)
    2 -> Ok(IpHash)
    3 -> Ok(Random)
    4 -> Ok(WeightedRoundRobin)
    5 -> Ok(LeastResponseTime)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HealthCheckType
// ===========================================================================

/// Backend health check types.
/// 
/// Matches `HealthCheckType` in `LoadbalancerABI.Types`.
pub type HealthCheckType {
  /// HTTP health check (tag 0).
  HealthCheckTypeHttp
  /// TCP health check (tag 1).
  HealthCheckTypeTcp
  /// gRPC health check (tag 2).
  HealthCheckTypeGrpc
  /// Script (tag 3).
  Script
}

/// Convert a `HealthCheckType` to its C-ABI tag value.
pub fn health_check_type_to_int(value: HealthCheckType) -> Int {
  case value {
    HealthCheckTypeHttp -> 0
    HealthCheckTypeTcp -> 1
    HealthCheckTypeGrpc -> 2
    Script -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn health_check_type_from_int(tag: Int) -> Result(HealthCheckType, Nil) {
  case tag {
    0 -> Ok(HealthCheckTypeHttp)
    1 -> Ok(HealthCheckTypeTcp)
    2 -> Ok(HealthCheckTypeGrpc)
    3 -> Ok(Script)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// BackendState
// ===========================================================================

/// Backend server states.
/// 
/// Matches `BackendState` in `LoadbalancerABI.Types`.
pub type BackendState {
  /// Healthy (tag 0).
  Healthy
  /// Unhealthy (tag 1).
  Unhealthy
  /// Draining (tag 2).
  Draining
  /// Disabled (tag 3).
  Disabled
}

/// Convert a `BackendState` to its C-ABI tag value.
pub fn backend_state_to_int(value: BackendState) -> Int {
  case value {
    Healthy -> 0
    Unhealthy -> 1
    Draining -> 2
    Disabled -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn backend_state_from_int(tag: Int) -> Result(BackendState, Nil) {
  case tag {
    0 -> Ok(Healthy)
    1 -> Ok(Unhealthy)
    2 -> Ok(Draining)
    3 -> Ok(Disabled)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionPersistence
// ===========================================================================

/// Session persistence strategies.
/// 
/// Matches `SessionPersistence` in `LoadbalancerABI.Types`.
pub type SessionPersistence {
  /// None (tag 0).
  SessionPersistenceNone
  /// Cookie (tag 1).
  Cookie
  /// Source IP affinity (tag 2).
  SourceIp
  /// Header (tag 3).
  Header
}

/// Convert a `SessionPersistence` to its C-ABI tag value.
pub fn session_persistence_to_int(value: SessionPersistence) -> Int {
  case value {
    SessionPersistenceNone -> 0
    Cookie -> 1
    SourceIp -> 2
    Header -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn session_persistence_from_int(tag: Int) -> Result(SessionPersistence, Nil) {
  case tag {
    0 -> Ok(SessionPersistenceNone)
    1 -> Ok(Cookie)
    2 -> Ok(SourceIp)
    3 -> Ok(Header)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LbProtocol
// ===========================================================================

/// Load balancer protocols.
/// 
/// Matches `LbProtocol` in `LoadbalancerABI.Types`.
pub type LbProtocol {
  /// HTTP (tag 0).
  LbProtocolHttp
  /// HTTPS (tag 1).
  Https
  /// TCP (tag 2).
  LbProtocolTcp
  /// UDP (tag 3).
  Udp
  /// gRPC (tag 4).
  LbProtocolGrpc
}

/// Convert a `LbProtocol` to its C-ABI tag value.
pub fn lb_protocol_to_int(value: LbProtocol) -> Int {
  case value {
    LbProtocolHttp -> 0
    Https -> 1
    LbProtocolTcp -> 2
    Udp -> 3
    LbProtocolGrpc -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn lb_protocol_from_int(tag: Int) -> Result(LbProtocol, Nil) {
  case tag {
    0 -> Ok(LbProtocolHttp)
    1 -> Ok(Https)
    2 -> Ok(LbProtocolTcp)
    3 -> Ok(Udp)
    4 -> Ok(LbProtocolGrpc)
    _ -> Error(Nil)
  }
}

