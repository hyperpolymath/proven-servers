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

// Domain name validation tests removed: validateDomainName was an unproven
// reimplementation deleted from ProvenDns. The verified check lives in the
// Idris2/Zig core. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

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
  testConstantsMatchIdris()
  Js.log("ProvenDns: all tests passed")
}
