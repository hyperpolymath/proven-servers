-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Zero Trust types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Zerotrust
  (
    PolicyType(..)
  , policyTypeToTag
  , policyTypeFromTag
  , IdentityConfidence(..)
  , identityConfidenceToTag
  , identityConfidenceFromTag
  , DeviceTrustScore(..)
  , deviceTrustScoreToTag
  , deviceTrustScoreFromTag
  , AccessDecision(..)
  , accessDecisionToTag
  , accessDecisionFromTag
  , isGranted
  , ContextSignalKind(..)
  , contextSignalKindToTag
  , contextSignalKindFromTag
  , AuthFactor(..)
  , authFactorToTag
  , authFactorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- PolicyType
-- ---------------------------------------------------------------------------

-- | Zero Trust policy types.
--
-- Tags 0-3 (4 constructors).
data PolicyType
  = AlwaysVerify  -- ^ AlwaysVerify (tag 0).
  | NeverTrust  -- ^ NeverTrust (tag 1).
  | LeastPrivilege  -- ^ LeastPrivilege (tag 2).
  | MicroSegmentation  -- ^ MicroSegmentation (tag 3).
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

-- | Identity verification confidence.
--
-- Tags 0-4 (5 constructors).
data IdentityConfidence
  = Unverified  -- ^ Unverified (tag 0).
  | BasicAuth  -- ^ BasicAuth (tag 1).
  | MfaVerified  -- ^ MFA verified (tag 2).
  | StrongAuth  -- ^ StrongAuth (tag 3).
  | ContinuousAuth  -- ^ ContinuousAuth (tag 4).
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

-- | Device trust assessment.
--
-- Tags 0-4 (5 constructors).
data DeviceTrustScore
  = DeviceUnknown  -- ^ DeviceUnknown (tag 0).
  | DevicePartial  -- ^ DevicePartial (tag 1).
  | DeviceCompliant  -- ^ DeviceCompliant (tag 2).
  | DeviceManaged  -- ^ DeviceManaged (tag 3).
  | DeviceHardened  -- ^ DeviceHardened (tag 4).
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

-- | Zero Trust access decisions.
--
-- Tags 0-3 (4 constructors).
data AccessDecision
  = Allow  -- ^ Allow (tag 0).
  | Deny  -- ^ Deny (tag 1).
  | Challenge  -- ^ Challenge (tag 2).
  | StepUp  -- ^ StepUp (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AccessDecision' to its ABI tag value.
accessDecisionToTag :: AccessDecision -> Word8
accessDecisionToTag = fromIntegral . fromEnum

-- | Decode a 'AccessDecision' from its ABI tag value.
accessDecisionFromTag :: Word8 -> Maybe AccessDecision
accessDecisionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AccessDecision)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether access is granted.
isGranted :: AccessDecision -> Bool
isGranted Allow = True
isGranted _ = False

-- ---------------------------------------------------------------------------
-- ContextSignalKind
-- ---------------------------------------------------------------------------

-- | Context signals for trust evaluation.
--
-- Tags 0-4 (5 constructors).
data ContextSignalKind
  = Location  -- ^ Location (tag 0).
  | Time  -- ^ Time (tag 1).
  | Device  -- ^ Device (tag 2).
  | Behavior  -- ^ Behavior (tag 3).
  | Network  -- ^ Network (tag 4).
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

-- | Authentication factor types.
--
-- Tags 0-5 (6 constructors).
data AuthFactor
  = Certificate  -- ^ Certificate (tag 0).
  | Token  -- ^ Token (tag 1).
  | Biometric  -- ^ Biometric (tag 2).
  | Fido2  -- ^ FIDO2 (tag 3).
  | Totp  -- ^ TOTP (tag 4).
  | Push  -- ^ Push (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'AuthFactor' to its ABI tag value.
authFactorToTag :: AuthFactor -> Word8
authFactorToTag = fromIntegral . fromEnum

-- | Decode a 'AuthFactor' from its ABI tag value.
authFactorFromTag :: Word8 -> Maybe AuthFactor
authFactorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: AuthFactor)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
