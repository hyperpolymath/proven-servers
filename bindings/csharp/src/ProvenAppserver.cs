// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

namespace Proven;

/// <summary>RequestType matching the Idris2 ABI tags (0-3).</summary>
public enum RequestType : byte
{
    Http = 0,
    WebSocket = 1,
    Grpc = 2,
    GraphQl = 3
}

/// <summary>LifecycleState matching the Idris2 ABI tags (0-5).</summary>
public enum LifecycleState : byte
{
    Initializing = 0,
    Starting = 1,
    Running = 2,
    Draining = 3,
    Stopping = 4,
    Stopped = 5
}

/// <summary>HealthCheck matching the Idris2 ABI tags (0-2).</summary>
public enum HealthCheck : byte
{
    Liveness = 0,
    Readiness = 1,
    Startup = 2
}

/// <summary>DeployStrategy matching the Idris2 ABI tags (0-3).</summary>
public enum DeployStrategy : byte
{
    RollingUpdate = 0,
    BlueGreen = 1,
    Canary = 2,
    Recreate = 3
}

/// <summary>ErrorCategory matching the Idris2 ABI tags (0-4).</summary>
public enum ErrorCategory : byte
{
    ClientError = 0,
    ServerError = 1,
    Timeout = 2,
    CircuitOpen = 3,
    RateLimited = 4
}
