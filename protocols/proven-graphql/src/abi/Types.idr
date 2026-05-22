-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphqlABI.Types: C-ABI-compatible numeric representations of Graphql types.
--
-- Maps every constructor of the core Graphql sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/graphql.zig) exactly.
--
-- Types covered:
--   OperationType             (3 constructors, tags 0-2)
--   TypeKind                  (6 constructors, tags 0-7)
--   ScalarKind                (6 constructors, tags 0-5)
--   DirectiveLocation         (18 constructors, tags 0-17)
--   ErrorCategory             (5 constructors, tags 0-4)
--   RequestPhase              (6 constructors, tags 0-5)
--   SubscriptionPhase         (4 constructors, tags 0-3)
--   IntrospectionField        (3 constructors, tags 0-2)
--   BatchQueryStatus          (4 constructors, tags 0-3)

module GraphqlABI.Types

%default total

---------------------------------------------------------------------------
-- OperationType (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
operation_typeSize : Nat
operation_typeSize = 1

||| OperationType sum type for ABI encoding.
public export
data OperationType : Type where
  Query : OperationType
  Mutation : OperationType
  Subscription : OperationType

||| Encode a OperationType to its ABI tag value.
public export
operation_typeToTag : OperationType -> Bits8
operation_typeToTag Query = 0
operation_typeToTag Mutation = 1
operation_typeToTag Subscription = 2

||| Decode an ABI tag to a OperationType.
public export
tagToOperationType : Bits8 -> Maybe OperationType
tagToOperationType 0 = Just Query
tagToOperationType 1 = Just Mutation
tagToOperationType 2 = Just Subscription
tagToOperationType _ = Nothing

||| Roundtrip proof: decoding an encoded OperationType yields the original.
public export
operation_typeRoundtrip : (x : OperationType) -> tagToOperationType (operation_typeToTag x) = Just x
operation_typeRoundtrip Query = Refl
operation_typeRoundtrip Mutation = Refl
operation_typeRoundtrip Subscription = Refl

---------------------------------------------------------------------------
-- TypeKind (6 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
type_kindSize : Nat
type_kindSize = 1

||| TypeKind sum type for ABI encoding.
public export
data TypeKind : Type where
  Scalar : TypeKind
  Object : TypeKind
  Interface : TypeKind
  InputObject : TypeKind
  List : TypeKind
  NonNull : TypeKind

||| Encode a TypeKind to its ABI tag value.
public export
type_kindToTag : TypeKind -> Bits8
type_kindToTag Scalar = 0
type_kindToTag Object = 1
type_kindToTag Interface = 2
type_kindToTag InputObject = 5
type_kindToTag List = 6
type_kindToTag NonNull = 7

||| Decode an ABI tag to a TypeKind.
public export
tagToTypeKind : Bits8 -> Maybe TypeKind
tagToTypeKind 0 = Just Scalar
tagToTypeKind 1 = Just Object
tagToTypeKind 2 = Just Interface
tagToTypeKind 5 = Just InputObject
tagToTypeKind 6 = Just List
tagToTypeKind 7 = Just NonNull
tagToTypeKind _ = Nothing

||| Roundtrip proof: decoding an encoded TypeKind yields the original.
public export
type_kindRoundtrip : (x : TypeKind) -> tagToTypeKind (type_kindToTag x) = Just x
type_kindRoundtrip Scalar = Refl
type_kindRoundtrip Object = Refl
type_kindRoundtrip Interface = Refl
type_kindRoundtrip InputObject = Refl
type_kindRoundtrip List = Refl
type_kindRoundtrip NonNull = Refl

---------------------------------------------------------------------------
-- ScalarKind (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
scalar_kindSize : Nat
scalar_kindSize = 1

||| ScalarKind sum type for ABI encoding.
public export
data ScalarKind : Type where
  GqlInt : ScalarKind
  GqlFloat : ScalarKind
  GqlString : ScalarKind
  GqlBoolean : ScalarKind
  GqlId : ScalarKind
  GqlCustom : ScalarKind

||| Encode a ScalarKind to its ABI tag value.
public export
scalar_kindToTag : ScalarKind -> Bits8
scalar_kindToTag GqlInt = 0
scalar_kindToTag GqlFloat = 1
scalar_kindToTag GqlString = 2
scalar_kindToTag GqlBoolean = 3
scalar_kindToTag GqlId = 4
scalar_kindToTag GqlCustom = 5

||| Decode an ABI tag to a ScalarKind.
public export
tagToScalarKind : Bits8 -> Maybe ScalarKind
tagToScalarKind 0 = Just GqlInt
tagToScalarKind 1 = Just GqlFloat
tagToScalarKind 2 = Just GqlString
tagToScalarKind 3 = Just GqlBoolean
tagToScalarKind 4 = Just GqlId
tagToScalarKind 5 = Just GqlCustom
tagToScalarKind _ = Nothing

||| Roundtrip proof: decoding an encoded ScalarKind yields the original.
public export
scalar_kindRoundtrip : (x : ScalarKind) -> tagToScalarKind (scalar_kindToTag x) = Just x
scalar_kindRoundtrip GqlInt = Refl
scalar_kindRoundtrip GqlFloat = Refl
scalar_kindRoundtrip GqlString = Refl
scalar_kindRoundtrip GqlBoolean = Refl
scalar_kindRoundtrip GqlId = Refl
scalar_kindRoundtrip GqlCustom = Refl

---------------------------------------------------------------------------
-- DirectiveLocation (18 constructors, tags 0-17)
---------------------------------------------------------------------------

public export
directive_locationSize : Nat
directive_locationSize = 1

||| DirectiveLocation sum type for ABI encoding.
public export
data DirectiveLocation : Type where
  QueryLoc : DirectiveLocation
  MutationLoc : DirectiveLocation
  SubscriptionLoc : DirectiveLocation
  Field : DirectiveLocation
  FragmentDefinition : DirectiveLocation
  FragmentSpread : DirectiveLocation
  InlineFragment : DirectiveLocation
  Schema : DirectiveLocation
  ScalarLoc : DirectiveLocation
  ObjectLoc : DirectiveLocation
  FieldDefinition : DirectiveLocation
  ArgumentDefinition : DirectiveLocation
  InterfaceLoc : DirectiveLocation
  UnionLoc : DirectiveLocation
  EnumLoc : DirectiveLocation
  EnumValue : DirectiveLocation
  InputObjectLoc : DirectiveLocation
  InputFieldDefinition : DirectiveLocation

||| Encode a DirectiveLocation to its ABI tag value.
public export
directive_locationToTag : DirectiveLocation -> Bits8
directive_locationToTag QueryLoc = 0
directive_locationToTag MutationLoc = 1
directive_locationToTag SubscriptionLoc = 2
directive_locationToTag Field = 3
directive_locationToTag FragmentDefinition = 4
directive_locationToTag FragmentSpread = 5
directive_locationToTag InlineFragment = 6
directive_locationToTag Schema = 7
directive_locationToTag ScalarLoc = 8
directive_locationToTag ObjectLoc = 9
directive_locationToTag FieldDefinition = 10
directive_locationToTag ArgumentDefinition = 11
directive_locationToTag InterfaceLoc = 12
directive_locationToTag UnionLoc = 13
directive_locationToTag EnumLoc = 14
directive_locationToTag EnumValue = 15
directive_locationToTag InputObjectLoc = 16
directive_locationToTag InputFieldDefinition = 17

||| Decode an ABI tag to a DirectiveLocation.
public export
tagToDirectiveLocation : Bits8 -> Maybe DirectiveLocation
tagToDirectiveLocation 0 = Just QueryLoc
tagToDirectiveLocation 1 = Just MutationLoc
tagToDirectiveLocation 2 = Just SubscriptionLoc
tagToDirectiveLocation 3 = Just Field
tagToDirectiveLocation 4 = Just FragmentDefinition
tagToDirectiveLocation 5 = Just FragmentSpread
tagToDirectiveLocation 6 = Just InlineFragment
tagToDirectiveLocation 7 = Just Schema
tagToDirectiveLocation 8 = Just ScalarLoc
tagToDirectiveLocation 9 = Just ObjectLoc
tagToDirectiveLocation 10 = Just FieldDefinition
tagToDirectiveLocation 11 = Just ArgumentDefinition
tagToDirectiveLocation 12 = Just InterfaceLoc
tagToDirectiveLocation 13 = Just UnionLoc
tagToDirectiveLocation 14 = Just EnumLoc
tagToDirectiveLocation 15 = Just EnumValue
tagToDirectiveLocation 16 = Just InputObjectLoc
tagToDirectiveLocation 17 = Just InputFieldDefinition
tagToDirectiveLocation _ = Nothing

||| Roundtrip proof: decoding an encoded DirectiveLocation yields the original.
public export
directive_locationRoundtrip : (x : DirectiveLocation) -> tagToDirectiveLocation (directive_locationToTag x) = Just x
directive_locationRoundtrip QueryLoc = Refl
directive_locationRoundtrip MutationLoc = Refl
directive_locationRoundtrip SubscriptionLoc = Refl
directive_locationRoundtrip Field = Refl
directive_locationRoundtrip FragmentDefinition = Refl
directive_locationRoundtrip FragmentSpread = Refl
directive_locationRoundtrip InlineFragment = Refl
directive_locationRoundtrip Schema = Refl
directive_locationRoundtrip ScalarLoc = Refl
directive_locationRoundtrip ObjectLoc = Refl
directive_locationRoundtrip FieldDefinition = Refl
directive_locationRoundtrip ArgumentDefinition = Refl
directive_locationRoundtrip InterfaceLoc = Refl
directive_locationRoundtrip UnionLoc = Refl
directive_locationRoundtrip EnumLoc = Refl
directive_locationRoundtrip EnumValue = Refl
directive_locationRoundtrip InputObjectLoc = Refl
directive_locationRoundtrip InputFieldDefinition = Refl

---------------------------------------------------------------------------
-- ErrorCategory (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
error_categorySize : Nat
error_categorySize = 1

||| ErrorCategory sum type for ABI encoding.
public export
data ErrorCategory : Type where
  ParseError : ErrorCategory
  ValidationError : ErrorCategory
  ExecutionError : ErrorCategory
  AuthError : ErrorCategory
  RateLimited : ErrorCategory

||| Encode a ErrorCategory to its ABI tag value.
public export
error_categoryToTag : ErrorCategory -> Bits8
error_categoryToTag ParseError = 0
error_categoryToTag ValidationError = 1
error_categoryToTag ExecutionError = 2
error_categoryToTag AuthError = 3
error_categoryToTag RateLimited = 4

||| Decode an ABI tag to a ErrorCategory.
public export
tagToErrorCategory : Bits8 -> Maybe ErrorCategory
tagToErrorCategory 0 = Just ParseError
tagToErrorCategory 1 = Just ValidationError
tagToErrorCategory 2 = Just ExecutionError
tagToErrorCategory 3 = Just AuthError
tagToErrorCategory 4 = Just RateLimited
tagToErrorCategory _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorCategory yields the original.
public export
error_categoryRoundtrip : (x : ErrorCategory) -> tagToErrorCategory (error_categoryToTag x) = Just x
error_categoryRoundtrip ParseError = Refl
error_categoryRoundtrip ValidationError = Refl
error_categoryRoundtrip ExecutionError = Refl
error_categoryRoundtrip AuthError = Refl
error_categoryRoundtrip RateLimited = Refl

---------------------------------------------------------------------------
-- RequestPhase (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
request_phaseSize : Nat
request_phaseSize = 1

||| RequestPhase sum type for ABI encoding.
public export
data RequestPhase : Type where
  Parse : RequestPhase
  Validate : RequestPhase
  Execute : RequestPhase
  Resolve : RequestPhase
  Serialize : RequestPhase
  Failed : RequestPhase

||| Encode a RequestPhase to its ABI tag value.
public export
request_phaseToTag : RequestPhase -> Bits8
request_phaseToTag Parse = 0
request_phaseToTag Validate = 1
request_phaseToTag Execute = 2
request_phaseToTag Resolve = 3
request_phaseToTag Serialize = 4
request_phaseToTag Failed = 5

||| Decode an ABI tag to a RequestPhase.
public export
tagToRequestPhase : Bits8 -> Maybe RequestPhase
tagToRequestPhase 0 = Just Parse
tagToRequestPhase 1 = Just Validate
tagToRequestPhase 2 = Just Execute
tagToRequestPhase 3 = Just Resolve
tagToRequestPhase 4 = Just Serialize
tagToRequestPhase 5 = Just Failed
tagToRequestPhase _ = Nothing

||| Roundtrip proof: decoding an encoded RequestPhase yields the original.
public export
request_phaseRoundtrip : (x : RequestPhase) -> tagToRequestPhase (request_phaseToTag x) = Just x
request_phaseRoundtrip Parse = Refl
request_phaseRoundtrip Validate = Refl
request_phaseRoundtrip Execute = Refl
request_phaseRoundtrip Resolve = Refl
request_phaseRoundtrip Serialize = Refl
request_phaseRoundtrip Failed = Refl

---------------------------------------------------------------------------
-- SubscriptionPhase (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
subscription_phaseSize : Nat
subscription_phaseSize = 1

||| SubscriptionPhase sum type for ABI encoding.
public export
data SubscriptionPhase : Type where
  Subscribe : SubscriptionPhase
  Active : SubscriptionPhase
  Unsubscribe : SubscriptionPhase
  SubFailed : SubscriptionPhase

||| Encode a SubscriptionPhase to its ABI tag value.
public export
subscription_phaseToTag : SubscriptionPhase -> Bits8
subscription_phaseToTag Subscribe = 0
subscription_phaseToTag Active = 1
subscription_phaseToTag Unsubscribe = 2
subscription_phaseToTag SubFailed = 3

||| Decode an ABI tag to a SubscriptionPhase.
public export
tagToSubscriptionPhase : Bits8 -> Maybe SubscriptionPhase
tagToSubscriptionPhase 0 = Just Subscribe
tagToSubscriptionPhase 1 = Just Active
tagToSubscriptionPhase 2 = Just Unsubscribe
tagToSubscriptionPhase 3 = Just SubFailed
tagToSubscriptionPhase _ = Nothing

||| Roundtrip proof: decoding an encoded SubscriptionPhase yields the original.
public export
subscription_phaseRoundtrip : (x : SubscriptionPhase) -> tagToSubscriptionPhase (subscription_phaseToTag x) = Just x
subscription_phaseRoundtrip Subscribe = Refl
subscription_phaseRoundtrip Active = Refl
subscription_phaseRoundtrip Unsubscribe = Refl
subscription_phaseRoundtrip SubFailed = Refl

---------------------------------------------------------------------------
-- IntrospectionField (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
introspection_fieldSize : Nat
introspection_fieldSize = 1

||| IntrospectionField sum type for ABI encoding.
public export
data IntrospectionField : Type where
  SchemaField : IntrospectionField
  TypeField : IntrospectionField
  TypenameField : IntrospectionField

||| Encode a IntrospectionField to its ABI tag value.
public export
introspection_fieldToTag : IntrospectionField -> Bits8
introspection_fieldToTag SchemaField = 0
introspection_fieldToTag TypeField = 1
introspection_fieldToTag TypenameField = 2

||| Decode an ABI tag to a IntrospectionField.
public export
tagToIntrospectionField : Bits8 -> Maybe IntrospectionField
tagToIntrospectionField 0 = Just SchemaField
tagToIntrospectionField 1 = Just TypeField
tagToIntrospectionField 2 = Just TypenameField
tagToIntrospectionField _ = Nothing

||| Roundtrip proof: decoding an encoded IntrospectionField yields the original.
public export
introspection_fieldRoundtrip : (x : IntrospectionField) -> tagToIntrospectionField (introspection_fieldToTag x) = Just x
introspection_fieldRoundtrip SchemaField = Refl
introspection_fieldRoundtrip TypeField = Refl
introspection_fieldRoundtrip TypenameField = Refl

---------------------------------------------------------------------------
-- BatchQueryStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
batch_query_statusSize : Nat
batch_query_statusSize = 1

||| BatchQueryStatus sum type for ABI encoding.
public export
data BatchQueryStatus : Type where
  Pending : BatchQueryStatus
  Running : BatchQueryStatus
  Complete : BatchQueryStatus
  BqFailed : BatchQueryStatus

||| Encode a BatchQueryStatus to its ABI tag value.
public export
batch_query_statusToTag : BatchQueryStatus -> Bits8
batch_query_statusToTag Pending = 0
batch_query_statusToTag Running = 1
batch_query_statusToTag Complete = 2
batch_query_statusToTag BqFailed = 3

||| Decode an ABI tag to a BatchQueryStatus.
public export
tagToBatchQueryStatus : Bits8 -> Maybe BatchQueryStatus
tagToBatchQueryStatus 0 = Just Pending
tagToBatchQueryStatus 1 = Just Running
tagToBatchQueryStatus 2 = Just Complete
tagToBatchQueryStatus 3 = Just BqFailed
tagToBatchQueryStatus _ = Nothing

||| Roundtrip proof: decoding an encoded BatchQueryStatus yields the original.
public export
batch_query_statusRoundtrip : (x : BatchQueryStatus) -> tagToBatchQueryStatus (batch_query_statusToTag x) = Just x
batch_query_statusRoundtrip Pending = Refl
batch_query_statusRoundtrip Running = Refl
batch_query_statusRoundtrip Complete = Refl
batch_query_statusRoundtrip BqFailed = Refl
