// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// SOCKS5 protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// AuthMethod represents the AuthMethod type (Idris2 ABI tags).
type AuthMethod uint8

const (
	AuthMethodNoAuth AuthMethod = iota
	AuthMethodGssapi
	AuthMethodUsernamePassword
	AuthMethodNoAcceptable
)

// Command represents the Command type (Idris2 ABI tags).
type Command uint8

const (
	CommandConnect Command = iota
	CommandBind
	CommandUdpAssociate
)

// AddressType represents the AddressType type (Idris2 ABI tags).
type AddressType uint8

const (
	AddressTypeIPv4 AddressType = iota
	AddressTypeDomainName
	AddressTypeIPv6
)

// Reply represents the Reply type (Idris2 ABI tags).
type Reply uint8

const (
	ReplySucceeded Reply = iota
	ReplyGeneralFailure
	ReplyNotAllowed
	ReplyNetworkUnreachable
	ReplyHostUnreachable
	ReplyConnectionRefused
	ReplyTtlExpired
	ReplyCommandNotSupported
	ReplyAddressTypeNotSupported
)

// State represents the State type (Idris2 ABI tags).
type State uint8

const (
	StateInitial State = iota
	StateAuthenticating
	StateAuthenticated
	StateConnecting
	StateEstablished
	StateClosed
)
