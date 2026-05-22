// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH bastion protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - SSH.Transport        -- key exchange and cipher algorithms
// - SSH.Auth             -- authentication methods
// - SSH.Channel          -- channel types and states
// - SSH.Session          -- session lifecycle states
// - SSHABI.Layout        -- C-ABI tag values for all types
// - SSHABI.Transitions   -- session and channel state machines
//
// All tag values match the Layout encoders in SSHABI.Layout exactly.

// ===========================================================================
// SSH Message Type (SSHABI.Layout.SshMessageType, tags 0-7)
// ===========================================================================

/// SSH message types relevant to bastion operation.
/// Matches SshMessageType in SSHABI.Layout.
type messageType =
  | @as(0) Kexinit
  | @as(1) Newkeys
  | @as(2) ServiceRequest
  | @as(3) UserauthRequest
  | @as(4) ChannelOpen
  | @as(5) ChannelData
  | @as(6) ChannelClose
  | @as(7) Disconnect

/// Decode from C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
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

/// Encode to C-ABI tag value.
let messageTypeToTag = (mt: messageType): int =>
  switch mt {
  | Kexinit => 0
  | Newkeys => 1
  | ServiceRequest => 2
  | UserauthRequest => 3
  | ChannelOpen => 4
  | ChannelData => 5
  | ChannelClose => 6
  | Disconnect => 7
  }

/// Human-readable message type name.
let messageTypeName = (mt: messageType): string =>
  switch mt {
  | Kexinit => "SSH_MSG_KEXINIT"
  | Newkeys => "SSH_MSG_NEWKEYS"
  | ServiceRequest => "SSH_MSG_SERVICE_REQUEST"
  | UserauthRequest => "SSH_MSG_USERAUTH_REQUEST"
  | ChannelOpen => "SSH_MSG_CHANNEL_OPEN"
  | ChannelData => "SSH_MSG_CHANNEL_DATA"
  | ChannelClose => "SSH_MSG_CHANNEL_CLOSE"
  | Disconnect => "SSH_MSG_DISCONNECT"
  }

// ===========================================================================
// Auth Method (SSHABI.Layout.AuthMethod, tags 0-3)
// ===========================================================================

/// SSH authentication methods (RFC 4252).
/// Matches AuthMethod in SSH.Auth.
type authMethod =
  | @as(0) PublicKey
  | @as(1) Password
  | @as(2) KeyboardInteractive
  | @as(3) AuthNone

/// Decode from C-ABI tag value.
let authMethodFromTag = (tag: int): option<authMethod> =>
  switch tag {
  | 0 => Some(PublicKey)
  | 1 => Some(Password)
  | 2 => Some(KeyboardInteractive)
  | 3 => Some(AuthNone)
  | _ => None
  }

/// Encode to C-ABI tag value.
let authMethodToTag = (m: authMethod): int =>
  switch m {
  | PublicKey => 0
  | Password => 1
  | KeyboardInteractive => 2
  | AuthNone => 3
  }

/// SSH authentication method name string (RFC 4252 Section 5).
let authMethodName = (m: authMethod): string =>
  switch m {
  | PublicKey => "publickey"
  | Password => "password"
  | KeyboardInteractive => "keyboard-interactive"
  | AuthNone => "none"
  }

// ===========================================================================
// Key Exchange Method (SSHABI.Layout.KexMethod, tags 0-5)
// ===========================================================================

/// SSH key exchange algorithms.
/// Matches KexMethod in SSH.Transport.
type kexMethod =
  | @as(0) DiffieHellmanGroup14Sha256
  | @as(1) Curve25519Sha256
  | @as(2) DiffieHellmanGroup16Sha512
  | @as(3) DiffieHellmanGroup18Sha512
  | @as(4) EcdhSha2NistP256
  | @as(5) EcdhSha2NistP384

/// Decode from C-ABI tag value.
let kexMethodFromTag = (tag: int): option<kexMethod> =>
  switch tag {
  | 0 => Some(DiffieHellmanGroup14Sha256)
  | 1 => Some(Curve25519Sha256)
  | 2 => Some(DiffieHellmanGroup16Sha512)
  | 3 => Some(DiffieHellmanGroup18Sha512)
  | 4 => Some(EcdhSha2NistP256)
  | 5 => Some(EcdhSha2NistP384)
  | _ => None
  }

/// Encode to C-ABI tag value.
let kexMethodToTag = (k: kexMethod): int =>
  switch k {
  | DiffieHellmanGroup14Sha256 => 0
  | Curve25519Sha256 => 1
  | DiffieHellmanGroup16Sha512 => 2
  | DiffieHellmanGroup18Sha512 => 3
  | EcdhSha2NistP256 => 4
  | EcdhSha2NistP384 => 5
  }

/// SSH kex algorithm name string.
let kexMethodName = (k: kexMethod): string =>
  switch k {
  | DiffieHellmanGroup14Sha256 => "diffie-hellman-group14-sha256"
  | Curve25519Sha256 => "curve25519-sha256"
  | DiffieHellmanGroup16Sha512 => "diffie-hellman-group16-sha512"
  | DiffieHellmanGroup18Sha512 => "diffie-hellman-group18-sha512"
  | EcdhSha2NistP256 => "ecdh-sha2-nistp256"
  | EcdhSha2NistP384 => "ecdh-sha2-nistp384"
  }

// ===========================================================================
// Host Key Algorithm (SSHABI.Layout.HostKeyAlgorithm, tags 0-3)
// ===========================================================================

/// SSH host key algorithms.
/// Matches HostKeyAlgorithm in SSH.Transport.
type hostKeyAlgorithm =
  | @as(0) SshEd25519
  | @as(1) RsaSha2_256
  | @as(2) RsaSha2_512
  | @as(3) EcdsaNistP256

/// Decode from C-ABI tag value.
let hostKeyAlgorithmFromTag = (tag: int): option<hostKeyAlgorithm> =>
  switch tag {
  | 0 => Some(SshEd25519)
  | 1 => Some(RsaSha2_256)
  | 2 => Some(RsaSha2_512)
  | 3 => Some(EcdsaNistP256)
  | _ => None
  }

/// Encode to C-ABI tag value.
let hostKeyAlgorithmToTag = (h: hostKeyAlgorithm): int =>
  switch h {
  | SshEd25519 => 0
  | RsaSha2_256 => 1
  | RsaSha2_512 => 2
  | EcdsaNistP256 => 3
  }

/// SSH host key algorithm name string.
let hostKeyAlgorithmName = (h: hostKeyAlgorithm): string =>
  switch h {
  | SshEd25519 => "ssh-ed25519"
  | RsaSha2_256 => "rsa-sha2-256"
  | RsaSha2_512 => "rsa-sha2-512"
  | EcdsaNistP256 => "ecdsa-sha2-nistp256"
  }

// ===========================================================================
// Cipher Algorithm (SSHABI.Layout.CipherAlgorithm, tags 0-5)
// ===========================================================================

/// SSH cipher algorithms.
/// Matches CipherAlgorithm in SSH.Transport.
type cipherAlgorithm =
  | @as(0) ChaCha20Poly1305
  | @as(1) Aes256Gcm
  | @as(2) Aes128Gcm
  | @as(3) Aes256Ctr
  | @as(4) Aes192Ctr
  | @as(5) Aes128Ctr

/// Decode from C-ABI tag value.
let cipherAlgorithmFromTag = (tag: int): option<cipherAlgorithm> =>
  switch tag {
  | 0 => Some(ChaCha20Poly1305)
  | 1 => Some(Aes256Gcm)
  | 2 => Some(Aes128Gcm)
  | 3 => Some(Aes256Ctr)
  | 4 => Some(Aes192Ctr)
  | 5 => Some(Aes128Ctr)
  | _ => None
  }

/// Encode to C-ABI tag value.
let cipherAlgorithmToTag = (c: cipherAlgorithm): int =>
  switch c {
  | ChaCha20Poly1305 => 0
  | Aes256Gcm => 1
  | Aes128Gcm => 2
  | Aes256Ctr => 3
  | Aes192Ctr => 4
  | Aes128Ctr => 5
  }

/// SSH cipher algorithm name string.
let cipherAlgorithmName = (c: cipherAlgorithm): string =>
  switch c {
  | ChaCha20Poly1305 => "chacha20-poly1305@openssh.com"
  | Aes256Gcm => "aes256-gcm@openssh.com"
  | Aes128Gcm => "aes128-gcm@openssh.com"
  | Aes256Ctr => "aes256-ctr"
  | Aes192Ctr => "aes192-ctr"
  | Aes128Ctr => "aes128-ctr"
  }

// ===========================================================================
// Channel Type (SSHABI.Layout.ChannelType, tags 0-3)
// ===========================================================================

/// SSH channel types (RFC 4254 Section 5.1).
/// Matches ChannelType in SSH.Channel.
type channelType =
  | @as(0) Session
  | @as(1) DirectTcpIp
  | @as(2) ForwardedTcpIp
  | @as(3) X11

/// Decode from C-ABI tag value.
let channelTypeFromTag = (tag: int): option<channelType> =>
  switch tag {
  | 0 => Some(Session)
  | 1 => Some(DirectTcpIp)
  | 2 => Some(ForwardedTcpIp)
  | 3 => Some(X11)
  | _ => None
  }

/// Encode to C-ABI tag value.
let channelTypeToTag = (ct: channelType): int =>
  switch ct {
  | Session => 0
  | DirectTcpIp => 1
  | ForwardedTcpIp => 2
  | X11 => 3
  }

/// SSH channel type name string.
let channelTypeName = (ct: channelType): string =>
  switch ct {
  | Session => "session"
  | DirectTcpIp => "direct-tcpip"
  | ForwardedTcpIp => "forwarded-tcpip"
  | X11 => "x11"
  }

// ===========================================================================
// Session State (SSHABI.Layout.SessionState, tags 0-4)
// ===========================================================================

/// SSH session states.
/// Matches SessionState in SSH.Session.
type sessionState =
  | @as(0) VersionExchange
  | @as(1) KeyExchange
  | @as(2) UserAuth
  | @as(3) SshAuthenticated
  | @as(4) Disconnected

/// Decode from C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(VersionExchange)
  | 1 => Some(KeyExchange)
  | 2 => Some(UserAuth)
  | 3 => Some(SshAuthenticated)
  | 4 => Some(Disconnected)
  | _ => None
  }

/// Encode to C-ABI tag value.
let sessionStateToTag = (s: sessionState): int =>
  switch s {
  | VersionExchange => 0
  | KeyExchange => 1
  | UserAuth => 2
  | SshAuthenticated => 3
  | Disconnected => 4
  }

/// Whether this is a terminal state.
let sessionStateIsTerminal = (s: sessionState): bool =>
  switch s {
  | Disconnected => true
  | _ => false
  }

// ===========================================================================
// Channel State (SSHABI.Layout.ChannelState, tags 0-3)
// ===========================================================================

/// SSH channel lifecycle states.
/// Matches ChannelState in SSH.Channel.
type channelState =
  | @as(0) Opening
  | @as(1) Open
  | @as(2) Closing
  | @as(3) Closed

/// Decode from C-ABI tag value.
let channelStateFromTag = (tag: int): option<channelState> =>
  switch tag {
  | 0 => Some(Opening)
  | 1 => Some(Open)
  | 2 => Some(Closing)
  | 3 => Some(Closed)
  | _ => None
  }

/// Encode to C-ABI tag value.
let channelStateToTag = (s: channelState): int =>
  switch s {
  | Opening => 0
  | Open => 1
  | Closing => 2
  | Closed => 3
  }

/// Whether DATA can be sent in this channel state.
let channelCanSendData = (s: channelState): bool =>
  switch s {
  | Open => true
  | Opening | Closing | Closed => false
  }

// ===========================================================================
// Disconnect Reason (SSHABI.Layout.DisconnectReason, tags 0-11)
// ===========================================================================

/// SSH disconnect reason codes (RFC 4253 Section 11.1).
/// Matches DisconnectReason in SSH.Session.
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

/// Decode from C-ABI tag value.
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

/// Encode to C-ABI tag value.
let disconnectReasonToTag = (r: disconnectReason): int =>
  switch r {
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

/// Human-readable disconnect reason description.
let disconnectReasonAsStr = (r: disconnectReason): string =>
  switch r {
  | HostNotAllowed => "Host not allowed to connect"
  | ProtocolError => "Protocol error"
  | KeyExchangeFailed => "Key exchange failed"
  | HostAuthFailed => "Host authentication failed"
  | MacError => "MAC error"
  | ServiceNotAvailable => "Service not available"
  | VersionNotSupported => "Protocol version not supported"
  | HostKeyNotVerifiable => "Host key not verifiable"
  | ConnectionLost => "Connection lost"
  | ByApplication => "Disconnected by application"
  | TooManyConnections => "Too many connections"
  | AuthCancelled => "Authentication cancelled by user"
  }

// ===========================================================================
// Channel Open Failure (SSHABI.Layout.ChannelOpenFailure, tags 0-3)
// ===========================================================================

/// SSH channel open failure reasons (RFC 4254 Section 5.1).
/// Matches ChannelOpenFailure in SSH.Channel.
type channelOpenFailure =
  | @as(0) AdminProhibited
  | @as(1) ConnectFailed
  | @as(2) UnknownChannelType
  | @as(3) ResourceShortage

/// Decode from C-ABI tag value.
let channelOpenFailureFromTag = (tag: int): option<channelOpenFailure> =>
  switch tag {
  | 0 => Some(AdminProhibited)
  | 1 => Some(ConnectFailed)
  | 2 => Some(UnknownChannelType)
  | 3 => Some(ResourceShortage)
  | _ => None
  }

/// Encode to C-ABI tag value.
let channelOpenFailureToTag = (f: channelOpenFailure): int =>
  switch f {
  | AdminProhibited => 0
  | ConnectFailed => 1
  | UnknownChannelType => 2
  | ResourceShortage => 3
  }

/// Human-readable failure reason.
let channelOpenFailureAsStr = (f: channelOpenFailure): string =>
  switch f {
  | AdminProhibited => "Administratively prohibited"
  | ConnectFailed => "Connect failed"
  | UnknownChannelType => "Unknown channel type"
  | ResourceShortage => "Resource shortage"
  }

// ===========================================================================
// Constants
// ===========================================================================

/// Standard SSH port (RFC 4253).
let sshPort = 22
