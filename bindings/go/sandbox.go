// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Sandbox protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ExecutionPolicy represents the ExecutionPolicy type (Idris2 ABI tags).
type ExecutionPolicy uint8

const (
	ExecutionPolicyUnrestricted ExecutionPolicy = iota
	ExecutionPolicyReadOnly
	ExecutionPolicyNetworkDenied
	ExecutionPolicyIsolated
	ExecutionPolicyEphemeral
)

// ResourceLimit represents the ResourceLimit type (Idris2 ABI tags).
type ResourceLimit uint8

const (
	ResourceLimitCpuTime ResourceLimit = iota
	ResourceLimitMemory
	ResourceLimitDiskIo
	ResourceLimitNetworkIo
	ResourceLimitFileDescriptors
	ResourceLimitProcesses
)

// SandboxState represents the SandboxState type (Idris2 ABI tags).
type SandboxState uint8

const (
	SandboxStateCreating SandboxState = iota
	SandboxStateReady
	SandboxStateRunning
	SandboxStateSuspended
	SandboxStateTerminated
	SandboxStateDestroyed
)

// ExitReason represents the ExitReason type (Idris2 ABI tags).
type ExitReason uint8

const (
	ExitReasonNormal ExitReason = iota
	ExitReasonTimeout
	ExitReasonMemoryExceeded
	ExitReasonPolicyViolation
	ExitReasonKilled
	ExitReasonError
)

// SyscallPolicy represents the SyscallPolicy type (Idris2 ABI tags).
type SyscallPolicy uint8

const (
	SyscallPolicyAllow SyscallPolicy = iota
	SyscallPolicyDeny
	SyscallPolicyLog
	SyscallPolicyTrap
)
