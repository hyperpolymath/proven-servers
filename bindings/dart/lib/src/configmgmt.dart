// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

/// ResourceType matching the Idris2 ABI tags.
enum ResourceType {
  file(0),
  package(1),
  service(2),
  user(3),
  group(4),
  cron(5),
  mount(6),
  firewall(7),
  registry(8);

  const ResourceType(this.tag);
  final int tag;

  static ResourceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResourceState matching the Idris2 ABI tags.
enum ResourceState {
  present(0),
  absent(1),
  running(2),
  stopped(3),
  enabled(4),
  disabled(5);

  const ResourceState(this.tag);
  final int tag;

  static ResourceState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ChangeAction matching the Idris2 ABI tags.
enum ChangeAction {
  create(0),
  modify(1),
  delete(2),
  restart(3),
  reload(4),
  skip(5);

  const ChangeAction(this.tag);
  final int tag;

  static ChangeAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DriftStatus matching the Idris2 ABI tags.
enum DriftStatus {
  inSync(0),
  drifted(1),
  dUnknown(2),
  unmanaged(3);

  const DriftStatus(this.tag);
  final int tag;

  static DriftStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ApplyMode matching the Idris2 ABI tags.
enum ApplyMode {
  enforce(0),
  dryRun(1),
  audit(2);

  const ApplyMode(this.tag);
  final int tag;

  static ApplyMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
