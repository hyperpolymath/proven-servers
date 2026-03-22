// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  nick(0),
  user(1),
  join(2),
  part_(3),
  privmsg(4),
  notice(5),
  quit(6),
  ping(7),
  pong(8),
  mode(9),
  kick(10),
  topic(11),
  invite(12),
  names(13),
  list(14),
  who(15),
  whois(16);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NumericReply matching the Idris2 ABI tags.
enum NumericReply {
  welcome(0),
  yourHost(1),
  created(2),
  myInfo(3),
  bounce(4),
  numericReply_NickInUse(5),
  noSuchNick(6),
  noSuchChannel(7),
  channelIsFull(8),
  inviteOnlyChan(9),
  bannedFromChan(10);

  const NumericReply(this.tag);
  final int tag;

  static NumericReply? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ChannelMode matching the Idris2 ABI tags.
enum ChannelMode {
  op(0),
  voice(1),
  ban(2),
  limit(3),
  channelMode_InviteOnly(4),
  moderated(5),
  noExternalMsgs(6),
  topicLock(7),
  secret(8),
  private(9);

  const ChannelMode(this.tag);
  final int tag;

  static ChannelMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// State matching the Idris2 ABI tags.
enum State {
  disconnected(0),
  connecting(1),
  registered(2),
  inChannel(3),
  quitting(4);

  const State(this.tag);
  final int tag;

  static State? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IrcError matching the Idris2 ABI tags.
enum IrcError {
  none(0),
  ircError_NickInUse(1),
  channelFull(2),
  ircError_InviteOnly(3),
  banned(4),
  notRegistered(5);

  const IrcError(this.tag);
  final int tag;

  static IrcError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
