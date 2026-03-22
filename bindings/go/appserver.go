// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// App Server protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// RequestType represents the RequestType type (Idris2 ABI tags).
type RequestType uint8

const (
	RequestTypeHttp RequestType = iota
	RequestTypeWebSocket
	RequestTypeGrpc
	RequestTypeGraphQl
)

// LifecycleState represents the LifecycleState type (Idris2 ABI tags).
type LifecycleState uint8

const (
	LifecycleStateInitializing LifecycleState = iota
	LifecycleStateStarting
	LifecycleStateRunning
	LifecycleStateDraining
	LifecycleStateStopping
	LifecycleStateStopped
)

// HealthCheck represents the HealthCheck type (Idris2 ABI tags).
type HealthCheck uint8

const (
	HealthCheckLiveness HealthCheck = iota
	HealthCheckReadiness
	HealthCheckStartup
)

// DeployStrategy represents the DeployStrategy type (Idris2 ABI tags).
type DeployStrategy uint8

const (
	DeployStrategyRollingUpdate DeployStrategy = iota
	DeployStrategyBlueGreen
	DeployStrategyCanary
	DeployStrategyRecreate
)

// ErrorCategory represents the ErrorCategory type (Idris2 ABI tags).
type ErrorCategory uint8

const (
	ErrorCategoryClientError ErrorCategory = iota
	ErrorCategoryServerError
	ErrorCategoryTimeout
	ErrorCategoryCircuitOpen
	ErrorCategoryRateLimited
)
