// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Core ABI types shared across all proven-servers protocols.
//
// Mirrors the Idris2 ABI definitions in src/abi/Types.idr and
// src/abi/Layout.idr. All tag values match the Idris2 discriminants
// exactly, so roundtrip conversion between ReScript variants and
// C-ABI u8 tags is lossless.
//
// This module provides:
// - ResultCode: FFI operation result codes (tags 0-4)
// - Platform: supported target platforms for ABI layout selection
// - Handle: opaque non-null handle to library-managed resources
// - Alignment utilities: paddingFor, alignUp

// ---------------------------------------------------------------------------
// Result codes (mirrors ProvenServers.ABI.Types.Result)
// ---------------------------------------------------------------------------

/// FFI operation result codes.
/// Tag values match resultToInt in src/abi/Types.idr.
type resultCode =
  | @as(0) ResultOk
  | @as(1) ResultError
  | @as(2) InvalidParam
  | @as(3) OutOfMemory
  | @as(4) NullPointer

/// Convert a raw u8 tag to a ResultCode.
/// Returns None for values outside 0..4, matching the Idris2 partial decoder.
let resultCodeFromTag = (tag: int): option<resultCode> =>
  switch tag {
  | 0 => Some(ResultOk)
  | 1 => Some(ResultError)
  | 2 => Some(InvalidParam)
  | 3 => Some(OutOfMemory)
  | 4 => Some(NullPointer)
  | _ => None
  }

/// Convert a ResultCode to its C-ABI u8 tag value.
let resultCodeToTag = (code: resultCode): int =>
  switch code {
  | ResultOk => 0
  | ResultError => 1
  | InvalidParam => 2
  | OutOfMemory => 3
  | NullPointer => 4
  }

/// Whether this result represents success.
let resultIsOk = (code: resultCode): bool =>
  switch code {
  | ResultOk => true
  | ResultError | InvalidParam | OutOfMemory | NullPointer => false
  }

/// Whether this result represents any kind of error.
let resultIsError = (code: resultCode): bool => !resultIsOk(code)

/// Human-readable error description, matching errorDescription in
/// src/abi/Foreign.idr.
let resultDescription = (code: resultCode): string =>
  switch code {
  | ResultOk => "Success"
  | ResultError => "Generic error"
  | InvalidParam => "Invalid parameter"
  | OutOfMemory => "Out of memory"
  | NullPointer => "Null pointer"
  }

// ---------------------------------------------------------------------------
// Platform (mirrors ProvenServers.ABI.Types.Platform)
// ---------------------------------------------------------------------------

/// Supported target platforms for ABI layout selection.
/// Matches the Platform data type in src/abi/Types.idr.
type platform =
  | @as(0) Linux
  | @as(1) Windows
  | @as(2) MacOS
  | @as(3) Bsd
  | @as(4) Wasm

/// Pointer size in bits for a given platform.
/// Matches ptrSize in src/abi/Types.idr.
let platformPtrSizeBits = (p: platform): int =>
  switch p {
  | Linux | Windows | MacOS | Bsd => 64
  | Wasm => 32
  }

/// Pointer size in bytes for a given platform.
let platformPtrSizeBytes = (p: platform): int => platformPtrSizeBits(p) / 8

// ---------------------------------------------------------------------------
// Handle (mirrors ProvenServers.ABI.Types.Handle)
// ---------------------------------------------------------------------------

/// Opaque, non-null handle to a library-managed resource.
/// Mirrors the Idris2 Handle type which uses a So (ptr /= 0) proof
/// to enforce non-nullity at the type level. In ReScript, we enforce
/// via the constructor returning option<handle>.
type handle = Handle(float)

/// Create a handle from a raw pointer value.
/// Returns None if ptr is zero, matching createHandle in src/abi/Types.idr.
let handleNew = (ptr: float): option<handle> =>
  if ptr == 0.0 {
    None
  } else {
    Some(Handle(ptr))
  }

/// Extract the raw pointer value.
/// Matches handlePtr in src/abi/Types.idr.
let handleAsPtr = (h: handle): float => {
  let Handle(ptr) = h
  ptr
}

// ---------------------------------------------------------------------------
// Alignment utilities (mirrors ProvenServers.ABI.Layout)
// ---------------------------------------------------------------------------

/// Calculate padding needed to reach the next alignment boundary.
/// Mirrors paddingFor in src/abi/Layout.idr.
let paddingFor = (offset: int, alignment: int): int =>
  if alignment == 0 {
    0
  } else {
    let remainder = mod(offset, alignment)
    if remainder == 0 {
      0
    } else {
      alignment - remainder
    }
  }

/// Round size up to the next multiple of alignment.
/// Mirrors alignUp in src/abi/Layout.idr.
let alignUp = (size: int, alignment: int): int => size + paddingFor(size, alignment)
