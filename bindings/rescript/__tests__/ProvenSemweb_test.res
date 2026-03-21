// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSemweb protocol bindings.

open ProvenSemweb

let test_rdfFormat_roundtrip = () => {
  assert(rdfFormatFromTag(0) == Some(RdfXml))
  assert(rdfFormatFromTag(1) == Some(Turtle))
  assert(rdfFormatFromTag(2) == Some(NTriples))
  assert(rdfFormatFromTag(3) == Some(NQuads))
  assert(rdfFormatFromTag(4) == Some(JsonLd))
  assert(rdfFormatFromTag(5) == Some(Trig))
  assert(rdfFormatFromTag(6) == None)
}

let test_rdfFormat_toTag = () => {
  assert(rdfFormatToTag(RdfXml) == 0)
  assert(rdfFormatToTag(Turtle) == 1)
  assert(rdfFormatToTag(NTriples) == 2)
  assert(rdfFormatToTag(NQuads) == 3)
  assert(rdfFormatToTag(JsonLd) == 4)
  assert(rdfFormatToTag(Trig) == 5)
}

let test_semwebResourceType_roundtrip = () => {
  assert(semwebResourceTypeFromTag(0) == Some(Class))
  assert(semwebResourceTypeFromTag(1) == Some(Property))
  assert(semwebResourceTypeFromTag(2) == Some(Individual))
  assert(semwebResourceTypeFromTag(3) == Some(Ontology))
  assert(semwebResourceTypeFromTag(4) == Some(NamedGraph))
  assert(semwebResourceTypeFromTag(5) == None)
}

let test_semwebResourceType_toTag = () => {
  assert(semwebResourceTypeToTag(Class) == 0)
  assert(semwebResourceTypeToTag(Property) == 1)
  assert(semwebResourceTypeToTag(Individual) == 2)
  assert(semwebResourceTypeToTag(Ontology) == 3)
  assert(semwebResourceTypeToTag(NamedGraph) == 4)
}

let test_httpMethod_roundtrip = () => {
  assert(httpMethodFromTag(0) == Some(Get))
  assert(httpMethodFromTag(1) == Some(Post))
  assert(httpMethodFromTag(2) == Some(Put))
  assert(httpMethodFromTag(3) == Some(Patch))
  assert(httpMethodFromTag(4) == Some(Delete))
  assert(httpMethodFromTag(5) == None)
}

let test_httpMethod_toTag = () => {
  assert(httpMethodToTag(Get) == 0)
  assert(httpMethodToTag(Post) == 1)
  assert(httpMethodToTag(Put) == 2)
  assert(httpMethodToTag(Patch) == 3)
  assert(httpMethodToTag(Delete) == 4)
}

let test_contentNegotiation_roundtrip = () => {
  assert(contentNegotiationFromTag(0) == Some(NegRdfXml))
  assert(contentNegotiationFromTag(1) == Some(NegTurtle))
  assert(contentNegotiationFromTag(2) == Some(NegJsonLd))
  assert(contentNegotiationFromTag(3) == Some(NegHtml))
  assert(contentNegotiationFromTag(4) == None)
}

let test_contentNegotiation_toTag = () => {
  assert(contentNegotiationToTag(NegRdfXml) == 0)
  assert(contentNegotiationToTag(NegTurtle) == 1)
  assert(contentNegotiationToTag(NegJsonLd) == 2)
  assert(contentNegotiationToTag(NegHtml) == 3)
}

let test_semwebErrorCode_roundtrip = () => {
  assert(semwebErrorCodeFromTag(0) == Some(NotFound))
  assert(semwebErrorCodeFromTag(1) == Some(InvalidUri))
  assert(semwebErrorCodeFromTag(2) == Some(MalformedRdf))
  assert(semwebErrorCodeFromTag(3) == Some(UnsupportedFormat))
  assert(semwebErrorCodeFromTag(4) == Some(ConflictingTriples))
  assert(semwebErrorCodeFromTag(5) == None)
}

let test_semwebErrorCode_toTag = () => {
  assert(semwebErrorCodeToTag(NotFound) == 0)
  assert(semwebErrorCodeToTag(InvalidUri) == 1)
  assert(semwebErrorCodeToTag(MalformedRdf) == 2)
  assert(semwebErrorCodeToTag(UnsupportedFormat) == 3)
  assert(semwebErrorCodeToTag(ConflictingTriples) == 4)
}

// Run all tests
test_rdfFormat_roundtrip()
test_rdfFormat_toTag()
test_semwebResourceType_roundtrip()
test_semwebResourceType_toTag()
test_httpMethod_roundtrip()
test_httpMethod_toTag()
test_contentNegotiation_roundtrip()
test_contentNegotiation_toTag()
test_semwebErrorCode_roundtrip()
test_semwebErrorCode_toTag()
