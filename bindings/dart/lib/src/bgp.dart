// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for proven-servers.

/// BgpState matching the Idris2 ABI tags.
enum BgpState {
  idle(0),
  connect(1),
  active(2),
  openSent(3),
  openConfirm(4),
  established(5);

  const BgpState(this.tag);
  final int tag;

  static BgpState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BgpEvent matching the Idris2 ABI tags.
enum BgpEvent {
  manualStart(0),
  manualStop(1),
  automaticStart(2),
  connectRetryTimerExpires(3),
  holdTimerExpires(4),
  keepaliveTimerExpires(5),
  delayOpenTimerExpires(6),
  tcpConnectionValid(7),
  tcpCrAcked(8),
  tcpConnectionConfirmed(9),
  tcpConnectionFails(10),
  bgpOpenReceived(11),
  bgpHeaderErr(12),
  bgpOpenMsgErr(13),
  notifMsgVerErr(14),
  notifMsg(15),
  keepaliveMsg(16),
  updateMsg(17),
  updateMsgErr(18);

  const BgpEvent(this.tag);
  final int tag;

  static BgpEvent? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  open(0),
  update(1),
  notification(2),
  keepalive(3);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  messageHeaderError(0),
  openMessageError(1),
  updateMessageError(2),
  holdTimerExpired(3),
  fsmError(4),
  cease(5);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Origin matching the Idris2 ABI tags.
enum Origin {
  igp(0),
  egp(1),
  incomplete(2);

  const Origin(this.tag);
  final int tag;

  static Origin? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AsPathSegmentType matching the Idris2 ABI tags.
enum AsPathSegmentType {
  asSet(0),
  asSequence(1);

  const AsPathSegmentType(this.tag);
  final int tag;

  static AsPathSegmentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PathAttrType matching the Idris2 ABI tags.
enum PathAttrType {
  origin(0),
  asPath(1),
  nextHop(2),
  med(3),
  localPref(4),
  atomicAggr(5),
  aggregator(6),
  unknown(7);

  const PathAttrType(this.tag);
  final int tag;

  static PathAttrType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
