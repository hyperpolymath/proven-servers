// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
enum Method {
  invite(0),
  ack(1),
  bye(2),
  cancel(3),
  register(4),
  options(5),
  info(6),
  update(7),
  subscribe(8),
  notify(9),
  refer(10),
  message(11),
  prack(12);

  const Method(this.tag);
  final int tag;

  static Method? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponseCode matching the Idris2 ABI tags.
enum ResponseCode {
  trying(0),
  ringing(1),
  sessionProgress(2),
  ok(3),
  multipleChoices(4),
  movedPermanently(5),
  movedTemporarily(6),
  badRequest(7),
  unauthorized(8),
  forbidden(9),
  notFound(10),
  methodNotAllowed(11),
  requestTimeout(12),
  busyHere(13),
  decline(14),
  serverInternalError(15),
  serviceUnavailable(16);

  const ResponseCode(this.tag);
  final int tag;

  static ResponseCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DialogState matching the Idris2 ABI tags.
enum DialogState {
  early(0),
  confirmed(1),
  terminated(2);

  const DialogState(this.tag);
  final int tag;

  static DialogState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
