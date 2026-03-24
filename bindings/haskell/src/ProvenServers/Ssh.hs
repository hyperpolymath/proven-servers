-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SSH Bastion protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ssh
  (
    sshPort
  , SshMessageType(..)
  , sshMessageTypeToTag
  , sshMessageTypeFromTag
  , AuthMethod(..)
  , authMethodToTag
  , authMethodFromTag
  , isSecure
  , KexMethod(..)
  , kexMethodToTag
  , kexMethodFromTag
  , isEcc
  , ChannelType(..)
  , channelTypeToTag
  , channelTypeFromTag
  , isForwarding
  , BastionState(..)
  , bastionStateToTag
  , bastionStateFromTag
  , bastionStateCanTransitionTo
  , ChannelState(..)
  , channelStateToTag
  , channelStateFromTag
  , channelStateCanTransitionTo
  , DisconnectReason(..)
  , disconnectReasonToTag
  , disconnectReasonFromTag
  , isSecurityRelated
  , HostKeyAlgorithm(..)
  , hostKeyAlgorithmToTag
  , hostKeyAlgorithmFromTag
  , CipherAlgorithm(..)
  , cipherAlgorithmToTag
  , cipherAlgorithmFromTag
  , isAead
  , ChannelOpenFailure(..)
  , channelOpenFailureToTag
  , channelOpenFailureFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard SSH port (RFC 4253).
sshPort :: Word16
sshPort = 22

-- ---------------------------------------------------------------------------
-- SshMessageType
-- ---------------------------------------------------------------------------

-- | Standard SSH port (RFC 4253).
--
-- Tags 0-7 (8 constructors).
data SshMessageType
  = Kexinit  -- ^ Key exchange initialisation (tag 0).
  | Newkeys  -- ^ New keys established after key exchange (tag 1).
  | ServiceRequest  -- ^ Service request from client (tag 2).
  | UserauthRequest  -- ^ User authentication request (tag 3).
  | ChannelOpen  -- ^ Channel open request (tag 4).
  | ChannelData  -- ^ Channel data transfer (tag 5).
  | ChannelClose  -- ^ Channel close notification (tag 6).
  | Disconnect  -- ^ Disconnect notification (tag 7).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SshMessageType' to its ABI tag value.
sshMessageTypeToTag :: SshMessageType -> Word8
sshMessageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SshMessageType' from its ABI tag value.
sshMessageTypeFromTag :: Word8 -> Maybe SshMessageType
sshMessageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SshMessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthMethod
-- ---------------------------------------------------------------------------

-- | SSH authentication methods.
--
-- Tags 0-3 (4 constructors).
data AuthMethod
  = Publickey  -- ^ Public key authentication (tag 0).
  | Password  -- ^ Password authentication (tag 1).
  | KeyboardInteractive  -- ^ Keyboard-interactive authentication (tag 2).
  | AuthNone  -- ^ No authentication / "none" method (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | public key or keyboard-interactive with MFA.
isSecure :: AuthMethod -> Bool
isSecure Publickey = True
isSecure KeyboardInteractive = True
isSecure _ = False

-- ---------------------------------------------------------------------------
-- KexMethod
-- ---------------------------------------------------------------------------

-- | SSH key exchange methods.
--
-- Tags 0-5 (6 constructors).
data KexMethod
  = DiffieHellmanGroup14Sha256  -- ^ diffie-hellman-group14-sha256 (tag 0).
  | Curve25519Sha256  -- ^ curve25519-sha256 (tag 1).
  | DiffieHellmanGroup16Sha512  -- ^ diffie-hellman-group16-sha512 (tag 2).
  | DiffieHellmanGroup18Sha512  -- ^ diffie-hellman-group18-sha512 (tag 3).
  | EcdhSha2Nistp256  -- ^ ecdh-sha2-nistp256 (tag 4).
  | EcdhSha2Nistp384  -- ^ ecdh-sha2-nistp384 (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KexMethod' to its ABI tag value.
kexMethodToTag :: KexMethod -> Word8
kexMethodToTag = fromIntegral . fromEnum

-- | Decode a 'KexMethod' from its ABI tag value.
kexMethodFromTag :: Word8 -> Maybe KexMethod
kexMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KexMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this key exchange method uses elliptic curve cryptography.
isEcc :: KexMethod -> Bool
isEcc Curve25519Sha256 = True
isEcc EcdhSha2Nistp256 = True
isEcc EcdhSha2Nistp384 = True
isEcc _ = False

-- ---------------------------------------------------------------------------
-- ChannelType
-- ---------------------------------------------------------------------------

-- | SSH channel types.
--
-- Tags 0-3 (4 constructors).
data ChannelType
  = Session  -- ^ Interactive shell session (tag 0).
  | DirectTcpip  -- ^ Direct TCP/IP forwarding (tag 1).
  | ForwardedTcpip  -- ^ Forwarded TCP/IP from remote (tag 2).
  | X11  -- ^ X11 forwarding (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelType' to its ABI tag value.
channelTypeToTag :: ChannelType -> Word8
channelTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelType' from its ABI tag value.
channelTypeFromTag :: Word8 -> Maybe ChannelType
channelTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this channel type involves TCP/IP forwarding.
isForwarding :: ChannelType -> Bool
isForwarding DirectTcpip = True
isForwarding ForwardedTcpip = True
isForwarding _ = False

-- ---------------------------------------------------------------------------
-- BastionState
-- ---------------------------------------------------------------------------

-- | SSH bastion connection state machine.
--
-- Tags 0-5 (6 constructors).
data BastionState
  = Connected  -- ^ TCP connection established, no SSH handshake yet (tag 0).
  | KeyExchanged  -- ^ Key exchange completed successfully (tag 1).
  | Authenticated  -- ^ User authentication succeeded (tag 2).
  | ChannelOpen  -- ^ At least one channel is open (tag 3).
  | Active  -- ^ Actively transferring data (tag 4).
  | Closed  -- ^ Connection closed (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BastionState' to its ABI tag value.
bastionStateToTag :: BastionState -> Word8
bastionStateToTag = fromIntegral . fromEnum

-- | Decode a 'BastionState' from its ABI tag value.
bastionStateFromTag :: Word8 -> Maybe BastionState
bastionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BastionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | the ability to close from any state.
bastionStateCanTransitionTo :: BastionState -> BastionState -> Bool
bastionStateCanTransitionTo Connected KeyExchanged = True
bastionStateCanTransitionTo KeyExchanged Authenticated = True
bastionStateCanTransitionTo Authenticated ChannelOpen = True
bastionStateCanTransitionTo ChannelOpen Active = True
bastionStateCanTransitionTo _ Closed = True
bastionStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- ChannelState
-- ---------------------------------------------------------------------------

-- | SSH channel state machine.
--
-- Tags 0-3 (4 constructors).
data ChannelState
  = Opening  -- ^ Channel open request sent, awaiting confirmation (tag 0).
  | Open  -- ^ Channel is open and active (tag 1).
  | Closing  -- ^ Channel close has been initiated (tag 2).
  | Closed  -- ^ Channel is fully closed (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelState' to its ABI tag value.
channelStateToTag :: ChannelState -> Word8
channelStateToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelState' from its ABI tag value.
channelStateFromTag :: Word8 -> Maybe ChannelState
channelStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
channelStateCanTransitionTo :: ChannelState -> ChannelState -> Bool
channelStateCanTransitionTo Opening Open = True
channelStateCanTransitionTo Opening Closed = True
channelStateCanTransitionTo Open Closing = True
channelStateCanTransitionTo Closing Closed = True
channelStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- DisconnectReason
-- ---------------------------------------------------------------------------

-- | SSH disconnect reason codes.
--
-- Tags 0-11 (12 constructors).
data DisconnectReason
  = HostNotAllowed  -- ^ Host not allowed to connect (tag 0).
  | ProtocolError  -- ^ Protocol error detected (tag 1).
  | KeyExchangeFailed  -- ^ Key exchange failed (tag 2).
  | HostAuthFailed  -- ^ Host authentication failed (tag 3).
  | MacError  -- ^ MAC verification error (tag 4).
  | ServiceNotAvailable  -- ^ Requested service not available (tag 5).
  | VersionNotSupported  -- ^ Protocol version not supported (tag 6).
  | HostKeyNotVerifiable  -- ^ Host key not verifiable (tag 7).
  | ConnectionLost  -- ^ Connection lost unexpectedly (tag 8).
  | ByApplication  -- ^ Disconnected by application (tag 9).
  | TooManyConnections  -- ^ Too many concurrent connections (tag 10).
  | AuthCancelled  -- ^ Authentication cancelled by user (tag 11).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DisconnectReason' to its ABI tag value.
disconnectReasonToTag :: DisconnectReason -> Word8
disconnectReasonToTag = fromIntegral . fromEnum

-- | Decode a 'DisconnectReason' from its ABI tag value.
disconnectReasonFromTag :: Word8 -> Maybe DisconnectReason
disconnectReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DisconnectReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this disconnect reason indicates a security issue.
isSecurityRelated :: DisconnectReason -> Bool
isSecurityRelated HostNotAllowed = True
isSecurityRelated HostAuthFailed = True
isSecurityRelated MacError = True
isSecurityRelated HostKeyNotVerifiable = True
isSecurityRelated AuthCancelled = True
isSecurityRelated _ = False

-- ---------------------------------------------------------------------------
-- HostKeyAlgorithm
-- ---------------------------------------------------------------------------

-- | SSH host key algorithms.
--
-- Tags 0-3 (4 constructors).
data HostKeyAlgorithm
  = SshEd25519  -- ^ ssh-ed25519 (tag 0).
  | RsaSha2256  -- ^ rsa-sha2-256 (tag 1).
  | RsaSha2512  -- ^ rsa-sha2-512 (tag 2).
  | EcdsaNistp256  -- ^ ecdsa-sha2-nistp256 (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HostKeyAlgorithm' to its ABI tag value.
hostKeyAlgorithmToTag :: HostKeyAlgorithm -> Word8
hostKeyAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'HostKeyAlgorithm' from its ABI tag value.
hostKeyAlgorithmFromTag :: Word8 -> Maybe HostKeyAlgorithm
hostKeyAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HostKeyAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this algorithm uses elliptic curve cryptography.
isEcc :: HostKeyAlgorithm -> Bool
isEcc SshEd25519 = True
isEcc EcdsaNistp256 = True
isEcc _ = False

-- ---------------------------------------------------------------------------
-- CipherAlgorithm
-- ---------------------------------------------------------------------------

-- | SSH symmetric cipher algorithms.
--
-- Tags 0-5 (6 constructors).
data CipherAlgorithm
  = Chacha20Poly1305  -- ^ chacha20-poly1305@openssh.com (tag 0).
  | Aes256Gcm  -- ^ aes256-gcm@openssh.com (tag 1).
  | Aes128Gcm  -- ^ aes128-gcm@openssh.com (tag 2).
  | Aes256Ctr  -- ^ aes256-ctr (tag 3).
  | Aes192Ctr  -- ^ aes192-ctr (tag 4).
  | Aes128Ctr  -- ^ aes128-ctr (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CipherAlgorithm' to its ABI tag value.
cipherAlgorithmToTag :: CipherAlgorithm -> Word8
cipherAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'CipherAlgorithm' from its ABI tag value.
cipherAlgorithmFromTag :: Word8 -> Maybe CipherAlgorithm
cipherAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CipherAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this cipher provides authenticated encryption (AEAD).
isAead :: CipherAlgorithm -> Bool
isAead Chacha20Poly1305 = True
isAead Aes256Gcm = True
isAead Aes128Gcm = True
isAead _ = False

-- ---------------------------------------------------------------------------
-- ChannelOpenFailure
-- ---------------------------------------------------------------------------

-- | Reasons an SSH channel open request can be rejected.
--
-- Tags 0-3 (4 constructors).
data ChannelOpenFailure
  = AdminProhibited  -- ^ Administratively prohibited (tag 0).
  | ConnectFailed  -- ^ Connection to forwarding target failed (tag 1).
  | UnknownChannelType  -- ^ Unknown channel type requested (tag 2).
  | ResourceShortage  -- ^ Insufficient resources on server (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelOpenFailure' to its ABI tag value.
channelOpenFailureToTag :: ChannelOpenFailure -> Word8
channelOpenFailureToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelOpenFailure' from its ABI tag value.
channelOpenFailureFromTag :: Word8 -> Maybe ChannelOpenFailure
channelOpenFailureFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelOpenFailure)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
