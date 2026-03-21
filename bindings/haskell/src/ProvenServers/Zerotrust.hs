-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Zero Trust protocol types for proven-servers.
--
-- Zero Trust architecture types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Zerotrust
  ( -- * ADT types matching Idris2 ABI
      PolicyType(..)
    , IdentityConfidence(..)
    , DeviceTrustScore(..)
    , AccessDecision(..)
    , ContextSignalKind(..)
    , AuthFactor(..)
    , policyTypeToTag
    , policyTypeFromTag
    , identityConfidenceToTag
    , identityConfidenceFromTag
    , deviceTrustScoreToTag
    , deviceTrustScoreFromTag
    , accessDecisionToTag
    , accessDecisionFromTag
    , contextSignalKindToTag
    , contextSignalKindFromTag
    , authFactorToTag
    , authFactorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PolicyType
-- ---------------------------------------------------------------------------

-- | PolicyType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data PolicyType
  = AlwaysVerify  -- ^ Tag 0.
  | NeverTrust  -- ^ Tag 1.
  | LeastPrivilege  -- ^ Tag 2.
  | MicroSegmentation  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PolicyType' to its ABI tag value.
policyTypeToTag :: PolicyType -> Word8
policyTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PolicyType' from its ABI tag value.
policyTypeFromTag :: Word8 -> Maybe PolicyType
policyTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PolicyType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IdentityConfidence
-- ---------------------------------------------------------------------------

-- | IdentityConfidence type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data IdentityConfidence
  = Unverified  -- ^ Tag 0.
  | BasicAuth  -- ^ Tag 1.
  | MfaVerified  -- ^ Tag 2.
  | StrongAuth  -- ^ Tag 3.
  | ContinuousAuth  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IdentityConfidence' to its ABI tag value.
identityConfidenceToTag :: IdentityConfidence -> Word8
identityConfidenceToTag = fromIntegral . fromEnum

-- | Decode a 'IdentityConfidence' from its ABI tag value.
identityConfidenceFromTag :: Word8 -> Maybe IdentityConfidence
identityConfidenceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IdentityConfidence)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DeviceTrustScore
-- ---------------------------------------------------------------------------

-- | DeviceTrustScore type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data DeviceTrustScore
  = DeviceUnknown  -- ^ Tag 0.
  | DevicePartial  -- ^ Tag 1.
  | DeviceCompliant  -- ^ Tag 2.
  | DeviceManaged  -- ^ Tag 3.
  | DeviceHardened  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DeviceTrustScore' to its ABI tag value.
deviceTrustScoreToTag :: DeviceTrustScore -> Word8
deviceTrustScoreToTag = fromIntegral . fromEnum

-- | Decode a 'DeviceTrustScore' from its ABI tag value.
deviceTrustScoreFromTag :: Word8 -> Maybe DeviceTrustScore
deviceTrustScoreFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DeviceTrustScore)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AccessDecision
-- ---------------------------------------------------------------------------

-- | AccessDecision type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data AccessDecision
  = Allow  -- ^ Tag 0.
  | Deny  -- ^ Tag 1.
  | Challenge  -- ^ Tag 2.
  | StepUp  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AccessDecision' to its ABI tag value.
accessDecisionToTag :: AccessDecision -> Word8
accessDecisionToTag = fromIntegral . fromEnum

-- | Decode a 'AccessDecision' from its ABI tag value.
accessDecisionFromTag :: Word8 -> Maybe AccessDecision
accessDecisionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AccessDecision)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ContextSignalKind
-- ---------------------------------------------------------------------------

-- | ContextSignalKind type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ContextSignalKind
  = Location  -- ^ Tag 0.
  | Time  -- ^ Tag 1.
  | Device  -- ^ Tag 2.
  | Behavior  -- ^ Tag 3.
  | Network  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContextSignalKind' to its ABI tag value.
contextSignalKindToTag :: ContextSignalKind -> Word8
contextSignalKindToTag = fromIntegral . fromEnum

-- | Decode a 'ContextSignalKind' from its ABI tag value.
contextSignalKindFromTag :: Word8 -> Maybe ContextSignalKind
contextSignalKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContextSignalKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- AuthFactor
-- ---------------------------------------------------------------------------

-- | AuthFactor type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data AuthFactor
  = Certificate  -- ^ Tag 0.
  | Token  -- ^ Tag 1.
  | Biometric  -- ^ Tag 2.
  | Fido2  -- ^ Tag 3.
  | Totp  -- ^ Tag 4.
  | Push  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthFactor' to its ABI tag value.
authFactorToTag :: AuthFactor -> Word8
authFactorToTag = fromIntegral . fromEnum

-- | Decode a 'AuthFactor' from its ABI tag value.
authFactorFromTag :: Word8 -> Maybe AuthFactor
authFactorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthFactor)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
