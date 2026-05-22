-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | GraphQL protocol types for proven-servers.
--
-- GraphQL protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.GraphqlTypes
  ( -- * ADT types matching Idris2 ABI
      OperationType(..)
    , TypeKind(..)
    , DirectiveLocation(..)
    , ErrorCategory(..)
    , operationTypeToTag
    , operationTypeFromTag
    , typeKindToTag
    , typeKindFromTag
    , directiveLocationToTag
    , directiveLocationFromTag
    , errorCategoryToTag
    , errorCategoryFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- OperationType
-- ---------------------------------------------------------------------------

-- | OperationType type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data OperationType
  = OperationType_Query  -- ^ Tag 0.
  | OperationType_Mutation  -- ^ Tag 1.
  | OperationType_Subscription  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OperationType' to its ABI tag value.
operationTypeToTag :: OperationType -> Word8
operationTypeToTag = fromIntegral . fromEnum

-- | Decode a 'OperationType' from its ABI tag value.
operationTypeFromTag :: Word8 -> Maybe OperationType
operationTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OperationType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TypeKind
-- ---------------------------------------------------------------------------

-- | TypeKind type matching the Idris2 ABI.
--
-- Tags 0-7 (8 constructors).
data TypeKind
  = TypeKind_Scalar  -- ^ Tag 0.
  | TypeKind_Object  -- ^ Tag 1.
  | TypeKind_Interface  -- ^ Tag 2.
  | TypeKind_Union  -- ^ Tag 3.
  | TypeKind_Enum  -- ^ Tag 4.
  | TypeKind_InputObject  -- ^ Tag 5.
  | List  -- ^ Tag 6.
  | NonNull  -- ^ Tag 7.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TypeKind' to its ABI tag value.
typeKindToTag :: TypeKind -> Word8
typeKindToTag = fromIntegral . fromEnum

-- | Decode a 'TypeKind' from its ABI tag value.
typeKindFromTag :: Word8 -> Maybe TypeKind
typeKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TypeKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DirectiveLocation
-- ---------------------------------------------------------------------------

-- | DirectiveLocation type matching the Idris2 ABI.
--
-- Tags 0-17 (18 constructors).
data DirectiveLocation
  = DirectiveLocation_Query  -- ^ Tag 0.
  | DirectiveLocation_Mutation  -- ^ Tag 1.
  | DirectiveLocation_Subscription  -- ^ Tag 2.
  | Field  -- ^ Tag 3.
  | FragmentDefinition  -- ^ Tag 4.
  | FragmentSpread  -- ^ Tag 5.
  | InlineFragment  -- ^ Tag 6.
  | Schema  -- ^ Tag 7.
  | DirectiveLocation_Scalar  -- ^ Tag 8.
  | DirectiveLocation_Object  -- ^ Tag 9.
  | FieldDefinition  -- ^ Tag 10.
  | ArgumentDefinition  -- ^ Tag 11.
  | DirectiveLocation_Interface  -- ^ Tag 12.
  | DirectiveLocation_Union  -- ^ Tag 13.
  | DirectiveLocation_Enum  -- ^ Tag 14.
  | EnumValue  -- ^ Tag 15.
  | DirectiveLocation_InputObject  -- ^ Tag 16.
  | InputFieldDefinition  -- ^ Tag 17.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DirectiveLocation' to its ABI tag value.
directiveLocationToTag :: DirectiveLocation -> Word8
directiveLocationToTag = fromIntegral . fromEnum

-- | Decode a 'DirectiveLocation' from its ABI tag value.
directiveLocationFromTag :: Word8 -> Maybe DirectiveLocation
directiveLocationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DirectiveLocation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorCategory
-- ---------------------------------------------------------------------------

-- | ErrorCategory type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ErrorCategory
  = ParseError  -- ^ Tag 0.
  | ValidationError  -- ^ Tag 1.
  | ExecutionError  -- ^ Tag 2.
  | AuthError  -- ^ Tag 3.
  | RateLimited  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCategory' to its ABI tag value.
errorCategoryToTag :: ErrorCategory -> Word8
errorCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCategory' from its ABI tag value.
errorCategoryFromTag :: Word8 -> Maybe ErrorCategory
errorCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
