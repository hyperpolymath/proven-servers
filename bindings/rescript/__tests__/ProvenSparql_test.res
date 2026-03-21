// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSparql protocol bindings.

open ProvenSparql

let test_sparqlQueryType_roundtrip = () => {
  assert(sparqlQueryTypeFromTag(0) == Some(Select))
  assert(sparqlQueryTypeFromTag(1) == Some(Construct))
  assert(sparqlQueryTypeFromTag(2) == Some(Ask))
  assert(sparqlQueryTypeFromTag(3) == Some(Describe))
  assert(sparqlQueryTypeFromTag(4) == None)
}

let test_sparqlQueryType_toTag = () => {
  assert(sparqlQueryTypeToTag(Select) == 0)
  assert(sparqlQueryTypeToTag(Construct) == 1)
  assert(sparqlQueryTypeToTag(Ask) == 2)
  assert(sparqlQueryTypeToTag(Describe) == 3)
}

let test_updateType_roundtrip = () => {
  assert(updateTypeFromTag(0) == Some(Insert))
  assert(updateTypeFromTag(1) == Some(Delete))
  assert(updateTypeFromTag(2) == Some(Load))
  assert(updateTypeFromTag(3) == Some(Clear))
  assert(updateTypeFromTag(4) == Some(Create))
  assert(updateTypeFromTag(5) == Some(Drop))
  assert(updateTypeFromTag(6) == None)
}

let test_updateType_toTag = () => {
  assert(updateTypeToTag(Insert) == 0)
  assert(updateTypeToTag(Delete) == 1)
  assert(updateTypeToTag(Load) == 2)
  assert(updateTypeToTag(Clear) == 3)
  assert(updateTypeToTag(Create) == 4)
  assert(updateTypeToTag(Drop) == 5)
}

let test_resultFormat_roundtrip = () => {
  assert(resultFormatFromTag(0) == Some(Xml))
  assert(resultFormatFromTag(1) == Some(Json))
  assert(resultFormatFromTag(2) == Some(Csv))
  assert(resultFormatFromTag(3) == Some(Tsv))
  assert(resultFormatFromTag(4) == None)
}

let test_resultFormat_toTag = () => {
  assert(resultFormatToTag(Xml) == 0)
  assert(resultFormatToTag(Json) == 1)
  assert(resultFormatToTag(Csv) == 2)
  assert(resultFormatToTag(Tsv) == 3)
}

let test_sparqlErrorType_roundtrip = () => {
  assert(sparqlErrorTypeFromTag(0) == Some(ParseError))
  assert(sparqlErrorTypeFromTag(1) == Some(QueryTimeout))
  assert(sparqlErrorTypeFromTag(2) == Some(ResultsTooLarge))
  assert(sparqlErrorTypeFromTag(3) == Some(UnknownGraph))
  assert(sparqlErrorTypeFromTag(4) == Some(AccessDenied))
  assert(sparqlErrorTypeFromTag(5) == None)
}

let test_sparqlErrorType_toTag = () => {
  assert(sparqlErrorTypeToTag(ParseError) == 0)
  assert(sparqlErrorTypeToTag(QueryTimeout) == 1)
  assert(sparqlErrorTypeToTag(ResultsTooLarge) == 2)
  assert(sparqlErrorTypeToTag(UnknownGraph) == 3)
  assert(sparqlErrorTypeToTag(AccessDenied) == 4)
}

// Run all tests
test_sparqlQueryType_roundtrip()
test_sparqlQueryType_toTag()
test_updateType_roundtrip()
test_updateType_toTag()
test_resultFormat_roundtrip()
test_resultFormat_toTag()
test_sparqlErrorType_roundtrip()
test_sparqlErrorType_toTag()
