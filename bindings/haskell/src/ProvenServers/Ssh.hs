-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | SSH protocol types for proven-servers.
--
-- SSH Bastion types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ssh
  ( -- * ADT types matching Idris2 ABI
      SshMessageType(..)
    , AuthMethod(..)
    , KexMethod(..)
    , ChannelType(..)
    , BastionState(..)
    , ChannelState(..)
    , DisconnectReason(..)
    , HostKeyAlgorithm(..)
    , CipherAlgorithm(..)
    , ChannelOpenFailure(..)
    , sshMessageTypeToTag
    , sshMessageTypeFromTag
    , authMethodToTag
    , authMethodFromTag
    , kexMethodToTag
    , kexMethodFromTag
    , channelTypeToTag
    , channelTypeFromTag
    , bastionStateToTag
    , bastionStateFromTag
    , channelStateToTag
    , channelStateFromTag
    , disconnectReasonToTag
    , disconnectReasonFromTag
    , hostKeyAlgorithmToTag
    , hostKeyAlgorithmFromTag
    , cipherAlgorithmToTag
    , cipherAlgorithmFromTag
    , channelOpenFailureToTag
    , channelOpenFailureFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SshMessageType
-- ---------------------------------------------------------------------------

-- | SshMessageType type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data SshMessageType
  = Kexinit  -- ^ Tag 0.
  | Newkeys  -- ^ Tag 1.
  | ServiceRequest  -- ^ Tag 2.
  | UserauthRequest  -- ^ Tag 3.
  | SshMessageType_ChannelOpen  -- ^ Tag 4.
  | ChannelData  -- ^ Tag 5.
  | ChannelClose  -- ^ Tag 6.
  | Disconnect  -- ^ Tag 7.
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

-- | AuthMethod type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AuthMethod
  = Publickey  -- ^ Tag 0.
  | Password  -- ^ Tag 1.
  | KeyboardInteractive  -- ^ Tag 2.
  | AuthNone  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthMethod' to its ABI tag value.
authMethodToTag :: AuthMethod -> Word8
authMethodToTag = fromIntegral . fromEnum

-- | Decode a 'AuthMethod' from its ABI tag value.
authMethodFromTag :: Word8 -> Maybe AuthMethod
authMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- KexMethod
-- ---------------------------------------------------------------------------

-- | KexMethod type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data KexMethod
  = DiffieHellmanGroup14Sha256  -- ^ Tag 0.
  | Curve25519Sha256  -- ^ Tag 1.
  | DiffieHellmanGroup16Sha512  -- ^ Tag 2.
  | DiffieHellmanGroup18Sha512  -- ^ Tag 3.
  | EcdhSha2Nistp256  -- ^ Tag 4.
  | EcdhSha2Nistp384  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'KexMethod' to its ABI tag value.
kexMethodToTag :: KexMethod -> Word8
kexMethodToTag = fromIntegral . fromEnum

-- | Decode a 'KexMethod' from its ABI tag value.
kexMethodFromTag :: Word8 -> Maybe KexMethod
kexMethodFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: KexMethod)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChannelType
-- ---------------------------------------------------------------------------

-- | ChannelType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ChannelType
  = Session  -- ^ Tag 0.
  | DirectTcpip  -- ^ Tag 1.
  | ForwardedTcpip  -- ^ Tag 2.
  | X11  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelType' to its ABI tag value.
channelTypeToTag :: ChannelType -> Word8
channelTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelType' from its ABI tag value.
channelTypeFromTag :: Word8 -> Maybe ChannelType
channelTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BastionState
-- ---------------------------------------------------------------------------

-- | BastionState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data BastionState
  = Connected  -- ^ Tag 0.
  | KeyExchanged  -- ^ Tag 1.
  | Authenticated  -- ^ Tag 2.
  | BastionState_ChannelOpen  -- ^ Tag 3.
  | Active  -- ^ Tag 4.
  | BastionState_Closed  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BastionState' to its ABI tag value.
bastionStateToTag :: BastionState -> Word8
bastionStateToTag = fromIntegral . fromEnum

-- | Decode a 'BastionState' from its ABI tag value.
bastionStateFromTag :: Word8 -> Maybe BastionState
bastionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BastionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChannelState
-- ---------------------------------------------------------------------------

-- | ChannelState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ChannelState
  = Opening  -- ^ Tag 0.
  | Open  -- ^ Tag 1.
  | Closing  -- ^ Tag 2.
  | ChannelState_Closed  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelState' to its ABI tag value.
channelStateToTag :: ChannelState -> Word8
channelStateToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelState' from its ABI tag value.
channelStateFromTag :: Word8 -> Maybe ChannelState
channelStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DisconnectReason
-- ---------------------------------------------------------------------------

-- | DisconnectReason type matching the Idris2 ABI.
--
-- Tags 0-11 (12 constructors).
data DisconnectReason
  = HostNotAllowed  -- ^ Tag 0.
  | ProtocolError  -- ^ Tag 1.
  | KeyExchangeFailed  -- ^ Tag 2.
  | HostAuthFailed  -- ^ Tag 3.
  | MacError  -- ^ Tag 4.
  | ServiceNotAvailable  -- ^ Tag 5.
  | VersionNotSupported  -- ^ Tag 6.
  | HostKeyNotVerifiable  -- ^ Tag 7.
  | ConnectionLost  -- ^ Tag 8.
  | ByApplication  -- ^ Tag 9.
  | TooManyConnections  -- ^ Tag 10.
  | AuthCancelled  -- ^ Tag 11.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DisconnectReason' to its ABI tag value.
disconnectReasonToTag :: DisconnectReason -> Word8
disconnectReasonToTag = fromIntegral . fromEnum

-- | Decode a 'DisconnectReason' from its ABI tag value.
disconnectReasonFromTag :: Word8 -> Maybe DisconnectReason
disconnectReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DisconnectReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- HostKeyAlgorithm
-- ---------------------------------------------------------------------------

-- | HostKeyAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data HostKeyAlgorithm
  = SshEd25519  -- ^ Tag 0.
  | RsaSha2256  -- ^ Tag 1.
  | RsaSha2512  -- ^ Tag 2.
  | EcdsaNistp256  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'HostKeyAlgorithm' to its ABI tag value.
hostKeyAlgorithmToTag :: HostKeyAlgorithm -> Word8
hostKeyAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'HostKeyAlgorithm' from its ABI tag value.
hostKeyAlgorithmFromTag :: Word8 -> Maybe HostKeyAlgorithm
hostKeyAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: HostKeyAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- CipherAlgorithm
-- ---------------------------------------------------------------------------

-- | CipherAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data CipherAlgorithm
  = Chacha20Poly1305  -- ^ Tag 0.
  | Aes256Gcm  -- ^ Tag 1.
  | Aes128Gcm  -- ^ Tag 2.
  | Aes256Ctr  -- ^ Tag 3.
  | Aes192Ctr  -- ^ Tag 4.
  | Aes128Ctr  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CipherAlgorithm' to its ABI tag value.
cipherAlgorithmToTag :: CipherAlgorithm -> Word8
cipherAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'CipherAlgorithm' from its ABI tag value.
cipherAlgorithmFromTag :: Word8 -> Maybe CipherAlgorithm
cipherAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CipherAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChannelOpenFailure
-- ---------------------------------------------------------------------------

-- | ChannelOpenFailure type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ChannelOpenFailure
  = AdminProhibited  -- ^ Tag 0.
  | ConnectFailed  -- ^ Tag 1.
  | UnknownChannelType  -- ^ Tag 2.
  | ResourceShortage  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelOpenFailure' to its ABI tag value.
channelOpenFailureToTag :: ChannelOpenFailure -> Word8
channelOpenFailureToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelOpenFailure' from its ABI tag value.
channelOpenFailureFromTag :: Word8 -> Maybe ChannelOpenFailure
channelOpenFailureFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelOpenFailure)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
