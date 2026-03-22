// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

/// DecoyType matching the Idris2 ABI tags.
enum DecoyType {
  service(0),
  credential(1),
  file(2),
  network(3),
  token(4),
  breadcrumb(5);

  const DecoyType(this.tag);
  final int tag;

  static DecoyType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TriggerEvent matching the Idris2 ABI tags.
enum TriggerEvent {
  access(0),
  login(1),
  read(2),
  write(3),
  execute(4),
  scan(5);

  const TriggerEvent(this.tag);
  final int tag;

  static TriggerEvent? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AlertPriority matching the Idris2 ABI tags.
enum AlertPriority {
  low(0),
  medium(1),
  high(2),
  critical(3);

  const AlertPriority(this.tag);
  final int tag;

  static AlertPriority? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DecoyState matching the Idris2 ABI tags.
enum DecoyState {
  active(0),
  triggered(1),
  disabled(2),
  expired(3);

  const DecoyState(this.tag);
  final int tag;

  static DecoyState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponseAction matching the Idris2 ABI tags.
enum ResponseAction {
  alert(0),
  redirect(1),
  delay(2),
  fingerprint(3),
  isolate(4);

  const ResponseAction(this.tag);
  final int tag;

  static ResponseAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  configured(1),
  monitoring(2),
  responding(3),
  shutdown(4);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
