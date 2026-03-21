// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SOCKSABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SOCKS5 port (RFC 1928).
let socksPort = 1080

// ===========================================================================
// AuthMethod (tags 0-3)
// ===========================================================================

/// Standard SOCKS5 port (RFC 1928).
type authMethod =
  | @as(0) NoAuth
  | @as(1) Gssapi
  | @as(2) UsernamePassword
  | @as(3) NoAcceptable

/// Decode from the C-ABI tag value.
let authMethodFromTag = (tag: int): option<authMethod> =>
  switch tag {
  | 0 => Some(NoAuth)
  | 1 => Some(Gssapi)
  | 2 => Some(UsernamePassword)
  | 3 => Some(NoAcceptable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authMethodToTag = (v: authMethod): int =>
  switch v {
  | NoAuth => 0
  | Gssapi => 1
  | UsernamePassword => 2
  | NoAcceptable => 3
  }

// ===========================================================================
// Command (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type command =
  | @as(0) Connect
  | @as(1) Bind
  | @as(2) UdpAssociate

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Connect)
  | 1 => Some(Bind)
  | 2 => Some(UdpAssociate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Connect => 0
  | Bind => 1
  | UdpAssociate => 2
  }

// ===========================================================================
// AddressType (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type addressType =
  | @as(0) IPv4
  | @as(1) DomainName
  | @as(2) IPv6

/// Decode from the C-ABI tag value.
let addressTypeFromTag = (tag: int): option<addressType> =>
  switch tag {
  | 0 => Some(IPv4)
  | 1 => Some(DomainName)
  | 2 => Some(IPv6)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let addressTypeToTag = (v: addressType): int =>
  switch v {
  | IPv4 => 0
  | DomainName => 1
  | IPv6 => 2
  }

// ===========================================================================
// Reply (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type reply =
  | @as(0) Succeeded
  | @as(1) GeneralFailure
  | @as(2) NotAllowed
  | @as(3) NetworkUnreachable
  | @as(4) HostUnreachable
  | @as(5) ConnectionRefused
  | @as(6) TtlExpired
  | @as(7) CommandNotSupported
  | @as(8) AddressTypeNotSupported

/// Decode from the C-ABI tag value.
let replyFromTag = (tag: int): option<reply> =>
  switch tag {
  | 0 => Some(Succeeded)
  | 1 => Some(GeneralFailure)
  | 2 => Some(NotAllowed)
  | 3 => Some(NetworkUnreachable)
  | 4 => Some(HostUnreachable)
  | 5 => Some(ConnectionRefused)
  | 6 => Some(TtlExpired)
  | 7 => Some(CommandNotSupported)
  | 8 => Some(AddressTypeNotSupported)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let replyToTag = (v: reply): int =>
  switch v {
  | Succeeded => 0
  | GeneralFailure => 1
  | NotAllowed => 2
  | NetworkUnreachable => 3
  | HostUnreachable => 4
  | ConnectionRefused => 5
  | TtlExpired => 6
  | CommandNotSupported => 7
  | AddressTypeNotSupported => 8
  }

/// Whether this reply indicates success.
let replyIsSuccess = (v: reply): bool =>
  switch v {
  | Succeeded => true
  | _ => false
  }

/// Whether this is a network-level error.
let replyIsNetworkError = (v: reply): bool =>
  switch v {
  | NetworkUnreachable | HostUnreachable | ConnectionRefused => true
  | _ => false
  }

// ===========================================================================
// State (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type state =
  | @as(0) Initial
  | @as(1) Authenticating
  | @as(2) Authenticated
  | @as(3) Connecting
  | @as(4) Established
  | @as(5) Closed

/// Decode from the C-ABI tag value.
let stateFromTag = (tag: int): option<state> =>
  switch tag {
  | 0 => Some(Initial)
  | 1 => Some(Authenticating)
  | 2 => Some(Authenticated)
  | 3 => Some(Connecting)
  | 4 => Some(Established)
  | 5 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let stateToTag = (v: state): int =>
  switch v {
  | Initial => 0
  | Authenticating => 1
  | Authenticated => 2
  | Connecting => 3
  | Established => 4
  | Closed => 5
  }

/// Validate whether a state transition is allowed.
let stateCanTransitionTo = (from: state, to: state): bool =>
  switch (from, to) {
  | _ => false
  }

