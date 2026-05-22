// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// TACACS+ protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// PacketType represents the PacketType type (Idris2 ABI tags).
type PacketType uint8

const (
	PacketTypeAuthentication PacketType = iota
	PacketTypeAuthorization
	PacketTypeAccounting
)

// AuthenType represents the AuthenType type (Idris2 ABI tags).
type AuthenType uint8

const (
	AuthenTypeAscii AuthenType = iota
	AuthenTypePap
	AuthenTypeChap
	AuthenTypeMsChapV1
	AuthenTypeMsChapV2
)

// AuthenAction represents the AuthenAction type (Idris2 ABI tags).
type AuthenAction uint8

const (
	AuthenActionLogin AuthenAction = iota
	AuthenActionChangePass
	AuthenActionSendAuth
)

// AuthenStatus represents the AuthenStatus type (Idris2 ABI tags).
type AuthenStatus uint8

const (
	AuthenStatusPass AuthenStatus = iota
	AuthenStatusFail
	AuthenStatusGetData
	AuthenStatusGetUser
	AuthenStatusGetPass
	AuthenStatusRestart
	AuthenStatusError
	AuthenStatusFollow
)

// AuthorStatus represents the AuthorStatus type (Idris2 ABI tags).
type AuthorStatus uint8

const (
	AuthorStatusPassAdd AuthorStatus = iota
	AuthorStatusPassRepl
	AuthorStatusFail
	AuthorStatusError
	AuthorStatusFollow
)

// AcctStatus represents the AcctStatus type (Idris2 ABI tags).
type AcctStatus uint8

const (
	AcctStatusSuccess AcctStatus = iota
	AcctStatusError
	AcctStatusFollow
)

// AcctFlag represents the AcctFlag type (Idris2 ABI tags).
type AcctFlag uint8

const (
	AcctFlagStart AcctFlag = iota
	AcctFlagStop
	AcctFlagWatchdog
)

// SessionState represents the SessionState type (Idris2 ABI tags).
type SessionState uint8

const (
	SessionStateIdle SessionState = iota
	SessionStateAuthenticating
	SessionStateAuthorizing
	SessionStateActive
	SessionStateClosing
)
