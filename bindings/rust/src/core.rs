// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Core ABI types shared across all proven-servers protocols.
//!
//! These types mirror the definitions in `src/abi/Types.idr` and
//! `src/abi/Layout.idr`. They form the foundation that every protocol
//! module builds upon.
//!
//! ## Tag values
//!
//! All enums use `#[repr(u8)]` with discriminant values matching the
//! `resultToInt` / `*ToTag` functions in the Idris2 ABI, so that a
//! simple `transmute` or `as u8` produces the correct C-level tag.
//!
//! ## Handle
//!
//! The [`Handle`] wrapper enforces the same non-null invariant as the
//! Idris2 `Handle` type: construction is fallible and the inner pointer
//! is guaranteed non-zero.

use std::fmt;
use std::num::NonZeroU64;

// ---------------------------------------------------------------------------
// Result codes (mirrors ProvenServers.ABI.Types.Result)
// ---------------------------------------------------------------------------

/// FFI operation result codes.
///
/// Matches the `Result` type in `src/abi/Types.idr` with identical
/// discriminant values from `resultToInt`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResultCode {
    /// Operation succeeded (tag 0).
    Ok = 0,
    /// Generic error (tag 1).
    Error = 1,
    /// Invalid parameter provided (tag 2).
    InvalidParam = 2,
    /// Out of memory (tag 3).
    OutOfMemory = 3,
    /// Null pointer encountered (tag 4).
    NullPointer = 4,
}

impl ResultCode {
    /// Convert a raw `u8` tag to a [`ResultCode`].
    ///
    /// Returns `None` for values outside the valid range 0..=4,
    /// matching the Idris2 partial decoder pattern.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::Error),
            2 => Some(Self::InvalidParam),
            3 => Some(Self::OutOfMemory),
            4 => Some(Self::NullPointer),
            _ => None,
        }
    }

    /// Convert to the C-compatible `u8` tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this result represents success.
    pub fn is_ok(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// Whether this result represents any kind of error.
    pub fn is_error(self) -> bool {
        !self.is_ok()
    }

    /// Human-readable error description, matching `errorDescription` in
    /// `src/abi/Foreign.idr`.
    pub fn description(self) -> &'static str {
        match self {
            Self::Ok => "Success",
            Self::Error => "Generic error",
            Self::InvalidParam => "Invalid parameter",
            Self::OutOfMemory => "Out of memory",
            Self::NullPointer => "Null pointer",
        }
    }
}

impl fmt::Display for ResultCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", self.description())
    }
}

impl std::error::Error for ResultCode {}

// ---------------------------------------------------------------------------
// Platform (mirrors ProvenServers.ABI.Types.Platform)
// ---------------------------------------------------------------------------

/// Supported target platforms for ABI layout selection.
///
/// Matches the `Platform` data type in `src/abi/Types.idr`.
/// Platform-dependent sizing (pointer width, `size_t` width) is
/// determined by this value.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Platform {
    /// Linux (64-bit pointers, 64-bit size_t).
    Linux = 0,
    /// Windows (64-bit pointers, 64-bit size_t).
    Windows = 1,
    /// macOS (64-bit pointers, 64-bit size_t).
    MacOS = 2,
    /// BSD variants (64-bit pointers, 64-bit size_t).
    Bsd = 3,
    /// WebAssembly (32-bit pointers, 32-bit size_t).
    Wasm = 4,
}

impl Platform {
    /// Pointer size in bits for this platform.
    ///
    /// Matches the `ptrSize` function in `src/abi/Types.idr`.
    pub fn ptr_size_bits(self) -> u32 {
        match self {
            Self::Linux | Self::Windows | Self::MacOS | Self::Bsd => 64,
            Self::Wasm => 32,
        }
    }

    /// Pointer size in bytes for this platform.
    pub fn ptr_size_bytes(self) -> u32 {
        self.ptr_size_bits() / 8
    }

    /// Detect the current compilation target platform.
    ///
    /// Mirrors `thisPlatform` from `src/abi/Types.idr`, but uses Rust
    /// `cfg` attributes instead of Idris2 elaboration.
    pub fn current() -> Self {
        #[cfg(target_os = "linux")]
        {
            Self::Linux
        }
        #[cfg(target_os = "windows")]
        {
            Self::Windows
        }
        #[cfg(target_os = "macos")]
        {
            Self::MacOS
        }
        #[cfg(any(target_os = "freebsd", target_os = "openbsd", target_os = "netbsd"))]
        {
            Self::Bsd
        }
        #[cfg(target_family = "wasm")]
        {
            Self::Wasm
        }
        #[cfg(not(any(
            target_os = "linux",
            target_os = "windows",
            target_os = "macos",
            target_os = "freebsd",
            target_os = "openbsd",
            target_os = "netbsd",
            target_family = "wasm"
        )))]
        {
            Self::Linux // Default fallback, same as Idris2 ABI
        }
    }
}

// ---------------------------------------------------------------------------
// Handle (mirrors ProvenServers.ABI.Types.Handle)
// ---------------------------------------------------------------------------

/// Opaque, non-null handle to a library-managed resource.
///
/// Mirrors the Idris2 `Handle` type which uses a `So (ptr /= 0)` proof
/// to enforce non-nullity at the type level. In Rust, we achieve the
/// same guarantee through [`NonZeroU64`].
///
/// Handles are created via [`Handle::new`] (fallible) and cannot be
/// constructed from a null/zero pointer.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(transparent)]
pub struct Handle(NonZeroU64);

impl Handle {
    /// Create a handle from a raw pointer value.
    ///
    /// Returns `None` if `ptr` is zero, matching `createHandle` in
    /// `src/abi/Types.idr`.
    pub fn new(ptr: u64) -> Option<Self> {
        NonZeroU64::new(ptr).map(Handle)
    }

    /// Extract the raw pointer value.
    ///
    /// Matches `handlePtr` in `src/abi/Types.idr`.
    pub fn as_ptr(self) -> u64 {
        self.0.get()
    }
}

impl fmt::Display for Handle {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "Handle(0x{:016x})", self.as_ptr())
    }
}

// ---------------------------------------------------------------------------
// Alignment utilities (mirrors ProvenServers.ABI.Layout)
// ---------------------------------------------------------------------------

/// Calculate padding needed to reach the next alignment boundary.
///
/// Mirrors `paddingFor` in `src/abi/Layout.idr`.
pub const fn padding_for(offset: usize, alignment: usize) -> usize {
    if alignment == 0 {
        return 0;
    }
    let remainder = offset % alignment;
    if remainder == 0 {
        0
    } else {
        alignment - remainder
    }
}

/// Round `size` up to the next multiple of `alignment`.
///
/// Mirrors `alignUp` in `src/abi/Layout.idr`.
pub const fn align_up(size: usize, alignment: usize) -> usize {
    size + padding_for(size, alignment)
}

// ---------------------------------------------------------------------------
// FFI bindings (behind the `ffi` feature gate)
// ---------------------------------------------------------------------------

/// Raw FFI declarations for `libproven_servers`.
///
/// These match the C function signatures declared in
/// `src/abi/Foreign.idr` and implemented in `ffi/zig/src/main.zig`.
///
/// Only available when the `ffi` crate feature is enabled.
#[cfg(feature = "ffi")]
pub mod ffi {
    use super::Handle;

    extern "C" {
        /// Initialise the library. Returns a raw pointer (0 on failure).
        pub fn proven_servers_init() -> u64;
        /// Free library resources associated with `handle`.
        pub fn proven_servers_free(handle: u64);
        /// Process data through the library.
        pub fn proven_servers_process(handle: u64, input: u32) -> u32;
        /// Check if the library is initialised for the given handle.
        pub fn proven_servers_is_initialized(handle: u64) -> u32;
        /// Get the library version string (caller must not free).
        pub fn proven_servers_version() -> u64;
        /// Get library build info (caller must not free).
        pub fn proven_servers_build_info() -> u64;
        /// Get last error message pointer (0 if none).
        pub fn proven_servers_last_error() -> u64;
        /// Free a string previously returned by the library.
        pub fn proven_servers_free_string(ptr: u64);
    }

    /// Safe wrapper: initialise the library and return a [`Handle`].
    ///
    /// Returns `None` if initialisation fails (null pointer returned).
    pub fn init() -> Option<Handle> {
        // SAFETY: `proven_servers_init` is a C function with no preconditions.
        // The returned pointer is checked for null via `Handle::new`.
        let ptr = unsafe { proven_servers_init() };
        Handle::new(ptr)
    }

    /// Safe wrapper: release library resources.
    pub fn free(handle: Handle) {
        // SAFETY: `handle` is guaranteed non-null by construction.
        unsafe { proven_servers_free(handle.as_ptr()) }
    }

    /// Safe wrapper: check if the library is initialised.
    pub fn is_initialized(handle: Handle) -> bool {
        // SAFETY: `handle` is guaranteed non-null by construction.
        unsafe { proven_servers_is_initialized(handle.as_ptr()) != 0 }
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn result_code_roundtrip() {
        // Every valid tag should roundtrip through from_tag -> to_tag.
        for tag in 0u8..=4 {
            let code = ResultCode::from_tag(tag).expect("valid tag");
            assert_eq!(code.to_tag(), tag);
        }
    }

    #[test]
    fn result_code_invalid_tag() {
        assert!(ResultCode::from_tag(5).is_none());
        assert!(ResultCode::from_tag(255).is_none());
    }

    #[test]
    fn result_code_classification() {
        assert!(ResultCode::Ok.is_ok());
        assert!(!ResultCode::Ok.is_error());
        assert!(!ResultCode::Error.is_ok());
        assert!(ResultCode::Error.is_error());
        assert!(ResultCode::InvalidParam.is_error());
        assert!(ResultCode::OutOfMemory.is_error());
        assert!(ResultCode::NullPointer.is_error());
    }

    #[test]
    fn handle_non_null() {
        assert!(Handle::new(0).is_none(), "zero pointer must yield None");
        let h = Handle::new(42).expect("non-zero pointer");
        assert_eq!(h.as_ptr(), 42);
    }

    #[test]
    fn handle_display() {
        let h = Handle::new(0xDEAD_BEEF).unwrap();
        let s = format!("{h}");
        assert!(s.contains("deadbeef"), "display should show hex: {s}");
    }

    #[test]
    fn platform_detection() {
        let p = Platform::current();
        // On a normal 64-bit build, pointer size should be 64 bits.
        #[cfg(target_pointer_width = "64")]
        assert_eq!(p.ptr_size_bits(), 64);
        #[cfg(target_pointer_width = "32")]
        assert_eq!(p.ptr_size_bits(), 32);
    }

    #[test]
    fn alignment_helpers() {
        assert_eq!(padding_for(0, 8), 0);
        assert_eq!(padding_for(4, 8), 4);
        assert_eq!(padding_for(8, 8), 0);
        assert_eq!(padding_for(1, 4), 3);
        assert_eq!(align_up(4, 8), 8);
        assert_eq!(align_up(8, 8), 8);
        assert_eq!(align_up(9, 8), 16);
        assert_eq!(align_up(0, 8), 0);
    }
}
