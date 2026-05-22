<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ContainerState matching the Idris2 ABI tags. */
enum ContainerState: int
{
    case Creating = 0;
    case Running = 1;
    case Paused = 2;
    case Restarting = 3;
    case Stopped = 4;
    case Removing = 5;
    case Dead = 6;
}

/** ContainerOperation matching the Idris2 ABI tags. */
enum ContainerOperation: int
{
    case Create = 0;
    case Start = 1;
    case Stop = 2;
    case Restart = 3;
    case Pause = 4;
    case Unpause = 5;
    case Kill = 6;
    case Remove = 7;
    case Exec = 8;
    case Logs = 9;
    case Inspect = 10;
}

/** NetworkMode matching the Idris2 ABI tags. */
enum NetworkMode: int
{
    case Bridge = 0;
    case Host = 1;
    case None = 2;
    case Overlay = 3;
    case Macvlan = 4;
}

/** VolumeType matching the Idris2 ABI tags. */
enum VolumeType: int
{
    case Bind = 0;
    case Named = 1;
    case Tmpfs = 2;
}

/** RestartPolicy matching the Idris2 ABI tags. */
enum RestartPolicy: int
{
    case No = 0;
    case Always = 1;
    case OnFailure = 2;
    case UnlessStopped = 3;
}

/** HealthStatus matching the Idris2 ABI tags. */
enum HealthStatus: int
{
    case Starting = 0;
    case Healthy = 1;
    case Unhealthy = 2;
    case NoCheck = 3;
}
