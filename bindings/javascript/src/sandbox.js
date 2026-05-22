// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

/** ExecutionPolicy matching the Idris2 ABI tags. */
export const ExecutionPolicy = Object.freeze({
  UNRESTRICTED: 0,
  READ_ONLY: 1,
  NETWORK_DENIED: 2,
  ISOLATED: 3,
  EPHEMERAL: 4,
});

/** ResourceLimit matching the Idris2 ABI tags. */
export const ResourceLimit = Object.freeze({
  CPU_TIME: 0,
  MEMORY: 1,
  DISK_IO: 2,
  NETWORK_IO: 3,
  FILE_DESCRIPTORS: 4,
  PROCESSES: 5,
});

/** SandboxState matching the Idris2 ABI tags. */
export const SandboxState = Object.freeze({
  CREATING: 0,
  READY: 1,
  RUNNING: 2,
  SUSPENDED: 3,
  TERMINATED: 4,
  DESTROYED: 5,
});

/** ExitReason matching the Idris2 ABI tags. */
export const ExitReason = Object.freeze({
  NORMAL: 0,
  TIMEOUT: 1,
  MEMORY_EXCEEDED: 2,
  POLICY_VIOLATION: 3,
  KILLED: 4,
  ERROR: 5,
});

/** SyscallPolicy matching the Idris2 ABI tags. */
export const SyscallPolicy = Object.freeze({
  ALLOW: 0,
  DENY: 1,
  LOG: 2,
  TRAP: 3,
});
