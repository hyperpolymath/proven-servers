// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenLoadbalancer protocol bindings.

open ProvenLoadbalancer

let test_algorithm_roundtrip = () => {
  assert(algorithmFromTag(0) == Some(RoundRobin))
  assert(algorithmFromTag(1) == Some(LeastConnections))
  assert(algorithmFromTag(2) == Some(IpHash))
  assert(algorithmFromTag(3) == Some(Random))
  assert(algorithmFromTag(4) == Some(WeightedRoundRobin))
  assert(algorithmFromTag(5) == Some(LeastResponseTime))
  assert(algorithmFromTag(6) == None)
}

let test_algorithm_toTag = () => {
  assert(algorithmToTag(RoundRobin) == 0)
  assert(algorithmToTag(LeastConnections) == 1)
  assert(algorithmToTag(IpHash) == 2)
  assert(algorithmToTag(Random) == 3)
  assert(algorithmToTag(WeightedRoundRobin) == 4)
  assert(algorithmToTag(LeastResponseTime) == 5)
}

let test_healthCheckType_roundtrip = () => {
  assert(healthCheckTypeFromTag(0) == Some(Http))
  assert(healthCheckTypeFromTag(1) == Some(Tcp))
  assert(healthCheckTypeFromTag(2) == Some(Grpc))
  assert(healthCheckTypeFromTag(3) == Some(Script))
  assert(healthCheckTypeFromTag(4) == None)
}

let test_healthCheckType_toTag = () => {
  assert(healthCheckTypeToTag(Http) == 0)
  assert(healthCheckTypeToTag(Tcp) == 1)
  assert(healthCheckTypeToTag(Grpc) == 2)
  assert(healthCheckTypeToTag(Script) == 3)
}

let test_backendState_roundtrip = () => {
  assert(backendStateFromTag(0) == Some(Healthy))
  assert(backendStateFromTag(1) == Some(Unhealthy))
  assert(backendStateFromTag(2) == Some(Draining))
  assert(backendStateFromTag(3) == Some(Disabled))
  assert(backendStateFromTag(4) == None)
}

let test_backendState_toTag = () => {
  assert(backendStateToTag(Healthy) == 0)
  assert(backendStateToTag(Unhealthy) == 1)
  assert(backendStateToTag(Draining) == 2)
  assert(backendStateToTag(Disabled) == 3)
}

let test_sessionPersistence_roundtrip = () => {
  assert(sessionPersistenceFromTag(0) == Some(None))
  assert(sessionPersistenceFromTag(1) == Some(Cookie))
  assert(sessionPersistenceFromTag(2) == Some(SourceIp))
  assert(sessionPersistenceFromTag(3) == Some(Header))
  assert(sessionPersistenceFromTag(4) == None)
}

let test_sessionPersistence_toTag = () => {
  assert(sessionPersistenceToTag(None) == 0)
  assert(sessionPersistenceToTag(Cookie) == 1)
  assert(sessionPersistenceToTag(SourceIp) == 2)
  assert(sessionPersistenceToTag(Header) == 3)
}

let test_lbProtocol_roundtrip = () => {
  assert(lbProtocolFromTag(0) == Some(Http))
  assert(lbProtocolFromTag(1) == Some(Https))
  assert(lbProtocolFromTag(2) == Some(Tcp))
  assert(lbProtocolFromTag(3) == Some(Udp))
  assert(lbProtocolFromTag(4) == Some(Grpc))
  assert(lbProtocolFromTag(5) == None)
}

let test_lbProtocol_toTag = () => {
  assert(lbProtocolToTag(Http) == 0)
  assert(lbProtocolToTag(Https) == 1)
  assert(lbProtocolToTag(Tcp) == 2)
  assert(lbProtocolToTag(Udp) == 3)
  assert(lbProtocolToTag(Grpc) == 4)
}

// Run all tests
test_algorithm_roundtrip()
test_algorithm_toTag()
test_healthCheckType_roundtrip()
test_healthCheckType_toTag()
test_backendState_roundtrip()
test_backendState_toTag()
test_sessionPersistence_roundtrip()
test_sessionPersistence_toTag()
test_lbProtocol_roundtrip()
test_lbProtocol_toTag()
