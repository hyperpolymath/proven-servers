// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMcp protocol bindings.

open ProvenMcp

let test_mcpMessageType_roundtrip = () => {
  assert(mcpMessageTypeFromTag(0) == Some(Initialize))
  assert(mcpMessageTypeFromTag(1) == Some(Initialized))
  assert(mcpMessageTypeFromTag(2) == Some(Ping))
  assert(mcpMessageTypeFromTag(3) == Some(CallTool))
  assert(mcpMessageTypeFromTag(4) == Some(ToolResult))
  assert(mcpMessageTypeFromTag(5) == Some(ListTools))
  assert(mcpMessageTypeFromTag(6) == Some(ListResources))
  assert(mcpMessageTypeFromTag(7) == Some(ReadResource))
  assert(mcpMessageTypeFromTag(8) == Some(ListPrompts))
  assert(mcpMessageTypeFromTag(9) == Some(GetPrompt))
  assert(mcpMessageTypeFromTag(10) == Some(Subscribe))
  assert(mcpMessageTypeFromTag(11) == Some(Unsubscribe))
  assert(mcpMessageTypeFromTag(12) == Some(Notification))
  assert(mcpMessageTypeFromTag(13) == Some(Cancel))
  assert(mcpMessageTypeFromTag(14) == None)
}

let test_mcpMessageType_toTag = () => {
  assert(mcpMessageTypeToTag(Initialize) == 0)
  assert(mcpMessageTypeToTag(Initialized) == 1)
  assert(mcpMessageTypeToTag(Ping) == 2)
  assert(mcpMessageTypeToTag(CallTool) == 3)
  assert(mcpMessageTypeToTag(ToolResult) == 4)
  assert(mcpMessageTypeToTag(ListTools) == 5)
  assert(mcpMessageTypeToTag(ListResources) == 6)
  assert(mcpMessageTypeToTag(ReadResource) == 7)
  assert(mcpMessageTypeToTag(ListPrompts) == 8)
  assert(mcpMessageTypeToTag(GetPrompt) == 9)
  assert(mcpMessageTypeToTag(Subscribe) == 10)
  assert(mcpMessageTypeToTag(Unsubscribe) == 11)
  assert(mcpMessageTypeToTag(Notification) == 12)
  assert(mcpMessageTypeToTag(Cancel) == 13)
}

let test_transport_roundtrip = () => {
  assert(transportFromTag(0) == Some(Stdio))
  assert(transportFromTag(1) == Some(Sse))
  assert(transportFromTag(2) == Some(WebSocket))
  assert(transportFromTag(3) == Some(StreamableHttp))
  assert(transportFromTag(4) == None)
}

let test_transport_toTag = () => {
  assert(transportToTag(Stdio) == 0)
  assert(transportToTag(Sse) == 1)
  assert(transportToTag(WebSocket) == 2)
  assert(transportToTag(StreamableHttp) == 3)
}

let test_mcpContentType_roundtrip = () => {
  assert(mcpContentTypeFromTag(0) == Some(Text))
  assert(mcpContentTypeFromTag(1) == Some(Image))
  assert(mcpContentTypeFromTag(2) == Some(Resource))
  assert(mcpContentTypeFromTag(3) == Some(Embedding))
  assert(mcpContentTypeFromTag(4) == None)
}

let test_mcpContentType_toTag = () => {
  assert(mcpContentTypeToTag(Text) == 0)
  assert(mcpContentTypeToTag(Image) == 1)
  assert(mcpContentTypeToTag(Resource) == 2)
  assert(mcpContentTypeToTag(Embedding) == 3)
}

let test_mcpErrorCode_roundtrip = () => {
  assert(mcpErrorCodeFromTag(0) == Some(ParseError))
  assert(mcpErrorCodeFromTag(1) == Some(InvalidRequest))
  assert(mcpErrorCodeFromTag(2) == Some(MethodNotFound))
  assert(mcpErrorCodeFromTag(3) == Some(InvalidParams))
  assert(mcpErrorCodeFromTag(4) == Some(InternalError))
  assert(mcpErrorCodeFromTag(5) == Some(Timeout))
  assert(mcpErrorCodeFromTag(6) == None)
}

let test_mcpErrorCode_toTag = () => {
  assert(mcpErrorCodeToTag(ParseError) == 0)
  assert(mcpErrorCodeToTag(InvalidRequest) == 1)
  assert(mcpErrorCodeToTag(MethodNotFound) == 2)
  assert(mcpErrorCodeToTag(InvalidParams) == 3)
  assert(mcpErrorCodeToTag(InternalError) == 4)
  assert(mcpErrorCodeToTag(Timeout) == 5)
}

let test_mcpCapability_roundtrip = () => {
  assert(mcpCapabilityFromTag(0) == Some(Tools))
  assert(mcpCapabilityFromTag(1) == Some(Resources))
  assert(mcpCapabilityFromTag(2) == Some(Prompts))
  assert(mcpCapabilityFromTag(3) == Some(Logging))
  assert(mcpCapabilityFromTag(4) == Some(Sampling))
  assert(mcpCapabilityFromTag(5) == None)
}

let test_mcpCapability_toTag = () => {
  assert(mcpCapabilityToTag(Tools) == 0)
  assert(mcpCapabilityToTag(Resources) == 1)
  assert(mcpCapabilityToTag(Prompts) == 2)
  assert(mcpCapabilityToTag(Logging) == 3)
  assert(mcpCapabilityToTag(Sampling) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Connecting))
  assert(sessionStateFromTag(2) == Some(Ready))
  assert(sessionStateFromTag(3) == Some(Processing))
  assert(sessionStateFromTag(4) == Some(Disconnecting))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Connecting) == 1)
  assert(sessionStateToTag(Ready) == 2)
  assert(sessionStateToTag(Processing) == 3)
  assert(sessionStateToTag(Disconnecting) == 4)
}

// Run all tests
test_mcpMessageType_roundtrip()
test_mcpMessageType_toTag()
test_transport_roundtrip()
test_transport_toTag()
test_mcpContentType_roundtrip()
test_mcpContentType_toTag()
test_mcpErrorCode_roundtrip()
test_mcpErrorCode_toTag()
test_mcpCapability_roundtrip()
test_mcpCapability_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
