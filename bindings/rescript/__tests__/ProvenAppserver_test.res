// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenAppserver protocol bindings.

open ProvenAppserver

let test_requestType_roundtrip = () => {
  assert(requestTypeFromTag(0) == Some(Http))
  assert(requestTypeFromTag(1) == Some(WebSocket))
  assert(requestTypeFromTag(2) == Some(Grpc))
  assert(requestTypeFromTag(3) == Some(GraphQl))
  assert(requestTypeFromTag(4) == None)
}

let test_requestType_toTag = () => {
  assert(requestTypeToTag(Http) == 0)
  assert(requestTypeToTag(WebSocket) == 1)
  assert(requestTypeToTag(Grpc) == 2)
  assert(requestTypeToTag(GraphQl) == 3)
}

let test_lifecycleState_roundtrip = () => {
  assert(lifecycleStateFromTag(0) == Some(Initializing))
  assert(lifecycleStateFromTag(1) == Some(Starting))
  assert(lifecycleStateFromTag(2) == Some(Running))
  assert(lifecycleStateFromTag(3) == Some(Draining))
  assert(lifecycleStateFromTag(4) == Some(Stopping))
  assert(lifecycleStateFromTag(5) == Some(Stopped))
  assert(lifecycleStateFromTag(6) == None)
}

let test_lifecycleState_toTag = () => {
  assert(lifecycleStateToTag(Initializing) == 0)
  assert(lifecycleStateToTag(Starting) == 1)
  assert(lifecycleStateToTag(Running) == 2)
  assert(lifecycleStateToTag(Draining) == 3)
  assert(lifecycleStateToTag(Stopping) == 4)
  assert(lifecycleStateToTag(Stopped) == 5)
}

let test_healthCheck_roundtrip = () => {
  assert(healthCheckFromTag(0) == Some(Liveness))
  assert(healthCheckFromTag(1) == Some(Readiness))
  assert(healthCheckFromTag(2) == Some(Startup))
  assert(healthCheckFromTag(3) == None)
}

let test_healthCheck_toTag = () => {
  assert(healthCheckToTag(Liveness) == 0)
  assert(healthCheckToTag(Readiness) == 1)
  assert(healthCheckToTag(Startup) == 2)
}

let test_deployStrategy_roundtrip = () => {
  assert(deployStrategyFromTag(0) == Some(RollingUpdate))
  assert(deployStrategyFromTag(1) == Some(BlueGreen))
  assert(deployStrategyFromTag(2) == Some(Canary))
  assert(deployStrategyFromTag(3) == Some(Recreate))
  assert(deployStrategyFromTag(4) == None)
}

let test_deployStrategy_toTag = () => {
  assert(deployStrategyToTag(RollingUpdate) == 0)
  assert(deployStrategyToTag(BlueGreen) == 1)
  assert(deployStrategyToTag(Canary) == 2)
  assert(deployStrategyToTag(Recreate) == 3)
}

let test_errorCategory_roundtrip = () => {
  assert(errorCategoryFromTag(0) == Some(ClientError))
  assert(errorCategoryFromTag(1) == Some(ServerError))
  assert(errorCategoryFromTag(2) == Some(Timeout))
  assert(errorCategoryFromTag(3) == Some(CircuitOpen))
  assert(errorCategoryFromTag(4) == Some(RateLimited))
  assert(errorCategoryFromTag(5) == None)
}

let test_errorCategory_toTag = () => {
  assert(errorCategoryToTag(ClientError) == 0)
  assert(errorCategoryToTag(ServerError) == 1)
  assert(errorCategoryToTag(Timeout) == 2)
  assert(errorCategoryToTag(CircuitOpen) == 3)
  assert(errorCategoryToTag(RateLimited) == 4)
}

// Run all tests
test_requestType_roundtrip()
test_requestType_toTag()
test_lifecycleState_roundtrip()
test_lifecycleState_toTag()
test_healthCheck_roundtrip()
test_healthCheck_toTag()
test_deployStrategy_roundtrip()
test_deployStrategy_toTag()
test_errorCategory_roundtrip()
test_errorCategory_toTag()
