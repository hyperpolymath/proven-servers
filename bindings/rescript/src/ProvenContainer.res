// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container Runtime types for the proven-servers ABI.
//
// Mirrors the Idris2 module ContainerABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ContainerState (tags 0-6)
// ===========================================================================

/// Container lifecycle states.
type containerState =
  | @as(0) Creating
  | @as(1) Running
  | @as(2) Paused
  | @as(3) Restarting
  | @as(4) Stopped
  | @as(5) Removing
  | @as(6) Dead

/// Decode from the C-ABI tag value.
let containerStateFromTag = (tag: int): option<containerState> =>
  switch tag {
  | 0 => Some(Creating)
  | 1 => Some(Running)
  | 2 => Some(Paused)
  | 3 => Some(Restarting)
  | 4 => Some(Stopped)
  | 5 => Some(Removing)
  | 6 => Some(Dead)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let containerStateToTag = (v: containerState): int =>
  switch v {
  | Creating => 0
  | Running => 1
  | Paused => 2
  | Restarting => 3
  | Stopped => 4
  | Removing => 5
  | Dead => 6
  }

// ===========================================================================
// ContainerOperation (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type containerOperation =
  | @as(0) Create
  | @as(1) Start
  | @as(2) Stop
  | @as(3) Restart
  | @as(4) Pause
  | @as(5) Unpause
  | @as(6) Kill
  | @as(7) Remove
  | @as(8) Exec
  | @as(9) Logs
  | @as(10) Inspect

/// Decode from the C-ABI tag value.
let containerOperationFromTag = (tag: int): option<containerOperation> =>
  switch tag {
  | 0 => Some(Create)
  | 1 => Some(Start)
  | 2 => Some(Stop)
  | 3 => Some(Restart)
  | 4 => Some(Pause)
  | 5 => Some(Unpause)
  | 6 => Some(Kill)
  | 7 => Some(Remove)
  | 8 => Some(Exec)
  | 9 => Some(Logs)
  | 10 => Some(Inspect)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let containerOperationToTag = (v: containerOperation): int =>
  switch v {
  | Create => 0
  | Start => 1
  | Stop => 2
  | Restart => 3
  | Pause => 4
  | Unpause => 5
  | Kill => 6
  | Remove => 7
  | Exec => 8
  | Logs => 9
  | Inspect => 10
  }

// ===========================================================================
// NetworkMode (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type networkMode =
  | @as(0) Bridge
  | @as(1) Host
  | @as(2) None
  | @as(3) Overlay
  | @as(4) Macvlan

/// Decode from the C-ABI tag value.
let networkModeFromTag = (tag: int): option<networkMode> =>
  switch tag {
  | 0 => Some(Bridge)
  | 1 => Some(Host)
  | 2 => Some(None)
  | 3 => Some(Overlay)
  | 4 => Some(Macvlan)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let networkModeToTag = (v: networkMode): int =>
  switch v {
  | Bridge => 0
  | Host => 1
  | None => 2
  | Overlay => 3
  | Macvlan => 4
  }

// ===========================================================================
// VolumeType (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type volumeType =
  | @as(0) Bind
  | @as(1) Named
  | @as(2) Tmpfs

/// Decode from the C-ABI tag value.
let volumeTypeFromTag = (tag: int): option<volumeType> =>
  switch tag {
  | 0 => Some(Bind)
  | 1 => Some(Named)
  | 2 => Some(Tmpfs)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let volumeTypeToTag = (v: volumeType): int =>
  switch v {
  | Bind => 0
  | Named => 1
  | Tmpfs => 2
  }

// ===========================================================================
// RestartPolicy (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type restartPolicy =
  | @as(0) No
  | @as(1) Always
  | @as(2) OnFailure
  | @as(3) UnlessStopped

/// Decode from the C-ABI tag value.
let restartPolicyFromTag = (tag: int): option<restartPolicy> =>
  switch tag {
  | 0 => Some(No)
  | 1 => Some(Always)
  | 2 => Some(OnFailure)
  | 3 => Some(UnlessStopped)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let restartPolicyToTag = (v: restartPolicy): int =>
  switch v {
  | No => 0
  | Always => 1
  | OnFailure => 2
  | UnlessStopped => 3
  }

// ===========================================================================
// HealthStatus (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type healthStatus =
  | @as(0) Starting
  | @as(1) Healthy
  | @as(2) Unhealthy
  | @as(3) NoCheck

/// Decode from the C-ABI tag value.
let healthStatusFromTag = (tag: int): option<healthStatus> =>
  switch tag {
  | 0 => Some(Starting)
  | 1 => Some(Healthy)
  | 2 => Some(Unhealthy)
  | 3 => Some(NoCheck)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let healthStatusToTag = (v: healthStatus): int =>
  switch v {
  | Starting => 0
  | Healthy => 1
  | Unhealthy => 2
  | NoCheck => 3
  }

