// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SSH Bastion protocol bindings for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// BastionState represents the BastionState type (Idris2 ABI tags).
type BastionState uint8

const (
	BastionStateBastionConnected BastionState = iota
	BastionStateBastionKeyExchanged
	BastionStateBastionAuthenticated
	BastionStateBastionChannelOpen
	BastionStateBastionActive
	BastionStateBastionClosed
)

// KexMethod represents the KexMethod type (Idris2 ABI tags).
type KexMethod uint8

const (
	KexMethodKexCurve25519 KexMethod = iota
	KexMethodKexDhGroup14
	KexMethodKexDhGroup16
	KexMethodKexEcdhP256
	KexMethodKexEcdhP384
)

// AuthMethod represents the AuthMethod type (Idris2 ABI tags).
type AuthMethod uint8

const (
	AuthMethodAuthPublicKey AuthMethod = iota
	AuthMethodAuthPassword
	AuthMethodAuthKeyboard
	AuthMethodAuthCertificate
)

// ChannelType represents the ChannelType type (Idris2 ABI tags).
type ChannelType uint8

const (
	ChannelTypeChannelSession ChannelType = iota
	ChannelTypeChannelDirectTcpIp
	ChannelTypeChannelForwardedTcpIp
	ChannelTypeChannelSubsystem
)

// ChannelState represents the ChannelState type (Idris2 ABI tags).
type ChannelState uint8

const (
	ChannelStateChannelOpening ChannelState = iota
	ChannelStateChannelOpen
	ChannelStateChannelClosing
	ChannelStateChannelClosed
)

// DisconnectReason represents the DisconnectReason type (Idris2 ABI tags).
type DisconnectReason uint8

const (
	DisconnectReasonDisconnectHostNotAllowed DisconnectReason = iota
	DisconnectReasonDisconnectProtocolError
	DisconnectReasonDisconnectKeyExchangeFailed
	DisconnectReasonDisconnectAuthFailed
	DisconnectReasonDisconnectServiceNotAvailable
	DisconnectReasonDisconnectByApplication
	DisconnectReasonDisconnectTooManyConnections
)
