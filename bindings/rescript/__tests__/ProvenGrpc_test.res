// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenGrpc module: status codes, stream types, compression,
// stream states, and state machine transitions.

open ProvenGrpc

// ---------------------------------------------------------------------------
// Status code tests
// ---------------------------------------------------------------------------

let testStatusCodeRoundtrip = () =>
  for code in 0 to 16 {
    let sc = statusCodeFromCode(code)
    switch sc {
    | Some(c) => assert(statusCodeToCode(c) == code)
    | None => assert(false)
    }
  }

let testStatusCodeInvalid = () => {
  assert(statusCodeFromCode(17) == None)
  assert(statusCodeFromCode(255) == None)
}

// ---------------------------------------------------------------------------
// Stream type tests
// ---------------------------------------------------------------------------

let testStreamTypeClassification = () => {
  assert(!streamTypeIsClientStreaming(Unary))
  assert(!streamTypeIsServerStreaming(Unary))
  assert(streamTypeIsServerStreaming(ServerStreaming))
  assert(!streamTypeIsClientStreaming(ServerStreaming))
  assert(streamTypeIsClientStreaming(ClientStreaming))
  assert(!streamTypeIsServerStreaming(ClientStreaming))
  assert(streamTypeIsClientStreaming(BidiStreaming))
  assert(streamTypeIsServerStreaming(BidiStreaming))
}

// ---------------------------------------------------------------------------
// Stream state tests
// ---------------------------------------------------------------------------

let testStreamStateDataCapabilities = () => {
  // CanSendData: Open and HalfClosedRemote
  assert(streamCanSendData(StreamOpen))
  assert(streamCanSendData(HalfClosedRemote))
  assert(!streamCanSendData(HalfClosedLocal))
  assert(!streamCanSendData(StreamIdle))
  assert(!streamCanSendData(Closed))

  // CanReceiveData: Open and HalfClosedLocal
  assert(streamCanReceiveData(StreamOpen))
  assert(streamCanReceiveData(HalfClosedLocal))
  assert(!streamCanReceiveData(HalfClosedRemote))
  assert(!streamCanReceiveData(Closed))
}

// Stream transition tests (testClosedIsTerminal, testValidStreamTransitions,
// testImpossibleStreamTransitions) removed: validateStreamTransition was an
// unproven reimplementation deleted from ProvenGrpc. The verified check lives in
// the Idris2/Zig core. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testStatusCodeRoundtrip()
  testStatusCodeInvalid()
  testStreamTypeClassification()
  testStreamStateDataCapabilities()
  Js.log("ProvenGrpc: all tests passed")
}
