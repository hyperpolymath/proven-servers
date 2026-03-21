// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! WASM Runtime types for the proven-servers ABI.
//!
//! Formally verified WebAssembly runtime types.
//! Mirrors the Idris2 module `WasmABI.Types`.
//!
//! - `ValType` -- WebAssembly value types.
//! - `ExternKind` -- WebAssembly external kinds.
//! - `Mutability` -- WebAssembly global mutability.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ValType (tags 0-6)
// ===========================================================================

/// WebAssembly value types.
///
/// Matches `ValType` in `WasmABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ValType {
    /// I32 (tag 0).
    I32 = 0,
    /// I64 (tag 1).
    I64 = 1,
    /// F32 (tag 2).
    F32 = 2,
    /// F64 (tag 3).
    F64 = 3,
    /// V128 (tag 4).
    V128 = 4,
    /// FuncRef (tag 5).
    FuncRef = 5,
    /// ExternRef (tag 6).
    ExternRef = 6,
}

impl ValType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::I32),
            1 => Some(Self::I64),
            2 => Some(Self::F32),
            3 => Some(Self::F64),
            4 => Some(Self::V128),
            5 => Some(Self::FuncRef),
            6 => Some(Self::ExternRef),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a numeric type.
    pub fn is_numeric(self) -> bool {
        matches!(self, Self::I32 | Self::I64 | Self::F32 | Self::F64)
    }

    /// Whether this is a reference type.
    pub fn is_reference(self) -> bool {
        matches!(self, Self::FuncRef | Self::ExternRef)
    }

    /// All variants of this type.
    pub const ALL: [ValType; 7] = [
        Self::I32, Self::I64, Self::F32, Self::F64, Self::V128, Self::FuncRef, Self::ExternRef,
    ];
}

impl fmt::Display for ValType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ExternKind (tags 0-3)
// ===========================================================================

/// WebAssembly external kinds.
///
/// Matches `ExternKind` in `WasmABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ExternKind {
    /// Function (tag 0).
    FuncExtern = 0,
    /// Table (tag 1).
    TableExtern = 1,
    /// Memory (tag 2).
    MemExtern = 2,
    /// Global (tag 3).
    GlobalExtern = 3,
}

impl ExternKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::FuncExtern),
            1 => Some(Self::TableExtern),
            2 => Some(Self::MemExtern),
            3 => Some(Self::GlobalExtern),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ExternKind; 4] = [
        Self::FuncExtern, Self::TableExtern, Self::MemExtern, Self::GlobalExtern,
    ];
}

impl fmt::Display for ExternKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Mutability (tags 0-1)
// ===========================================================================

/// WebAssembly global mutability.
///
/// Matches `Mutability` in `WasmABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Mutability {
    /// Immutable (tag 0).
    Immutable = 0,
    /// Mutable (tag 1).
    Mutable = 1,
}

impl Mutability {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Immutable),
            1 => Some(Self::Mutable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Mutability; 2] = [
        Self::Immutable, Self::Mutable,
    ];
}

impl fmt::Display for Mutability {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn val_type_roundtrip() {
        for v in ValType::ALL {
            let tag = v.to_tag();
            let decoded = ValType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ValType::from_tag(7).is_none());
    }

    #[test]
    fn extern_kind_roundtrip() {
        for v in ExternKind::ALL {
            let tag = v.to_tag();
            let decoded = ExternKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ExternKind::from_tag(4).is_none());
    }

    #[test]
    fn mutability_roundtrip() {
        for v in Mutability::ALL {
            let tag = v.to_tag();
            let decoded = Mutability::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Mutability::from_tag(2).is_none());
    }

}
