// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  bindingRequest(0),
  bindingResponse(1),
  bindingError(2),
  allocateRequest(3),
  allocateResponse(4),
  allocateError(5),
  refreshRequest(6),
  refreshResponse(7),
  sendIndication(8),
  dataIndication(9),
  createPermission(10),
  channelBind(11);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransportProtocol matching the Idris2 ABI tags.
enum TransportProtocol {
  udp(0),
  tcp(1),
  tls(2),
  dtls(3);

  const TransportProtocol(this.tag);
  final int tag;

  static TransportProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  tryAlternate(0),
  badRequest(1),
  unauthorized(2),
  forbidden(3),
  mobilityForbidden(4),
  staleNonce(5),
  serverError(6),
  insufficientCapacity(7);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
