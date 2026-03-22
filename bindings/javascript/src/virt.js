// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Virtualization protocol types for proven-servers.

/** VmState matching the Idris2 ABI tags. */
export const VmState = Object.freeze({
  CREATING: 0,
  RUNNING: 1,
  PAUSED: 2,
  SUSPENDED: 3,
  SHUTTING_DOWN: 4,
  STOPPED: 5,
  CRASHED: 6,
  MIGRATING: 7,
});

/** VirtOperation matching the Idris2 ABI tags. */
export const VirtOperation = Object.freeze({
  CREATE: 0,
  START: 1,
  STOP: 2,
  RESTART: 3,
  PAUSE: 4,
  RESUME: 5,
  SUSPEND: 6,
  MIGRATE: 7,
  SNAPSHOT: 8,
  CLONE: 9,
  DELETE: 10,
});

/** DiskFormat matching the Idris2 ABI tags. */
export const DiskFormat = Object.freeze({
  RAW: 0,
  QCOW2: 1,
  VDI: 2,
  VMDK: 3,
  VHD: 4,
});

/** NetworkType matching the Idris2 ABI tags. */
export const NetworkType = Object.freeze({
  NAT: 0,
  BRIDGED: 1,
  INTERNAL: 2,
  HOST_ONLY: 3,
});

/** BootDevice matching the Idris2 ABI tags. */
export const BootDevice = Object.freeze({
  HARD_DISK: 0,
  CDROM: 1,
  NETWORK: 2,
  USB: 3,
});
