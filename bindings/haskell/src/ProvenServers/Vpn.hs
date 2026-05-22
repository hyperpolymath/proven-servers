-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | VPN (Virtual Private Network) types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Vpn
  (
    ikePort
  , ikeNattPort
  , wireguardPort
  , openvpnPort
  , TunnelType(..)
  , tunnelTypeToTag
  , tunnelTypeFromTag
  , usesIke
  , isKernelLevel
  , TunnelPhase(..)
  , tunnelPhaseToTag
  , tunnelPhaseFromTag
  , isEstablished
  , isNegotiating
  , phase1Complete
  , EncryptionAlgorithm(..)
  , encryptionAlgorithmToTag
  , encryptionAlgorithmFromTag
  , isAead
  , providesConfidentiality
  , IntegrityAlgorithm(..)
  , integrityAlgorithmToTag
  , integrityAlgorithmFromTag
  , providesIntegrity
  , DhGroup(..)
  , dhGroupToTag
  , dhGroupFromTag
  , isEcc
  , SaLifecycle(..)
  , saLifecycleToTag
  , saLifecycleFromTag
  , isUsable
  , isTerminated
  , IkeVersion(..)
  , ikeVersionToTag
  , ikeVersionFromTag
  , VpnError(..)
  , vpnErrorToTag
  , vpnErrorFromTag
  , isSecurityConcern
  , isRetryable
  ) where

import Data.Word (Word16, Word8)

-- | Standard IKE (Internet Key Exchange) port.
ikePort :: Word16
ikePort = 500

-- | IKE NAT-Traversal port (RFC 3947).
ikeNattPort :: Word16
ikeNattPort = 4500

-- | WireGuard default listening port.
wireguardPort :: Word16
wireguardPort = 51820

-- | OpenVPN default port.
openvpnPort :: Word16
openvpnPort = 1194

-- ---------------------------------------------------------------------------
-- TunnelType
-- ---------------------------------------------------------------------------

-- | WireGuard default listening port.
--
-- Tags 0-3 (4 constructors).
data TunnelType
  = Ipsec  -- ^ IPsec — RFC 4301 (tag 0).
  | Wireguard  -- ^ WireGuard — modern kernel-level VPN (tag 1).
  | Openvpn  -- ^ OpenVPN — TLS-based VPN (tag 2).
  | L2tp  -- ^ L2TP — Layer 2 Tunneling Protocol (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TunnelType' to its ABI tag value.
tunnelTypeToTag :: TunnelType -> Word8
tunnelTypeToTag = fromIntegral . fromEnum

-- | Decode a 'TunnelType' from its ABI tag value.
tunnelTypeFromTag :: Word8 -> Maybe TunnelType
tunnelTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TunnelType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this tunnel type uses IKE for key exchange.
usesIke :: TunnelType -> Bool
usesIke Ipsec = True
usesIke L2tp = True
usesIke _ = False

-- | Whether this tunnel type operates at the kernel level.
isKernelLevel :: TunnelType -> Bool
isKernelLevel Ipsec = True
isKernelLevel Wireguard = True
isKernelLevel _ = False

-- ---------------------------------------------------------------------------
-- TunnelPhase
-- ---------------------------------------------------------------------------

-- | VPN tunnel negotiation phases.
--
-- Tags 0-6 (7 constructors).
data TunnelPhase
  = Idle  -- ^ No tunnel negotiation in progress (tag 0).
  | Phase1Init  -- ^ IKE Phase 1 initial exchange started (tag 1).
  | Phase1Auth  -- ^ IKE Phase 1 authentication in progress (tag 2).
  | Phase1Done  -- ^ IKE Phase 1 complete — IKE SA established (tag 3).
  | Phase2Negotiating  -- ^ IKE Phase 2 / Child SA negotiation (tag 4).
  | Established  -- ^ Tunnel established and carrying traffic (tag 5).
  | Expired  -- ^ Security Association has expired (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TunnelPhase' to its ABI tag value.
tunnelPhaseToTag :: TunnelPhase -> Word8
tunnelPhaseToTag = fromIntegral . fromEnum

-- | Decode a 'TunnelPhase' from its ABI tag value.
tunnelPhaseFromTag :: Word8 -> Maybe TunnelPhase
tunnelPhaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TunnelPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the tunnel is carrying traffic.
isEstablished :: TunnelPhase -> Bool
isEstablished Established = True
isEstablished _ = False

-- | Whether negotiation is in progress.
isNegotiating :: TunnelPhase -> Bool
isNegotiating Phase1Init = True
isNegotiating Phase1Auth = True
isNegotiating Phase2Negotiating = True
isNegotiating _ = False

-- | Whether Phase 1 (IKE SA) is complete.
phase1Complete :: TunnelPhase -> Bool
phase1Complete Phase1Done = True
phase1Complete Phase2Negotiating = True
phase1Complete Established = True
phase1Complete _ = False

-- ---------------------------------------------------------------------------
-- EncryptionAlgorithm
-- ---------------------------------------------------------------------------

-- | VPN encryption algorithms.
--
-- Tags 0-5 (6 constructors).
data EncryptionAlgorithm
  = Aes128Cbc  -- ^ AES-128-CBC (tag 0).
  | Aes256Cbc  -- ^ AES-256-CBC (tag 1).
  | Aes128Gcm  -- ^ AES-128-GCM (AEAD) (tag 2).
  | Aes256Gcm  -- ^ AES-256-GCM (AEAD) (tag 3).
  | Chacha20Poly1305  -- ^ ChaCha20-Poly1305 (AEAD) (tag 4).
  | NullCipher  -- ^ Null cipher — no encryption (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncryptionAlgorithm' to its ABI tag value.
encryptionAlgorithmToTag :: EncryptionAlgorithm -> Word8
encryptionAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'EncryptionAlgorithm' from its ABI tag value.
encryptionAlgorithmFromTag :: Word8 -> Maybe EncryptionAlgorithm
encryptionAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncryptionAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this algorithm provides authenticated encryption (AEAD).
isAead :: EncryptionAlgorithm -> Bool
isAead Aes128Gcm = True
isAead Aes256Gcm = True
isAead Chacha20Poly1305 = True
isAead _ = False

-- | Whether this algorithm actually encrypts data.
providesConfidentiality :: EncryptionAlgorithm -> Bool
providesConfidentiality NullCipher = False
providesConfidentiality _ = True

-- ---------------------------------------------------------------------------
-- IntegrityAlgorithm
-- ---------------------------------------------------------------------------

-- | VPN integrity/MAC algorithms.
--
-- Tags 0-4 (5 constructors).
data IntegrityAlgorithm
  = HmacSha1  -- ^ HMAC-SHA-1-96 (tag 0).
  | HmacSha256  -- ^ HMAC-SHA-256-128 (tag 1).
  | HmacSha384  -- ^ HMAC-SHA-384-192 (tag 2).
  | HmacSha512  -- ^ HMAC-SHA-512-256 (tag 3).
  | NoIntegrity  -- ^ No integrity check (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IntegrityAlgorithm' to its ABI tag value.
integrityAlgorithmToTag :: IntegrityAlgorithm -> Word8
integrityAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'IntegrityAlgorithm' from its ABI tag value.
integrityAlgorithmFromTag :: Word8 -> Maybe IntegrityAlgorithm
integrityAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IntegrityAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this algorithm provides integrity protection.
providesIntegrity :: IntegrityAlgorithm -> Bool
providesIntegrity NoIntegrity = False
providesIntegrity _ = True

-- ---------------------------------------------------------------------------
-- DhGroup
-- ---------------------------------------------------------------------------

-- | Diffie-Hellman key exchange groups.
--
-- Tags 0-3 (4 constructors).
data DhGroup
  = Dh14  -- ^ DH Group 14 — 2048-bit MODP (tag 0).
  | Ecp256  -- ^ ECP-256 — 256-bit Elliptic Curve (tag 1).
  | Ecp384  -- ^ ECP-384 — 384-bit Elliptic Curve (tag 2).
  | Curve25519  -- ^ Curve25519 — modern elliptic curve (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DhGroup' to its ABI tag value.
dhGroupToTag :: DhGroup -> Word8
dhGroupToTag = fromIntegral . fromEnum

-- | Decode a 'DhGroup' from its ABI tag value.
dhGroupFromTag :: Word8 -> Maybe DhGroup
dhGroupFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DhGroup)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this group uses elliptic curve cryptography.
isEcc :: DhGroup -> Bool
isEcc Ecp256 = True
isEcc Ecp384 = True
isEcc Curve25519 = True
isEcc _ = False

-- ---------------------------------------------------------------------------
-- SaLifecycle
-- ---------------------------------------------------------------------------

-- | Security Association lifecycle states.
--
-- Tags 0-4 (5 constructors).
data SaLifecycle
  = None  -- ^ No SA exists (tag 0).
  | Active  -- ^ SA is active and carrying traffic (tag 1).
  | Rekeying  -- ^ SA is being rekeyed (tag 2).
  | Expired  -- ^ SA lifetime has expired (tag 3).
  | Deleted  -- ^ SA has been deleted (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SaLifecycle' to its ABI tag value.
saLifecycleToTag :: SaLifecycle -> Word8
saLifecycleToTag = fromIntegral . fromEnum

-- | Decode a 'SaLifecycle' from its ABI tag value.
saLifecycleFromTag :: Word8 -> Maybe SaLifecycle
saLifecycleFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SaLifecycle)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the SA is usable for traffic.
isUsable :: SaLifecycle -> Bool
isUsable Active = True
isUsable Rekeying = True
isUsable _ = False

-- | Whether the SA has been terminated.
isTerminated :: SaLifecycle -> Bool
isTerminated Expired = True
isTerminated Deleted = True
isTerminated _ = False

-- ---------------------------------------------------------------------------
-- IkeVersion
-- ---------------------------------------------------------------------------

-- | IKE (Internet Key Exchange) protocol versions.
--
-- Tags 0-1 (2 constructors).
data IkeVersion
  = V1  -- ^ IKEv1 (RFC 2409) (tag 0).
  | V2  -- ^ IKEv2 (RFC 7296) (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IkeVersion' to its ABI tag value.
ikeVersionToTag :: IkeVersion -> Word8
ikeVersionToTag = fromIntegral . fromEnum

-- | Decode a 'IkeVersion' from its ABI tag value.
ikeVersionFromTag :: Word8 -> Maybe IkeVersion
ikeVersionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IkeVersion)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- VpnError
-- ---------------------------------------------------------------------------

-- | VPN error codes.
--
-- Tags 0-5 (6 constructors).
data VpnError
  = AuthenticationFailed  -- ^ Authentication failed (tag 0).
  | NoProposalChosen  -- ^ No acceptable proposal from peer (tag 1).
  | LifetimeExpired  -- ^ SA lifetime expired (tag 2).
  | InvalidSpi  -- ^ Invalid Security Parameter Index (tag 3).
  | ReplayDetected  -- ^ Replay attack detected (tag 4).
  | NegotiationTimeout  -- ^ Negotiation timed out (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VpnError' to its ABI tag value.
vpnErrorToTag :: VpnError -> Word8
vpnErrorToTag = fromIntegral . fromEnum

-- | Decode a 'VpnError' from its ABI tag value.
vpnErrorFromTag :: Word8 -> Maybe VpnError
vpnErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VpnError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error indicates a security concern.
isSecurityConcern :: VpnError -> Bool
isSecurityConcern AuthenticationFailed = True
isSecurityConcern InvalidSpi = True
isSecurityConcern ReplayDetected = True
isSecurityConcern _ = False

-- | Whether this error is likely transient and retryable.
isRetryable :: VpnError -> Bool
isRetryable NegotiationTimeout = True
isRetryable LifetimeExpired = True
isRetryable _ = False
