//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Core ABI types shared across all proven-servers protocols.
////
//// These types mirror the definitions in `src/abi/Types.idr` and
//// `src/abi/Layout.idr`. They form the foundation that every protocol
//// module builds upon.
////
//// ## Tag values
////
//// All custom types use integer tag values matching the `resultToInt` /
//// `*ToTag` functions in the Idris2 ABI, ensuring wire-compatible
//// encoding across language bindings.

// ---------------------------------------------------------------------------
// Result codes (mirrors ProvenServers.ABI.Types.Result)
// ---------------------------------------------------------------------------

/// FFI operation result codes.
///
/// Matches the `Result` type in `src/abi/Types.idr` with identical
/// discriminant values from `resultToInt`.
pub type ResultCode {
  /// Operation succeeded (tag 0).
  ResultOk
  /// Generic error (tag 1).
  ResultError
  /// Invalid parameter provided (tag 2).
  ResultInvalidParam
  /// Out of memory (tag 3).
  ResultOutOfMemory
  /// Null pointer encountered (tag 4).
  ResultNullPointer
}

/// Convert a `ResultCode` to its C-ABI tag value.
pub fn result_to_int(code: ResultCode) -> Int {
  case code {
    ResultOk -> 0
    ResultError -> 1
    ResultInvalidParam -> 2
    ResultOutOfMemory -> 3
    ResultNullPointer -> 4
  }
}

/// Decode a raw tag value to a `ResultCode`.
///
/// Returns `Error(Nil)` for values outside the valid range 0..4.
pub fn result_from_int(tag: Int) -> Result(ResultCode, Nil) {
  case tag {
    0 -> Ok(ResultOk)
    1 -> Ok(ResultError)
    2 -> Ok(ResultInvalidParam)
    3 -> Ok(ResultOutOfMemory)
    4 -> Ok(ResultNullPointer)
    _ -> Error(Nil)
  }
}

/// Whether this result represents success.
pub fn result_is_ok(code: ResultCode) -> Bool {
  case code {
    ResultOk -> True
    _ -> False
  }
}

/// Whether this result represents any kind of error.
pub fn result_is_error(code: ResultCode) -> Bool {
  !result_is_ok(code)
}

/// Human-readable error description, matching `errorDescription` in
/// `src/abi/Foreign.idr`.
pub fn result_description(code: ResultCode) -> String {
  case code {
    ResultOk -> "Success"
    ResultError -> "Generic error"
    ResultInvalidParam -> "Invalid parameter"
    ResultOutOfMemory -> "Out of memory"
    ResultNullPointer -> "Null pointer"
  }
}

// ---------------------------------------------------------------------------
// Platform (mirrors ProvenServers.ABI.Types.Platform)
// ---------------------------------------------------------------------------

/// Supported target platforms for ABI layout selection.
///
/// Matches the `Platform` data type in `src/abi/Types.idr`.
pub type Platform {
  /// Linux (64-bit pointers, 64-bit size_t).
  Linux
  /// Windows (64-bit pointers, 64-bit size_t).
  Windows
  /// macOS (64-bit pointers, 64-bit size_t).
  MacOS
  /// BSD variants (64-bit pointers, 64-bit size_t).
  Bsd
  /// WebAssembly (32-bit pointers, 32-bit size_t).
  Wasm
}

/// Pointer size in bits for this platform.
///
/// Matches the `ptrSize` function in `src/abi/Types.idr`.
pub fn platform_ptr_size_bits(platform: Platform) -> Int {
  case platform {
    Wasm -> 32
    _ -> 64
  }
}

/// Pointer size in bytes for this platform.
pub fn platform_ptr_size_bytes(platform: Platform) -> Int {
  platform_ptr_size_bits(platform) / 8
}

// ---------------------------------------------------------------------------
// Alignment utilities (mirrors ProvenServers.ABI.Layout)
// ---------------------------------------------------------------------------

/// Calculate padding needed to reach the next alignment boundary.
///
/// Mirrors `paddingFor` in `src/abi/Layout.idr`.
pub fn padding_for(offset: Int, alignment: Int) -> Int {
  case alignment {
    0 -> 0
    _ -> {
      let remainder = offset % alignment
      case remainder {
        0 -> 0
        _ -> alignment - remainder
      }
    }
  }
}

/// Round `size` up to the next multiple of `alignment`.
///
/// Mirrors `alignUp` in `src/abi/Layout.idr`.
pub fn align_up(size: Int, alignment: Int) -> Int {
  size + padding_for(size, alignment)
}
