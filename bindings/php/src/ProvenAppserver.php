<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** RequestType matching the Idris2 ABI tags. */
enum RequestType: int
{
    case Http = 0;
    case WebSocket = 1;
    case Grpc = 2;
    case GraphQl = 3;
}

/** LifecycleState matching the Idris2 ABI tags. */
enum LifecycleState: int
{
    case Initializing = 0;
    case Starting = 1;
    case Running = 2;
    case Draining = 3;
    case Stopping = 4;
    case Stopped = 5;
}

/** HealthCheck matching the Idris2 ABI tags. */
enum HealthCheck: int
{
    case Liveness = 0;
    case Readiness = 1;
    case Startup = 2;
}

/** DeployStrategy matching the Idris2 ABI tags. */
enum DeployStrategy: int
{
    case RollingUpdate = 0;
    case BlueGreen = 1;
    case Canary = 2;
    case Recreate = 3;
}

/** ErrorCategory matching the Idris2 ABI tags. */
enum ErrorCategory: int
{
    case ClientError = 0;
    case ServerError = 1;
    case Timeout = 2;
    case CircuitOpen = 3;
    case RateLimited = 4;
}
