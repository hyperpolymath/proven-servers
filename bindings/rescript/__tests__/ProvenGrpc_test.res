// SPDX-License-Identifier: PMPL-1.0-or-later
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

let testClosedIsTerminal = () =>
  for toTag in 0 to 5 {
    let to_ = streamStateFromTag(toTag)
    switch to_ {
    | Some(toState) => assert(validateStreamTransition(Closed, toState) == None)
    | None => assert(false)
    }
  }

let testValidStreamTransitions = () => {
  let validPairs = [
    (StreamIdle, StreamOpen),
    (StreamOpen, HalfClosedLocal),
    (StreamOpen, HalfClosedRemote),
    (StreamOpen, Closed),
    (HalfClosedLocal, Closed),
    (HalfClosedRemote, Closed),
    (StreamIdle, Reserved),
    (Reserved, HalfClosedRemote),
    (Reserved, Closed),
  ]
  Belt.Array.forEach(validPairs, ((from, to_)) => {
    assert(validateStreamTransition(from, to_) != None)
  })
}

let testImpossibleStreamTransitions = () => {
  let impossiblePairs = [
    (StreamIdle, HalfClosedLocal),
    (HalfClosedLocal, StreamOpen),
    (Reserved, StreamOpen),
  ]
  Belt.Array.forEach(impossiblePairs, ((from, to_)) => {
    assert(validateStreamTransition(from, to_) == None)
  })
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testStatusCodeRoundtrip()
  testStatusCodeInvalid()
  testStreamTypeClassification()
  testStreamStateDataCapabilities()
  testClosedIsTerminal()
  testValidStreamTransitions()
  testImpossibleStreamTransitions()
  Js.log("ProvenGrpc: all tests passed")
}
