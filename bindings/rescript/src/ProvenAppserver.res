// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Application Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module AppserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard application server port.
let appPort = 8080

// ===========================================================================
// RequestType (tags 0-3)
// ===========================================================================

/// Standard application server port.
type requestType =
  | @as(0) Http
  | @as(1) WebSocket
  | @as(2) Grpc
  | @as(3) GraphQl

/// Decode from the C-ABI tag value.
let requestTypeFromTag = (tag: int): option<requestType> =>
  switch tag {
  | 0 => Some(Http)
  | 1 => Some(WebSocket)
  | 2 => Some(Grpc)
  | 3 => Some(GraphQl)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let requestTypeToTag = (v: requestType): int =>
  switch v {
  | Http => 0
  | WebSocket => 1
  | Grpc => 2
  | GraphQl => 3
  }

// ===========================================================================
// LifecycleState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type lifecycleState =
  | @as(0) Initializing
  | @as(1) Starting
  | @as(2) Running
  | @as(3) Draining
  | @as(4) Stopping
  | @as(5) Stopped

/// Decode from the C-ABI tag value.
let lifecycleStateFromTag = (tag: int): option<lifecycleState> =>
  switch tag {
  | 0 => Some(Initializing)
  | 1 => Some(Starting)
  | 2 => Some(Running)
  | 3 => Some(Draining)
  | 4 => Some(Stopping)
  | 5 => Some(Stopped)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lifecycleStateToTag = (v: lifecycleState): int =>
  switch v {
  | Initializing => 0
  | Starting => 1
  | Running => 2
  | Draining => 3
  | Stopping => 4
  | Stopped => 5
  }

/// Whether the server is ready to handle requests.
let lifecycleStateIsReady = (v: lifecycleState): bool =>
  switch v {
  | Running => true
  | _ => false
  }

// ===========================================================================
// HealthCheck (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type healthCheck =
  | @as(0) Liveness
  | @as(1) Readiness
  | @as(2) Startup

/// Decode from the C-ABI tag value.
let healthCheckFromTag = (tag: int): option<healthCheck> =>
  switch tag {
  | 0 => Some(Liveness)
  | 1 => Some(Readiness)
  | 2 => Some(Startup)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let healthCheckToTag = (v: healthCheck): int =>
  switch v {
  | Liveness => 0
  | Readiness => 1
  | Startup => 2
  }

// ===========================================================================
// DeployStrategy (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type deployStrategy =
  | @as(0) RollingUpdate
  | @as(1) BlueGreen
  | @as(2) Canary
  | @as(3) Recreate

/// Decode from the C-ABI tag value.
let deployStrategyFromTag = (tag: int): option<deployStrategy> =>
  switch tag {
  | 0 => Some(RollingUpdate)
  | 1 => Some(BlueGreen)
  | 2 => Some(Canary)
  | 3 => Some(Recreate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let deployStrategyToTag = (v: deployStrategy): int =>
  switch v {
  | RollingUpdate => 0
  | BlueGreen => 1
  | Canary => 2
  | Recreate => 3
  }

// ===========================================================================
// ErrorCategory (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCategory =
  | @as(0) ClientError
  | @as(1) ServerError
  | @as(2) Timeout
  | @as(3) CircuitOpen
  | @as(4) RateLimited

/// Decode from the C-ABI tag value.
let errorCategoryFromTag = (tag: int): option<errorCategory> =>
  switch tag {
  | 0 => Some(ClientError)
  | 1 => Some(ServerError)
  | 2 => Some(Timeout)
  | 3 => Some(CircuitOpen)
  | 4 => Some(RateLimited)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCategoryToTag = (v: errorCategory): int =>
  switch v {
  | ClientError => 0
  | ServerError => 1
  | Timeout => 2
  | CircuitOpen => 3
  | RateLimited => 4
  }

