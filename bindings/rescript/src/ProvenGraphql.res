// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// GraphQL protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module GraphQL.Types which defines:
// - OperationType     -- query, mutation, subscription
// - TypeKind          -- introspection __TypeKind values
// - DirectiveLocation -- executable and type system locations
// - ErrorCategory     -- structured error classification

// ===========================================================================
// Operation Type (GraphQL.Types.OperationType)
// ===========================================================================

/// GraphQL root operation types.
/// Matches OperationType in GraphQL.Types.
type operationType =
  | @as(0) Query
  | @as(1) Mutation
  | @as(2) Subscription

/// Decode from a tag value.
let operationTypeFromTag = (tag: int): option<operationType> =>
  switch tag {
  | 0 => Some(Query)
  | 1 => Some(Mutation)
  | 2 => Some(Subscription)
  | _ => None
  }

/// Encode to a tag value.
let operationTypeToTag = (op: operationType): int =>
  switch op {
  | Query => 0
  | Mutation => 1
  | Subscription => 2
  }

/// GraphQL keyword for this operation type.
let operationTypeAsStr = (op: operationType): string =>
  switch op {
  | Query => "query"
  | Mutation => "mutation"
  | Subscription => "subscription"
  }

// ===========================================================================
// Type Kind (GraphQL.Types.TypeKind)
// ===========================================================================

/// GraphQL type system kinds (introspection __TypeKind).
/// Matches TypeKind in GraphQL.Types.
type typeKind =
  | @as(0) Scalar
  | @as(1) Object
  | @as(2) Interface
  | @as(3) Union
  | @as(4) Enum
  | @as(5) InputObject
  | @as(6) List
  | @as(7) NonNull

/// Decode from a tag value.
let typeKindFromTag = (tag: int): option<typeKind> =>
  switch tag {
  | 0 => Some(Scalar)
  | 1 => Some(Object)
  | 2 => Some(Interface)
  | 3 => Some(Union)
  | 4 => Some(Enum)
  | 5 => Some(InputObject)
  | 6 => Some(List)
  | 7 => Some(NonNull)
  | _ => None
  }

/// Encode to a tag value.
let typeKindToTag = (tk: typeKind): int =>
  switch tk {
  | Scalar => 0
  | Object => 1
  | Interface => 2
  | Union => 3
  | Enum => 4
  | InputObject => 5
  | List => 6
  | NonNull => 7
  }

/// Introspection name string (e.g. "SCALAR", "OBJECT").
/// Matches the Show instance in GraphQL.Types.
let typeKindIntrospectionName = (tk: typeKind): string =>
  switch tk {
  | Scalar => "SCALAR"
  | Object => "OBJECT"
  | Interface => "INTERFACE"
  | Union => "UNION"
  | Enum => "ENUM"
  | InputObject => "INPUT_OBJECT"
  | List => "LIST"
  | NonNull => "NON_NULL"
  }

/// Whether this is a wrapper type (List or NonNull).
let typeKindIsWrapper = (tk: typeKind): bool =>
  switch tk {
  | List | NonNull => true
  | Scalar | Object | Interface | Union | Enum | InputObject => false
  }

/// Whether this is a composite type (Object, Interface, or Union).
let typeKindIsComposite = (tk: typeKind): bool =>
  switch tk {
  | Object | Interface | Union => true
  | Scalar | Enum | InputObject | List | NonNull => false
  }

// ===========================================================================
// Directive Location (GraphQL.Types.DirectiveLocation)
// ===========================================================================

/// GraphQL directive locations (executable and type system).
/// Matches DirectiveLocation in GraphQL.Types.
type directiveLocation =
  // Executable locations
  | @as(0) DirQuery
  | @as(1) DirMutation
  | @as(2) DirSubscription
  | @as(3) DirField
  | @as(4) DirFragmentDefinition
  | @as(5) DirFragmentSpread
  | @as(6) DirInlineFragment
  // Type system locations
  | @as(7) DirSchema
  | @as(8) DirScalar
  | @as(9) DirObject
  | @as(10) DirFieldDefinition
  | @as(11) DirArgumentDefinition
  | @as(12) DirInterface
  | @as(13) DirUnion
  | @as(14) DirEnum
  | @as(15) DirEnumValue
  | @as(16) DirInputObject
  | @as(17) DirInputFieldDefinition

/// Decode from a tag value.
let directiveLocationFromTag = (tag: int): option<directiveLocation> =>
  switch tag {
  | 0 => Some(DirQuery)
  | 1 => Some(DirMutation)
  | 2 => Some(DirSubscription)
  | 3 => Some(DirField)
  | 4 => Some(DirFragmentDefinition)
  | 5 => Some(DirFragmentSpread)
  | 6 => Some(DirInlineFragment)
  | 7 => Some(DirSchema)
  | 8 => Some(DirScalar)
  | 9 => Some(DirObject)
  | 10 => Some(DirFieldDefinition)
  | 11 => Some(DirArgumentDefinition)
  | 12 => Some(DirInterface)
  | 13 => Some(DirUnion)
  | 14 => Some(DirEnum)
  | 15 => Some(DirEnumValue)
  | 16 => Some(DirInputObject)
  | 17 => Some(DirInputFieldDefinition)
  | _ => None
  }

/// Encode to a tag value.
let directiveLocationToTag = (loc: directiveLocation): int =>
  switch loc {
  | DirQuery => 0
  | DirMutation => 1
  | DirSubscription => 2
  | DirField => 3
  | DirFragmentDefinition => 4
  | DirFragmentSpread => 5
  | DirInlineFragment => 6
  | DirSchema => 7
  | DirScalar => 8
  | DirObject => 9
  | DirFieldDefinition => 10
  | DirArgumentDefinition => 11
  | DirInterface => 12
  | DirUnion => 13
  | DirEnum => 14
  | DirEnumValue => 15
  | DirInputObject => 16
  | DirInputFieldDefinition => 17
  }

/// Whether this is an executable location (query/mutation/subscription/field/fragment).
let directiveLocationIsExecutable = (loc: directiveLocation): bool =>
  directiveLocationToTag(loc) <= 6

/// Whether this is a type system location.
let directiveLocationIsTypeSystem = (loc: directiveLocation): bool =>
  !directiveLocationIsExecutable(loc)

/// Display name for the directive location.
let directiveLocationAsStr = (loc: directiveLocation): string =>
  switch loc {
  | DirQuery => "QUERY"
  | DirMutation => "MUTATION"
  | DirSubscription => "SUBSCRIPTION"
  | DirField => "FIELD"
  | DirFragmentDefinition => "FRAGMENT_DEFINITION"
  | DirFragmentSpread => "FRAGMENT_SPREAD"
  | DirInlineFragment => "INLINE_FRAGMENT"
  | DirSchema => "SCHEMA"
  | DirScalar => "SCALAR"
  | DirObject => "OBJECT"
  | DirFieldDefinition => "FIELD_DEFINITION"
  | DirArgumentDefinition => "ARGUMENT_DEFINITION"
  | DirInterface => "INTERFACE"
  | DirUnion => "UNION"
  | DirEnum => "ENUM"
  | DirEnumValue => "ENUM_VALUE"
  | DirInputObject => "INPUT_OBJECT"
  | DirInputFieldDefinition => "INPUT_FIELD_DEFINITION"
  }

// ===========================================================================
// Error Category (GraphQL.Types.ErrorCategory)
// ===========================================================================

/// GraphQL error categories for structured error reporting.
/// Matches ErrorCategory in GraphQL.Types.
type errorCategory =
  | @as(0) ParseError
  | @as(1) ValidationError
  | @as(2) ExecutionError
  | @as(3) AuthError
  | @as(4) RateLimited

/// Decode from a tag value.
let errorCategoryFromTag = (tag: int): option<errorCategory> =>
  switch tag {
  | 0 => Some(ParseError)
  | 1 => Some(ValidationError)
  | 2 => Some(ExecutionError)
  | 3 => Some(AuthError)
  | 4 => Some(RateLimited)
  | _ => None
  }

/// Encode to a tag value.
let errorCategoryToTag = (ec: errorCategory): int =>
  switch ec {
  | ParseError => 0
  | ValidationError => 1
  | ExecutionError => 2
  | AuthError => 3
  | RateLimited => 4
  }

/// GraphQL extensions code string.
/// Matches the Show instance in GraphQL.Types.
let errorCategoryCode = (ec: errorCategory): string =>
  switch ec {
  | ParseError => "PARSE_ERROR"
  | ValidationError => "VALIDATION_ERROR"
  | ExecutionError => "EXECUTION_ERROR"
  | AuthError => "AUTH_ERROR"
  | RateLimited => "RATE_LIMITED"
  }
