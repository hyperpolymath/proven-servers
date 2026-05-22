-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SandboxABI.Types: C-ABI-compatible numeric representations of sandbox types.
--
-- Maps every constructor of the core sandbox sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/sandbox.zig) exactly.
--
-- Types covered:
--   ExecutionPolicy  (5 constructors, tags 0-4)
--   ResourceLimit    (6 constructors, tags 0-5)
--   SandboxState     (6 constructors, tags 0-5)
--   ExitReason       (6 constructors, tags 0-5)
--   SyscallPolicy    (4 constructors, tags 0-3)

module SandboxABI.Types

import Sandbox.Types

%default total

---------------------------------------------------------------------------
-- ExecutionPolicy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
executionPolicySize : Nat
executionPolicySize = 1

||| Encode an ExecutionPolicy to its ABI tag value.
public export
executionPolicyToTag : ExecutionPolicy -> Bits8
executionPolicyToTag Unrestricted  = 0
executionPolicyToTag ReadOnly      = 1
executionPolicyToTag NetworkDenied = 2
executionPolicyToTag Isolated      = 3
executionPolicyToTag Ephemeral     = 4

||| Decode an ABI tag value to an ExecutionPolicy.
public export
tagToExecutionPolicy : Bits8 -> Maybe ExecutionPolicy
tagToExecutionPolicy 0 = Just Unrestricted
tagToExecutionPolicy 1 = Just ReadOnly
tagToExecutionPolicy 2 = Just NetworkDenied
tagToExecutionPolicy 3 = Just Isolated
tagToExecutionPolicy 4 = Just Ephemeral
tagToExecutionPolicy _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
executionPolicyRoundtrip : (p : ExecutionPolicy) -> tagToExecutionPolicy (executionPolicyToTag p) = Just p
executionPolicyRoundtrip Unrestricted  = Refl
executionPolicyRoundtrip ReadOnly      = Refl
executionPolicyRoundtrip NetworkDenied = Refl
executionPolicyRoundtrip Isolated      = Refl
executionPolicyRoundtrip Ephemeral     = Refl

---------------------------------------------------------------------------
-- ResourceLimit (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
resourceLimitSize : Nat
resourceLimitSize = 1

||| Encode a ResourceLimit to its ABI tag value.
public export
resourceLimitToTag : ResourceLimit -> Bits8
resourceLimitToTag CPUTime         = 0
resourceLimitToTag Memory          = 1
resourceLimitToTag DiskIO          = 2
resourceLimitToTag NetworkIO       = 3
resourceLimitToTag FileDescriptors = 4
resourceLimitToTag Processes       = 5

||| Decode an ABI tag value to a ResourceLimit.
public export
tagToResourceLimit : Bits8 -> Maybe ResourceLimit
tagToResourceLimit 0 = Just CPUTime
tagToResourceLimit 1 = Just Memory
tagToResourceLimit 2 = Just DiskIO
tagToResourceLimit 3 = Just NetworkIO
tagToResourceLimit 4 = Just FileDescriptors
tagToResourceLimit 5 = Just Processes
tagToResourceLimit _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
resourceLimitRoundtrip : (r : ResourceLimit) -> tagToResourceLimit (resourceLimitToTag r) = Just r
resourceLimitRoundtrip CPUTime         = Refl
resourceLimitRoundtrip Memory          = Refl
resourceLimitRoundtrip DiskIO          = Refl
resourceLimitRoundtrip NetworkIO       = Refl
resourceLimitRoundtrip FileDescriptors = Refl
resourceLimitRoundtrip Processes       = Refl

---------------------------------------------------------------------------
-- SandboxState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
sandboxStateSize : Nat
sandboxStateSize = 1

||| Encode a SandboxState to its ABI tag value.
public export
sandboxStateToTag : SandboxState -> Bits8
sandboxStateToTag Creating   = 0
sandboxStateToTag Ready      = 1
sandboxStateToTag Running    = 2
sandboxStateToTag Suspended  = 3
sandboxStateToTag Terminated = 4
sandboxStateToTag Destroyed  = 5

||| Decode an ABI tag value to a SandboxState.
public export
tagToSandboxState : Bits8 -> Maybe SandboxState
tagToSandboxState 0 = Just Creating
tagToSandboxState 1 = Just Ready
tagToSandboxState 2 = Just Running
tagToSandboxState 3 = Just Suspended
tagToSandboxState 4 = Just Terminated
tagToSandboxState 5 = Just Destroyed
tagToSandboxState _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
sandboxStateRoundtrip : (s : SandboxState) -> tagToSandboxState (sandboxStateToTag s) = Just s
sandboxStateRoundtrip Creating   = Refl
sandboxStateRoundtrip Ready      = Refl
sandboxStateRoundtrip Running    = Refl
sandboxStateRoundtrip Suspended  = Refl
sandboxStateRoundtrip Terminated = Refl
sandboxStateRoundtrip Destroyed  = Refl

---------------------------------------------------------------------------
-- ExitReason (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
exitReasonSize : Nat
exitReasonSize = 1

||| Encode an ExitReason to its ABI tag value.
public export
exitReasonToTag : ExitReason -> Bits8
exitReasonToTag Normal          = 0
exitReasonToTag Timeout         = 1
exitReasonToTag MemoryExceeded  = 2
exitReasonToTag PolicyViolation = 3
exitReasonToTag Killed          = 4
exitReasonToTag Error           = 5

||| Decode an ABI tag value to an ExitReason.
public export
tagToExitReason : Bits8 -> Maybe ExitReason
tagToExitReason 0 = Just Normal
tagToExitReason 1 = Just Timeout
tagToExitReason 2 = Just MemoryExceeded
tagToExitReason 3 = Just PolicyViolation
tagToExitReason 4 = Just Killed
tagToExitReason 5 = Just Error
tagToExitReason _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
exitReasonRoundtrip : (e : ExitReason) -> tagToExitReason (exitReasonToTag e) = Just e
exitReasonRoundtrip Normal          = Refl
exitReasonRoundtrip Timeout         = Refl
exitReasonRoundtrip MemoryExceeded  = Refl
exitReasonRoundtrip PolicyViolation = Refl
exitReasonRoundtrip Killed          = Refl
exitReasonRoundtrip Error           = Refl

---------------------------------------------------------------------------
-- SyscallPolicy (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
syscallPolicySize : Nat
syscallPolicySize = 1

||| Encode a SyscallPolicy to its ABI tag value.
public export
syscallPolicyToTag : SyscallPolicy -> Bits8
syscallPolicyToTag Allow = 0
syscallPolicyToTag Deny  = 1
syscallPolicyToTag Log   = 2
syscallPolicyToTag Trap  = 3

||| Decode an ABI tag value to a SyscallPolicy.
public export
tagToSyscallPolicy : Bits8 -> Maybe SyscallPolicy
tagToSyscallPolicy 0 = Just Allow
tagToSyscallPolicy 1 = Just Deny
tagToSyscallPolicy 2 = Just Log
tagToSyscallPolicy 3 = Just Trap
tagToSyscallPolicy _ = Nothing

||| Roundtrip proof: encoding then decoding yields the original value.
public export
syscallPolicyRoundtrip : (s : SyscallPolicy) -> tagToSyscallPolicy (syscallPolicyToTag s) = Just s
syscallPolicyRoundtrip Allow = Refl
syscallPolicyRoundtrip Deny  = Refl
syscallPolicyRoundtrip Log   = Refl
syscallPolicyRoundtrip Trap  = Refl
