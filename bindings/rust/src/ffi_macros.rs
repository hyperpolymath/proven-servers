// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Macros for generating proven-servers FFI binding modules.
//!
//! All 98 protocols follow the same slot-based context pool pattern:
//! - `<prefix>_abi_version() -> u32`
//! - `<prefix>_create_context() -> c_int`  (or `<prefix>_create(...)`)
//! - `<prefix>_destroy_context(slot)` (or `<prefix>_destroy(slot)`)
//! - `<prefix>_<state_query>(slot) -> u8`
//! - `<prefix>_can_transition(from, to) -> u8`
//!
//! The macros below generate the boilerplate for the context handle (with
//! Drop), the extern "C" block, and the safe wrappers.

/// Generate a minimal FFI binding module for a proven-servers protocol.
///
/// This macro creates:
/// - An opaque context handle with Drop (calls the destroy function)
/// - `abi_version() -> u32`
/// - `create_context() -> ProvenResult<$context_type>`
/// - `state(ctx) -> u8` (raw state tag)
/// - `can_transition(from, to) -> bool`
///
/// # Arguments
///
/// - `$mod_name`: the Rust module name (e.g. `ffi_amqp`)
/// - `$context_type`: the context struct name (e.g. `AmqpContext`)
/// - `$prefix`: the C function prefix (e.g. `amqp`)
/// - `$create_fn`: the create function name (e.g. `amqp_create_context`)
/// - `$destroy_fn`: the destroy function name (e.g. `amqp_destroy_context`)
/// - `$version_fn`: the ABI version function name (e.g. `amqp_abi_version`)
/// - `$state_fn`: the state query function name (e.g. `amqp_state`)
/// - `$transition_fn`: the transition check function name (e.g. `amqp_can_transition`)
/// - `$doc`: module-level doc comment
///
/// # Example
///
/// ```ignore
/// proven_ffi_module! {
///     mod_name: ffi_amqp,
///     context_type: AmqpContext,
///     doc: "Safe Rust wrappers for proven-amqp FFI.",
///     create_fn: amqp_create_context,
///     destroy_fn: amqp_destroy_context,
///     version_fn: amqp_abi_version,
///     state_fn: amqp_state,
///     transition_fn: amqp_can_transition,
/// }
/// ```
#[macro_export]
macro_rules! proven_ffi_module {
    (
        context_type: $ctx:ident,
        doc: $doc:expr,
        create_fn: $create:ident,
        destroy_fn: $destroy:ident,
        version_fn: $version:ident,
        state_fn: $state:ident,
        transition_fn: $transition:ident $(,)?
    ) => {
        #[doc = $doc]

        #[cfg(feature = "ffi")]
        use $crate::error::{ProvenError, ProvenResult};
        #[cfg(feature = "ffi")]
        use std::os::raw::c_int;

        #[cfg(feature = "ffi")]
        extern "C" {
            fn $version() -> u32;
            fn $create() -> c_int;
            fn $destroy(slot: c_int);
            fn $state(slot: c_int) -> u8;
            fn $transition(from: u8, to: u8) -> u8;
        }

        /// An opaque handle to a protocol context slot in the Zig FFI pool.
        ///
        /// Automatically releases its slot on drop.
        #[cfg(feature = "ffi")]
        #[derive(Debug)]
        pub struct $ctx {
            slot: c_int,
        }

        #[cfg(feature = "ffi")]
        impl Drop for $ctx {
            fn drop(&mut self) {
                // SAFETY: slot was validated on creation; destroy is idempotent.
                unsafe { $destroy(self.slot) }
            }
        }

        /// Return the ABI version of the linked library.
        #[cfg(feature = "ffi")]
        pub fn abi_version() -> u32 {
            unsafe { $version() }
        }

        /// Create a new context.
        ///
        /// Returns an owned context handle that releases its slot on drop.
        ///
        /// # Errors
        ///
        /// Returns [`ProvenError::PoolExhausted`] if all 64 slots are in use.
        #[cfg(feature = "ffi")]
        pub fn create_context() -> ProvenResult<$ctx> {
            let slot = unsafe { $create() };
            ProvenError::from_slot(slot).map(|s| $ctx { slot: s })
        }

        /// Get the current state tag (raw u8 from the FFI).
        #[cfg(feature = "ffi")]
        pub fn state(ctx: &$ctx) -> u8 {
            unsafe { $state(ctx.slot) }
        }

        /// Stateless query: check whether a state transition is valid.
        #[cfg(feature = "ffi")]
        pub fn can_transition(from: u8, to: u8) -> bool {
            unsafe { $transition(from, to) == 1 }
        }
    };
}
