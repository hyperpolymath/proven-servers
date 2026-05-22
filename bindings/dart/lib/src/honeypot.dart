// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

/// ServiceEmulation matching the Idris2 ABI tags.
enum ServiceEmulation {
  ssh(0),
  http(1),
  ftp(2),
  smtp(3),
  telnet(4),
  mysql(5),
  rdp(6);

  const ServiceEmulation(this.tag);
  final int tag;

  static ServiceEmulation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// InteractionLevel matching the Idris2 ABI tags.
enum InteractionLevel {
  low(0),
  medium(1),
  high(2);

  const InteractionLevel(this.tag);
  final int tag;

  static InteractionLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HoneypotAlertSeverity matching the Idris2 ABI tags.
enum HoneypotAlertSeverity {
  info(0),
  asLow(1),
  asMedium(2),
  asHigh(3),
  critical(4);

  const HoneypotAlertSeverity(this.tag);
  final int tag;

  static HoneypotAlertSeverity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AttackerAction matching the Idris2 ABI tags.
enum AttackerAction {
  scan(0),
  bruteForce(1),
  exploit(2),
  payload(3),
  lateral(4),
  exfiltration(5);

  const AttackerAction(this.tag);
  final int tag;

  static AttackerAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  deployed(1),
  engaged(2),
  shutdown(3);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
