// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

/// ServiceType matching the Idris2 ABI tags.
enum ServiceType {
  read(0),
  write(1),
  browse(2),
  subscribe(3),
  publish(4),
  call(5),
  createSession(6),
  activateSession(7),
  closeSession(8),
  createSubscription(9),
  deleteSubscription(10);

  const ServiceType(this.tag);
  final int tag;

  static ServiceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NodeClass matching the Idris2 ABI tags.
enum NodeClass {
  object(0),
  variable(1),
  method(2),
  objectType(3),
  variableType(4),
  referenceType(5),
  dataType(6),
  view(7);

  const NodeClass(this.tag);
  final int tag;

  static NodeClass? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StatusCode matching the Idris2 ABI tags.
enum StatusCode {
  good(0),
  uncertain(1),
  bad(2),
  badNodeIdUnknown(3),
  badAttributeIdInvalid(4),
  badNotReadable(5),
  badNotWritable(6),
  badOutOfRange(7),
  badTypeMismatch(8),
  badSessionIdInvalid(9),
  badSubscriptionIdInvalid(10),
  badTimeout(11);

  const StatusCode(this.tag);
  final int tag;

  static StatusCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SecurityMode matching the Idris2 ABI tags.
enum SecurityMode {
  none(0),
  sign(1),
  signAndEncrypt(2);

  const SecurityMode(this.tag);
  final int tag;

  static SecurityMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  connected(1),
  created(2),
  activated(3),
  monitoring(4),
  closing(5);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
