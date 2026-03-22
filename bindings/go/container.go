// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Container protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ContainerState represents the ContainerState type (Idris2 ABI tags).
type ContainerState uint8

const (
	ContainerStateCreating ContainerState = iota
	ContainerStateRunning
	ContainerStatePaused
	ContainerStateRestarting
	ContainerStateStopped
	ContainerStateRemoving
	ContainerStateDead
)

// ContainerOperation represents the ContainerOperation type (Idris2 ABI tags).
type ContainerOperation uint8

const (
	ContainerOperationCreate ContainerOperation = iota
	ContainerOperationStart
	ContainerOperationStop
	ContainerOperationRestart
	ContainerOperationPause
	ContainerOperationUnpause
	ContainerOperationKill
	ContainerOperationRemove
	ContainerOperationExec
	ContainerOperationLogs
	ContainerOperationInspect
)

// NetworkMode represents the NetworkMode type (Idris2 ABI tags).
type NetworkMode uint8

const (
	NetworkModeBridge NetworkMode = iota
	NetworkModeHost
	NetworkModeNone
	NetworkModeOverlay
	NetworkModeMacvlan
)

// VolumeType represents the VolumeType type (Idris2 ABI tags).
type VolumeType uint8

const (
	VolumeTypeBind VolumeType = iota
	VolumeTypeNamed
	VolumeTypeTmpfs
)

// RestartPolicy represents the RestartPolicy type (Idris2 ABI tags).
type RestartPolicy uint8

const (
	RestartPolicyNo RestartPolicy = iota
	RestartPolicyAlways
	RestartPolicyOnFailure
	RestartPolicyUnlessStopped
)

// HealthStatus represents the HealthStatus type (Idris2 ABI tags).
type HealthStatus uint8

const (
	HealthStatusStarting HealthStatus = iota
	HealthStatusHealthy
	HealthStatusUnhealthy
	HealthStatusNoCheck
)
