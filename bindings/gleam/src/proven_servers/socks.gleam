//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SOCKS5 protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SocksABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SOCKS5 Constants
// ===========================================================================

/// Socks Port constant.
pub const socks_port = 1080

// ===========================================================================
// AuthMethod
// ===========================================================================

/// SOCKS5 authentication methods (RFC 1928).
/// 
/// Matches `AuthMethod` in `SOCKSABI.Types`.
pub type AuthMethod {
  /// No authentication required (tag 0).
  NoAuth
  /// GSSAPI (tag 1).
  Gssapi
  /// Username/Password (RFC 1929) (tag 2).
  UsernamePassword
  /// No acceptable methods (tag 3).
  NoAcceptable
}

/// Convert a `AuthMethod` to its C-ABI tag value.
pub fn auth_method_to_int(value: AuthMethod) -> Int {
  case value {
    NoAuth -> 0
    Gssapi -> 1
    UsernamePassword -> 2
    NoAcceptable -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_method_from_int(tag: Int) -> Result(AuthMethod, Nil) {
  case tag {
    0 -> Ok(NoAuth)
    1 -> Ok(Gssapi)
    2 -> Ok(UsernamePassword)
    3 -> Ok(NoAcceptable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Command
// ===========================================================================

/// SOCKS5 commands (RFC 1928).
/// 
/// Matches `Command` in `SOCKSABI.Types`.
pub type Command {
  /// CONNECT — establish TCP connection (tag 0).
  Connect
  /// BIND — listen for incoming connection (tag 1).
  Bind
  /// UDP ASSOCIATE — set up UDP relay (tag 2).
  UdpAssociate
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Connect -> 0
    Bind -> 1
    UdpAssociate -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Connect)
    1 -> Ok(Bind)
    2 -> Ok(UdpAssociate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AddressType
// ===========================================================================

/// SOCKS5 address types (RFC 1928).
/// 
/// Matches `AddressType` in `SOCKSABI.Types`.
pub type AddressType {
  /// IPv4 address (tag 0).
  IPv4
  /// Domain name (tag 1).
  DomainName
  /// IPv6 address (tag 2).
  IPv6
}

/// Convert a `AddressType` to its C-ABI tag value.
pub fn address_type_to_int(value: AddressType) -> Int {
  case value {
    IPv4 -> 0
    DomainName -> 1
    IPv6 -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn address_type_from_int(tag: Int) -> Result(AddressType, Nil) {
  case tag {
    0 -> Ok(IPv4)
    1 -> Ok(DomainName)
    2 -> Ok(IPv6)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Reply
// ===========================================================================

/// SOCKS5 reply codes (RFC 1928).
/// 
/// Matches `Reply` in `SOCKSABI.Types`.
pub type Reply {
  /// Succeeded (tag 0).
  Succeeded
  /// General SOCKS server failure (tag 1).
  GeneralFailure
  /// Connection not allowed by ruleset (tag 2).
  NotAllowed
  /// Network unreachable (tag 3).
  NetworkUnreachable
  /// Host unreachable (tag 4).
  HostUnreachable
  /// Connection refused (tag 5).
  ConnectionRefused
  /// TTL expired (tag 6).
  TtlExpired
  /// Command not supported (tag 7).
  CommandNotSupported
  /// Address type not supported (tag 8).
  AddressTypeNotSupported
}

/// Convert a `Reply` to its C-ABI tag value.
pub fn reply_to_int(value: Reply) -> Int {
  case value {
    Succeeded -> 0
    GeneralFailure -> 1
    NotAllowed -> 2
    NetworkUnreachable -> 3
    HostUnreachable -> 4
    ConnectionRefused -> 5
    TtlExpired -> 6
    CommandNotSupported -> 7
    AddressTypeNotSupported -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn reply_from_int(tag: Int) -> Result(Reply, Nil) {
  case tag {
    0 -> Ok(Succeeded)
    1 -> Ok(GeneralFailure)
    2 -> Ok(NotAllowed)
    3 -> Ok(NetworkUnreachable)
    4 -> Ok(HostUnreachable)
    5 -> Ok(ConnectionRefused)
    6 -> Ok(TtlExpired)
    7 -> Ok(CommandNotSupported)
    8 -> Ok(AddressTypeNotSupported)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// State
// ===========================================================================

/// SOCKS5 connection state machine.
/// 
/// Matches `State` in `SOCKSABI.Types`.
pub type State {
  /// Initial — awaiting method negotiation (tag 0).
  Initial
  /// Authenticating (tag 1).
  Authenticating
  /// Authenticated — awaiting command (tag 2).
  Authenticated
  /// Connecting to target (tag 3).
  Connecting
  /// Connection established — relaying data (tag 4).
  Established
  /// Connection closed (tag 5).
  Closed
}

/// Convert a `State` to its C-ABI tag value.
pub fn state_to_int(value: State) -> Int {
  case value {
    Initial -> 0
    Authenticating -> 1
    Authenticated -> 2
    Connecting -> 3
    Established -> 4
    Closed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn state_from_int(tag: Int) -> Result(State, Nil) {
  case tag {
    0 -> Ok(Initial)
    1 -> Ok(Authenticating)
    2 -> Ok(Authenticated)
    3 -> Ok(Connecting)
    4 -> Ok(Established)
    5 -> Ok(Closed)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn state_can_transition_to(from: State, to: State) -> Bool {
  case from, to {
    Initial, Authenticating -> True
    Initial, Authenticated -> True
    Authenticating, Authenticated -> True
    Authenticated, Connecting -> True
    Connecting, Established -> True
    Connecting, Closed -> True
    Established, Closed -> True
    _, _ -> False
  }
}

