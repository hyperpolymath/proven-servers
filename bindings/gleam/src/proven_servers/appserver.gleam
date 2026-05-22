//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// App Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `AppserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// App Server Constants
// ===========================================================================

/// App Port constant.
pub const app_port = 8080

// ===========================================================================
// RequestType
// ===========================================================================

/// Request protocol types.
/// 
/// Matches `RequestType` in `AppserverABI.Types`.
pub type RequestType {
  /// HTTP (tag 0).
  Http
  /// WebSocket (tag 1).
  WebSocket
  /// gRPC (tag 2).
  Grpc
  /// GraphQL (tag 3).
  GraphQl
}

/// Convert a `RequestType` to its C-ABI tag value.
pub fn request_type_to_int(value: RequestType) -> Int {
  case value {
    Http -> 0
    WebSocket -> 1
    Grpc -> 2
    GraphQl -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn request_type_from_int(tag: Int) -> Result(RequestType, Nil) {
  case tag {
    0 -> Ok(Http)
    1 -> Ok(WebSocket)
    2 -> Ok(Grpc)
    3 -> Ok(GraphQl)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LifecycleState
// ===========================================================================

/// Application lifecycle states.
/// 
/// Matches `LifecycleState` in `AppserverABI.Types`.
pub type LifecycleState {
  /// Initializing (tag 0).
  Initializing
  /// Starting (tag 1).
  Starting
  /// Running (tag 2).
  Running
  /// Draining (tag 3).
  Draining
  /// Stopping (tag 4).
  Stopping
  /// Stopped (tag 5).
  Stopped
}

/// Convert a `LifecycleState` to its C-ABI tag value.
pub fn lifecycle_state_to_int(value: LifecycleState) -> Int {
  case value {
    Initializing -> 0
    Starting -> 1
    Running -> 2
    Draining -> 3
    Stopping -> 4
    Stopped -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn lifecycle_state_from_int(tag: Int) -> Result(LifecycleState, Nil) {
  case tag {
    0 -> Ok(Initializing)
    1 -> Ok(Starting)
    2 -> Ok(Running)
    3 -> Ok(Draining)
    4 -> Ok(Stopping)
    5 -> Ok(Stopped)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HealthCheck
// ===========================================================================

/// Health check types.
/// 
/// Matches `HealthCheck` in `AppserverABI.Types`.
pub type HealthCheck {
  /// Liveness (tag 0).
  Liveness
  /// Readiness (tag 1).
  Readiness
  /// Startup (tag 2).
  Startup
}

/// Convert a `HealthCheck` to its C-ABI tag value.
pub fn health_check_to_int(value: HealthCheck) -> Int {
  case value {
    Liveness -> 0
    Readiness -> 1
    Startup -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn health_check_from_int(tag: Int) -> Result(HealthCheck, Nil) {
  case tag {
    0 -> Ok(Liveness)
    1 -> Ok(Readiness)
    2 -> Ok(Startup)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DeployStrategy
// ===========================================================================

/// Deployment strategies.
/// 
/// Matches `DeployStrategy` in `AppserverABI.Types`.
pub type DeployStrategy {
  /// RollingUpdate (tag 0).
  RollingUpdate
  /// BlueGreen (tag 1).
  BlueGreen
  /// Canary (tag 2).
  Canary
  /// Recreate (tag 3).
  Recreate
}

/// Convert a `DeployStrategy` to its C-ABI tag value.
pub fn deploy_strategy_to_int(value: DeployStrategy) -> Int {
  case value {
    RollingUpdate -> 0
    BlueGreen -> 1
    Canary -> 2
    Recreate -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn deploy_strategy_from_int(tag: Int) -> Result(DeployStrategy, Nil) {
  case tag {
    0 -> Ok(RollingUpdate)
    1 -> Ok(BlueGreen)
    2 -> Ok(Canary)
    3 -> Ok(Recreate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCategory
// ===========================================================================

/// Application error categories.
/// 
/// Matches `ErrorCategory` in `AppserverABI.Types`.
pub type ErrorCategory {
  /// ClientError (tag 0).
  ClientError
  /// ServerError (tag 1).
  ServerError
  /// Timeout (tag 2).
  Timeout
  /// CircuitOpen (tag 3).
  CircuitOpen
  /// RateLimited (tag 4).
  RateLimited
}

/// Convert a `ErrorCategory` to its C-ABI tag value.
pub fn error_category_to_int(value: ErrorCategory) -> Int {
  case value {
    ClientError -> 0
    ServerError -> 1
    Timeout -> 2
    CircuitOpen -> 3
    RateLimited -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn error_category_from_int(tag: Int) -> Result(ErrorCategory, Nil) {
  case tag {
    0 -> Ok(ClientError)
    1 -> Ok(ServerError)
    2 -> Ok(Timeout)
    3 -> Ok(CircuitOpen)
    4 -> Ok(RateLimited)
    _ -> Error(Nil)
  }
}

