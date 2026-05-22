// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Shared error types for proven-servers FFI bindings.
//!
//! All safe wrapper functions across protocol modules return
//! `Result<T, ProvenError>` using this unified error type. The error
//! variants map to failure modes common to the slot-based context
//! pattern used by every Zig FFI implementation.

use std::fmt;

/// Unified error type for all proven-servers FFI operations.
///
/// Every protocol FFI uses the same slot-based context pool pattern
/// with `c_int` return values (-1 = no slot, 0/1 = success/failure).
/// This enum maps those patterns to descriptive Rust errors.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum ProvenError {
    /// No free context slots available in the pool (64-slot limit).
    PoolExhausted,

    /// The slot index is invalid or the context is not active.
    InvalidSlot,

    /// The operation was rejected because the context is in the wrong
    /// lifecycle state for the requested transition.
    InvalidState,

    /// A parameter value is outside the valid ABI tag range.
    InvalidParameter,

    /// The operation would exceed a fixed-size buffer or array limit
    /// (e.g. max headers, max subscriptions, max rules).
    CapacityExceeded,

    /// A path or name failed validation (e.g. traversal attack, too long).
    ValidationFailed,

    /// The FFI returned an unexpected or undocumented error code.
    Unknown {
        /// The raw return code from the FFI function.
        code: i32,
    },
}

impl ProvenError {
    /// Interpret a slot-returning FFI call (returns `c_int`).
    ///
    /// Returns `Ok(slot)` for non-negative values, `Err(PoolExhausted)` for -1.
    pub fn from_slot(raw: i32) -> Result<i32, Self> {
        if raw >= 0 {
            Ok(raw)
        } else {
            Err(Self::PoolExhausted)
        }
    }

    /// Interpret a status-returning FFI call (0 = success, 1 = failure).
    ///
    /// Returns `Ok(())` for 0, maps non-zero to the appropriate error variant.
    pub fn from_status(raw: u8) -> Result<(), Self> {
        match raw {
            0 => Ok(()),
            1 => Err(Self::InvalidState),
            2 => Err(Self::ValidationFailed),
            _ => Err(Self::Unknown { code: raw as i32 }),
        }
    }

    /// Interpret a status-returning FFI call where 1 = invalid parameter.
    pub fn from_param_status(raw: u8) -> Result<(), Self> {
        match raw {
            0 => Ok(()),
            1 => Err(Self::InvalidParameter),
            _ => Err(Self::Unknown { code: raw as i32 }),
        }
    }
}

impl fmt::Display for ProvenError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::PoolExhausted => write!(f, "context pool exhausted (64-slot limit)"),
            Self::InvalidSlot => write!(f, "invalid or inactive context slot"),
            Self::InvalidState => write!(f, "operation rejected: wrong lifecycle state"),
            Self::InvalidParameter => write!(f, "parameter value outside valid ABI tag range"),
            Self::CapacityExceeded => write!(f, "fixed-size buffer or array capacity exceeded"),
            Self::ValidationFailed => write!(f, "input validation failed"),
            Self::Unknown { code } => write!(f, "unknown FFI error (code {})", code),
        }
    }
}

impl std::error::Error for ProvenError {}

/// Convenience type alias used throughout all protocol FFI wrappers.
pub type ProvenResult<T> = Result<T, ProvenError>;

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn from_slot_success() {
        assert_eq!(ProvenError::from_slot(0), Ok(0));
        assert_eq!(ProvenError::from_slot(42), Ok(42));
        assert_eq!(ProvenError::from_slot(63), Ok(63));
    }

    #[test]
    fn from_slot_failure() {
        assert_eq!(ProvenError::from_slot(-1), Err(ProvenError::PoolExhausted));
        assert_eq!(ProvenError::from_slot(-99), Err(ProvenError::PoolExhausted));
    }

    #[test]
    fn from_status_success() {
        assert!(ProvenError::from_status(0).is_ok());
    }

    #[test]
    fn from_status_failure() {
        assert_eq!(
            ProvenError::from_status(1),
            Err(ProvenError::InvalidState)
        );
        assert_eq!(
            ProvenError::from_status(2),
            Err(ProvenError::ValidationFailed)
        );
    }

    #[test]
    fn display_messages() {
        // Verify all variants produce non-empty messages.
        let variants = [
            ProvenError::PoolExhausted,
            ProvenError::InvalidSlot,
            ProvenError::InvalidState,
            ProvenError::InvalidParameter,
            ProvenError::CapacityExceeded,
            ProvenError::ValidationFailed,
            ProvenError::Unknown { code: 42 },
        ];
        for err in variants {
            let msg = format!("{err}");
            assert!(!msg.is_empty(), "empty display for {err:?}");
        }
    }
}
