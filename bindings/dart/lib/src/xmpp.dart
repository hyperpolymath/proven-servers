// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

/// StanzaType matching the Idris2 ABI tags.
enum StanzaType {
  message(0),
  presence(1),
  iq(2);

  const StanzaType(this.tag);
  final int tag;

  static StanzaType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  chat(0),
  messageType_Error(1),
  groupchat(2),
  headline(3),
  normal(4);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PresenceType matching the Idris2 ABI tags.
enum PresenceType {
  available(0),
  away(1),
  dnd(2),
  xa(3),
  unavailable(4);

  const PresenceType(this.tag);
  final int tag;

  static PresenceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IqType matching the Idris2 ABI tags.
enum IqType {
  get_(0),
  set_(1),
  result(2),
  iqType_Error(3);

  const IqType(this.tag);
  final int tag;

  static IqType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StreamError matching the Idris2 ABI tags.
enum StreamError {
  badFormat(0),
  conflict(1),
  connectionTimeout(2),
  hostGone(3),
  hostUnknown(4),
  notAuthorized(5),
  policyViolation(6),
  resourceConstraint(7),
  systemShutdown(8);

  const StreamError(this.tag);
  final int tag;

  static StreamError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
