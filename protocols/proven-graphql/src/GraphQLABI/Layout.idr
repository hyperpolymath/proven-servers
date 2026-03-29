-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQLABI.Layout: C-ABI-compatible numeric representations of GraphQL types.
--
-- Maps every constructor of the core sum types (OperationType, TypeKind,
-- ScalarKind, DirectiveLocation, ErrorCategory) to fixed Bits8 values for
-- C interop.  Each type gets a total encoder, partial decoder, and roundtrip
-- proof.
--
-- Tag values here MUST match the C header (generated/abi/graphql.h) and the
-- Zig FFI enums (ffi/zig/src/graphql.zig) exactly.

module GraphQLABI.Layout

import GraphQL.Types

%default total

---------------------------------------------------------------------------
-- OperationType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
operationTypeSize : Nat
operationTypeSize = 1

public export
operationTypeToTag : OperationType -> Bits8
operationTypeToTag Query        = 0
operationTypeToTag Mutation     = 1
operationTypeToTag Subscription = 2

public export
tagToOperationType : Bits8 -> Maybe OperationType
tagToOperationType 0 = Just Query
tagToOperationType 1 = Just Mutation
tagToOperationType 2 = Just Subscription
tagToOperationType _ = Nothing

public export
operationTypeRoundtrip : (o : OperationType) -> tagToOperationType (operationTypeToTag o) = Just o
operationTypeRoundtrip Query        = Refl
operationTypeRoundtrip Mutation     = Refl
operationTypeRoundtrip Subscription = Refl

---------------------------------------------------------------------------
-- TypeKind (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
typeKindSize : Nat
typeKindSize = 1

public export
typeKindToTag : TypeKind -> Bits8
typeKindToTag Scalar      = 0
typeKindToTag Object      = 1
typeKindToTag Interface   = 2
typeKindToTag Union       = 3
typeKindToTag Enum        = 4
typeKindToTag InputObject = 5
typeKindToTag List        = 6
typeKindToTag NonNull     = 7

public export
tagToTypeKind : Bits8 -> Maybe TypeKind
tagToTypeKind 0 = Just Scalar
tagToTypeKind 1 = Just Object
tagToTypeKind 2 = Just Interface
tagToTypeKind 3 = Just Union
tagToTypeKind 4 = Just Enum
tagToTypeKind 5 = Just InputObject
tagToTypeKind 6 = Just List
tagToTypeKind 7 = Just NonNull
tagToTypeKind _ = Nothing

public export
typeKindRoundtrip : (k : TypeKind) -> tagToTypeKind (typeKindToTag k) = Just k
typeKindRoundtrip Scalar      = Refl
typeKindRoundtrip Object      = Refl
typeKindRoundtrip Interface   = Refl
typeKindRoundtrip Union       = Refl
typeKindRoundtrip Enum        = Refl
typeKindRoundtrip InputObject = Refl
typeKindRoundtrip List        = Refl
typeKindRoundtrip NonNull     = Refl

---------------------------------------------------------------------------
-- ScalarKind (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| Built-in and custom GraphQL scalar types.
||| Int, Float, String, Boolean, ID are the standard five;
||| Custom represents user-defined scalars.
public export
data ScalarKind : Type where
  GqlInt     : ScalarKind
  GqlFloat   : ScalarKind
  GqlString  : ScalarKind
  GqlBoolean : ScalarKind
  GqlID      : ScalarKind
  GqlCustom  : ScalarKind

public export
Show ScalarKind where
  show GqlInt     = "Int"
  show GqlFloat   = "Float"
  show GqlString  = "String"
  show GqlBoolean = "Boolean"
  show GqlID      = "ID"
  show GqlCustom  = "Custom"

public export
scalarKindSize : Nat
scalarKindSize = 1

public export
scalarKindToTag : ScalarKind -> Bits8
scalarKindToTag GqlInt     = 0
scalarKindToTag GqlFloat   = 1
scalarKindToTag GqlString  = 2
scalarKindToTag GqlBoolean = 3
scalarKindToTag GqlID      = 4
scalarKindToTag GqlCustom  = 5

public export
tagToScalarKind : Bits8 -> Maybe ScalarKind
tagToScalarKind 0 = Just GqlInt
tagToScalarKind 1 = Just GqlFloat
tagToScalarKind 2 = Just GqlString
tagToScalarKind 3 = Just GqlBoolean
tagToScalarKind 4 = Just GqlID
tagToScalarKind 5 = Just GqlCustom
tagToScalarKind _ = Nothing

public export
scalarKindRoundtrip : (s : ScalarKind) -> tagToScalarKind (scalarKindToTag s) = Just s
scalarKindRoundtrip GqlInt     = Refl
scalarKindRoundtrip GqlFloat   = Refl
scalarKindRoundtrip GqlString  = Refl
scalarKindRoundtrip GqlBoolean = Refl
scalarKindRoundtrip GqlID      = Refl
scalarKindRoundtrip GqlCustom  = Refl

---------------------------------------------------------------------------
-- DirectiveLocation (18 constructors, tags 0-17)
---------------------------------------------------------------------------

public export
directiveLocationSize : Nat
directiveLocationSize = 1

public export
directiveLocationToTag : DirectiveLocation -> Bits8
directiveLocationToTag QUERY                  = 0
directiveLocationToTag MUTATION               = 1
directiveLocationToTag SUBSCRIPTION           = 2
directiveLocationToTag FIELD                  = 3
directiveLocationToTag FRAGMENT_DEFINITION    = 4
directiveLocationToTag FRAGMENT_SPREAD        = 5
directiveLocationToTag INLINE_FRAGMENT        = 6
directiveLocationToTag SCHEMA                 = 7
directiveLocationToTag SCALAR_LOC             = 8
directiveLocationToTag OBJECT_LOC             = 9
directiveLocationToTag FIELD_DEFINITION       = 10
directiveLocationToTag ARGUMENT_DEFINITION    = 11
directiveLocationToTag INTERFACE_LOC          = 12
directiveLocationToTag UNION_LOC              = 13
directiveLocationToTag ENUM_LOC               = 14
directiveLocationToTag ENUM_VALUE             = 15
directiveLocationToTag INPUT_OBJECT_LOC       = 16
directiveLocationToTag INPUT_FIELD_DEFINITION = 17

public export
tagToDirectiveLocation : Bits8 -> Maybe DirectiveLocation
tagToDirectiveLocation 0  = Just QUERY
tagToDirectiveLocation 1  = Just MUTATION
tagToDirectiveLocation 2  = Just SUBSCRIPTION
tagToDirectiveLocation 3  = Just FIELD
tagToDirectiveLocation 4  = Just FRAGMENT_DEFINITION
tagToDirectiveLocation 5  = Just FRAGMENT_SPREAD
tagToDirectiveLocation 6  = Just INLINE_FRAGMENT
tagToDirectiveLocation 7  = Just SCHEMA
tagToDirectiveLocation 8  = Just SCALAR_LOC
tagToDirectiveLocation 9  = Just OBJECT_LOC
tagToDirectiveLocation 10 = Just FIELD_DEFINITION
tagToDirectiveLocation 11 = Just ARGUMENT_DEFINITION
tagToDirectiveLocation 12 = Just INTERFACE_LOC
tagToDirectiveLocation 13 = Just UNION_LOC
tagToDirectiveLocation 14 = Just ENUM_LOC
tagToDirectiveLocation 15 = Just ENUM_VALUE
tagToDirectiveLocation 16 = Just INPUT_OBJECT_LOC
tagToDirectiveLocation 17 = Just INPUT_FIELD_DEFINITION
tagToDirectiveLocation _  = Nothing

public export
directiveLocationRoundtrip : (d : DirectiveLocation)
                           -> tagToDirectiveLocation (directiveLocationToTag d) = Just d
directiveLocationRoundtrip QUERY                  = Refl
directiveLocationRoundtrip MUTATION               = Refl
directiveLocationRoundtrip SUBSCRIPTION           = Refl
directiveLocationRoundtrip FIELD                  = Refl
directiveLocationRoundtrip FRAGMENT_DEFINITION    = Refl
directiveLocationRoundtrip FRAGMENT_SPREAD        = Refl
directiveLocationRoundtrip INLINE_FRAGMENT        = Refl
directiveLocationRoundtrip SCHEMA                 = Refl
directiveLocationRoundtrip SCALAR_LOC             = Refl
directiveLocationRoundtrip OBJECT_LOC             = Refl
directiveLocationRoundtrip FIELD_DEFINITION       = Refl
directiveLocationRoundtrip ARGUMENT_DEFINITION    = Refl
directiveLocationRoundtrip INTERFACE_LOC          = Refl
directiveLocationRoundtrip UNION_LOC              = Refl
directiveLocationRoundtrip ENUM_LOC               = Refl
directiveLocationRoundtrip ENUM_VALUE             = Refl
directiveLocationRoundtrip INPUT_OBJECT_LOC       = Refl
directiveLocationRoundtrip INPUT_FIELD_DEFINITION = Refl

---------------------------------------------------------------------------
-- ErrorCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
errorCategorySize : Nat
errorCategorySize = 1

public export
errorCategoryToTag : ErrorCategory -> Bits8
errorCategoryToTag ParseError      = 0
errorCategoryToTag ValidationError = 1
errorCategoryToTag ExecutionError  = 2
errorCategoryToTag AuthError       = 3
errorCategoryToTag RateLimited     = 4

public export
tagToErrorCategory : Bits8 -> Maybe ErrorCategory
tagToErrorCategory 0 = Just ParseError
tagToErrorCategory 1 = Just ValidationError
tagToErrorCategory 2 = Just ExecutionError
tagToErrorCategory 3 = Just AuthError
tagToErrorCategory 4 = Just RateLimited
tagToErrorCategory _ = Nothing

public export
errorCategoryRoundtrip : (e : ErrorCategory) -> tagToErrorCategory (errorCategoryToTag e) = Just e
errorCategoryRoundtrip ParseError      = Refl
errorCategoryRoundtrip ValidationError = Refl
errorCategoryRoundtrip ExecutionError  = Refl
errorCategoryRoundtrip AuthError       = Refl
errorCategoryRoundtrip RateLimited     = Refl
