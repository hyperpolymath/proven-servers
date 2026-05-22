// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! GraphQL protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `GraphQL.Types` which defines:
//! - [`OperationType`]     — query, mutation, subscription
//! - [`TypeKind`]          — introspection `__TypeKind` values
//! - [`DirectiveLocation`] — executable and type system locations
//! - [`ErrorCategory`]     — structured error classification

use std::fmt;

// ===========================================================================
// Operation Type (GraphQL.Types.OperationType)
// ===========================================================================

/// GraphQL root operation types.
///
/// Matches `OperationType` in `GraphQL.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OperationType {
    /// A read-only fetch.
    Query = 0,
    /// A write followed by a fetch.
    Mutation = 1,
    /// A long-lived request yielding events.
    Subscription = 2,
}

impl OperationType {
    /// Decode from a tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Query),
            1 => Some(Self::Mutation),
            2 => Some(Self::Subscription),
            _ => None,
        }
    }

    /// Encode to a tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// GraphQL keyword for this operation type.
    pub fn as_str(self) -> &'static str {
        match self {
            Self::Query => "query",
            Self::Mutation => "mutation",
            Self::Subscription => "subscription",
        }
    }
}

impl fmt::Display for OperationType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.as_str())
    }
}

// ===========================================================================
// Type Kind (GraphQL.Types.TypeKind)
// ===========================================================================

/// GraphQL type system kinds (introspection `__TypeKind`).
///
/// Matches `TypeKind` in `GraphQL.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TypeKind {
    /// Scalar type (e.g. `Int`, `String`, `Boolean`).
    Scalar = 0,
    /// Object type with fields.
    Object = 1,
    /// Interface type.
    Interface = 2,
    /// Union of object types.
    Union = 3,
    /// Enum type.
    Enum = 4,
    /// Input object type.
    InputObject = 5,
    /// List wrapper type.
    List = 6,
    /// Non-null wrapper type.
    NonNull = 7,
}

impl TypeKind {
    /// Decode from a tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Scalar),
            1 => Some(Self::Object),
            2 => Some(Self::Interface),
            3 => Some(Self::Union),
            4 => Some(Self::Enum),
            5 => Some(Self::InputObject),
            6 => Some(Self::List),
            7 => Some(Self::NonNull),
            _ => None,
        }
    }

    /// Encode to a tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Introspection name string (e.g. `"SCALAR"`, `"OBJECT"`).
    ///
    /// Matches the `Show` instance in `GraphQL.Types`.
    pub fn introspection_name(self) -> &'static str {
        match self {
            Self::Scalar => "SCALAR",
            Self::Object => "OBJECT",
            Self::Interface => "INTERFACE",
            Self::Union => "UNION",
            Self::Enum => "ENUM",
            Self::InputObject => "INPUT_OBJECT",
            Self::List => "LIST",
            Self::NonNull => "NON_NULL",
        }
    }

    /// Whether this is a wrapper type (List or NonNull).
    pub fn is_wrapper(self) -> bool {
        matches!(self, Self::List | Self::NonNull)
    }

    /// Whether this is a composite type (Object, Interface, or Union).
    pub fn is_composite(self) -> bool {
        matches!(self, Self::Object | Self::Interface | Self::Union)
    }
}

impl fmt::Display for TypeKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.introspection_name())
    }
}

// ===========================================================================
// Directive Location (GraphQL.Types.DirectiveLocation)
// ===========================================================================

/// GraphQL directive locations (executable and type system).
///
/// Matches `DirectiveLocation` in `GraphQL.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DirectiveLocation {
    // Executable locations
    /// On a query operation.
    Query = 0,
    /// On a mutation operation.
    Mutation = 1,
    /// On a subscription operation.
    Subscription = 2,
    /// On a field selection.
    Field = 3,
    /// On a fragment definition.
    FragmentDefinition = 4,
    /// On a fragment spread.
    FragmentSpread = 5,
    /// On an inline fragment.
    InlineFragment = 6,
    // Type system locations
    /// On a schema definition.
    Schema = 7,
    /// On a scalar type definition.
    Scalar = 8,
    /// On an object type definition.
    Object = 9,
    /// On a field definition.
    FieldDefinition = 10,
    /// On an argument definition.
    ArgumentDefinition = 11,
    /// On an interface type definition.
    Interface = 12,
    /// On a union type definition.
    Union = 13,
    /// On an enum type definition.
    Enum = 14,
    /// On an enum value definition.
    EnumValue = 15,
    /// On an input object type definition.
    InputObject = 16,
    /// On an input field definition.
    InputFieldDefinition = 17,
}

impl DirectiveLocation {
    /// Decode from a tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Query),
            1 => Some(Self::Mutation),
            2 => Some(Self::Subscription),
            3 => Some(Self::Field),
            4 => Some(Self::FragmentDefinition),
            5 => Some(Self::FragmentSpread),
            6 => Some(Self::InlineFragment),
            7 => Some(Self::Schema),
            8 => Some(Self::Scalar),
            9 => Some(Self::Object),
            10 => Some(Self::FieldDefinition),
            11 => Some(Self::ArgumentDefinition),
            12 => Some(Self::Interface),
            13 => Some(Self::Union),
            14 => Some(Self::Enum),
            15 => Some(Self::EnumValue),
            16 => Some(Self::InputObject),
            17 => Some(Self::InputFieldDefinition),
            _ => None,
        }
    }

    /// Encode to a tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is an executable location (query/mutation/subscription/field/fragment).
    pub fn is_executable(self) -> bool {
        (self as u8) <= 6
    }

    /// Whether this is a type system location.
    pub fn is_type_system(self) -> bool {
        !self.is_executable()
    }
}

impl fmt::Display for DirectiveLocation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Query => "QUERY",
            Self::Mutation => "MUTATION",
            Self::Subscription => "SUBSCRIPTION",
            Self::Field => "FIELD",
            Self::FragmentDefinition => "FRAGMENT_DEFINITION",
            Self::FragmentSpread => "FRAGMENT_SPREAD",
            Self::InlineFragment => "INLINE_FRAGMENT",
            Self::Schema => "SCHEMA",
            Self::Scalar => "SCALAR",
            Self::Object => "OBJECT",
            Self::FieldDefinition => "FIELD_DEFINITION",
            Self::ArgumentDefinition => "ARGUMENT_DEFINITION",
            Self::Interface => "INTERFACE",
            Self::Union => "UNION",
            Self::Enum => "ENUM",
            Self::EnumValue => "ENUM_VALUE",
            Self::InputObject => "INPUT_OBJECT",
            Self::InputFieldDefinition => "INPUT_FIELD_DEFINITION",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Error Category (GraphQL.Types.ErrorCategory)
// ===========================================================================

/// GraphQL error categories for structured error reporting.
///
/// Matches `ErrorCategory` in `GraphQL.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCategory {
    /// Syntax error in the GraphQL query.
    ParseError = 0,
    /// The query does not pass validation against the schema.
    ValidationError = 1,
    /// An error occurred during query execution.
    ExecutionError = 2,
    /// Authentication/authorisation failure.
    AuthError = 3,
    /// Request rate limit exceeded.
    RateLimited = 4,
}

impl ErrorCategory {
    /// Decode from a tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ParseError),
            1 => Some(Self::ValidationError),
            2 => Some(Self::ExecutionError),
            3 => Some(Self::AuthError),
            4 => Some(Self::RateLimited),
            _ => None,
        }
    }

    /// Encode to a tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// GraphQL extensions code string.
    ///
    /// Matches the `Show` instance in `GraphQL.Types`.
    pub fn code(self) -> &'static str {
        match self {
            Self::ParseError => "PARSE_ERROR",
            Self::ValidationError => "VALIDATION_ERROR",
            Self::ExecutionError => "EXECUTION_ERROR",
            Self::AuthError => "AUTH_ERROR",
            Self::RateLimited => "RATE_LIMITED",
        }
    }
}

impl fmt::Display for ErrorCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.code())
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn operation_type_roundtrip() {
        for tag in 0u8..=2 {
            let op = OperationType::from_tag(tag).expect("valid tag");
            assert_eq!(op.to_tag(), tag);
        }
        assert!(OperationType::from_tag(3).is_none());
    }

    #[test]
    fn type_kind_roundtrip() {
        for tag in 0u8..=7 {
            let tk = TypeKind::from_tag(tag).expect("valid tag");
            assert_eq!(tk.to_tag(), tag);
        }
        assert!(TypeKind::from_tag(8).is_none());
    }

    #[test]
    fn type_kind_classification() {
        assert!(TypeKind::List.is_wrapper());
        assert!(TypeKind::NonNull.is_wrapper());
        assert!(!TypeKind::Scalar.is_wrapper());

        assert!(TypeKind::Object.is_composite());
        assert!(TypeKind::Interface.is_composite());
        assert!(TypeKind::Union.is_composite());
        assert!(!TypeKind::Scalar.is_composite());
        assert!(!TypeKind::Enum.is_composite());
    }

    #[test]
    fn directive_location_roundtrip() {
        for tag in 0u8..=17 {
            let loc = DirectiveLocation::from_tag(tag).expect("valid tag");
            assert_eq!(loc.to_tag(), tag);
        }
        assert!(DirectiveLocation::from_tag(18).is_none());
    }

    #[test]
    fn directive_location_classification() {
        assert!(DirectiveLocation::Query.is_executable());
        assert!(DirectiveLocation::Field.is_executable());
        assert!(DirectiveLocation::InlineFragment.is_executable());
        assert!(!DirectiveLocation::Schema.is_executable());
        assert!(DirectiveLocation::Schema.is_type_system());
        assert!(DirectiveLocation::FieldDefinition.is_type_system());
    }

    #[test]
    fn error_category_roundtrip() {
        for tag in 0u8..=4 {
            let ec = ErrorCategory::from_tag(tag).expect("valid tag");
            assert_eq!(ec.to_tag(), tag);
        }
        assert!(ErrorCategory::from_tag(5).is_none());
    }
}
