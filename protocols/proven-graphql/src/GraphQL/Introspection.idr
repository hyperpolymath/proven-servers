-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQL.Introspection: Introspection system types and validation.
--
-- Models the GraphQL introspection system (__schema, __type, __typename)
-- as specified in the GraphQL specification section 4.5.  Provides proofs
-- that introspection queries target valid meta-fields and that introspection
-- types have the correct structure.

module GraphQL.Introspection

import GraphQL.Types

%default total

---------------------------------------------------------------------------
-- Introspection meta-fields
---------------------------------------------------------------------------

||| The three built-in introspection meta-fields available on every query.
public export
data IntrospectionField : Type where
  ||| __schema: returns the full schema introspection result.
  SchemaField   : IntrospectionField
  ||| __type(name: String!): returns introspection data for a named type.
  TypeField     : IntrospectionField
  ||| __typename: returns the name of the current object type.
  TypenameField : IntrospectionField

public export
Show IntrospectionField where
  show SchemaField   = "__schema"
  show TypeField     = "__type"
  show TypenameField = "__typename"

||| Tag encoding for FFI (matches C header GQL_INTRO_* defines).
public export
introspectionFieldToTag : IntrospectionField -> Bits8
introspectionFieldToTag SchemaField   = 0
introspectionFieldToTag TypeField     = 1
introspectionFieldToTag TypenameField = 2

public export
tagToIntrospectionField : Bits8 -> Maybe IntrospectionField
tagToIntrospectionField 0 = Just SchemaField
tagToIntrospectionField 1 = Just TypeField
tagToIntrospectionField 2 = Just TypenameField
tagToIntrospectionField _ = Nothing

public export
introspectionFieldRoundtrip : (f : IntrospectionField)
                            -> tagToIntrospectionField (introspectionFieldToTag f) = Just f
introspectionFieldRoundtrip SchemaField   = Refl
introspectionFieldRoundtrip TypeField     = Refl
introspectionFieldRoundtrip TypenameField = Refl

---------------------------------------------------------------------------
-- Introspection type names (__Type, __Schema, __Field, etc.)
---------------------------------------------------------------------------

||| The built-in introspection type names from the GraphQL specification.
public export
data IntrospectionTypeName : Type where
  ITSchema          : IntrospectionTypeName
  ITType            : IntrospectionTypeName
  ITField           : IntrospectionTypeName
  ITInputValue      : IntrospectionTypeName
  ITEnumValue       : IntrospectionTypeName
  ITDirective       : IntrospectionTypeName
  ITTypeKind        : IntrospectionTypeName
  ITDirectiveLocation : IntrospectionTypeName

public export
Show IntrospectionTypeName where
  show ITSchema            = "__Schema"
  show ITType              = "__Type"
  show ITField             = "__Field"
  show ITInputValue        = "__InputValue"
  show ITEnumValue         = "__EnumValue"
  show ITDirective         = "__Directive"
  show ITTypeKind          = "__TypeKind"
  show ITDirectiveLocation = "__DirectiveLocation"

---------------------------------------------------------------------------
-- Introspection availability proof
---------------------------------------------------------------------------

||| Proof that introspection is enabled.
||| Guards introspection queries at the type level.
public export
data IntrospectionEnabled : Bool -> Type where
  Enabled : IntrospectionEnabled True

||| Cannot run introspection queries when disabled.
public export
introspectionDisabledBlocks : IntrospectionEnabled False -> Void
introspectionDisabledBlocks _ impossible

---------------------------------------------------------------------------
-- Valid introspection context
---------------------------------------------------------------------------

||| Proof that an operation type supports introspection meta-fields.
||| Only Query operations support __schema and __type.
||| __typename is available on any object in any operation.
public export
data CanIntrospect : OperationType -> IntrospectionField -> Type where
  ||| __schema is only available on Query root.
  QueryCanSchema   : CanIntrospect Query SchemaField
  ||| __type is only available on Query root.
  QueryCanType     : CanIntrospect Query TypeField
  ||| __typename is available on any operation (it's a field-level meta-field).
  QueryCanTypename    : CanIntrospect Query TypenameField
  MutationCanTypename : CanIntrospect Mutation TypenameField
  SubCanTypename      : CanIntrospect Subscription TypenameField

||| Cannot use __schema on a Mutation operation.
public export
mutationCannotSchema : CanIntrospect Mutation SchemaField -> Void
mutationCannotSchema _ impossible

||| Cannot use __type on a Mutation operation.
public export
mutationCannotType : CanIntrospect Mutation TypeField -> Void
mutationCannotType _ impossible

||| Cannot use __schema on a Subscription operation.
public export
subscriptionCannotSchema : CanIntrospect Subscription SchemaField -> Void
subscriptionCannotSchema _ impossible

||| Cannot use __type on a Subscription operation.
public export
subscriptionCannotType : CanIntrospect Subscription TypeField -> Void
subscriptionCannotType _ impossible

---------------------------------------------------------------------------
-- Introspection validation (runtime decision)
---------------------------------------------------------------------------

||| Check whether an introspection query is valid for a given operation type.
public export
canIntrospect : (op : OperationType) -> (field : IntrospectionField)
              -> Maybe (CanIntrospect op field)
canIntrospect Query        SchemaField   = Just QueryCanSchema
canIntrospect Query        TypeField     = Just QueryCanType
canIntrospect Query        TypenameField = Just QueryCanTypename
canIntrospect Mutation     TypenameField = Just MutationCanTypename
canIntrospect Subscription TypenameField = Just SubCanTypename
canIntrospect _            _             = Nothing
