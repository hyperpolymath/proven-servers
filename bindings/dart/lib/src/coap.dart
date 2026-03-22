// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
enum Method {
  get_(0),
  post(1),
  put(2),
  delete(3);

  const Method(this.tag);
  final int tag;

  static Method? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  confirmable(0),
  nonConfirmable(1),
  acknowledgement(2),
  reset(3);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ContentFormat matching the Idris2 ABI tags.
enum ContentFormat {
  textPlain(0),
  linkFormat(1),
  xml(2),
  octetStream(3),
  exi(4),
  json(5),
  cbor(6);

  const ContentFormat(this.tag);
  final int tag;

  static ContentFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponseClass matching the Idris2 ABI tags.
enum ResponseClass {
  success(0),
  clientError(1),
  serverError(2),
  signaling(3),
  empty(4);

  const ResponseClass(this.tag);
  final int tag;

  static ResponseClass? fromTag(int tag) {
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
  observing(3),
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
