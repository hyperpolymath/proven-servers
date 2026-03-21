// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenProxy protocol bindings.

open ProvenProxy

let test_proxyMode_roundtrip = () => {
  assert(proxyModeFromTag(0) == Some(Forward))
  assert(proxyModeFromTag(1) == Some(Reverse))
  assert(proxyModeFromTag(2) == None)
}

let test_proxyMode_toTag = () => {
  assert(proxyModeToTag(Forward) == 0)
  assert(proxyModeToTag(Reverse) == 1)
}

let test_hopByHopHeader_roundtrip = () => {
  assert(hopByHopHeaderFromTag(0) == Some(Connection))
  assert(hopByHopHeaderFromTag(1) == Some(KeepAlive))
  assert(hopByHopHeaderFromTag(2) == Some(ProxyAuth))
  assert(hopByHopHeaderFromTag(3) == Some(ProxyAuthz))
  assert(hopByHopHeaderFromTag(4) == Some(Te))
  assert(hopByHopHeaderFromTag(5) == Some(Trailers))
  assert(hopByHopHeaderFromTag(6) == Some(TransferEncoding))
  assert(hopByHopHeaderFromTag(7) == Some(Upgrade))
  assert(hopByHopHeaderFromTag(8) == None)
}

let test_hopByHopHeader_toTag = () => {
  assert(hopByHopHeaderToTag(Connection) == 0)
  assert(hopByHopHeaderToTag(KeepAlive) == 1)
  assert(hopByHopHeaderToTag(ProxyAuth) == 2)
  assert(hopByHopHeaderToTag(ProxyAuthz) == 3)
  assert(hopByHopHeaderToTag(Te) == 4)
  assert(hopByHopHeaderToTag(Trailers) == 5)
  assert(hopByHopHeaderToTag(TransferEncoding) == 6)
  assert(hopByHopHeaderToTag(Upgrade) == 7)
}

let test_cacheDirective_roundtrip = () => {
  assert(cacheDirectiveFromTag(0) == Some(NoCache))
  assert(cacheDirectiveFromTag(1) == Some(NoStore))
  assert(cacheDirectiveFromTag(2) == Some(MaxAge))
  assert(cacheDirectiveFromTag(3) == Some(Public))
  assert(cacheDirectiveFromTag(4) == Some(Private))
  assert(cacheDirectiveFromTag(5) == Some(MustRevalidate))
  assert(cacheDirectiveFromTag(6) == None)
}

let test_cacheDirective_toTag = () => {
  assert(cacheDirectiveToTag(NoCache) == 0)
  assert(cacheDirectiveToTag(NoStore) == 1)
  assert(cacheDirectiveToTag(MaxAge) == 2)
  assert(cacheDirectiveToTag(Public) == 3)
  assert(cacheDirectiveToTag(Private) == 4)
  assert(cacheDirectiveToTag(MustRevalidate) == 5)
}

let test_proxyError_roundtrip = () => {
  assert(proxyErrorFromTag(0) == Some(BadGateway))
  assert(proxyErrorFromTag(1) == Some(GatewayTimeout))
  assert(proxyErrorFromTag(2) == Some(UpstreamRefused))
  assert(proxyErrorFromTag(3) == Some(UpstreamTls))
  assert(proxyErrorFromTag(4) == None)
}

let test_proxyError_toTag = () => {
  assert(proxyErrorToTag(BadGateway) == 0)
  assert(proxyErrorToTag(GatewayTimeout) == 1)
  assert(proxyErrorToTag(UpstreamRefused) == 2)
  assert(proxyErrorToTag(UpstreamTls) == 3)
}

// Run all tests
test_proxyMode_roundtrip()
test_proxyMode_toTag()
test_hopByHopHeader_roundtrip()
test_hopByHopHeader_toTag()
test_cacheDirective_roundtrip()
test_cacheDirective_toTag()
test_proxyError_roundtrip()
test_proxyError_toTag()
