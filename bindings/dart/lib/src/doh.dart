// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

/// ContentType matching the Idris2 ABI tags.
enum ContentType {
  dnsMessage(0),
  dnsJson(1);

  const ContentType(this.tag);
  final int tag;

  static ContentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RequestMethod matching the Idris2 ABI tags.
enum RequestMethod {
  get_(0),
  post(1);

  const RequestMethod(this.tag);
  final int tag;

  static RequestMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// WireFormat matching the Idris2 ABI tags.
enum WireFormat {
  binary(0),
  json(1);

  const WireFormat(this.tag);
  final int tag;

  static WireFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorReason matching the Idris2 ABI tags.
enum ErrorReason {
  badContentType(0),
  badMethod(1),
  payloadTooLarge(2),
  upstreamTimeout(3),
  upstreamError(4);

  const ErrorReason(this.tag);
  final int tag;

  static ErrorReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  bound(1),
  serving(2),
  resolving(3),
  shutdown(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
