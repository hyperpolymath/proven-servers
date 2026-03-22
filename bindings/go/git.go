// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Git protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandUploadPack Command = iota
	CommandReceivePack
	CommandUploadArchive
)

// PacketType represents the PacketType type (Idris2 ABI tags).
type PacketType uint8

const (
	PacketTypeFlush PacketType = iota
	PacketTypeDelimiter
	PacketTypeResponseEnd
	PacketTypeData
	PacketTypePktError
	PacketTypeSidebandData
	PacketTypeSidebandProgress
	PacketTypeSidebandError
)

// RefType represents the RefType type (Idris2 ABI tags).
type RefType uint8

const (
	RefTypeBranch RefType = iota
	RefTypeTag
	RefTypeHead
	RefTypeRemote
	RefTypeGitNote
)

// Capability represents the Capability type (Idris2 ABI tags).
type Capability uint8

const (
	CapabilityMultiAck Capability = iota
	CapabilityThinPack
	CapabilitySideBand64k
	CapabilityOfsDelta
	CapabilityShallow
	CapabilityDeepenSince
	CapabilityDeepenNot
	CapabilityFilterSpec
	CapabilityObjectFormat
)

// HookResult represents the HookResult type (Idris2 ABI tags).
type HookResult uint8

const (
	HookResultAccept HookResult = iota
	HookResultReject
)

// ServerState represents the ServerState type (Idris2 ABI tags).
type ServerState uint8

const (
	ServerStateIdle ServerState = iota
	ServerStateDiscovery
	ServerStateNegotiating
	ServerStateTransfer
	ServerStateShutdown
)
