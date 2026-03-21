//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// GraphQL protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `GraphQL.Types` which defines:
//// - `OperationType`     -- query, mutation, subscription
//// - `TypeKind`          -- introspection `__TypeKind` values
//// - `DirectiveLocation` -- executable and type system locations
//// - `ErrorCategory`     -- structured error classification

// ===========================================================================
// Operation Type (GraphQL.Types.OperationType)
// ===========================================================================

/// GraphQL root operation types.
pub type OperationType {
  Query
  Mutation
  Subscription
}

/// Convert an `OperationType` to its tag value.
pub fn operation_to_int(op: OperationType) -> Int {
  case op {
    Query -> 0
    Mutation -> 1
    Subscription -> 2
  }
}

/// Decode from a tag value.
pub fn operation_from_int(tag: Int) -> Result(OperationType, Nil) {
  case tag {
    0 -> Ok(Query)
    1 -> Ok(Mutation)
    2 -> Ok(Subscription)
    _ -> Error(Nil)
  }
}

/// GraphQL keyword for this operation type.
pub fn operation_to_string(op: OperationType) -> String {
  case op {
    Query -> "query"
    Mutation -> "mutation"
    Subscription -> "subscription"
  }
}

// ===========================================================================
// Type Kind (GraphQL.Types.TypeKind)
// ===========================================================================

/// GraphQL type system kinds (introspection `__TypeKind`).
pub type TypeKind {
  Scalar
  Object
  Interface
  Union
  Enum
  InputObject
  List
  NonNull
}

/// Convert a `TypeKind` to its tag value.
pub fn type_kind_to_int(tk: TypeKind) -> Int {
  case tk {
    Scalar -> 0
    Object -> 1
    Interface -> 2
    Union -> 3
    Enum -> 4
    InputObject -> 5
    List -> 6
    NonNull -> 7
  }
}

/// Decode from a tag value.
pub fn type_kind_from_int(tag: Int) -> Result(TypeKind, Nil) {
  case tag {
    0 -> Ok(Scalar)
    1 -> Ok(Object)
    2 -> Ok(Interface)
    3 -> Ok(Union)
    4 -> Ok(Enum)
    5 -> Ok(InputObject)
    6 -> Ok(List)
    7 -> Ok(NonNull)
    _ -> Error(Nil)
  }
}

/// Introspection name string (e.g. "SCALAR", "OBJECT").
pub fn type_kind_introspection_name(tk: TypeKind) -> String {
  case tk {
    Scalar -> "SCALAR"
    Object -> "OBJECT"
    Interface -> "INTERFACE"
    Union -> "UNION"
    Enum -> "ENUM"
    InputObject -> "INPUT_OBJECT"
    List -> "LIST"
    NonNull -> "NON_NULL"
  }
}

/// Whether this is a wrapper type (List or NonNull).
pub fn type_kind_is_wrapper(tk: TypeKind) -> Bool {
  case tk {
    List | NonNull -> True
    _ -> False
  }
}

/// Whether this is a composite type (Object, Interface, or Union).
pub fn type_kind_is_composite(tk: TypeKind) -> Bool {
  case tk {
    Object | Interface | Union -> True
    _ -> False
  }
}

// ===========================================================================
// Directive Location (GraphQL.Types.DirectiveLocation)
// ===========================================================================

/// GraphQL directive locations (executable and type system).
pub type DirectiveLocation {
  // Executable locations
  DlQuery
  DlMutation
  DlSubscription
  DlField
  DlFragmentDefinition
  DlFragmentSpread
  DlInlineFragment
  // Type system locations
  DlSchema
  DlScalar
  DlObject
  DlFieldDefinition
  DlArgumentDefinition
  DlInterface
  DlUnion
  DlEnum
  DlEnumValue
  DlInputObject
  DlInputFieldDefinition
}

/// Convert a `DirectiveLocation` to its tag value.
pub fn directive_location_to_int(loc: DirectiveLocation) -> Int {
  case loc {
    DlQuery -> 0
    DlMutation -> 1
    DlSubscription -> 2
    DlField -> 3
    DlFragmentDefinition -> 4
    DlFragmentSpread -> 5
    DlInlineFragment -> 6
    DlSchema -> 7
    DlScalar -> 8
    DlObject -> 9
    DlFieldDefinition -> 10
    DlArgumentDefinition -> 11
    DlInterface -> 12
    DlUnion -> 13
    DlEnum -> 14
    DlEnumValue -> 15
    DlInputObject -> 16
    DlInputFieldDefinition -> 17
  }
}

/// Decode from a tag value.
pub fn directive_location_from_int(tag: Int) -> Result(DirectiveLocation, Nil) {
  case tag {
    0 -> Ok(DlQuery)
    1 -> Ok(DlMutation)
    2 -> Ok(DlSubscription)
    3 -> Ok(DlField)
    4 -> Ok(DlFragmentDefinition)
    5 -> Ok(DlFragmentSpread)
    6 -> Ok(DlInlineFragment)
    7 -> Ok(DlSchema)
    8 -> Ok(DlScalar)
    9 -> Ok(DlObject)
    10 -> Ok(DlFieldDefinition)
    11 -> Ok(DlArgumentDefinition)
    12 -> Ok(DlInterface)
    13 -> Ok(DlUnion)
    14 -> Ok(DlEnum)
    15 -> Ok(DlEnumValue)
    16 -> Ok(DlInputObject)
    17 -> Ok(DlInputFieldDefinition)
    _ -> Error(Nil)
  }
}

/// Whether this is an executable location (tags 0-6).
pub fn directive_location_is_executable(loc: DirectiveLocation) -> Bool {
  directive_location_to_int(loc) <= 6
}

/// Whether this is a type system location (tags 7-17).
pub fn directive_location_is_type_system(loc: DirectiveLocation) -> Bool {
  !directive_location_is_executable(loc)
}

/// Display name for a directive location.
pub fn directive_location_to_string(loc: DirectiveLocation) -> String {
  case loc {
    DlQuery -> "QUERY"
    DlMutation -> "MUTATION"
    DlSubscription -> "SUBSCRIPTION"
    DlField -> "FIELD"
    DlFragmentDefinition -> "FRAGMENT_DEFINITION"
    DlFragmentSpread -> "FRAGMENT_SPREAD"
    DlInlineFragment -> "INLINE_FRAGMENT"
    DlSchema -> "SCHEMA"
    DlScalar -> "SCALAR"
    DlObject -> "OBJECT"
    DlFieldDefinition -> "FIELD_DEFINITION"
    DlArgumentDefinition -> "ARGUMENT_DEFINITION"
    DlInterface -> "INTERFACE"
    DlUnion -> "UNION"
    DlEnum -> "ENUM"
    DlEnumValue -> "ENUM_VALUE"
    DlInputObject -> "INPUT_OBJECT"
    DlInputFieldDefinition -> "INPUT_FIELD_DEFINITION"
  }
}

// ===========================================================================
// Error Category (GraphQL.Types.ErrorCategory)
// ===========================================================================

/// GraphQL error categories for structured error reporting.
pub type ErrorCategory {
  ParseError
  ValidationError
  ExecutionError
  AuthError
  RateLimited
}

/// Convert an `ErrorCategory` to its tag value.
pub fn error_category_to_int(ec: ErrorCategory) -> Int {
  case ec {
    ParseError -> 0
    ValidationError -> 1
    ExecutionError -> 2
    AuthError -> 3
    RateLimited -> 4
  }
}

/// Decode from a tag value.
pub fn error_category_from_int(tag: Int) -> Result(ErrorCategory, Nil) {
  case tag {
    0 -> Ok(ParseError)
    1 -> Ok(ValidationError)
    2 -> Ok(ExecutionError)
    3 -> Ok(AuthError)
    4 -> Ok(RateLimited)
    _ -> Error(Nil)
  }
}

/// GraphQL extensions code string.
pub fn error_category_code(ec: ErrorCategory) -> String {
  case ec {
    ParseError -> "PARSE_ERROR"
    ValidationError -> "VALIDATION_ERROR"
    ExecutionError -> "EXECUTION_ERROR"
    AuthError -> "AUTH_ERROR"
    RateLimited -> "RATE_LIMITED"
  }
}
