// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Config Mgmt protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// ResourceType represents the ResourceType type (Idris2 ABI tags).
type ResourceType uint8

const (
	ResourceTypeFile ResourceType = iota
	ResourceTypePackage
	ResourceTypeService
	ResourceTypeUser
	ResourceTypeGroup
	ResourceTypeCron
	ResourceTypeMount
	ResourceTypeFirewall
	ResourceTypeRegistry
)

// ResourceState represents the ResourceState type (Idris2 ABI tags).
type ResourceState uint8

const (
	ResourceStatePresent ResourceState = iota
	ResourceStateAbsent
	ResourceStateRunning
	ResourceStateStopped
	ResourceStateEnabled
	ResourceStateDisabled
)

// ChangeAction represents the ChangeAction type (Idris2 ABI tags).
type ChangeAction uint8

const (
	ChangeActionCreate ChangeAction = iota
	ChangeActionModify
	ChangeActionDelete
	ChangeActionRestart
	ChangeActionReload
	ChangeActionSkip
)

// DriftStatus represents the DriftStatus type (Idris2 ABI tags).
type DriftStatus uint8

const (
	DriftStatusInSync DriftStatus = iota
	DriftStatusDrifted
	DriftStatusDUnknown
	DriftStatusUnmanaged
)

// ApplyMode represents the ApplyMode type (Idris2 ABI tags).
type ApplyMode uint8

const (
	ApplyModeEnforce ApplyMode = iota
	ApplyModeDryRun
	ApplyModeAudit
)
