// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Virtualization protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// VmState represents the VmState type (Idris2 ABI tags).
type VmState uint8

const (
	VmStateCreating VmState = iota
	VmStateRunning
	VmStatePaused
	VmStateSuspended
	VmStateShuttingDown
	VmStateStopped
	VmStateCrashed
	VmStateMigrating
)

// VirtOperation represents the VirtOperation type (Idris2 ABI tags).
type VirtOperation uint8

const (
	VirtOperationCreate VirtOperation = iota
	VirtOperationStart
	VirtOperationStop
	VirtOperationRestart
	VirtOperationPause
	VirtOperationResume
	VirtOperationSuspend
	VirtOperationMigrate
	VirtOperationSnapshot
	VirtOperationClone
	VirtOperationDelete
)

// DiskFormat represents the DiskFormat type (Idris2 ABI tags).
type DiskFormat uint8

const (
	DiskFormatRaw DiskFormat = iota
	DiskFormatQcow2
	DiskFormatVdi
	DiskFormatVmdk
	DiskFormatVhd
)

// NetworkType represents the NetworkType type (Idris2 ABI tags).
type NetworkType uint8

const (
	NetworkTypeNat NetworkType = iota
	NetworkTypeBridged
	NetworkTypeInternal
	NetworkTypeHostOnly
)

// BootDevice represents the BootDevice type (Idris2 ABI tags).
type BootDevice uint8

const (
	BootDeviceHardDisk BootDevice = iota
	BootDeviceCdrom
	BootDeviceNetwork
	BootDeviceUsb
)
