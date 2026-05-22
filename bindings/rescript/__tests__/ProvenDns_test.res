// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDns module: record types, response codes,
// domain name validation, and constants.

open ProvenDns

// ---------------------------------------------------------------------------
// Record type tests
// ---------------------------------------------------------------------------

let testRecordTypeRoundtrip = () =>
  Belt.Array.forEach(allRecordTypes, rt => {
    let code = recordTypeToTypeCode(rt)
    let decoded = recordTypeFromTypeCode(code)
    assert(decoded == Some(rt))
  })

let testRecordTypeUnknownRejected = () => {
  assert(recordTypeFromTypeCode(0) == None)
  assert(recordTypeFromTypeCode(255) == None)
}

let testRecordTypeClassification = () => {
  assert(recordTypeIsAddress(A))
  assert(recordTypeIsAddress(Aaaa))
  assert(!recordTypeIsAddress(Cname))
  assert(recordTypeIsInfrastructure(Ns))
  assert(recordTypeIsInfrastructure(Soa))
  assert(!recordTypeIsInfrastructure(Mx))
}

// ---------------------------------------------------------------------------
// Response code tests
// ---------------------------------------------------------------------------

let testResponseCodeRoundtrip = () =>
  for code in 0 to 5 {
    let rc = responseCodeFromRcode(code)
    switch rc {
    | Some(r) => assert(responseCodeToRcode(r) == code)
    | None => assert(false)
    }
  }

let testResponseCodeInvalid = () => assert(responseCodeFromRcode(6) == None)

let testResponseCodeClassification = () => {
  assert(responseCodeIsSuccess(NoError))
  assert(!responseCodeIsSuccess(NameError))
  assert(responseCodeIsNxdomain(NameError))
  assert(!responseCodeIsNxdomain(NoError))
}

// ---------------------------------------------------------------------------
// Domain name validation tests
// ---------------------------------------------------------------------------

let testDomainNameValid = () => {
  assert(validateDomainName("example.com") == Ok())
  assert(validateDomainName("sub.example.com") == Ok())
  assert(validateDomainName("a") == Ok())
}

let testDomainNameEmpty = () =>
  switch validateDomainName("") {
  | Error(EmptyName) => ()
  | _ => assert(false)
  }

let testDomainNameEmptyLabel = () =>
  switch validateDomainName("example..com") {
  | Error(EmptyLabel) => ()
  | _ => assert(false)
  }

let testDomainNameLabelTooLong = () => {
  // Build a 64-character label (exceeds 63 limit)
  let longLabel = Js.String2.repeat("a", 64)
  let name = longLabel ++ ".com"
  switch validateDomainName(name) {
  | Error(LabelTooLong(_)) => ()
  | _ => assert(false)
  }
}

let testDomainNameTooLong = () => {
  // Build a name over 253 characters
  let label = Js.String2.repeat("a", 63)
  let name = label ++ "." ++ label ++ "." ++ label ++ "." ++ label ++ ".x"
  assert(Js.String2.length(name) > maxNameLength)
  switch validateDomainName(name) {
  | Error(NameTooLong(_)) => ()
  | _ => assert(false)
  }
}

// ---------------------------------------------------------------------------
// Constants tests
// ---------------------------------------------------------------------------

let testConstantsMatchIdris = () => {
  assert(dnsPort == 53)
  assert(maxUdpSize == 512)
  assert(maxTcpSize == 65535)
  assert(maxLabelLength == 63)
  assert(maxNameLength == 253)
  assert(ednsUdpSize == 4096)
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testRecordTypeRoundtrip()
  testRecordTypeUnknownRejected()
  testRecordTypeClassification()
  testResponseCodeRoundtrip()
  testResponseCodeInvalid()
  testResponseCodeClassification()
  testDomainNameValid()
  testDomainNameEmpty()
  testDomainNameEmptyLabel()
  testDomainNameLabelTooLong()
  testDomainNameTooLong()
  testConstantsMatchIdris()
  Js.log("ProvenDns: all tests passed")
}
