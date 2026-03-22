// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

/// SdnMessageType matching the Idris2 ABI tags.
enum SdnMessageType {
  hello(0),
  error(1),
  echoRequest(2),
  echoReply(3),
  featuresRequest(4),
  featuresReply(5),
  flowMod(6),
  packetIn(7),
  packetOut(8),
  portStatus(9),
  barrierRequest(10),
  barrierReply(11);

  const SdnMessageType(this.tag);
  final int tag;

  static SdnMessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// FlowAction matching the Idris2 ABI tags.
enum FlowAction {
  output(0),
  setField(1),
  drop(2),
  pushVlan(3),
  popVlan(4),
  setQueue(5),
  group(6);

  const FlowAction(this.tag);
  final int tag;

  static FlowAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MatchField matching the Idris2 ABI tags.
enum MatchField {
  inPort(0),
  ethDst(1),
  ethSrc(2),
  ethType(3),
  vlanId(4),
  ipSrc(5),
  ipDst(6),
  tcpSrc(7),
  tcpDst(8),
  udpSrc(9),
  udpDst(10);

  const MatchField(this.tag);
  final int tag;

  static MatchField? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PortState matching the Idris2 ABI tags.
enum PortState {
  up(0),
  down(1),
  blocked(2);

  const PortState(this.tag);
  final int tag;

  static PortState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
