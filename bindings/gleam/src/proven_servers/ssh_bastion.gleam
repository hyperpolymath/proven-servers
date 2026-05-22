//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SSH bastion protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `SSH.Transport`        -- key exchange and cipher algorithms
//// - `SSH.Auth`             -- authentication methods
//// - `SSH.Channel`          -- channel types and states
//// - `SSH.Session`          -- session lifecycle states
//// - `SSHABI.Layout`        -- C-ABI tag values for all types
//// - `SSHABI.Transitions`   -- session and channel state machines

// ===========================================================================
// SSH Constants
// ===========================================================================

/// Standard SSH port (RFC 4253).
pub const ssh_port = 22

// ===========================================================================
// SshMessageType (tags 0-7)
// ===========================================================================

/// SSH message types relevant to bastion operation.
///
/// Matches `SshMessageType` in `SshBastionABI.Types`.
pub type SshMessageType {
  /// Key exchange initialisation.
  Kexinit
  /// New keys established after key exchange.
  Newkeys
  /// Service request from client.
  ServiceRequest
  /// User authentication request.
  UserauthRequest
  /// Channel open request.
  ChannelOpen
  /// Channel data transfer.
  ChannelData
  /// Channel close notification.
  ChannelClose
  /// Disconnect notification.
  SshDisconnect
}

/// Convert a `SshMessageType` to its C-ABI tag value.
pub fn message_type_to_int(mt: SshMessageType) -> Int {
  case mt {
    Kexinit -> 0
    Newkeys -> 1
    ServiceRequest -> 2
    UserauthRequest -> 3
    ChannelOpen -> 4
    ChannelData -> 5
    ChannelClose -> 6
    SshDisconnect -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(SshMessageType, Nil) {
  case tag {
    0 -> Ok(Kexinit)
    1 -> Ok(Newkeys)
    2 -> Ok(ServiceRequest)
    3 -> Ok(UserauthRequest)
    4 -> Ok(ChannelOpen)
    5 -> Ok(ChannelData)
    6 -> Ok(ChannelClose)
    7 -> Ok(SshDisconnect)
    _ -> Error(Nil)
  }
}

/// Human-readable message type name.
pub fn message_type_name(mt: SshMessageType) -> String {
  case mt {
    Kexinit -> "SSH_MSG_KEXINIT"
    Newkeys -> "SSH_MSG_NEWKEYS"
    ServiceRequest -> "SSH_MSG_SERVICE_REQUEST"
    UserauthRequest -> "SSH_MSG_USERAUTH_REQUEST"
    ChannelOpen -> "SSH_MSG_CHANNEL_OPEN"
    ChannelData -> "SSH_MSG_CHANNEL_DATA"
    ChannelClose -> "SSH_MSG_CHANNEL_CLOSE"
    SshDisconnect -> "SSH_MSG_DISCONNECT"
  }
}

// ===========================================================================
// AuthMethod (tags 0-3)
// ===========================================================================

/// SSH authentication methods (RFC 4252).
pub type AuthMethod {
  /// Public key authentication.
  Publickey
  /// Password authentication.
  SshPassword
  /// Keyboard-interactive authentication.
  KeyboardInteractive
  /// No authentication / "none" method.
  AuthNone
}

/// Convert an `AuthMethod` to its C-ABI tag value.
pub fn auth_method_to_int(method: AuthMethod) -> Int {
  case method {
    Publickey -> 0
    SshPassword -> 1
    KeyboardInteractive -> 2
    AuthNone -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_method_from_int(tag: Int) -> Result(AuthMethod, Nil) {
  case tag {
    0 -> Ok(Publickey)
    1 -> Ok(SshPassword)
    2 -> Ok(KeyboardInteractive)
    3 -> Ok(AuthNone)
    _ -> Error(Nil)
  }
}

/// Whether this method is considered secure for production use.
pub fn auth_method_is_secure(method: AuthMethod) -> Bool {
  case method {
    Publickey | KeyboardInteractive -> True
    _ -> False
  }
}

// ===========================================================================
// KexMethod (tags 0-5)
// ===========================================================================

/// SSH key exchange methods.
pub type KexMethod {
  DiffieHellmanGroup14Sha256
  Curve25519Sha256
  DiffieHellmanGroup16Sha512
  DiffieHellmanGroup18Sha512
  EcdhSha2Nistp256
  EcdhSha2Nistp384
}

/// Convert a `KexMethod` to its C-ABI tag value.
pub fn kex_method_to_int(method: KexMethod) -> Int {
  case method {
    DiffieHellmanGroup14Sha256 -> 0
    Curve25519Sha256 -> 1
    DiffieHellmanGroup16Sha512 -> 2
    DiffieHellmanGroup18Sha512 -> 3
    EcdhSha2Nistp256 -> 4
    EcdhSha2Nistp384 -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn kex_method_from_int(tag: Int) -> Result(KexMethod, Nil) {
  case tag {
    0 -> Ok(DiffieHellmanGroup14Sha256)
    1 -> Ok(Curve25519Sha256)
    2 -> Ok(DiffieHellmanGroup16Sha512)
    3 -> Ok(DiffieHellmanGroup18Sha512)
    4 -> Ok(EcdhSha2Nistp256)
    5 -> Ok(EcdhSha2Nistp384)
    _ -> Error(Nil)
  }
}

/// Whether this key exchange method uses elliptic curve cryptography.
pub fn kex_method_is_ecc(method: KexMethod) -> Bool {
  case method {
    Curve25519Sha256 | EcdhSha2Nistp256 | EcdhSha2Nistp384 -> True
    _ -> False
  }
}

// ===========================================================================
// ChannelType (tags 0-3)
// ===========================================================================

/// SSH channel types.
pub type ChannelType {
  /// Interactive shell session.
  Session
  /// Direct TCP/IP forwarding.
  DirectTcpip
  /// Forwarded TCP/IP from remote.
  ForwardedTcpip
  /// X11 forwarding.
  X11
}

/// Convert a `ChannelType` to its C-ABI tag value.
pub fn channel_type_to_int(ct: ChannelType) -> Int {
  case ct {
    Session -> 0
    DirectTcpip -> 1
    ForwardedTcpip -> 2
    X11 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn channel_type_from_int(tag: Int) -> Result(ChannelType, Nil) {
  case tag {
    0 -> Ok(Session)
    1 -> Ok(DirectTcpip)
    2 -> Ok(ForwardedTcpip)
    3 -> Ok(X11)
    _ -> Error(Nil)
  }
}

/// Whether this channel type involves TCP/IP forwarding.
pub fn channel_type_is_forwarding(ct: ChannelType) -> Bool {
  case ct {
    DirectTcpip | ForwardedTcpip -> True
    _ -> False
  }
}

// ===========================================================================
// BastionState (tags 0-5)
// ===========================================================================

/// SSH bastion connection state machine.
///
/// States progress linearly: Connected -> KeyExchanged -> Authenticated ->
/// ChannelOpen -> Active -> Closed.
pub type BastionState {
  BastionConnected
  KeyExchanged
  BastionAuthenticated
  BastionChannelOpen
  BastionActive
  BastionClosed
}

/// Convert a `BastionState` to its C-ABI tag value.
pub fn bastion_state_to_int(state: BastionState) -> Int {
  case state {
    BastionConnected -> 0
    KeyExchanged -> 1
    BastionAuthenticated -> 2
    BastionChannelOpen -> 3
    BastionActive -> 4
    BastionClosed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn bastion_state_from_int(tag: Int) -> Result(BastionState, Nil) {
  case tag {
    0 -> Ok(BastionConnected)
    1 -> Ok(KeyExchanged)
    2 -> Ok(BastionAuthenticated)
    3 -> Ok(BastionChannelOpen)
    4 -> Ok(BastionActive)
    5 -> Ok(BastionClosed)
    _ -> Error(Nil)
  }
}

/// Validate whether a bastion state transition is allowed.
pub fn bastion_can_transition(
  from: BastionState,
  to: BastionState,
) -> Bool {
  case from, to {
    BastionConnected, KeyExchanged -> True
    KeyExchanged, BastionAuthenticated -> True
    BastionAuthenticated, BastionChannelOpen -> True
    BastionChannelOpen, BastionActive -> True
    _, BastionClosed -> True
    _, _ -> False
  }
}

// ===========================================================================
// ChannelState (tags 0-3)
// ===========================================================================

/// SSH channel state machine.
pub type ChannelState {
  Opening
  ChannelOpened
  Closing
  ChannelClosed
}

/// Convert a `ChannelState` to its C-ABI tag value.
pub fn channel_state_to_int(state: ChannelState) -> Int {
  case state {
    Opening -> 0
    ChannelOpened -> 1
    Closing -> 2
    ChannelClosed -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn channel_state_from_int(tag: Int) -> Result(ChannelState, Nil) {
  case tag {
    0 -> Ok(Opening)
    1 -> Ok(ChannelOpened)
    2 -> Ok(Closing)
    3 -> Ok(ChannelClosed)
    _ -> Error(Nil)
  }
}

/// Validate whether a channel state transition is allowed.
pub fn channel_can_transition(
  from: ChannelState,
  to: ChannelState,
) -> Bool {
  case from, to {
    Opening, ChannelOpened -> True
    Opening, ChannelClosed -> True
    ChannelOpened, Closing -> True
    Closing, ChannelClosed -> True
    _, _ -> False
  }
}

// ===========================================================================
// DisconnectReason (tags 0-11)
// ===========================================================================

/// SSH disconnect reason codes.
pub type DisconnectReason {
  HostNotAllowed
  SshProtocolError
  KeyExchangeFailed
  HostAuthFailed
  MacError
  ServiceNotAvailable
  VersionNotSupported
  HostKeyNotVerifiable
  ConnectionLost
  ByApplication
  TooManyConnections
  AuthCancelled
}

/// Convert a `DisconnectReason` to its C-ABI tag value.
pub fn disconnect_reason_to_int(reason: DisconnectReason) -> Int {
  case reason {
    HostNotAllowed -> 0
    SshProtocolError -> 1
    KeyExchangeFailed -> 2
    HostAuthFailed -> 3
    MacError -> 4
    ServiceNotAvailable -> 5
    VersionNotSupported -> 6
    HostKeyNotVerifiable -> 7
    ConnectionLost -> 8
    ByApplication -> 9
    TooManyConnections -> 10
    AuthCancelled -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn disconnect_reason_from_int(tag: Int) -> Result(DisconnectReason, Nil) {
  case tag {
    0 -> Ok(HostNotAllowed)
    1 -> Ok(SshProtocolError)
    2 -> Ok(KeyExchangeFailed)
    3 -> Ok(HostAuthFailed)
    4 -> Ok(MacError)
    5 -> Ok(ServiceNotAvailable)
    6 -> Ok(VersionNotSupported)
    7 -> Ok(HostKeyNotVerifiable)
    8 -> Ok(ConnectionLost)
    9 -> Ok(ByApplication)
    10 -> Ok(TooManyConnections)
    11 -> Ok(AuthCancelled)
    _ -> Error(Nil)
  }
}

/// Whether this disconnect reason indicates a security issue.
pub fn disconnect_reason_is_security_related(reason: DisconnectReason) -> Bool {
  case reason {
    HostNotAllowed | HostAuthFailed | MacError | HostKeyNotVerifiable
    | AuthCancelled -> True
    _ -> False
  }
}
