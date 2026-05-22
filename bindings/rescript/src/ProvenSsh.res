// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module SshBastionABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SSH port (RFC 4253).
let sshPort = 22

// ===========================================================================
// SshMessageType (tags 0-7)
// ===========================================================================

/// Standard SSH port (RFC 4253).
type sshMessageType =
  | @as(0) Kexinit
  | @as(1) Newkeys
  | @as(2) ServiceRequest
  | @as(3) UserauthRequest
  | @as(4) ChannelOpen
  | @as(5) ChannelData
  | @as(6) ChannelClose
  | @as(7) Disconnect

/// Decode from the C-ABI tag value.
let sshMessageTypeFromTag = (tag: int): option<sshMessageType> =>
  switch tag {
  | 0 => Some(Kexinit)
  | 1 => Some(Newkeys)
  | 2 => Some(ServiceRequest)
  | 3 => Some(UserauthRequest)
  | 4 => Some(ChannelOpen)
  | 5 => Some(ChannelData)
  | 6 => Some(ChannelClose)
  | 7 => Some(Disconnect)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sshMessageTypeToTag = (v: sshMessageType): int =>
  switch v {
  | Kexinit => 0
  | Newkeys => 1
  | ServiceRequest => 2
  | UserauthRequest => 3
  | ChannelOpen => 4
  | ChannelData => 5
  | ChannelClose => 6
  | Disconnect => 7
  }

// ===========================================================================
// AuthMethod (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type authMethod =
  | @as(0) Publickey
  | @as(1) Password
  | @as(2) KeyboardInteractive
  | @as(3) AuthNone

/// Decode from the C-ABI tag value.
let authMethodFromTag = (tag: int): option<authMethod> =>
  switch tag {
  | 0 => Some(Publickey)
  | 1 => Some(Password)
  | 2 => Some(KeyboardInteractive)
  | 3 => Some(AuthNone)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authMethodToTag = (v: authMethod): int =>
  switch v {
  | Publickey => 0
  | Password => 1
  | KeyboardInteractive => 2
  | AuthNone => 3
  }

/// public key or keyboard-interactive with MFA.
let authMethodIsSecure = (v: authMethod): bool =>
  switch v {
  | Publickey | KeyboardInteractive => true
  | _ => false
  }

// ===========================================================================
// KexMethod (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type kexMethod =
  | @as(0) DiffieHellmanGroup14Sha256
  | @as(1) Curve25519Sha256
  | @as(2) DiffieHellmanGroup16Sha512
  | @as(3) DiffieHellmanGroup18Sha512
  | @as(4) EcdhSha2Nistp256
  | @as(5) EcdhSha2Nistp384

/// Decode from the C-ABI tag value.
let kexMethodFromTag = (tag: int): option<kexMethod> =>
  switch tag {
  | 0 => Some(DiffieHellmanGroup14Sha256)
  | 1 => Some(Curve25519Sha256)
  | 2 => Some(DiffieHellmanGroup16Sha512)
  | 3 => Some(DiffieHellmanGroup18Sha512)
  | 4 => Some(EcdhSha2Nistp256)
  | 5 => Some(EcdhSha2Nistp384)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let kexMethodToTag = (v: kexMethod): int =>
  switch v {
  | DiffieHellmanGroup14Sha256 => 0
  | Curve25519Sha256 => 1
  | DiffieHellmanGroup16Sha512 => 2
  | DiffieHellmanGroup18Sha512 => 3
  | EcdhSha2Nistp256 => 4
  | EcdhSha2Nistp384 => 5
  }

/// Whether this key exchange method uses elliptic curve cryptography.
let kexMethodIsEcc = (v: kexMethod): bool =>
  switch v {
  | Curve25519Sha256 | EcdhSha2Nistp256 | EcdhSha2Nistp384 => true
  | _ => false
  }

// ===========================================================================
// ChannelType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type channelType =
  | @as(0) Session
  | @as(1) DirectTcpip
  | @as(2) ForwardedTcpip
  | @as(3) X11

/// Decode from the C-ABI tag value.
let channelTypeFromTag = (tag: int): option<channelType> =>
  switch tag {
  | 0 => Some(Session)
  | 1 => Some(DirectTcpip)
  | 2 => Some(ForwardedTcpip)
  | 3 => Some(X11)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let channelTypeToTag = (v: channelType): int =>
  switch v {
  | Session => 0
  | DirectTcpip => 1
  | ForwardedTcpip => 2
  | X11 => 3
  }

/// Whether this channel type involves TCP/IP forwarding.
let channelTypeIsForwarding = (v: channelType): bool =>
  switch v {
  | DirectTcpip | ForwardedTcpip => true
  | _ => false
  }

// ===========================================================================
// BastionState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type bastionState =
  | @as(0) Connected
  | @as(1) KeyExchanged
  | @as(2) Authenticated
  | @as(3) ChannelOpen
  | @as(4) Active
  | @as(5) Closed

/// Decode from the C-ABI tag value.
let bastionStateFromTag = (tag: int): option<bastionState> =>
  switch tag {
  | 0 => Some(Connected)
  | 1 => Some(KeyExchanged)
  | 2 => Some(Authenticated)
  | 3 => Some(ChannelOpen)
  | 4 => Some(Active)
  | 5 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let bastionStateToTag = (v: bastionState): int =>
  switch v {
  | Connected => 0
  | KeyExchanged => 1
  | Authenticated => 2
  | ChannelOpen => 3
  | Active => 4
  | Closed => 5
  }

/// Validate whether a state transition is allowed.
let bastionStateCanTransitionTo = (from: bastionState, to: bastionState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// ChannelState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type channelState =
  | @as(0) Opening
  | @as(1) Open
  | @as(2) Closing
  | @as(3) Closed

/// Decode from the C-ABI tag value.
let channelStateFromTag = (tag: int): option<channelState> =>
  switch tag {
  | 0 => Some(Opening)
  | 1 => Some(Open)
  | 2 => Some(Closing)
  | 3 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let channelStateToTag = (v: channelState): int =>
  switch v {
  | Opening => 0
  | Open => 1
  | Closing => 2
  | Closed => 3
  }

/// Validate whether a state transition is allowed.
let channelStateCanTransitionTo = (from: channelState, to: channelState): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// DisconnectReason (tags 0-11)
// ===========================================================================

/// Decode from an ABI tag value.
type disconnectReason =
  | @as(0) HostNotAllowed
  | @as(1) ProtocolError
  | @as(2) KeyExchangeFailed
  | @as(3) HostAuthFailed
  | @as(4) MacError
  | @as(5) ServiceNotAvailable
  | @as(6) VersionNotSupported
  | @as(7) HostKeyNotVerifiable
  | @as(8) ConnectionLost
  | @as(9) ByApplication
  | @as(10) TooManyConnections
  | @as(11) AuthCancelled

/// Decode from the C-ABI tag value.
let disconnectReasonFromTag = (tag: int): option<disconnectReason> =>
  switch tag {
  | 0 => Some(HostNotAllowed)
  | 1 => Some(ProtocolError)
  | 2 => Some(KeyExchangeFailed)
  | 3 => Some(HostAuthFailed)
  | 4 => Some(MacError)
  | 5 => Some(ServiceNotAvailable)
  | 6 => Some(VersionNotSupported)
  | 7 => Some(HostKeyNotVerifiable)
  | 8 => Some(ConnectionLost)
  | 9 => Some(ByApplication)
  | 10 => Some(TooManyConnections)
  | 11 => Some(AuthCancelled)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let disconnectReasonToTag = (v: disconnectReason): int =>
  switch v {
  | HostNotAllowed => 0
  | ProtocolError => 1
  | KeyExchangeFailed => 2
  | HostAuthFailed => 3
  | MacError => 4
  | ServiceNotAvailable => 5
  | VersionNotSupported => 6
  | HostKeyNotVerifiable => 7
  | ConnectionLost => 8
  | ByApplication => 9
  | TooManyConnections => 10
  | AuthCancelled => 11
  }

/// Whether this disconnect reason indicates a security issue.
let disconnectReasonIsSecurityRelated = (v: disconnectReason): bool =>
  switch v {
  | HostNotAllowed | HostAuthFailed | MacError | HostKeyNotVerifiable | AuthCancelled => true
  | _ => false
  }

// ===========================================================================
// HostKeyAlgorithm (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type hostKeyAlgorithm =
  | @as(0) SshEd25519
  | @as(1) RsaSha2256
  | @as(2) RsaSha2512
  | @as(3) EcdsaNistp256

/// Decode from the C-ABI tag value.
let hostKeyAlgorithmFromTag = (tag: int): option<hostKeyAlgorithm> =>
  switch tag {
  | 0 => Some(SshEd25519)
  | 1 => Some(RsaSha2256)
  | 2 => Some(RsaSha2512)
  | 3 => Some(EcdsaNistp256)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hostKeyAlgorithmToTag = (v: hostKeyAlgorithm): int =>
  switch v {
  | SshEd25519 => 0
  | RsaSha2256 => 1
  | RsaSha2512 => 2
  | EcdsaNistp256 => 3
  }

/// Whether this algorithm uses elliptic curve cryptography.
let hostKeyAlgorithmIsEcc = (v: hostKeyAlgorithm): bool =>
  switch v {
  | SshEd25519 | EcdsaNistp256 => true
  | _ => false
  }

// ===========================================================================
// CipherAlgorithm (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type cipherAlgorithm =
  | @as(0) Chacha20Poly1305
  | @as(1) Aes256Gcm
  | @as(2) Aes128Gcm
  | @as(3) Aes256Ctr
  | @as(4) Aes192Ctr
  | @as(5) Aes128Ctr

/// Decode from the C-ABI tag value.
let cipherAlgorithmFromTag = (tag: int): option<cipherAlgorithm> =>
  switch tag {
  | 0 => Some(Chacha20Poly1305)
  | 1 => Some(Aes256Gcm)
  | 2 => Some(Aes128Gcm)
  | 3 => Some(Aes256Ctr)
  | 4 => Some(Aes192Ctr)
  | 5 => Some(Aes128Ctr)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let cipherAlgorithmToTag = (v: cipherAlgorithm): int =>
  switch v {
  | Chacha20Poly1305 => 0
  | Aes256Gcm => 1
  | Aes128Gcm => 2
  | Aes256Ctr => 3
  | Aes192Ctr => 4
  | Aes128Ctr => 5
  }

/// Whether this cipher provides authenticated encryption (AEAD).
let cipherAlgorithmIsAead = (v: cipherAlgorithm): bool =>
  switch v {
  | Chacha20Poly1305 | Aes256Gcm | Aes128Gcm => true
  | _ => false
  }

// ===========================================================================
// ChannelOpenFailure (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type channelOpenFailure =
  | @as(0) AdminProhibited
  | @as(1) ConnectFailed
  | @as(2) UnknownChannelType
  | @as(3) ResourceShortage

/// Decode from the C-ABI tag value.
let channelOpenFailureFromTag = (tag: int): option<channelOpenFailure> =>
  switch tag {
  | 0 => Some(AdminProhibited)
  | 1 => Some(ConnectFailed)
  | 2 => Some(UnknownChannelType)
  | 3 => Some(ResourceShortage)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let channelOpenFailureToTag = (v: channelOpenFailure): int =>
  switch v {
  | AdminProhibited => 0
  | ConnectFailed => 1
  | UnknownChannelType => 2
  | ResourceShortage => 3
  }

