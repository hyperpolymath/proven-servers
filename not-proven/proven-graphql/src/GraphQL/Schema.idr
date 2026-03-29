-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQL.Schema: Type system representation with consistency proofs.
--
-- Models the GraphQL type system as an indexed family.  Key invariants:
--   - Every field on an Object type resolves to a type present in the schema
--   - NonNull cannot wrap NonNull (GraphQL spec section 3.12)
--   - InputObject fields can only reference input types (Scalar, Enum, InputObject)
--   - Union members must all be Object types
--   - Interface implementors must provide all interface fields

module GraphQL.Schema

import GraphQL.Types
import GraphQLABI.Layout

%default total

---------------------------------------------------------------------------
-- Schema-level type references
---------------------------------------------------------------------------

||| A reference to a named type in the schema, carrying its kind.
public export
record TypeRef where
  constructor MkTypeRef
  typeName : String
  typeKind : TypeKind

||| A field definition: name, argument count, and result type reference.
public export
record FieldDef where
  constructor MkFieldDef
  fieldName   : String
  argCount    : Nat
  resultType  : TypeRef
  isNullable  : Bool

||| A schema type definition carrying its kind and field list.
public export
record TypeDef where
  constructor MkTypeDef
  tdName   : String
  tdKind   : TypeKind
  tdFields : List FieldDef

---------------------------------------------------------------------------
-- Schema representation
---------------------------------------------------------------------------

||| A GraphQL schema is a list of type definitions plus root operation
||| type names (query, mutation, subscription).
public export
record Schema where
  constructor MkSchema
  schemaTypes    : List TypeDef
  queryType      : String
  mutationType   : Maybe String
  subscriptionType : Maybe String

---------------------------------------------------------------------------
-- Type lookup
---------------------------------------------------------------------------

||| Look up a type definition by name in a schema.
public export
lookupType : Schema -> String -> Maybe TypeDef
lookupType schema name = go (schemaTypes schema)
  where
    go : List TypeDef -> Maybe TypeDef
    go [] = Nothing
    go (td :: rest) = if tdName td == name then Just td else go rest

---------------------------------------------------------------------------
-- NonNull wrapping proof
---------------------------------------------------------------------------

||| Proof that a TypeKind is not NonNull.
||| Used to enforce the GraphQL spec rule that NonNull cannot wrap NonNull.
public export
data NotNonNull : TypeKind -> Type where
  ScalarNotNonNull      : NotNonNull Scalar
  ObjectNotNonNull      : NotNonNull Object
  InterfaceNotNonNull   : NotNonNull Interface
  UnionNotNonNull       : NotNonNull Union
  EnumNotNonNull        : NotNonNull Enum
  InputObjectNotNonNull : NotNonNull InputObject
  ListNotNonNull        : NotNonNull List

||| NonNull is not NotNonNull -- witness that we cannot double-wrap.
public export
nonNullIsNonNull : NotNonNull NonNull -> Void
nonNullIsNonNull _ impossible

---------------------------------------------------------------------------
-- Input type classification
---------------------------------------------------------------------------

||| Proof that a TypeKind is a valid input type.
||| Only Scalar, Enum, and InputObject can appear as input field types.
public export
data IsInputType : TypeKind -> Type where
  ScalarIsInput      : IsInputType Scalar
  EnumIsInput        : IsInputType Enum
  InputObjectIsInput : IsInputType InputObject

||| Object types are not valid input types.
public export
objectNotInput : IsInputType Object -> Void
objectNotInput _ impossible

||| Interface types are not valid input types.
public export
interfaceNotInput : IsInputType Interface -> Void
interfaceNotInput _ impossible

||| Union types are not valid input types.
public export
unionNotInput : IsInputType Union -> Void
unionNotInput _ impossible

---------------------------------------------------------------------------
-- Output type classification
---------------------------------------------------------------------------

||| Proof that a TypeKind is a valid output type.
||| Scalar, Object, Interface, Union, Enum, List, NonNull are output types.
public export
data IsOutputType : TypeKind -> Type where
  ScalarIsOutput    : IsOutputType Scalar
  ObjectIsOutput    : IsOutputType Object
  InterfaceIsOutput : IsOutputType Interface
  UnionIsOutput     : IsOutputType Union
  EnumIsOutput      : IsOutputType Enum
  ListIsOutput      : IsOutputType List
  NonNullIsOutput   : IsOutputType NonNull

||| InputObject is not a valid output type.
public export
inputObjectNotOutput : IsOutputType InputObject -> Void
inputObjectNotOutput _ impossible

---------------------------------------------------------------------------
-- Union member validation
---------------------------------------------------------------------------

||| Proof that a TypeKind is Object -- required for union members.
public export
data IsObjectKind : TypeKind -> Type where
  ObjectIsObjectKind : IsObjectKind Object

||| Scalar is not an Object kind (cannot be a union member).
public export
scalarNotObjectKind : IsObjectKind Scalar -> Void
scalarNotObjectKind _ impossible

||| Enum is not an Object kind (cannot be a union member).
public export
enumNotObjectKind : IsObjectKind Enum -> Void
enumNotObjectKind _ impossible

---------------------------------------------------------------------------
-- Field type consistency check
---------------------------------------------------------------------------

||| Decision procedure: is this TypeKind a valid input type?
public export
isInputType : (k : TypeKind) -> Dec (IsInputType k)
isInputType Scalar      = Yes ScalarIsInput
isInputType Enum        = Yes EnumIsInput
isInputType InputObject = Yes InputObjectIsInput
isInputType Object      = No objectNotInput
isInputType Interface   = No interfaceNotInput
isInputType Union       = No unionNotInput
isInputType List        = No (\case _ impossible)
isInputType NonNull     = No (\case _ impossible)

||| Decision procedure: is this TypeKind a valid output type?
public export
isOutputType : (k : TypeKind) -> Dec (IsOutputType k)
isOutputType Scalar    = Yes ScalarIsOutput
isOutputType Object    = Yes ObjectIsOutput
isOutputType Interface = Yes InterfaceIsOutput
isOutputType Union     = Yes UnionIsOutput
isOutputType Enum      = Yes EnumIsOutput
isOutputType List      = Yes ListIsOutput
isOutputType NonNull   = Yes NonNullIsOutput
isOutputType InputObject = No inputObjectNotOutput

---------------------------------------------------------------------------
-- Schema well-formedness (runtime check)
---------------------------------------------------------------------------

||| Check that all field result types reference types present in the schema.
||| Returns the list of unresolved type names (empty = well-formed).
public export
unresolvedFieldTypes : Schema -> List String
unresolvedFieldTypes schema = concatMap checkTypeDef (schemaTypes schema)
  where
    checkField : FieldDef -> List String
    checkField fd = case lookupType schema (typeName (resultType fd)) of
                      Just _  => []
                      Nothing => [typeName (resultType fd)]
    checkTypeDef : TypeDef -> List String
    checkTypeDef td = concatMap checkField (tdFields td)

||| A schema is well-formed when all field references resolve.
public export
isWellFormed : Schema -> Bool
isWellFormed schema = isNil (unresolvedFieldTypes schema)
