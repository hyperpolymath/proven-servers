// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenHttp module: methods, versions, status codes,
// content types, headers, request phases, and transitions.

open ProvenHttp

// ---------------------------------------------------------------------------
// Method tests
// ---------------------------------------------------------------------------

let testMethodRoundtrip = () =>
  Belt.Array.forEach(allMethods, method => {
    let tag = methodToTag(method)
    let decoded = methodFromTag(tag)
    assert(decoded == Some(method))
  })

let testMethodParseRoundtrip = () =>
  Belt.Array.forEach(allMethods, method => {
    let s = methodAsStr(method)
    let parsed = methodParse(s)
    assert(parsed == Some(method))
  })

let testMethodSafety = () => {
  assert(methodIsSafe(Get))
  assert(methodIsSafe(Head))
  assert(!methodIsSafe(Post))
  assert(!methodIsSafe(Delete))
}

let testMethodIdempotency = () => {
  assert(methodIsIdempotent(Get))
  assert(methodIsIdempotent(Put))
  assert(methodIsIdempotent(Delete))
  assert(!methodIsIdempotent(Post))
  assert(!methodIsIdempotent(Patch))
}

// ---------------------------------------------------------------------------
// Status code tests
// ---------------------------------------------------------------------------

let testStatusCodeRoundtrip = () => {
  for tag in 0 to 28 {
    let code = statusCodeFromTag(tag)
    switch code {
    | Some(c) => assert(statusCodeToTag(c) == tag)
    | None => assert(false)
    }
  }
}

let testStatusNumericCode = () => {
  assert(statusNumericCode(StatusOk) == 200)
  assert(statusNumericCode(NotFound) == 404)
  assert(statusNumericCode(InternalError) == 500)
}

let testStatusFromNumeric = () => {
  assert(statusFromNumeric(200) == Some(StatusOk))
  assert(statusFromNumeric(404) == Some(NotFound))
  assert(statusFromNumeric(999) == None)
}

let testStatusCategoryClassification = () => {
  assert(statusIsSuccess(StatusOk))
  assert(statusIsError(NotFound))
  assert(statusIsError(InternalError))
  assert(statusIsRedirect(MovedPermanently))
  assert(!statusIsError(StatusOk))
}

// ---------------------------------------------------------------------------
// Transition tests
// ---------------------------------------------------------------------------

let testValidHttpTransitions = () => {
  let validPairs = [
    (Idle, Receiving),
    (Receiving, HeadersParsed),
    (HeadersParsed, BodyReceiving),
    (HeadersParsed, Complete),
    (BodyReceiving, Complete),
    (Complete, Responding),
    (Responding, Sent),
    (Sent, Idle),
    (Receiving, Sent),
    (HeadersParsed, Sent),
    (BodyReceiving, Sent),
    (Complete, Sent),
  ]
  Belt.Array.forEach(validPairs, ((from, to_)) => {
    assert(validateHttpTransition(from, to_) != None)
  })
}

let testInvalidHttpTransitions = () => {
  let invalidPairs = [
    (Idle, Complete),
    (Idle, Responding),
    (Complete, Receiving),
    (Responding, HeadersParsed),
    (Idle, Idle),
  ]
  Belt.Array.forEach(invalidPairs, ((from, to_)) => {
    assert(validateHttpTransition(from, to_) == None)
  })
}

// ---------------------------------------------------------------------------
// Content type and version tests
// ---------------------------------------------------------------------------

let testContentTypeRoundtrip = () =>
  for tag in 0 to 7 {
    let ct = contentTypeFromTag(tag)
    switch ct {
    | Some(c) => assert(contentTypeToTag(c) == tag)
    | None => assert(false)
    }
  }

let testVersionOrdering = () => {
  assert(versionToTag(Http10) < versionToTag(Http11))
  assert(versionToTag(Http11) < versionToTag(Http20))
  assert(versionToTag(Http20) < versionToTag(Http30))
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testMethodRoundtrip()
  testMethodParseRoundtrip()
  testMethodSafety()
  testMethodIdempotency()
  testStatusCodeRoundtrip()
  testStatusNumericCode()
  testStatusFromNumeric()
  testStatusCategoryClassification()
  testValidHttpTransitions()
  testInvalidHttpTransitions()
  testContentTypeRoundtrip()
  testVersionOrdering()
  Js.log("ProvenHttp: all tests passed")
}
