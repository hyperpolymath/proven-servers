// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  text(0),
  image(1),
  file(2),
  system(3),
  reaction(4),
  edit(5),
  delete(6),
  reply(7),
  thread(8);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PresenceStatus matching the Idris2 ABI tags.
enum PresenceStatus {
  online(0),
  away(1),
  dnd(2),
  invisible(3),
  offline(4);

  const PresenceStatus(this.tag);
  final int tag;

  static PresenceStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RoomType matching the Idris2 ABI tags.
enum RoomType {
  direct(0),
  group(1),
  channel(2),
  broadcast(3);

  const RoomType(this.tag);
  final int tag;

  static RoomType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Permission matching the Idris2 ABI tags.
enum Permission {
  read(0),
  write(1),
  admin(2),
  invite(3),
  kick(4),
  ban(5),
  pin(6),
  deleteOthers(7);

  const Permission(this.tag);
  final int tag;

  static Permission? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Event matching the Idris2 ABI tags.
enum Event {
  messageSent(0),
  messageDelivered(1),
  messageRead(2),
  userJoined(3),
  userLeft(4),
  typing(5),
  roomCreated(6);

  const Event(this.tag);
  final int tag;

  static Event? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
