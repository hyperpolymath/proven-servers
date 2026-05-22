// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MCP protocol types for proven-servers.

/// McpMessageType matching the Idris2 ABI tags.
enum McpMessageType {
  initialize(0),
  initialized(1),
  ping(2),
  callTool(3),
  toolResult(4),
  listTools(5),
  listResources(6),
  readResource(7),
  listPrompts(8),
  getPrompt(9),
  subscribe(10),
  unsubscribe(11),
  notification(12),
  cancel(13);

  const McpMessageType(this.tag);
  final int tag;

  static McpMessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Transport matching the Idris2 ABI tags.
enum Transport {
  stdio(0),
  sse(1),
  webSocket(2),
  streamableHttp(3);

  const Transport(this.tag);
  final int tag;

  static Transport? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// McpContentType matching the Idris2 ABI tags.
enum McpContentType {
  text(0),
  image(1),
  resource(2),
  embedding(3);

  const McpContentType(this.tag);
  final int tag;

  static McpContentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// McpErrorCode matching the Idris2 ABI tags.
enum McpErrorCode {
  parseError(0),
  invalidRequest(1),
  methodNotFound(2),
  invalidParams(3),
  internalError(4),
  timeout(5);

  const McpErrorCode(this.tag);
  final int tag;

  static McpErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// McpCapability matching the Idris2 ABI tags.
enum McpCapability {
  tools(0),
  resources(1),
  prompts(2),
  logging(3),
  sampling(4);

  const McpCapability(this.tag);
  final int tag;

  static McpCapability? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  connecting(1),
  ready(2),
  processing(3),
  disconnecting(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
