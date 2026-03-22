// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

/// Role matching the Idris2 ABI tags.
enum Role {
  client(0),
  proxy(1),
  target(2);

  const Role(this.tag);
  final int tag;

  static Role? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OdnsMessageType matching the Idris2 ABI tags.
enum OdnsMessageType {
  query(0),
  response(1);

  const OdnsMessageType(this.tag);
  final int tag;

  static OdnsMessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OdnsErrorReason matching the Idris2 ABI tags.
enum OdnsErrorReason {
  proxyError(0),
  targetError(1),
  decryptionFailed(2),
  invalidConfig(3),
  payloadTooLarge(4);

  const OdnsErrorReason(this.tag);
  final int tag;

  static OdnsErrorReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EncapsulationFormat matching the Idris2 ABI tags.
enum EncapsulationFormat {
  hpke(0);

  const EncapsulationFormat(this.tag);
  final int tag;

  static EncapsulationFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  keyExchange(1),
  ready(2),
  processing(3),
  closing(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
