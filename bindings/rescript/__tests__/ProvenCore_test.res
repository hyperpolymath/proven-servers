// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCore module: result codes, platforms, handles, alignment.

open ProvenCore

// ---------------------------------------------------------------------------
// ResultCode tests
// ---------------------------------------------------------------------------

let testResultCodeRoundtrip = () => {
  let codes = [ResultOk, ResultError, InvalidParam, OutOfMemory, NullPointer]
  Belt.Array.forEach(codes, code => {
    let tag = resultCodeToTag(code)
    let decoded = resultCodeFromTag(tag)
    assert(decoded == Some(code))
  })
}

let testResultCodeInvalidTag = () => {
  assert(resultCodeFromTag(5) == None)
  assert(resultCodeFromTag(255) == None)
}

let testResultCodeClassification = () => {
  assert(resultIsOk(ResultOk))
  assert(!resultIsError(ResultOk))
  assert(!resultIsOk(ResultError))
  assert(resultIsError(ResultError))
  assert(resultIsError(InvalidParam))
  assert(resultIsError(OutOfMemory))
  assert(resultIsError(NullPointer))
}

let testResultCodeDescription = () => {
  assert(resultDescription(ResultOk) == "Success")
  assert(resultDescription(NullPointer) == "Null pointer")
}

// ---------------------------------------------------------------------------
// Handle tests
// ---------------------------------------------------------------------------

let testHandleNonNull = () => {
  assert(handleNew(0.0) == None)
  let h = handleNew(42.0)
  switch h {
  | Some(handle) => assert(handleAsPtr(handle) == 42.0)
  | None => assert(false)
  }
}

// ---------------------------------------------------------------------------
// Alignment tests
// ---------------------------------------------------------------------------

let testAlignmentHelpers = () => {
  assert(paddingFor(0, 8) == 0)
  assert(paddingFor(4, 8) == 4)
  assert(paddingFor(8, 8) == 0)
  assert(paddingFor(1, 4) == 3)
  assert(alignUp(4, 8) == 8)
  assert(alignUp(8, 8) == 8)
  assert(alignUp(9, 8) == 16)
  assert(alignUp(0, 8) == 0)
}

// ---------------------------------------------------------------------------
// Platform tests
// ---------------------------------------------------------------------------

let testPlatformPtrSize = () => {
  assert(platformPtrSizeBits(Linux) == 64)
  assert(platformPtrSizeBits(Windows) == 64)
  assert(platformPtrSizeBits(MacOS) == 64)
  assert(platformPtrSizeBits(Bsd) == 64)
  assert(platformPtrSizeBits(Wasm) == 32)
  assert(platformPtrSizeBytes(Linux) == 8)
  assert(platformPtrSizeBytes(Wasm) == 4)
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testResultCodeRoundtrip()
  testResultCodeInvalidTag()
  testResultCodeClassification()
  testResultCodeDescription()
  testHandleNonNull()
  testAlignmentHelpers()
  testPlatformPtrSize()
  Js.log("ProvenCore: all tests passed")
}
