-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LDP protocol types for proven-servers.
--
-- Linked Data Platform types (W3C LDP), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Ldp
  ( -- * ADT types matching Idris2 ABI
      ContainerType(..)
    , LdpResourceType(..)
    , Preference(..)
    , InteractionModel(..)
    , ConstraintViolation(..)
    , containerTypeToTag
    , containerTypeFromTag
    , ldpResourceTypeToTag
    , ldpResourceTypeFromTag
    , preferenceToTag
    , preferenceFromTag
    , interactionModelToTag
    , interactionModelFromTag
    , constraintViolationToTag
    , constraintViolationFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- ContainerType
-- ---------------------------------------------------------------------------

-- | ContainerType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data ContainerType
  = Basic  -- ^ Tag 0.
  | Direct  -- ^ Tag 1.
  | Indirect  -- ^ Tag 2.
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

-- | LdpResourceType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data LdpResourceType
  = RdfSource  -- ^ Tag 0.
  | NonRdfSource  -- ^ Tag 1.
  | Container  -- ^ Tag 2.
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

-- | Preference type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data Preference
  = MinimalContainer  -- ^ Tag 0.
  | IncludeContainment  -- ^ Tag 1.
  | IncludeMembership  -- ^ Tag 2.
  | OmitContainment  -- ^ Tag 3.
  | OmitMembership  -- ^ Tag 4.
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

-- | InteractionModel type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data InteractionModel
  = Ldpr  -- ^ Tag 0.
  | Ldpc  -- ^ Tag 1.
  | LdpBasicContainer  -- ^ Tag 2.
  | LdpDirectContainer  -- ^ Tag 3.
  | LdpIndirectContainer  -- ^ Tag 4.
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

-- | ConstraintViolation type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ConstraintViolation
  = MembershipConstant  -- ^ Tag 0.
  | ContainsTriplesModified  -- ^ Tag 1.
  | ServerManaged  -- ^ Tag 2.
  | TypeConflict  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConstraintViolation' to its ABI tag value.
constraintViolationToTag :: ConstraintViolation -> Word8
constraintViolationToTag = fromIntegral . fromEnum

-- | Decode a 'ConstraintViolation' from its ABI tag value.
constraintViolationFromTag :: Word8 -> Maybe ConstraintViolation
constraintViolationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConstraintViolation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
