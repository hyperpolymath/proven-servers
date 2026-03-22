// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  se(0),
  nop(1),
  dataMark(2),
  break_(3),
  interruptProcess(4),
  abortOutput(5),
  areYouThere(6),
  eraseChar(7),
  eraseLine(8),
  goAhead(9),
  sb(10),
  will(11),
  wont(12),
  do_(13),
  dont(14),
  iac(15);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TelnetOption matching the Idris2 ABI tags.
enum TelnetOption {
  echo(0),
  suppressGoAhead(1),
  status(2),
  timingMark(3),
  terminalType(4),
  windowSize(5),
  terminalSpeed(6),
  remoteFlowControl(7),
  linemode(8),
  environment(9);

  const TelnetOption(this.tag);
  final int tag;

  static TelnetOption? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NegotiationState matching the Idris2 ABI tags.
enum NegotiationState {
  inactive(0),
  willSent(1),
  doSent(2),
  negotiationState_Active(3);

  const NegotiationState(this.tag);
  final int tag;

  static NegotiationState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  negotiating(1),
  sessionState_Active(2),
  subneg(3),
  closing(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
