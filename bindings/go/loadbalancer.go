// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Load Balancer protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Algorithm represents the Algorithm type (Idris2 ABI tags).
type Algorithm uint8

const (
	AlgorithmRoundRobin Algorithm = iota
	AlgorithmLeastConnections
	AlgorithmIpHash
	AlgorithmRandom
	AlgorithmWeightedRoundRobin
	AlgorithmLeastResponseTime
)

// HealthCheckType represents the HealthCheckType type (Idris2 ABI tags).
type HealthCheckType uint8

const (
	HealthCheckTypeHttp HealthCheckType = iota
	HealthCheckTypeTcp
	HealthCheckTypeGrpc
	HealthCheckTypeScript
)

// BackendState represents the BackendState type (Idris2 ABI tags).
type BackendState uint8

const (
	BackendStateHealthy BackendState = iota
	BackendStateUnhealthy
	BackendStateDraining
	BackendStateDisabled
)

// SessionPersistence represents the SessionPersistence type (Idris2 ABI tags).
type SessionPersistence uint8

const (
	SessionPersistenceNone SessionPersistence = iota
	SessionPersistenceCookie
	SessionPersistenceSourceIp
	SessionPersistenceHeader
)

// LbProtocol represents the LbProtocol type (Idris2 ABI tags).
type LbProtocol uint8

const (
	LbProtocolHttp LbProtocol = iota
	LbProtocolHttps
	LbProtocolTcp
	LbProtocolUdp
	LbProtocolGrpc
)
