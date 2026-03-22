// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Syslog protocol types for proven-servers.

/// Severity matching the Idris2 ABI tags.
enum Severity {
  emergency(0),
  severity_Alert(1),
  critical(2),
  error(3),
  warning(4),
  notice(5),
  informational(6),
  debug(7);

  const Severity(this.tag);
  final int tag;

  static Severity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Facility matching the Idris2 ABI tags.
enum Facility {
  kern(0),
  user(1),
  mail(2),
  daemon(3),
  auth(4),
  syslog(5),
  lpr(6),
  news(7),
  uucp(8),
  cron(9),
  authPriv(10),
  ftp(11),
  ntp(12),
  audit(13),
  facility_Alert(14),
  clock(15),
  local0(16),
  local1(17),
  local2(18),
  local3(19),
  local4(20),
  local5(21),
  local6(22),
  local7(23);

  const Facility(this.tag);
  final int tag;

  static Facility? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Transport matching the Idris2 ABI tags.
enum Transport {
  udp514(0),
  tcp514(1),
  tls6514(2);

  const Transport(this.tag);
  final int tag;

  static Transport? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
