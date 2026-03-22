// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  login(0),
  command_Logout(1),
  select(2),
  examine(3),
  create(4),
  delete(5),
  rename(6),
  list(7),
  fetch(8),
  store(9),
  search(10),
  copy(11),
  noop(12),
  capability(13);

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
  notAuthenticated(0),
  authenticated(1),
  selected(2),
  state_Logout(3);

  const State(this.tag);
  final int tag;

  static State? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Flag matching the Idris2 ABI tags.
enum Flag {
  seen(0),
  answered(1),
  flagged(2),
  deleted(3),
  draft(4),
  recent(5);

  const Flag(this.tag);
  final int tag;

  static Flag? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
