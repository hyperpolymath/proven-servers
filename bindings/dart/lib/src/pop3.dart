// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  user(0),
  pass(1),
  stat(2),
  list(3),
  retr(4),
  dele(5),
  noop(6),
  rset(7),
  quit(8),
  top(9),
  uidl(10);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// State matching the Idris2 ABI tags.
enum State {
  authorization(0),
  transaction(1),
  update(2);

  const State(this.tag);
  final int tag;

  static State? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Response matching the Idris2 ABI tags.
enum Response {
  response_Ok(0),
  err(1);

  const Response(this.tag);
  final int tag;

  static Response? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Pop3Error matching the Idris2 ABI tags.
enum Pop3Error {
  pop3Error_Ok(0),
  invalidSlot(1),
  notActive(2),
  invalidTransition(3),
  invalidCommand(4),
  authFailed(5);

  const Pop3Error(this.tag);
  final int tag;

  static Pop3Error? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
