-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | VPN protocol types for proven-servers.
--
-- VPN/IPsec types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Vpn
  ( -- * ADT types matching Idris2 ABI
      TunnelType(..)
    , TunnelPhase(..)
    , EncryptionAlgorithm(..)
    , IntegrityAlgorithm(..)
    , DhGroup(..)
    , SaLifecycle(..)
    , IkeVersion(..)
    , VpnError(..)
    , tunnelTypeToTag
    , tunnelTypeFromTag
    , tunnelPhaseToTag
    , tunnelPhaseFromTag
    , encryptionAlgorithmToTag
    , encryptionAlgorithmFromTag
    , integrityAlgorithmToTag
    , integrityAlgorithmFromTag
    , dhGroupToTag
    , dhGroupFromTag
    , saLifecycleToTag
    , saLifecycleFromTag
    , ikeVersionToTag
    , ikeVersionFromTag
    , vpnErrorToTag
    , vpnErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- TunnelType
-- ---------------------------------------------------------------------------

-- | TunnelType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data TunnelType
  = Ipsec  -- ^ Tag 0.
  | Wireguard  -- ^ Tag 1.
  | Openvpn  -- ^ Tag 2.
  | L2tp  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TunnelType' to its ABI tag value.
tunnelTypeToTag :: TunnelType -> Word8
tunnelTypeToTag = fromIntegral . fromEnum

-- | Decode a 'TunnelType' from its ABI tag value.
tunnelTypeFromTag :: Word8 -> Maybe TunnelType
tunnelTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TunnelType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TunnelPhase
-- ---------------------------------------------------------------------------

-- | TunnelPhase type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data TunnelPhase
  = Idle  -- ^ Tag 0.
  | Phase1Init  -- ^ Tag 1.
  | Phase1Auth  -- ^ Tag 2.
  | Phase1Done  -- ^ Tag 3.
  | Phase2Negotiating  -- ^ Tag 4.
  | Established  -- ^ Tag 5.
  | TunnelPhase_Expired  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TunnelPhase' to its ABI tag value.
tunnelPhaseToTag :: TunnelPhase -> Word8
tunnelPhaseToTag = fromIntegral . fromEnum

-- | Decode a 'TunnelPhase' from its ABI tag value.
tunnelPhaseFromTag :: Word8 -> Maybe TunnelPhase
tunnelPhaseFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TunnelPhase)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EncryptionAlgorithm
-- ---------------------------------------------------------------------------

-- | EncryptionAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data EncryptionAlgorithm
  = Aes128Cbc  -- ^ Tag 0.
  | Aes256Cbc  -- ^ Tag 1.
  | Aes128Gcm  -- ^ Tag 2.
  | Aes256Gcm  -- ^ Tag 3.
  | Chacha20Poly1305  -- ^ Tag 4.
  | NullCipher  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncryptionAlgorithm' to its ABI tag value.
encryptionAlgorithmToTag :: EncryptionAlgorithm -> Word8
encryptionAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'EncryptionAlgorithm' from its ABI tag value.
encryptionAlgorithmFromTag :: Word8 -> Maybe EncryptionAlgorithm
encryptionAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncryptionAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IntegrityAlgorithm
-- ---------------------------------------------------------------------------

-- | IntegrityAlgorithm type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data IntegrityAlgorithm
  = HmacSha1  -- ^ Tag 0.
  | HmacSha256  -- ^ Tag 1.
  | HmacSha384  -- ^ Tag 2.
  | HmacSha512  -- ^ Tag 3.
  | NoIntegrity  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IntegrityAlgorithm' to its ABI tag value.
integrityAlgorithmToTag :: IntegrityAlgorithm -> Word8
integrityAlgorithmToTag = fromIntegral . fromEnum

-- | Decode a 'IntegrityAlgorithm' from its ABI tag value.
integrityAlgorithmFromTag :: Word8 -> Maybe IntegrityAlgorithm
integrityAlgorithmFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IntegrityAlgorithm)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DhGroup
-- ---------------------------------------------------------------------------

-- | DhGroup type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data DhGroup
  = Dh14  -- ^ Tag 0.
  | Ecp256  -- ^ Tag 1.
  | Ecp384  -- ^ Tag 2.
  | Curve25519  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DhGroup' to its ABI tag value.
dhGroupToTag :: DhGroup -> Word8
dhGroupToTag = fromIntegral . fromEnum

-- | Decode a 'DhGroup' from its ABI tag value.
dhGroupFromTag :: Word8 -> Maybe DhGroup
dhGroupFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DhGroup)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SaLifecycle
-- ---------------------------------------------------------------------------

-- | SaLifecycle type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SaLifecycle
  = None  -- ^ Tag 0.
  | Active  -- ^ Tag 1.
  | Rekeying  -- ^ Tag 2.
  | SaLifecycle_Expired  -- ^ Tag 3.
  | Deleted  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SaLifecycle' to its ABI tag value.
saLifecycleToTag :: SaLifecycle -> Word8
saLifecycleToTag = fromIntegral . fromEnum

-- | Decode a 'SaLifecycle' from its ABI tag value.
saLifecycleFromTag :: Word8 -> Maybe SaLifecycle
saLifecycleFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SaLifecycle)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IkeVersion
-- ---------------------------------------------------------------------------

-- | IkeVersion type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data IkeVersion
  = V1  -- ^ Tag 0.
  | V2  -- ^ Tag 1.
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

-- | VpnError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data VpnError
  = AuthenticationFailed  -- ^ Tag 0.
  | NoProposalChosen  -- ^ Tag 1.
  | LifetimeExpired  -- ^ Tag 2.
  | InvalidSpi  -- ^ Tag 3.
  | ReplayDetected  -- ^ Tag 4.
  | NegotiationTimeout  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'VpnError' to its ABI tag value.
vpnErrorToTag :: VpnError -> Word8
vpnErrorToTag = fromIntegral . fromEnum

-- | Decode a 'VpnError' from its ABI tag value.
vpnErrorFromTag :: Word8 -> Maybe VpnError
vpnErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: VpnError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
