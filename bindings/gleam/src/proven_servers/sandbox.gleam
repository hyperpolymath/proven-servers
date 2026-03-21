//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Sandbox protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SandboxABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ExecutionPolicy
// ===========================================================================

/// Sandbox execution policies.
/// 
/// Matches `ExecutionPolicy` in `SandboxABI.Types`.
pub type ExecutionPolicy {
  /// Unrestricted (tag 0).
  Unrestricted
  /// ReadOnly (tag 1).
  ReadOnly
  /// NetworkDenied (tag 2).
  NetworkDenied
  /// Isolated (tag 3).
  Isolated
  /// Ephemeral (tag 4).
  Ephemeral
}

/// Convert a `ExecutionPolicy` to its C-ABI tag value.
pub fn execution_policy_to_int(value: ExecutionPolicy) -> Int {
  case value {
    Unrestricted -> 0
    ReadOnly -> 1
    NetworkDenied -> 2
    Isolated -> 3
    Ephemeral -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn execution_policy_from_int(tag: Int) -> Result(ExecutionPolicy, Nil) {
  case tag {
    0 -> Ok(Unrestricted)
    1 -> Ok(ReadOnly)
    2 -> Ok(NetworkDenied)
    3 -> Ok(Isolated)
    4 -> Ok(Ephemeral)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResourceLimit
// ===========================================================================

/// Sandbox resource limits.
/// 
/// Matches `ResourceLimit` in `SandboxABI.Types`.
pub type ResourceLimit {
  /// CPU time (tag 0).
  CpuTime
  /// Memory (tag 1).
  Memory
  /// Disk I/O (tag 2).
  DiskIo
  /// Network I/O (tag 3).
  NetworkIo
  /// FileDescriptors (tag 4).
  FileDescriptors
  /// Processes (tag 5).
  Processes
}

/// Convert a `ResourceLimit` to its C-ABI tag value.
pub fn resource_limit_to_int(value: ResourceLimit) -> Int {
  case value {
    CpuTime -> 0
    Memory -> 1
    DiskIo -> 2
    NetworkIo -> 3
    FileDescriptors -> 4
    Processes -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn resource_limit_from_int(tag: Int) -> Result(ResourceLimit, Nil) {
  case tag {
    0 -> Ok(CpuTime)
    1 -> Ok(Memory)
    2 -> Ok(DiskIo)
    3 -> Ok(NetworkIo)
    4 -> Ok(FileDescriptors)
    5 -> Ok(Processes)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SandboxState
// ===========================================================================

/// Sandbox lifecycle states.
/// 
/// Matches `SandboxState` in `SandboxABI.Types`.
pub type SandboxState {
  /// Creating (tag 0).
  Creating
  /// Ready (tag 1).
  Ready
  /// Running (tag 2).
  Running
  /// Suspended (tag 3).
  Suspended
  /// Terminated (tag 4).
  Terminated
  /// Destroyed (tag 5).
  Destroyed
}

/// Convert a `SandboxState` to its C-ABI tag value.
pub fn sandbox_state_to_int(value: SandboxState) -> Int {
  case value {
    Creating -> 0
    Ready -> 1
    Running -> 2
    Suspended -> 3
    Terminated -> 4
    Destroyed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn sandbox_state_from_int(tag: Int) -> Result(SandboxState, Nil) {
  case tag {
    0 -> Ok(Creating)
    1 -> Ok(Ready)
    2 -> Ok(Running)
    3 -> Ok(Suspended)
    4 -> Ok(Terminated)
    5 -> Ok(Destroyed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ExitReason
// ===========================================================================

/// Sandbox exit reasons.
/// 
/// Matches `ExitReason` in `SandboxABI.Types`.
pub type ExitReason {
  /// Normal (tag 0).
  Normal
  /// Timeout (tag 1).
  Timeout
  /// MemoryExceeded (tag 2).
  MemoryExceeded
  /// PolicyViolation (tag 3).
  PolicyViolation
  /// Killed (tag 4).
  Killed
  /// Error (tag 5).
  ExitReasonError
}

/// Convert a `ExitReason` to its C-ABI tag value.
pub fn exit_reason_to_int(value: ExitReason) -> Int {
  case value {
    Normal -> 0
    Timeout -> 1
    MemoryExceeded -> 2
    PolicyViolation -> 3
    Killed -> 4
    ExitReasonError -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn exit_reason_from_int(tag: Int) -> Result(ExitReason, Nil) {
  case tag {
    0 -> Ok(Normal)
    1 -> Ok(Timeout)
    2 -> Ok(MemoryExceeded)
    3 -> Ok(PolicyViolation)
    4 -> Ok(Killed)
    5 -> Ok(ExitReasonError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SyscallPolicy
// ===========================================================================

/// System call filter policies.
/// 
/// Matches `SyscallPolicy` in `SandboxABI.Types`.
pub type SyscallPolicy {
  /// Allow (tag 0).
  Allow
  /// Deny (tag 1).
  Deny
  /// Log (tag 2).
  Log
  /// Trap (tag 3).
  Trap
}

/// Convert a `SyscallPolicy` to its C-ABI tag value.
pub fn syscall_policy_to_int(value: SyscallPolicy) -> Int {
  case value {
    Allow -> 0
    Deny -> 1
    Log -> 2
    Trap -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn syscall_policy_from_int(tag: Int) -> Result(SyscallPolicy, Nil) {
  case tag {
    0 -> Ok(Allow)
    1 -> Ok(Deny)
    2 -> Ok(Log)
    3 -> Ok(Trap)
    _ -> Error(Nil)
  }
}

