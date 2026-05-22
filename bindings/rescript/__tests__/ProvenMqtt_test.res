// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMqtt module: QoS levels, SUBACK codes, packet types,
// and packet directions.

open ProvenMqtt

// ---------------------------------------------------------------------------
// QoS tests
// ---------------------------------------------------------------------------

let testQosRoundtrip = () =>
  for code in 0 to 2 {
    let q = qosFromCode(code)
    switch q {
    | Some(qos) => assert(qosToCode(qos) == code)
    | None => assert(false)
    }
  }

let testQosReservedRejected = () => assert(qosFromCode(3) == None)

let testQosAckRequirements = () => {
  assert(!qosRequiresAck(AtMostOnce))
  assert(qosRequiresAck(AtLeastOnce))
  assert(qosRequiresAck(ExactlyOnce))

  assert(qosAckPacketCount(AtMostOnce) == 0)
  assert(qosAckPacketCount(AtLeastOnce) == 1)
  assert(qosAckPacketCount(ExactlyOnce) == 3)
}

let testQosNegotiation = () => {
  assert(qosEffective(ExactlyOnce, AtLeastOnce) == AtLeastOnce)
  assert(qosEffective(AtMostOnce, ExactlyOnce) == AtMostOnce)
  assert(qosDelivery(ExactlyOnce, AtMostOnce) == AtMostOnce)
}

// ---------------------------------------------------------------------------
// SUBACK code tests
// ---------------------------------------------------------------------------

let testSubAckCodeRoundtrip = () => {
  let codes = [(0x00, GrantedQoS0), (0x01, GrantedQoS1), (0x02, GrantedQoS2), (0x80, Failure)]
  Belt.Array.forEach(codes, ((byte, expected)) => {
    let decoded = subAckCodeFromByte(byte)
    assert(decoded == Some(expected))
    switch decoded {
    | Some(c) => assert(subAckCodeToByte(c) == byte)
    | None => assert(false)
    }
  })
}

let testSubAckToQos = () => {
  assert(subAckCodeToQos(GrantedQoS0) == Some(AtMostOnce))
  assert(subAckCodeToQos(GrantedQoS1) == Some(AtLeastOnce))
  assert(subAckCodeToQos(GrantedQoS2) == Some(ExactlyOnce))
  assert(subAckCodeToQos(Failure) == None)
}

// ---------------------------------------------------------------------------
// Packet type tests
// ---------------------------------------------------------------------------

let testPacketTypeRoundtrip = () =>
  for code in 1 to 15 {
    let pt = packetTypeFromCode(code)
    switch pt {
    | Some(p) => assert(packetTypeToCode(p) == code)
    | None => assert(false)
    }
  }

let testPacketTypeReservedRejected = () => {
  assert(packetTypeFromCode(0) == None)
  assert(packetTypeFromCode(16) == None)
}

let testPacketTypeDirection = () => {
  assert(packetTypeDirection(Connect) == ClientToServer)
  assert(packetTypeDirection(Connack) == ServerToClient)
  assert(packetTypeDirection(Publish) == Bidirectional)
  assert(packetTypeDirection(Subscribe) == ClientToServer)
  assert(packetTypeDirection(Suback) == ServerToClient)
}

let testPacketTypePacketId = () => {
  assert(packetTypeRequiresPacketId(Puback))
  assert(packetTypeRequiresPacketId(Subscribe))
  assert(!packetTypeRequiresPacketId(Connect))
  assert(!packetTypeRequiresPacketId(Publish))
  assert(!packetTypeRequiresPacketId(Auth))
  assert(!packetTypeRequiresPacketId(Disconnect))
}

// ---------------------------------------------------------------------------
// Run all tests
// ---------------------------------------------------------------------------

let () = {
  testQosRoundtrip()
  testQosReservedRejected()
  testQosAckRequirements()
  testQosNegotiation()
  testSubAckCodeRoundtrip()
  testSubAckToQos()
  testPacketTypeRoundtrip()
  testPacketTypeReservedRejected()
  testPacketTypeDirection()
  testPacketTypePacketId()
  Js.log("ProvenMqtt: all tests passed")
}
