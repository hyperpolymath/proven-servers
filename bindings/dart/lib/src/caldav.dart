// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

/// ComponentType matching the Idris2 ABI tags.
enum ComponentType {
  vevent(0),
  vtodo(1),
  vjournal(2),
  vfreebusy(3);

  const ComponentType(this.tag);
  final int tag;

  static ComponentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CalMethod matching the Idris2 ABI tags.
enum CalMethod {
  get_(0),
  put(1),
  delete(2),
  propfind(3),
  proppatch(4),
  report(5),
  mkcalendar(6);

  const CalMethod(this.tag);
  final int tag;

  static CalMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ScheduleStatus matching the Idris2 ABI tags.
enum ScheduleStatus {
  needsAction(0),
  accepted(1),
  declined(2),
  tentative(3),
  delegated(4);

  const ScheduleStatus(this.tag);
  final int tag;

  static ScheduleStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CalError matching the Idris2 ABI tags.
enum CalError {
  validCalendarData(0),
  noResourceTypeChange(1),
  supportedComponentMismatch(2),
  maxResourceSize(3),
  uidConflict(4),
  preconditionFailed(5);

  const CalError(this.tag);
  final int tag;

  static CalError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  bound(1),
  serving(2),
  scheduling(3),
  shutdown(4);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
