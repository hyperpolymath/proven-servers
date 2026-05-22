// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

/// ExecutionPolicy matching the Idris2 ABI tags.
enum ExecutionPolicy {
  unrestricted(0),
  readOnly(1),
  networkDenied(2),
  isolated(3),
  ephemeral(4);

  const ExecutionPolicy(this.tag);
  final int tag;

  static ExecutionPolicy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResourceLimit matching the Idris2 ABI tags.
enum ResourceLimit {
  cpuTime(0),
  memory(1),
  diskIo(2),
  networkIo(3),
  fileDescriptors(4),
  processes(5);

  const ResourceLimit(this.tag);
  final int tag;

  static ResourceLimit? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SandboxState matching the Idris2 ABI tags.
enum SandboxState {
  creating(0),
  ready(1),
  running(2),
  suspended(3),
  terminated(4),
  destroyed(5);

  const SandboxState(this.tag);
  final int tag;

  static SandboxState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ExitReason matching the Idris2 ABI tags.
enum ExitReason {
  normal(0),
  timeout(1),
  memoryExceeded(2),
  policyViolation(3),
  killed(4),
  error(5);

  const ExitReason(this.tag);
  final int tag;

  static ExitReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SyscallPolicy matching the Idris2 ABI tags.
enum SyscallPolicy {
  allow(0),
  deny(1),
  log(2),
  trap(3);

  const SyscallPolicy(this.tag);
  final int tag;

  static SyscallPolicy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
