// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenWasm protocol bindings.

open ProvenWasm

let test_valType_roundtrip = () => {
  assert(valTypeFromTag(0) == Some(I32))
  assert(valTypeFromTag(1) == Some(I64))
  assert(valTypeFromTag(2) == Some(F32))
  assert(valTypeFromTag(3) == Some(F64))
  assert(valTypeFromTag(4) == Some(V128))
  assert(valTypeFromTag(5) == Some(FuncRef))
  assert(valTypeFromTag(6) == Some(ExternRef))
  assert(valTypeFromTag(7) == None)
}

let test_valType_toTag = () => {
  assert(valTypeToTag(I32) == 0)
  assert(valTypeToTag(I64) == 1)
  assert(valTypeToTag(F32) == 2)
  assert(valTypeToTag(F64) == 3)
  assert(valTypeToTag(V128) == 4)
  assert(valTypeToTag(FuncRef) == 5)
  assert(valTypeToTag(ExternRef) == 6)
}

let test_externKind_roundtrip = () => {
  assert(externKindFromTag(0) == Some(FuncExtern))
  assert(externKindFromTag(1) == Some(TableExtern))
  assert(externKindFromTag(2) == Some(MemExtern))
  assert(externKindFromTag(3) == Some(GlobalExtern))
  assert(externKindFromTag(4) == None)
}

let test_externKind_toTag = () => {
  assert(externKindToTag(FuncExtern) == 0)
  assert(externKindToTag(TableExtern) == 1)
  assert(externKindToTag(MemExtern) == 2)
  assert(externKindToTag(GlobalExtern) == 3)
}

let test_mutability_roundtrip = () => {
  assert(mutabilityFromTag(0) == Some(Immutable))
  assert(mutabilityFromTag(1) == Some(Mutable))
  assert(mutabilityFromTag(2) == None)
}

let test_mutability_toTag = () => {
  assert(mutabilityToTag(Immutable) == 0)
  assert(mutabilityToTag(Mutable) == 1)
}

// Run all tests
test_valType_roundtrip()
test_valType_toTag()
test_externKind_roundtrip()
test_externKind_toTag()
test_mutability_roundtrip()
test_mutability_toTag()
