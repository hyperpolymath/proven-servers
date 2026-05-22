<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Algorithm matching the Idris2 ABI tags. */
enum Algorithm: int
{
    case RoundRobin = 0;
    case LeastConnections = 1;
    case IpHash = 2;
    case Random = 3;
    case WeightedRoundRobin = 4;
    case LeastResponseTime = 5;
}

/** HealthCheckType matching the Idris2 ABI tags. */
enum HealthCheckType: int
{
    case HealthCheckType_Http = 0;
    case HealthCheckType_Tcp = 1;
    case HealthCheckType_Grpc = 2;
    case Script = 3;
}

/** BackendState matching the Idris2 ABI tags. */
enum BackendState: int
{
    case Healthy = 0;
    case Unhealthy = 1;
    case Draining = 2;
    case Disabled = 3;
}

/** SessionPersistence matching the Idris2 ABI tags. */
enum SessionPersistence: int
{
    case None = 0;
    case Cookie = 1;
    case SourceIp = 2;
    case Header = 3;
}

/** LbProtocol matching the Idris2 ABI tags. */
enum LbProtocol: int
{
    case LbProtocol_Http = 0;
    case Https = 1;
    case LbProtocol_Tcp = 2;
    case Udp = 3;
    case LbProtocol_Grpc = 4;
}
