//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Container Runtime protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ContainerABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ContainerState
// ===========================================================================

/// Container lifecycle states.
/// 
/// Matches `ContainerState` in `ContainerABI.Types`.
pub type ContainerState {
  /// Creating (tag 0).
  Creating
  /// Running (tag 1).
  Running
  /// Paused (tag 2).
  Paused
  /// Restarting (tag 3).
  Restarting
  /// Stopped (tag 4).
  Stopped
  /// Removing (tag 5).
  Removing
  /// Dead (tag 6).
  Dead
}

/// Convert a `ContainerState` to its C-ABI tag value.
pub fn container_state_to_int(value: ContainerState) -> Int {
  case value {
    Creating -> 0
    Running -> 1
    Paused -> 2
    Restarting -> 3
    Stopped -> 4
    Removing -> 5
    Dead -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn container_state_from_int(tag: Int) -> Result(ContainerState, Nil) {
  case tag {
    0 -> Ok(Creating)
    1 -> Ok(Running)
    2 -> Ok(Paused)
    3 -> Ok(Restarting)
    4 -> Ok(Stopped)
    5 -> Ok(Removing)
    6 -> Ok(Dead)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ContainerOperation
// ===========================================================================

/// Container operations.
/// 
/// Matches `ContainerOperation` in `ContainerABI.Types`.
pub type ContainerOperation {
  /// Create (tag 0).
  Create
  /// Start (tag 1).
  Start
  /// Stop (tag 2).
  Stop
  /// Restart (tag 3).
  Restart
  /// Pause (tag 4).
  Pause
  /// Unpause (tag 5).
  Unpause
  /// Kill (tag 6).
  Kill
  /// Remove (tag 7).
  Remove
  /// Exec (tag 8).
  Exec
  /// Logs (tag 9).
  Logs
  /// Inspect (tag 10).
  Inspect
}

/// Convert a `ContainerOperation` to its C-ABI tag value.
pub fn container_operation_to_int(value: ContainerOperation) -> Int {
  case value {
    Create -> 0
    Start -> 1
    Stop -> 2
    Restart -> 3
    Pause -> 4
    Unpause -> 5
    Kill -> 6
    Remove -> 7
    Exec -> 8
    Logs -> 9
    Inspect -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn container_operation_from_int(tag: Int) -> Result(ContainerOperation, Nil) {
  case tag {
    0 -> Ok(Create)
    1 -> Ok(Start)
    2 -> Ok(Stop)
    3 -> Ok(Restart)
    4 -> Ok(Pause)
    5 -> Ok(Unpause)
    6 -> Ok(Kill)
    7 -> Ok(Remove)
    8 -> Ok(Exec)
    9 -> Ok(Logs)
    10 -> Ok(Inspect)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NetworkMode
// ===========================================================================

/// Container network modes.
/// 
/// Matches `NetworkMode` in `ContainerABI.Types`.
pub type NetworkMode {
  /// Bridge (tag 0).
  Bridge
  /// Host (tag 1).
  Host
  /// None (tag 2).
  NetworkModeNone
  /// Overlay (tag 3).
  Overlay
  /// Macvlan (tag 4).
  Macvlan
}

/// Convert a `NetworkMode` to its C-ABI tag value.
pub fn network_mode_to_int(value: NetworkMode) -> Int {
  case value {
    Bridge -> 0
    Host -> 1
    NetworkModeNone -> 2
    Overlay -> 3
    Macvlan -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn network_mode_from_int(tag: Int) -> Result(NetworkMode, Nil) {
  case tag {
    0 -> Ok(Bridge)
    1 -> Ok(Host)
    2 -> Ok(NetworkModeNone)
    3 -> Ok(Overlay)
    4 -> Ok(Macvlan)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// VolumeType
// ===========================================================================

/// Container volume types.
/// 
/// Matches `VolumeType` in `ContainerABI.Types`.
pub type VolumeType {
  /// Bind (tag 0).
  Bind
  /// Named (tag 1).
  Named
  /// Tmpfs (tag 2).
  Tmpfs
}

/// Convert a `VolumeType` to its C-ABI tag value.
pub fn volume_type_to_int(value: VolumeType) -> Int {
  case value {
    Bind -> 0
    Named -> 1
    Tmpfs -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn volume_type_from_int(tag: Int) -> Result(VolumeType, Nil) {
  case tag {
    0 -> Ok(Bind)
    1 -> Ok(Named)
    2 -> Ok(Tmpfs)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RestartPolicy
// ===========================================================================

/// Container restart policies.
/// 
/// Matches `RestartPolicy` in `ContainerABI.Types`.
pub type RestartPolicy {
  /// No (tag 0).
  No
  /// Always (tag 1).
  Always
  /// OnFailure (tag 2).
  OnFailure
  /// UnlessStopped (tag 3).
  UnlessStopped
}

/// Convert a `RestartPolicy` to its C-ABI tag value.
pub fn restart_policy_to_int(value: RestartPolicy) -> Int {
  case value {
    No -> 0
    Always -> 1
    OnFailure -> 2
    UnlessStopped -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn restart_policy_from_int(tag: Int) -> Result(RestartPolicy, Nil) {
  case tag {
    0 -> Ok(No)
    1 -> Ok(Always)
    2 -> Ok(OnFailure)
    3 -> Ok(UnlessStopped)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HealthStatus
// ===========================================================================

/// Container health check status.
/// 
/// Matches `HealthStatus` in `ContainerABI.Types`.
pub type HealthStatus {
  /// Starting (tag 0).
  Starting
  /// Healthy (tag 1).
  Healthy
  /// Unhealthy (tag 2).
  Unhealthy
  /// NoCheck (tag 3).
  NoCheck
}

/// Convert a `HealthStatus` to its C-ABI tag value.
pub fn health_status_to_int(value: HealthStatus) -> Int {
  case value {
    Starting -> 0
    Healthy -> 1
    Unhealthy -> 2
    NoCheck -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn health_status_from_int(tag: Int) -> Result(HealthStatus, Nil) {
  case tag {
    0 -> Ok(Starting)
    1 -> Ok(Healthy)
    2 -> Ok(Unhealthy)
    3 -> Ok(NoCheck)
    _ -> Error(Nil)
  }
}

