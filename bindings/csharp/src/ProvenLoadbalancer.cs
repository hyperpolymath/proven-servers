// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

namespace Proven;

/// <summary>Algorithm matching the Idris2 ABI tags (0-5).</summary>
public enum Algorithm : byte
{
    RoundRobin = 0,
    LeastConnections = 1,
    IpHash = 2,
    Random = 3,
    WeightedRoundRobin = 4,
    LeastResponseTime = 5
}

/// <summary>HealthCheckType matching the Idris2 ABI tags (0-3).</summary>
public enum HealthCheckType : byte
{
    Http = 0,
    Tcp = 1,
    Grpc = 2,
    Script = 3
}

/// <summary>BackendState matching the Idris2 ABI tags (0-3).</summary>
public enum BackendState : byte
{
    Healthy = 0,
    Unhealthy = 1,
    Draining = 2,
    Disabled = 3
}

/// <summary>SessionPersistence matching the Idris2 ABI tags (0-3).</summary>
public enum SessionPersistence : byte
{
    None = 0,
    Cookie = 1,
    SourceIp = 2,
    Header = 3
}

/// <summary>LbProtocol matching the Idris2 ABI tags (0-4).</summary>
public enum LbProtocol : byte
{
    Http = 0,
    Https = 1,
    Tcp = 2,
    Udp = 3,
    Grpc = 4
}
