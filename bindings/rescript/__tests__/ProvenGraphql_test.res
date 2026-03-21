// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenGraphql module: operation types, type kinds,
// directive locations, and error categories.

open ProvenGraphql

// ---------------------------------------------------------------------------
// Operation type tests
// ---------------------------------------------------------------------------

let testOperationTypeRoundtrip = () =>
  for tag in 0 to 2 {
    let op = operationTypeFromTag(tag)
    switch op {
    | Some(o) => assert(operationTypeToTag(o) == tag)
    | None => assert(false)
    }
  }

let testOperationTypeInvalid = () => assert(operationTypeFromTag(3) == None)

// ---------------------------------------------------------------------------
// Type kind tests
// ---------------------------------------------------------------------------

let testTypeKindRoundtrip = () =>
  for tag in 0 to 7 {
    let tk = typeKindFromTag(tag)
    switch tk {
    | Some(t) => assert(typeKindToTag(t) == tag)
    | None => assert(false)
    }
  }

let testTypeKindInvalid = () => assert(typeKindFromTag(8) == None)

let testTypeKindClassification = () => {
  assert(typeKindIsWrapper(List))
  assert(typeKindIsWrapper(NonNull))
  assert(!typeKindIsWrapper(Scalar))

  assert(typeKindIsComposite(Object))
  assert(typeKindIsComposite(Interface))
  assert(typeKindIsComposite(Union))
  assert(!typeKindIsComposite(Scalar))
  assert(!typeKindIsComposite(Enum))
}

// ---------------------------------------------------------------------------
// Directive location tests
// ---------------------------------------------------------------------------

let testDirectiveLocationRoundtrip = () =>
  for tag in 0 to 17 {
    let loc = directiveLocationFromTag(tag)
    switch loc {
    | Some(l) => assert(directiveLocationToTag(l) == tag)
    | None => assert(false)
    }
  }

let testDirectiveLocationInvalid = () => assert(directiveLocationFromTag(18) == None)

let testDirectiveLocationClassification = () => {
  assert(directiveLocationIsExecutable(DirQuery))
  assert(directiveLocationIsExecutable(DirField))
  assert(directiveLocationIsExecutable(DirInlineFragment))
  assert(!directiveLocationIsExecutable(DirSchema))
  assert(directiveLocationIsTypeSystem(DirSchema))
  assert(directiveLocationIsTypeSystem(DirFieldDefinition))
}

// ---------------------------------------------------------------------------
// Error category tests
// ---------------------------------------------------------------------------

let testErrorCategoryRoundtrip = () =>
  for tag in 0 to 4 {
    let ec = errorCategoryFromTag(tag)
    switch ec {
    | Some(e) => assert(errorCategoryToTag(e) == tag)
    | None => assert(false)
    }
  }

let testErrorCategoryInvalid = () => assert(errorCategoryFromTag(5) == None)

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testOperationTypeRoundtrip()
  testOperationTypeInvalid()
  testTypeKindRoundtrip()
  testTypeKindInvalid()
  testTypeKindClassification()
  testDirectiveLocationRoundtrip()
  testDirectiveLocationInvalid()
  testDirectiveLocationClassification()
  testErrorCategoryRoundtrip()
  testErrorCategoryInvalid()
  Js.log("ProvenGraphql: all tests passed")
}
