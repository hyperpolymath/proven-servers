// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSyslog protocol bindings.

open ProvenSyslog

let test_severity_roundtrip = () => {
  assert(severityFromTag(0) == Some(Emergency))
  assert(severityFromTag(1) == Some(Alert))
  assert(severityFromTag(2) == Some(Critical))
  assert(severityFromTag(3) == Some(Error))
  assert(severityFromTag(4) == Some(Warning))
  assert(severityFromTag(5) == Some(Notice))
  assert(severityFromTag(6) == Some(Informational))
  assert(severityFromTag(7) == Some(Debug))
  assert(severityFromTag(8) == None)
}

let test_severity_toTag = () => {
  assert(severityToTag(Emergency) == 0)
  assert(severityToTag(Alert) == 1)
  assert(severityToTag(Critical) == 2)
  assert(severityToTag(Error) == 3)
  assert(severityToTag(Warning) == 4)
  assert(severityToTag(Notice) == 5)
  assert(severityToTag(Informational) == 6)
  assert(severityToTag(Debug) == 7)
}

let test_facility_roundtrip = () => {
  assert(facilityFromTag(0) == Some(Kern))
  assert(facilityFromTag(1) == Some(User))
  assert(facilityFromTag(2) == Some(Mail))
  assert(facilityFromTag(3) == Some(Daemon))
  assert(facilityFromTag(4) == Some(Auth))
  assert(facilityFromTag(5) == Some(Syslog))
  assert(facilityFromTag(6) == Some(Lpr))
  assert(facilityFromTag(7) == Some(News))
  assert(facilityFromTag(8) == Some(Uucp))
  assert(facilityFromTag(9) == Some(Cron))
  assert(facilityFromTag(10) == Some(AuthPriv))
  assert(facilityFromTag(11) == Some(Ftp))
  assert(facilityFromTag(12) == Some(Ntp))
  assert(facilityFromTag(13) == Some(Audit))
  assert(facilityFromTag(14) == Some(Alert))
  assert(facilityFromTag(15) == Some(Clock))
  assert(facilityFromTag(16) == Some(Local0))
  assert(facilityFromTag(17) == Some(Local1))
  assert(facilityFromTag(18) == Some(Local2))
  assert(facilityFromTag(19) == Some(Local3))
  assert(facilityFromTag(20) == Some(Local4))
  assert(facilityFromTag(21) == Some(Local5))
  assert(facilityFromTag(22) == Some(Local6))
  assert(facilityFromTag(23) == Some(Local7))
  assert(facilityFromTag(24) == None)
}

let test_facility_toTag = () => {
  assert(facilityToTag(Kern) == 0)
  assert(facilityToTag(User) == 1)
  assert(facilityToTag(Mail) == 2)
  assert(facilityToTag(Daemon) == 3)
  assert(facilityToTag(Auth) == 4)
  assert(facilityToTag(Syslog) == 5)
  assert(facilityToTag(Lpr) == 6)
  assert(facilityToTag(News) == 7)
  assert(facilityToTag(Uucp) == 8)
  assert(facilityToTag(Cron) == 9)
  assert(facilityToTag(AuthPriv) == 10)
  assert(facilityToTag(Ftp) == 11)
  assert(facilityToTag(Ntp) == 12)
  assert(facilityToTag(Audit) == 13)
  assert(facilityToTag(Alert) == 14)
  assert(facilityToTag(Clock) == 15)
  assert(facilityToTag(Local0) == 16)
  assert(facilityToTag(Local1) == 17)
  assert(facilityToTag(Local2) == 18)
  assert(facilityToTag(Local3) == 19)
  assert(facilityToTag(Local4) == 20)
  assert(facilityToTag(Local5) == 21)
  assert(facilityToTag(Local6) == 22)
  assert(facilityToTag(Local7) == 23)
}

let test_transport_roundtrip = () => {
  assert(transportFromTag(0) == Some(Udp514))
  assert(transportFromTag(1) == Some(Tcp514))
  assert(transportFromTag(2) == Some(Tls6514))
  assert(transportFromTag(3) == None)
}

let test_transport_toTag = () => {
  assert(transportToTag(Udp514) == 0)
  assert(transportToTag(Tcp514) == 1)
  assert(transportToTag(Tls6514) == 2)
}

// Run all tests
test_severity_roundtrip()
test_severity_toTag()
test_facility_roundtrip()
test_facility_toTag()
test_transport_roundtrip()
test_transport_toTag()
