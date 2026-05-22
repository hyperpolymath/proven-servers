-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LDP types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Ldp
  (
    ContainerType(..)
  , containerTypeToTag
  , containerTypeFromTag
  , LdpResourceType(..)
  , ldpResourceTypeToTag
  , ldpResourceTypeFromTag
  , Preference(..)
  , preferenceToTag
  , preferenceFromTag
  , InteractionModel(..)
  , interactionModelToTag
  , interactionModelFromTag
  , ConstraintViolation(..)
  , constraintViolationToTag
  , constraintViolationFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ContainerType
-- ---------------------------------------------------------------------------

-- | LDP container types.
--
-- Tags 0-2 (3 constructors).
data ContainerType
  = Basic  -- ^ Basic (tag 0).
  | Direct  -- ^ Direct (tag 1).
  | Indirect  -- ^ Indirect (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ContainerType' to its ABI tag value.
containerTypeToTag :: ContainerType -> Word8
containerTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ContainerType' from its ABI tag value.
containerTypeFromTag :: Word8 -> Maybe ContainerType
containerTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ContainerType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- LdpResourceType
-- ---------------------------------------------------------------------------

-- | LDP resource types.
--
-- Tags 0-2 (3 constructors).
data LdpResourceType
  = RdfSource  -- ^ RdfSource (tag 0).
  | NonRdfSource  -- ^ NonRdfSource (tag 1).
  | Container  -- ^ Container (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'LdpResourceType' to its ABI tag value.
ldpResourceTypeToTag :: LdpResourceType -> Word8
ldpResourceTypeToTag = fromIntegral . fromEnum

-- | Decode a 'LdpResourceType' from its ABI tag value.
ldpResourceTypeFromTag :: Word8 -> Maybe LdpResourceType
ldpResourceTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: LdpResourceType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- Preference
-- ---------------------------------------------------------------------------

-- | LDP prefer header values.
--
-- Tags 0-4 (5 constructors).
data Preference
  = MinimalContainer  -- ^ MinimalContainer (tag 0).
  | IncludeContainment  -- ^ IncludeContainment (tag 1).
  | IncludeMembership  -- ^ IncludeMembership (tag 2).
  | OmitContainment  -- ^ OmitContainment (tag 3).
  | OmitMembership  -- ^ OmitMembership (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Preference' to its ABI tag value.
preferenceToTag :: Preference -> Word8
preferenceToTag = fromIntegral . fromEnum

-- | Decode a 'Preference' from its ABI tag value.
preferenceFromTag :: Word8 -> Maybe Preference
preferenceFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Preference)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- InteractionModel
-- ---------------------------------------------------------------------------

-- | LDP interaction models.
--
-- Tags 0-4 (5 constructors).
data InteractionModel
  = Ldpr  -- ^ LDP Resource (tag 0).
  | Ldpc  -- ^ LDP Container (tag 1).
  | LdpBasicContainer  -- ^ LdpBasicContainer (tag 2).
  | LdpDirectContainer  -- ^ LdpDirectContainer (tag 3).
  | LdpIndirectContainer  -- ^ LdpIndirectContainer (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'InteractionModel' to its ABI tag value.
interactionModelToTag :: InteractionModel -> Word8
interactionModelToTag = fromIntegral . fromEnum

-- | Decode a 'InteractionModel' from its ABI tag value.
interactionModelFromTag :: Word8 -> Maybe InteractionModel
interactionModelFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: InteractionModel)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConstraintViolation
-- ---------------------------------------------------------------------------

-- | LDP constraint violations.
--
-- Tags 0-3 (4 constructors).
data ConstraintViolation
  = MembershipConstant  -- ^ MembershipConstant (tag 0).
  | ContainsTriplesModified  -- ^ ContainsTriplesModified (tag 1).
  | ServerManaged  -- ^ ServerManaged (tag 2).
  | TypeConflict  -- ^ TypeConflict (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConstraintViolation' to its ABI tag value.
constraintViolationToTag :: ConstraintViolation -> Word8
constraintViolationToTag = fromIntegral . fromEnum

-- | Decode a 'ConstraintViolation' from its ABI tag value.
constraintViolationFromTag :: Word8 -> Maybe ConstraintViolation
constraintViolationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConstraintViolation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
