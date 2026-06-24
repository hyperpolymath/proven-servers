// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenWebsocket module: opcodes, close codes, and frame validation.

open ProvenWebsocket

// ---------------------------------------------------------------------------
// Opcode tests
// ---------------------------------------------------------------------------

let testOpcodeRoundtrip = () => {
  let opcodes = [(0x0, Continuation), (0x1, Text), (0x2, Binary), (0x8, Close), (0x9, Ping), (0xA, Pong)]
  Belt.Array.forEach(opcodes, ((nibble, expected)) => {
    let decoded = opcodeFromNibble(nibble)
    assert(decoded == Some(expected))
    switch decoded {
    | Some(op) => assert(opcodeToNibble(op) == nibble)
    | None => assert(false)
    }
  })
}

let testOpcodeReservedRejected = () => {
  let reserved = [0x3, 0x4, 0x5, 0x6, 0x7, 0xB, 0xC, 0xD, 0xE, 0xF]
  Belt.Array.forEach(reserved, nibble => {
    assert(opcodeFromNibble(nibble) == None)
  })
}

let testOpcodeClassification = () => {
  assert(opcodeIsData(Text))
  assert(opcodeIsData(Binary))
  assert(opcodeIsData(Continuation))
  assert(!opcodeIsData(Close))

  assert(opcodeIsControl(Close))
  assert(opcodeIsControl(Ping))
  assert(opcodeIsControl(Pong))
  assert(!opcodeIsControl(Text))

  assert(opcodeIsMessageStart(Text))
  assert(opcodeIsMessageStart(Binary))
  assert(!opcodeIsMessageStart(Continuation))

  assert(opcodeRequiresResponse(Ping))
  assert(opcodeRequiresResponse(Close))
  assert(!opcodeRequiresResponse(Text))
}

// ---------------------------------------------------------------------------
// Close code tests
// ---------------------------------------------------------------------------

let testCloseCodeRoundtrip = () => {
  let codes = [1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008, 1009, 1010, 1011]
  Belt.Array.forEach(codes, wire => {
    let code = closeCodeFromWire(wire)
    switch code {
    | Some(c) => assert(closeCodeToWire(c) == wire)
    | None => assert(false)
    }
  })
}

let testCloseCodeUnknownRejected = () => {
  assert(closeCodeFromWire(1004) == None)
  assert(closeCodeFromWire(999) == None)
  assert(closeCodeFromWire(1012) == None)
}

let testCloseCodeClassification = () => {
  assert(closeCodeIsNormal(Normal))
  assert(closeCodeIsNormal(GoingAway))
  assert(!closeCodeIsNormal(ProtocolError))

  assert(closeCodeIsError(ProtocolError))
  assert(closeCodeIsError(InternalError))
  assert(!closeCodeIsError(Normal))
  assert(!closeCodeIsError(NoStatus))

  assert(closeCodeIsSendable(Normal))
  assert(!closeCodeIsSendable(NoStatus))
  assert(!closeCodeIsSendable(Abnormal))
}

let testCloseCodeRanges = () => {
  assert(isApplicationCode(4000))
  assert(isApplicationCode(4999))
  assert(!isApplicationCode(3999))
  assert(!isApplicationCode(5000))

  assert(isPrivateCode(3000))
  assert(isPrivateCode(3999))
  assert(!isPrivateCode(2999))
  assert(!isPrivateCode(4000))
}

// ---------------------------------------------------------------------------
// Frame tests
// ---------------------------------------------------------------------------

let testFrameTextConstruction = () => {
  let frame = makeTextFrame([104, 101, 108, 108, 111])
  assert(frame.fin == true)
  assert(frame.opcode == Text)
  assert(!frame.masked)
  assert(frame.payloadLength == 5)
}

// Frame validation tests removed: validateClientFrame / validateServerFrame were
// unproven reimplementations deleted from ProvenWebsocket. The verified checks
// live in the Idris2/Zig core. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testOpcodeRoundtrip()
  testOpcodeReservedRejected()
  testOpcodeClassification()
  testCloseCodeRoundtrip()
  testCloseCodeUnknownRejected()
  testCloseCodeClassification()
  testCloseCodeRanges()
  testFrameTextConstruction()
  Js.log("ProvenWebsocket: all tests passed")
}
