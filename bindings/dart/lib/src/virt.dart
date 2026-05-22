// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

/// VmState matching the Idris2 ABI tags.
enum VmState {
  creating(0),
  running(1),
  paused(2),
  suspended(3),
  shuttingDown(4),
  stopped(5),
  crashed(6),
  migrating(7);

  const VmState(this.tag);
  final int tag;

  static VmState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// VirtOperation matching the Idris2 ABI tags.
enum VirtOperation {
  create(0),
  start(1),
  stop(2),
  restart(3),
  pause(4),
  resume(5),
  suspend(6),
  migrate(7),
  snapshot(8),
  clone(9),
  delete(10);

  const VirtOperation(this.tag);
  final int tag;

  static VirtOperation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DiskFormat matching the Idris2 ABI tags.
enum DiskFormat {
  raw(0),
  qcow2(1),
  vdi(2),
  vmdk(3),
  vhd(4);

  const DiskFormat(this.tag);
  final int tag;

  static DiskFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NetworkType matching the Idris2 ABI tags.
enum NetworkType {
  nat(0),
  bridged(1),
  internal(2),
  hostOnly(3);

  const NetworkType(this.tag);
  final int tag;

  static NetworkType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BootDevice matching the Idris2 ABI tags.
enum BootDevice {
  hardDisk(0),
  cdrom(1),
  network(2),
  usb(3);

  const BootDevice(this.tag);
  final int tag;

  static BootDevice? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
