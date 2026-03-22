// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
enum Method {
  describe(0),
  setup(1),
  play(2),
  pause(3),
  teardown(4),
  getParameter(5),
  setParameter(6),
  options(7),
  announce(8),
  record(9),
  redirect(10);

  const Method(this.tag);
  final int tag;

  static Method? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransportProtocol matching the Idris2 ABI tags.
enum TransportProtocol {
  rtpAvpUdp(0),
  rtpAvpTcp(1),
  rtpAvpUdpMulticast(2);

  const TransportProtocol(this.tag);
  final int tag;

  static TransportProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  init(0),
  ready(1),
  playing(2),
  recording(3);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StatusCode matching the Idris2 ABI tags.
enum StatusCode {
  statusCode_Ok(0),
  movedPermanently(1),
  movedTemporarily(2),
  badRequest(3),
  unauthorized(4),
  notFound(5),
  statusCode_MethodNotAllowed(6),
  notAcceptable(7),
  sessionNotFound(8),
  internalServerError(9),
  notImplemented(10),
  serviceUnavailable(11);

  const StatusCode(this.tag);
  final int tag;

  static StatusCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RtspError matching the Idris2 ABI tags.
enum RtspError {
  rtspError_Ok(0),
  invalidSlot(1),
  notActive(2),
  invalidTransition(3),
  rtspError_MethodNotAllowed(4),
  transportError(5),
  sessionExpired(6);

  const RtspError(this.tag);
  final int tag;

  static RtspError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
