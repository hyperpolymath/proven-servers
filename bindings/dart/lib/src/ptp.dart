// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP protocol types for proven-servers.

/// PtpMessageType matching the Idris2 ABI tags.
enum PtpMessageType {
  sync_(0),
  delayReq(1),
  pdelayReq(2),
  pdelayResp(3),
  followUp(4),
  delayResp(5),
  pdelayRespFollowUp(6),
  announce(7),
  signaling(8),
  management(9);

  const PtpMessageType(this.tag);
  final int tag;

  static PtpMessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ClockClass matching the Idris2 ABI tags.
enum ClockClass {
  primaryClock(0),
  applicationSpecific(1),
  slaveOnly(2),
  defaultClass(3);

  const ClockClass(this.tag);
  final int tag;

  static ClockClass? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PtpPortState matching the Idris2 ABI tags.
enum PtpPortState {
  initializing(0),
  faulty(1),
  disabled(2),
  listening(3),
  preMaster(4),
  master(5),
  passive(6),
  uncalibrated(7),
  slave(8);

  const PtpPortState(this.tag);
  final int tag;

  static PtpPortState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DelayMechanism matching the Idris2 ABI tags.
enum DelayMechanism {
  e2e(0),
  p2p(1),
  dmDisabled(2);

  const DelayMechanism(this.tag);
  final int tag;

  static DelayMechanism? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
