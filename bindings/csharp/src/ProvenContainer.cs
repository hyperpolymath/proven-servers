// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

namespace Proven;

/// <summary>ContainerState matching the Idris2 ABI tags (0-6).</summary>
public enum ContainerState : byte
{
    Creating = 0,
    Running = 1,
    Paused = 2,
    Restarting = 3,
    Stopped = 4,
    Removing = 5,
    Dead = 6
}

/// <summary>ContainerOperation matching the Idris2 ABI tags (0-10).</summary>
public enum ContainerOperation : byte
{
    Create = 0,
    Start = 1,
    Stop = 2,
    Restart = 3,
    Pause = 4,
    Unpause = 5,
    Kill = 6,
    Remove = 7,
    Exec = 8,
    Logs = 9,
    Inspect = 10
}

/// <summary>NetworkMode matching the Idris2 ABI tags (0-4).</summary>
public enum NetworkMode : byte
{
    Bridge = 0,
    Host = 1,
    None = 2,
    Overlay = 3,
    Macvlan = 4
}

/// <summary>VolumeType matching the Idris2 ABI tags (0-2).</summary>
public enum VolumeType : byte
{
    Bind = 0,
    Named = 1,
    Tmpfs = 2
}

/// <summary>RestartPolicy matching the Idris2 ABI tags (0-3).</summary>
public enum RestartPolicy : byte
{
    No = 0,
    Always = 1,
    OnFailure = 2,
    UnlessStopped = 3
}

/// <summary>HealthStatus matching the Idris2 ABI tags (0-3).</summary>
public enum HealthStatus : byte
{
    Starting = 0,
    Healthy = 1,
    Unhealthy = 2,
    NoCheck = 3
}
