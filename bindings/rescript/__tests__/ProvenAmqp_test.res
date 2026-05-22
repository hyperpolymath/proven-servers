// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenAmqp protocol bindings.

open ProvenAmqp

let test_frameType_roundtrip = () => {
  assert(frameTypeFromTag(0) == Some(Method))
  assert(frameTypeFromTag(1) == Some(Header))
  assert(frameTypeFromTag(2) == Some(Body))
  assert(frameTypeFromTag(3) == Some(Heartbeat))
  assert(frameTypeFromTag(4) == None)
}

let test_frameType_toTag = () => {
  assert(frameTypeToTag(Method) == 0)
  assert(frameTypeToTag(Header) == 1)
  assert(frameTypeToTag(Body) == 2)
  assert(frameTypeToTag(Heartbeat) == 3)
}

let test_methodClass_roundtrip = () => {
  assert(methodClassFromTag(0) == Some(Connection))
  assert(methodClassFromTag(1) == Some(Channel))
  assert(methodClassFromTag(2) == Some(Exchange))
  assert(methodClassFromTag(3) == Some(Queue))
  assert(methodClassFromTag(4) == Some(Basic))
  assert(methodClassFromTag(5) == Some(Tx))
  assert(methodClassFromTag(6) == Some(Confirm))
  assert(methodClassFromTag(7) == None)
}

let test_methodClass_toTag = () => {
  assert(methodClassToTag(Connection) == 0)
  assert(methodClassToTag(Channel) == 1)
  assert(methodClassToTag(Exchange) == 2)
  assert(methodClassToTag(Queue) == 3)
  assert(methodClassToTag(Basic) == 4)
  assert(methodClassToTag(Tx) == 5)
  assert(methodClassToTag(Confirm) == 6)
}

let test_exchangeType_roundtrip = () => {
  assert(exchangeTypeFromTag(0) == Some(Direct))
  assert(exchangeTypeFromTag(1) == Some(Fanout))
  assert(exchangeTypeFromTag(2) == Some(Topic))
  assert(exchangeTypeFromTag(3) == Some(Headers))
  assert(exchangeTypeFromTag(4) == None)
}

let test_exchangeType_toTag = () => {
  assert(exchangeTypeToTag(Direct) == 0)
  assert(exchangeTypeToTag(Fanout) == 1)
  assert(exchangeTypeToTag(Topic) == 2)
  assert(exchangeTypeToTag(Headers) == 3)
}

let test_deliveryMode_roundtrip = () => {
  assert(deliveryModeFromTag(0) == Some(NonPersistent))
  assert(deliveryModeFromTag(1) == Some(Persistent))
  assert(deliveryModeFromTag(2) == None)
}

let test_deliveryMode_toTag = () => {
  assert(deliveryModeToTag(NonPersistent) == 0)
  assert(deliveryModeToTag(Persistent) == 1)
}

let test_errorSeverity_roundtrip = () => {
  assert(errorSeverityFromTag(0) == Some(ChannelLevel))
  assert(errorSeverityFromTag(1) == Some(ConnectionLevel))
  assert(errorSeverityFromTag(2) == None)
}

let test_errorSeverity_toTag = () => {
  assert(errorSeverityToTag(ChannelLevel) == 0)
  assert(errorSeverityToTag(ConnectionLevel) == 1)
}

let test_connectionState_roundtrip = () => {
  assert(connectionStateFromTag(0) == Some(Idle))
  assert(connectionStateFromTag(1) == Some(Negotiating))
  assert(connectionStateFromTag(2) == Some(TuningOk))
  assert(connectionStateFromTag(3) == Some(Open))
  assert(connectionStateFromTag(4) == Some(Closing))
  assert(connectionStateFromTag(5) == None)
}

let test_connectionState_toTag = () => {
  assert(connectionStateToTag(Idle) == 0)
  assert(connectionStateToTag(Negotiating) == 1)
  assert(connectionStateToTag(TuningOk) == 2)
  assert(connectionStateToTag(Open) == 3)
  assert(connectionStateToTag(Closing) == 4)
}

let test_channelState_roundtrip = () => {
  assert(channelStateFromTag(0) == Some(Closed))
  assert(channelStateFromTag(1) == Some(Opening))
  assert(channelStateFromTag(2) == Some(ChOpen))
  assert(channelStateFromTag(3) == Some(ChClosing))
  assert(channelStateFromTag(4) == None)
}

let test_channelState_toTag = () => {
  assert(channelStateToTag(Closed) == 0)
  assert(channelStateToTag(Opening) == 1)
  assert(channelStateToTag(ChOpen) == 2)
  assert(channelStateToTag(ChClosing) == 3)
}

let test_brokerState_roundtrip = () => {
  assert(brokerStateFromTag(0) == Some(Idle))
  assert(brokerStateFromTag(1) == Some(Connected))
  assert(brokerStateFromTag(2) == Some(ChannelOpen))
  assert(brokerStateFromTag(3) == Some(Consuming))
  assert(brokerStateFromTag(4) == Some(Publishing))
  assert(brokerStateFromTag(5) == Some(Disconnecting))
  assert(brokerStateFromTag(6) == None)
}

let test_brokerState_toTag = () => {
  assert(brokerStateToTag(Idle) == 0)
  assert(brokerStateToTag(Connected) == 1)
  assert(brokerStateToTag(ChannelOpen) == 2)
  assert(brokerStateToTag(Consuming) == 3)
  assert(brokerStateToTag(Publishing) == 4)
  assert(brokerStateToTag(Disconnecting) == 5)
}

// Run all tests
test_frameType_roundtrip()
test_frameType_toTag()
test_methodClass_roundtrip()
test_methodClass_toTag()
test_exchangeType_roundtrip()
test_exchangeType_toTag()
test_deliveryMode_roundtrip()
test_deliveryMode_toTag()
test_errorSeverity_roundtrip()
test_errorSeverity_toTag()
test_connectionState_roundtrip()
test_connectionState_toTag()
test_channelState_roundtrip()
test_channelState_toTag()
test_brokerState_roundtrip()
test_brokerState_toTag()
