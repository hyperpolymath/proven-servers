// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

/// LeapIndicator matching the Idris2 ABI tags.
enum LeapIndicator {
  noWarning(0),
  lastMinute61(1),
  lastMinute59(2),
  unsynchronised(3);

  const LeapIndicator(this.tag);
  final int tag;

  static LeapIndicator? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NtpMode matching the Idris2 ABI tags.
enum NtpMode {
  reserved(0),
  symmetricActive(1),
  symmetricPassive(2),
  client(3),
  server(4),
  broadcast(5),
  controlMessage(6),
  private(7);

  const NtpMode(this.tag);
  final int tag;

  static NtpMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ExchangeState matching the Idris2 ABI tags.
enum ExchangeState {
  idle(0),
  requestReceived(1),
  timestampCalculated(2),
  responseSent(3);

  const ExchangeState(this.tag);
  final int tag;

  static ExchangeState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ClockDisciplineState matching the Idris2 ABI tags.
enum ClockDisciplineState {
  unset(0),
  spike(1),
  freq(2),
  sync_(3),
  panic(4);

  const ClockDisciplineState(this.tag);
  final int tag;

  static ClockDisciplineState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KissCode matching the Idris2 ABI tags.
enum KissCode {
  deny(0),
  rstr(1),
  rate(2),
  other(3);

  const KissCode(this.tag);
  final int tag;

  static KissCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NtpError matching the Idris2 ABI tags.
enum NtpError {
  ok(0),
  invalidSlot(1),
  notActive(2),
  invalidPacket(3),
  kissOfDeath(4),
  stratumTooHigh(5);

  const NtpError(this.tag);
  final int tag;

  static NtpError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
