-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | GraphQL protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Graphql
  (
    OperationType(..)
  , operationTypeToTag
  , operationTypeFromTag
  , asStr
  , TypeKind(..)
  , typeKindToTag
  , typeKindFromTag
  , isWrapper
  , isComposite
  , introspectionName
  , DirectiveLocation(..)
  , directiveLocationToTag
  , directiveLocationFromTag
  , isExecutable
  , isTypeSystem
  , ErrorCategory(..)
  , errorCategoryToTag
  , errorCategoryFromTag
  , code
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- OperationType
-- ---------------------------------------------------------------------------

-- | GraphQL root operation types.
--
-- Tags 0-2 (3 constructors).
data OperationType
  = Query  -- ^ A read-only fetch.
  | Mutation  -- ^ A write followed by a fetch.
  | Subscription  -- ^ A long-lived request yielding events.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OperationType' to its ABI tag value.
operationTypeToTag :: OperationType -> Word8
operationTypeToTag = fromIntegral . fromEnum

-- | Decode a 'OperationType' from its ABI tag value.
operationTypeFromTag :: Word8 -> Maybe OperationType
operationTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OperationType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | GraphQL keyword for this operation type.
asStr :: OperationType -> String
asStr Query = "query"
asStr Mutation = "mutation"
asStr Subscription = "subscription"

-- ---------------------------------------------------------------------------
-- TypeKind
-- ---------------------------------------------------------------------------

-- | GraphQL type system kinds (introspection `__TypeKind`).
--
-- Tags 0-7 (8 constructors).
data TypeKind
  = Scalar  -- ^ Scalar type (e.g. `Int`, `String`, `Boolean`).
  | Object  -- ^ Object type with fields.
  | Interface  -- ^ Interface type.
  | Union  -- ^ Union of object types.
  | Enum  -- ^ Enum type.
  | InputObject  -- ^ Input object type.
  | List  -- ^ List wrapper type.
  | NonNull  -- ^ Non-null wrapper type.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TypeKind' to its ABI tag value.
typeKindToTag :: TypeKind -> Word8
typeKindToTag = fromIntegral . fromEnum

-- | Decode a 'TypeKind' from its ABI tag value.
typeKindFromTag :: Word8 -> Maybe TypeKind
typeKindFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TypeKind)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is a wrapper type (List or NonNull).
isWrapper :: TypeKind -> Bool
isWrapper List = True
isWrapper NonNull = True
isWrapper _ = False

-- | Whether this is a composite type (Object, Interface, or Union).
isComposite :: TypeKind -> Bool
isComposite Object = True
isComposite Interface = True
isComposite Union = True
isComposite _ = False

-- | /// Matches the `Show` instance in `GraphQL.Types`.
introspectionName :: TypeKind -> String
introspectionName Scalar = "SCALAR"
introspectionName Object = "OBJECT"
introspectionName Interface = "INTERFACE"
introspectionName Union = "UNION"
introspectionName Enum = "ENUM"
introspectionName InputObject = "INPUT_OBJECT"
introspectionName List = "LIST"
introspectionName NonNull = "NON_NULL"

-- ---------------------------------------------------------------------------
-- DirectiveLocation
-- ---------------------------------------------------------------------------

-- | GraphQL directive locations (executable and type system).
--
-- Tags 0-17 (18 constructors).
data DirectiveLocation
  = Query  -- ^ On a query operation.
  | Mutation  -- ^ On a mutation operation.
  | Subscription  -- ^ On a subscription operation.
  | Field  -- ^ On a field selection.
  | FragmentDefinition  -- ^ On a fragment definition.
  | FragmentSpread  -- ^ On a fragment spread.
  | InlineFragment  -- ^ On an inline fragment.
  | Schema  -- ^ On a schema definition.
  | Scalar  -- ^ On a scalar type definition.
  | Object  -- ^ On an object type definition.
  | FieldDefinition  -- ^ On a field definition.
  | ArgumentDefinition  -- ^ On an argument definition.
  | Interface  -- ^ On an interface type definition.
  | Union  -- ^ On a union type definition.
  | Enum  -- ^ On an enum type definition.
  | EnumValue  -- ^ On an enum value definition.
  | InputObject  -- ^ On an input object type definition.
  | InputFieldDefinition  -- ^ On an input field definition.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DirectiveLocation' to its ABI tag value.
directiveLocationToTag :: DirectiveLocation -> Word8
directiveLocationToTag = fromIntegral . fromEnum

-- | Decode a 'DirectiveLocation' from its ABI tag value.
directiveLocationFromTag :: Word8 -> Maybe DirectiveLocation
directiveLocationFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DirectiveLocation)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this is an executable location (query/mutation/subscription/field/fragment).
isExecutable :: DirectiveLocation -> Bool
isExecutable Query = True
isExecutable Mutation = True
isExecutable Subscription = True
isExecutable Field = True
isExecutable FragmentDefinition = True
isExecutable FragmentSpread = True
isExecutable InlineFragment = True
isExecutable _ = False

-- | Whether this is a type system location.
isTypeSystem :: DirectiveLocation -> Bool
isTypeSystem Query = False
isTypeSystem Mutation = False
isTypeSystem Subscription = False
isTypeSystem Field = False
isTypeSystem FragmentDefinition = False
isTypeSystem FragmentSpread = False
isTypeSystem InlineFragment = False
isTypeSystem _ = True

-- ---------------------------------------------------------------------------
-- ErrorCategory
-- ---------------------------------------------------------------------------

-- | GraphQL error categories for structured error reporting.
--
-- Tags 0-4 (5 constructors).
data ErrorCategory
  = ParseError  -- ^ Syntax error in the GraphQL query.
  | ValidationError  -- ^ The query does not pass validation against the schema.
  | ExecutionError  -- ^ An error occurred during query execution.
  | AuthError  -- ^ Authentication/authorisation failure.
  | RateLimited  -- ^ Request rate limit exceeded.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorCategory' to its ABI tag value.
errorCategoryToTag :: ErrorCategory -> Word8
errorCategoryToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorCategory' from its ABI tag value.
errorCategoryFromTag :: Word8 -> Maybe ErrorCategory
errorCategoryFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorCategory)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | /// Matches the `Show` instance in `GraphQL.Types`.
code :: ErrorCategory -> String
code ParseError = "PARSE_ERROR"
code ValidationError = "VALIDATION_ERROR"
code ExecutionError = "EXECUTION_ERROR"
code AuthError = "AUTH_ERROR"
code RateLimited = "RATE_LIMITED"
