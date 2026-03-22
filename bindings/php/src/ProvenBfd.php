<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** BfdState matching the Idris2 ABI tags. */
enum BfdState: int
{
    case AdminDown = 0;
    case Down = 1;
    case Init = 2;
    case Up = 3;
}

/** Diagnostic matching the Idris2 ABI tags. */
enum Diagnostic: int
{
    case NoDiagnostic = 0;
    case ControlDetectionTimeExpired = 1;
    case EchoFunctionFailed = 2;
    case NeighborSignaledSessionDown = 3;
    case ForwardingPlaneReset = 4;
    case PathDown = 5;
    case ConcatenatedPathDown = 6;
    case AdministrativelyDown = 7;
    case ReverseConcatenatedPathDown = 8;
}

/** SessionMode matching the Idris2 ABI tags. */
enum SessionMode: int
{
    case AsyncMode = 0;
    case DemandMode = 1;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case SsDown = 1;
    case Negotiating = 2;
    case Established = 3;
    case Teardown = 4;
}
